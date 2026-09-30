import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/data/models/firestore/firestore_collections.dart';

/// Top-level background message handler for Firebase Messaging.
/// Must be annotated with `@pragma('vm:entry-point')`.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[NotificationService] Background message received: ${message.messageId}');
}

/// Service handling FCM token generation, syncing with Firestore,
/// permission requests, and foreground message handling.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  String? _cachedFcmToken;

  String? get cachedFcmToken => _cachedFcmToken;

  /// Initialize Firebase Messaging:
  /// - Requests push permissions
  /// - Retrieves the APNS/FCM device token
  /// - Listens for token refreshes and updates Firestore
  /// - Listens for foreground messages
  Future<void> init() async {
    try {
      // 1. Request user permission for notifications
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint(
        '[NotificationService] Notification permission status: ${settings.authorizationStatus}',
      );

      // 2. Set foreground presentation options (iOS / macOS)
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Fetch current token
      final token = await _fcm.getToken();
      if (token != null && token.isNotEmpty) {
        _cachedFcmToken = token;
        debugPrint('[NotificationService] FCM Token obtained: $token');
        await syncTokenToFirestore(token);
      }

      // 4. Listen for token refreshes
      _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = _fcm.onTokenRefresh.listen((newToken) async {
        debugPrint('[NotificationService] FCM Token refreshed: $newToken');
        _cachedFcmToken = newToken;
        await syncTokenToFirestore(newToken);
      });

      // 5. Listen for incoming messages while app is in foreground
      _foregroundMessageSubscription?.cancel();
      _foregroundMessageSubscription =
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
          '[NotificationService] Foreground notification received: ${message.notification?.title}',
        );
        _handleForegroundMessage(message);
      });

      // 6. Handle notification click when app opens from background or terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint(
          '[NotificationService] Notification opened from background: ${message.data}',
        );
      });

      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
          '[NotificationService] App launched from terminated state via notification: ${initialMessage.data}',
        );
      }
    } catch (e) {
      debugPrint('[NotificationService] Error initializing FCM: $e');
    }
  }

  /// Sync the current device FCM token to `users/{userId}.fcmToken`.
  /// Enforces that only ONE single token string is stored at a time per user.
  Future<void> syncTokenToFirestore([String? tokenToSync]) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('[NotificationService] No user logged in. Skipping FCM sync.');
      return;
    }

    final token = tokenToSync ?? _cachedFcmToken ?? await _fcm.getToken();
    if (token == null || token.isEmpty) return;
    _cachedFcmToken = token;

    try {
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .set({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('[NotificationService] Synced FCM token to user ${user.uid}');
    } catch (e) {
      debugPrint('[NotificationService] Failed to sync FCM token: $e');
    }
  }

  /// Remove FCM token from `users/{userId}` when the user signs out.
  /// Ensures no push notifications are delivered to a signed-out user on this device.
  Future<void> removeTokenFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .update({
        'fcmToken': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[NotificationService] Removed FCM token for user ${user.uid}');
    } catch (e) {
      debugPrint('[NotificationService] Failed to remove FCM token on sign-out: $e');
    }
  }

  /// Handle incoming message in foreground
  void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title']?.toString() ?? 'Notification';
    final body = message.notification?.body ?? message.data['body']?.toString() ?? '';

    if (body.isNotEmpty || title.isNotEmpty) {
      AppSnackBar.info(
        message: body.isNotEmpty ? '$title: $body' : title,
      );
    }
  }

  /// Dispose resources
  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _foregroundMessageSubscription?.cancel();
  }
}

