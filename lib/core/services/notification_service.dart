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
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _inAppNotificationsSubscription;
  final Set<String> _seenNotificationIds = {};
  String? _cachedFcmToken;
  bool _isInitialized = false;

  String? get cachedFcmToken => _cachedFcmToken;

  /// Initialize Firebase Messaging:
  /// - Requests push permissions
  /// - Configures foreground presentation options
  /// - Sets up live foreground and auth listeners
  /// - Retrieves the device token safely (handles iOS APNs delay)
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    // 1. Request user permission for notifications
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint(
        '[NotificationService] Notification permission status: ${settings.authorizationStatus}',
      );
    } catch (e) {
      debugPrint('[NotificationService] Error requesting notification permissions: $e');
    }

    // 2. Set foreground presentation options (iOS / macOS / Android)
    try {
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('[NotificationService] Error setting foreground options: $e');
    }

    // 3. Listen for token refreshes
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _fcm.onTokenRefresh.listen((newToken) async {
      debugPrint('[NotificationService] FCM Token refreshed: $newToken');
      _cachedFcmToken = newToken;
      await syncTokenToFirestore(newToken);
    });

    // 4. Listen for Firebase Auth state changes to automatically sync or clear tokens
    _authSubscription?.cancel();
    _authSubscription = _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        debugPrint(
          '[NotificationService] Auth state changed: User logged in (${user.uid}). Syncing FCM token & attaching live listener.',
        );
        _startInAppNotificationListener(user.uid);
        await syncTokenToFirestore();
      } else {
        debugPrint('[NotificationService] Auth state changed: User signed out.');
        _inAppNotificationsSubscription?.cancel();
        _inAppNotificationsSubscription = null;
      }
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

    try {
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
          '[NotificationService] App launched from terminated state via notification: ${initialMessage.data}',
        );
      }
    } catch (_) {}

    // 7. Start in-app notification listener if a user is already authenticated
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _startInAppNotificationListener(currentUser.uid);
    }

    // 8. Safely retrieve and sync token asynchronously
    _fetchAndSyncToken();
  }

  /// Safely fetches the FCM token without letting APNs delays abort initialization.
  Future<void> _fetchAndSyncToken() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('[NotificationService] iOS APNS token not ready yet. Retrying in 2 seconds...');
          await Future.delayed(const Duration(seconds: 2));
          apnsToken = await _fcm.getAPNSToken();
        }
      }

      final token = await _fcm.getToken();
      if (token != null && token.isNotEmpty) {
        _cachedFcmToken = token;
        debugPrint('[NotificationService] FCM Token obtained: $token');
        await syncTokenToFirestore(token);
      }
    } catch (e) {
      debugPrint('[NotificationService] Note on FCM token retrieval: $e');
    }
  }

  /// Live Firestore notification listener for instantaneous in-app delivery
  void _startInAppNotificationListener(String userId) {
    _inAppNotificationsSubscription?.cancel();
    _inAppNotificationsSubscription = _firestore
        .collection(FirestoreCollections.notifications)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
      (snapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final doc = change.doc;
            if (_seenNotificationIds.contains(doc.id)) continue;
            _seenNotificationIds.add(doc.id);

            final data = doc.data() ?? {};
            // If notification was created more than 1 minute ago, skip showing it again
            final createdAt = data['createdAt'];
            if (createdAt is Timestamp) {
              final age = DateTime.now().difference(createdAt.toDate());
              if (age.inMinutes > 2) continue;
            }

            final title = data['title']?.toString() ?? 'RideLink';
            final body = data['body']?.toString() ?? '';

            if (title.isNotEmpty || body.isNotEmpty) {
              AppSnackBar.info(
                message: body.isNotEmpty ? '$title: $body' : title,
              );
            }
          }
        }
      },
      onError: (err) {
        debugPrint('[NotificationService] In-app notification stream error: $err');
      },
    );
  }

  /// Sync the current device FCM token to `users/{userId}.fcmToken`.
  Future<void> syncTokenToFirestore([String? tokenToSync]) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('[NotificationService] No user logged in. Skipping FCM sync.');
      return;
    }

    String? token = tokenToSync ?? _cachedFcmToken;
    if (token == null || token.isEmpty) {
      try {
        token = await _fcm.getToken();
      } catch (_) {}
    }

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
      debugPrint('[NotificationService] Successfully synced FCM token to user ${user.uid}');
    } catch (e) {
      debugPrint('[NotificationService] Failed to sync FCM token: $e');
    }
  }

  /// Remove FCM token from `users/{userId}` when the user signs out.
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
    _authSubscription?.cancel();
    _inAppNotificationsSubscription?.cancel();
  }
}

