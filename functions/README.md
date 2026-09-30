# RideLink Cloud Functions (Gen 2)

This directory contains the Firebase Cloud Functions Gen 2 for RideLink.

## Features

### `sendNotificationOnCreate`
A Cloud Function Gen 2 triggered whenever a new document is created in the Firestore collection `notifications/{notificationId}`.
- Sends push notifications directly to the specified `fcmToken`.
- If `fcmToken` is omitted from the document but `userId` is present, it looks up the single registered device token from `users/{userId}.fcmToken`.
- Converts any custom `data` dictionary values to strings required by FCM.
- Updates the notification document status to `sent` (`sentAt`, `messageId`) or `failed` (`error`, `errorCode`).
- Automatically clears stale or unregistered tokens from `users/{userId}` if FCM indicates `messaging/registration-token-not-registered`.

---

## Firestore Collection Schema: `notifications`

To trigger a notification from anywhere (admin panel, backend, or Firestore):

```json
{
  "title": "Ride Accepted! 🚗",
  "body": "Your driver John is on the way.",
  "userId": "TARGET_USER_ID",
  "fcmToken": "optional_if_userId_provided",
  "data": {
    "type": "ride_update",
    "rideId": "ride_12345",
    "route": "/passenger_dashboard"
  },
  "sound": "default",
  "channelId": "high_importance_channel"
}
```

---

## Deployment Instructions

1. Install Firebase CLI (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```

2. Log in and initialize:
   ```bash
   firebase login
   firebase use ridelink-d4408
   ```

3. Install dependencies:
   ```bash
   cd functions
   npm install
   ```

4. Deploy Functions:
   ```bash
   firebase deploy --only functions
   ```

