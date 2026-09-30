const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Cloud Function Gen 2:
 * Triggers when a new document is created in the `notifications` collection.
 * 
 * Expected Document Schema in `notifications/{notificationId}`:
 * - title: string (required) - Notification title
 * - body: string (required) - Notification body text
 * - fcmToken: string (optional) - Target device FCM token. If omitted, will be fetched from users/{userId}.fcmToken
 * - userId: string (optional) - Target user's Firestore ID
 * - data: object (optional) - Custom key-value pairs (must be string values for FCM)
 * - sound: string (optional) - Notification sound (default 'default')
 * - channelId: string (optional) - Android notification channel (default 'high_importance_channel')
 */
exports.sendNotificationOnCreate = onDocumentCreated(
  "notifications/{notificationId}",
  async (event) => {
    const snap = event.data;
    if (!snap) {
      logger.warn("No snapshot data found for event", event.id);
      return null;
    }

    const docRef = snap.ref;
    const notificationData = snap.data();

    // Prevent re-processing if already handled
    if (notificationData.status === "sent" || notificationData.status === "failed") {
      logger.info(`Notification ${event.params.notificationId} already processed with status: ${notificationData.status}`);
      return null;
    }

    const title = notificationData.title || "RideLink";
    const body = notificationData.body || "";
    let fcmToken = notificationData.fcmToken;
    const userId = notificationData.userId;

    // If fcmToken is not provided on the notification document, try to look it up from the user's document
    if (!fcmToken && userId) {
      try {
        const userDoc = await db.collection("users").doc(userId).get();
        if (userDoc.exists) {
          fcmToken = userDoc.data()?.fcmToken;
        }
      } catch (err) {
        logger.error(`Failed to fetch user document for userId: ${userId}`, err);
      }
    }

    if (!fcmToken) {
      const errorMsg = "No FCM token available to send notification (neither fcmToken nor active user fcmToken found).";
      logger.error(errorMsg, { notificationId: event.params.notificationId, userId });
      await docRef.update({
        status: "failed",
        error: errorMsg,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return null;
    }

    // Convert custom data payload values to string (FCM requires string-only data map)
    const rawData = notificationData.data || {};
    const sanitizedData = {};
    for (const [key, value] of Object.entries(rawData)) {
      if (value !== null && value !== undefined) {
        sanitizedData[key] = typeof value === "object" ? JSON.stringify(value) : String(value);
      }
    }

    // Add standard notification metadata into data payload for app consumption
    sanitizedData.notificationId = event.params.notificationId;
    if (userId) sanitizedData.userId = String(userId);

    const message = {
      token: fcmToken,
      notification: {
        title: title,
        body: body,
      },
      data: sanitizedData,
      android: {
        priority: "high",
        notification: {
          channelId: notificationData.channelId || "high_importance_channel",
          sound: notificationData.sound || "default",
          priority: "high",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: notificationData.sound || "default",
            badge: 1,
          },
        },
      },
    };

    try {
      logger.info(`Sending FCM message for notification ${event.params.notificationId} to token: ${fcmToken.substring(0, 15)}...`);
      const response = await admin.messaging().send(message);
      logger.info(`Successfully sent FCM notification. Message ID: ${response}`);

      await docRef.update({
        status: "sent",
        messageId: response,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return response;
    } catch (error) {
      logger.error(`Error sending FCM notification for ${event.params.notificationId}:`, error);

      // Clean up invalid or expired token from user's document if applicable
      const isUnregistered =
        error.code === "messaging/registration-token-not-registered" ||
        error.code === "messaging/invalid-registration-token";

      if (isUnregistered && userId) {
        try {
          logger.warn(`Removing invalid FCM token for user ${userId}`);
          await db.collection("users").doc(userId).update({
            fcmToken: admin.firestore.FieldValue.delete(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        } catch (cleanupErr) {
          logger.error(`Failed to remove stale token for user ${userId}`, cleanupErr);
        }
      }

      await docRef.update({
        status: "failed",
        error: error.message || String(error),
        errorCode: error.code || "unknown",
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return null;
    }
  }
);

