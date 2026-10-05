import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ridelink/data/models/firestore/firestore_collections.dart';
import 'package:ridelink/data/models/firestore/user_profile_model.dart';

class FirebaseAuthExceptionInfo {
  final String message;
  final String? code;

  const FirebaseAuthExceptionInfo({required this.message, this.code});
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Map Firebase error codes to user-friendly messages
  String getFriendlyErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with this email. Please sign up first.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect password or credentials. Please try again.';
        case 'email-already-in-use':
          return 'An account already exists for this email address.';
        case 'invalid-email':
          return 'The email address format is invalid.';
        case 'weak-password':
          return 'The password is too weak. Please choose at least 6 characters.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please wait a few minutes before trying again.';
        case 'operation-not-allowed':
          return 'Sign-in method is currently disabled. Please contact support.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        default:
          return error.message ?? 'An authentication error occurred (${error.code}).';
      }
    }
    return error?.toString() ?? 'An unexpected error occurred. Please try again.';
  }

  /// Sign Up with Email & Password and send a verification email
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String role, // 'passenger' | 'driver'
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      await user.updateDisplayName(fullName.trim());
      // Send Firebase Email Verification
      await sendVerificationEmail(user);

      // Create initial Firestore user document
      final userProfile = UserProfileModel(
        id: user.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber.trim(),
        activeRole: role,
        roles: [role],
        isEmailVerified: false,
        isVerifiedDriver: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .set(userProfile.toMap(), SetOptions(merge: true));
    }

    return credential;
  }

  /// Sign In with Email & Password
  /// Returns the UserCredential and whether the user's email is verified.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      await user.reload();
      final refreshedUser = _auth.currentUser;
      if (refreshedUser != null && refreshedUser.emailVerified) {
        await _firestore
            .collection(FirestoreCollections.users)
            .doc(refreshedUser.uid)
            .set({
          'isEmailVerified': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }

    return credential;
  }

  /// Send verification email to currently signed in or provided user
  Future<void> sendVerificationEmail([User? user]) async {
    final targetUser = user ?? _auth.currentUser;
    if (targetUser != null && !targetUser.emailVerified) {
      await targetUser.sendEmailVerification();
    }
  }

  /// Check if the user's email is verified (reloads token from Firebase)
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    final refreshedUser = _auth.currentUser;
    final isVerified = refreshedUser?.emailVerified ?? false;
    if (isVerified) {
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .set({
        'isEmailVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    return isVerified;
  }

  /// Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Sign In with Google (defaults to passenger role)
  Future<UserCredential?> signInWithGoogle({
    String defaultRole = 'passenger',
  }) async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // User cancelled the Google sign-in dialog
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    final user = userCredential.user;
    if (user != null) {
      final docRef = _firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        // First-time Google user
        final userProfile = UserProfileModel(
          id: user.uid,
          fullName: user.displayName ?? googleUser.displayName ?? '',
          email: user.email ?? googleUser.email,
          phoneNumber: user.phoneNumber ?? '',
          photoUrl: null,
          activeRole: defaultRole,
          roles: [defaultRole],
          isEmailVerified: true, // Google accounts come pre-verified
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await docRef.set(userProfile.toMap());
      } else {
        // Existing user: preserve existing role & update profile details if changed
        await docRef.set({
          'isEmailVerified': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }

    return userCredential;
  }

  /// Fetch user profile from Firestore
  Future<UserProfileModel?> getUserProfile(String uid) async {
    final doc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .get();
    if (doc.exists && doc.data() != null) {
      return UserProfileModel.fromMap(doc.data()!, uid);
    }
    return null;
  }

  /// Update user profile in Firestore (and Firebase Auth display name if changed)
  Future<void> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? email,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (fullName != null && fullName.trim().isNotEmpty) {
      updates['fullName'] = fullName.trim();
      await user.updateDisplayName(fullName.trim());
    }

    if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      updates['phoneNumber'] = phoneNumber.trim();
    }

    if (email != null && email.trim().isNotEmpty && email.trim() != user.email) {
      updates['email'] = email.trim();
    }

    await _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .set(updates, SetOptions(merge: true));
  }

  /// Update saved locations in Firestore
  Future<void> updateSavedLocations(List<Map<String, dynamic>> locations) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .set({
      'savedLocations': locations,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Update emergency contacts in Firestore
  Future<void> updateEmergencyContacts(
      List<Map<String, dynamic>> contacts) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .set({
      'emergencyContacts': contacts,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Update active role in Firestore and ensure role is in roles list
  Future<void> updateActiveRole(String role) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .set({
        'activeRole': role,
        'roles': FieldValue.arrayUnion([role]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[AuthService] Failed to update activeRole in Firestore: $e');
    }
  }

  /// Update driver online/offline availability status in Firestore
  Future<void> updateOnlineStatus(bool isOnline) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .set({
        'isOnline': isOnline,
        'driverStats': {
          'isOnline': isOnline,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[AuthService] Failed to update online status: $e');
    }
  }

  double? _lastAuthDriverLat;
  double? _lastAuthDriverLng;
  DateTime? _lastAuthDriverUpdate;

  /// Update driver's live GPS device location in Firestore user document.
  /// Applies smart stationary filtering:
  /// - Suppresses database writes if driver is stationary (moved < 10 meters).
  /// - Sends periodic 60-second heartbeat so status remains fresh.
  /// - Throttles updates to max once per 3 seconds.
  /// - Pass [force] = true to bypass checks (e.g. going online, starting app).
  Future<void> updateDriverLocation({
    required double latitude,
    required double longitude,
    bool force = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    if (!force &&
        _lastAuthDriverLat != null &&
        _lastAuthDriverLng != null &&
        _lastAuthDriverUpdate != null) {
      final elapsedMs = now.difference(_lastAuthDriverUpdate!).inMilliseconds;

      // Throttle: max once per 3 seconds
      if (elapsedMs < 3000) {
        return;
      }

      final double distanceMeters = Geolocator.distanceBetween(
        _lastAuthDriverLat!,
        _lastAuthDriverLng!,
        latitude,
        longitude,
      );

      // Skip DB write if stationary (< 10 meters) and within 60-second heartbeat
      if (distanceMeters < 10.0 && elapsedMs < 60000) {
        return;
      }
    }

    _lastAuthDriverLat = latitude;
    _lastAuthDriverLng = longitude;
    _lastAuthDriverUpdate = now;

    try {
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .set({
        'currentLocation': {
          'latitude': latitude,
          'longitude': longitude,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        'lastLatitude': latitude,
        'lastLongitude': longitude,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[AuthService] Failed to update driver location: $e');
    }
  }

  /// Stream user profile model in real-time
  Stream<UserProfileModel?> streamUserProfile(String uid) {
    if (uid.isEmpty) return Stream.value(null);
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserProfileModel.fromMap(doc.data()!, uid);
    });
  }

  /// Stream raw user document data in real-time
  Stream<Map<String, dynamic>?> userDocumentStream(String uid) {
    if (uid.isEmpty) return Stream.value(null);
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  /// Stream a user's real-time online status by their UID
  Stream<bool> streamUserOnlineStatus(String uid) {
    if (uid.isEmpty) return Stream.value(true);
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return true;
      final data = doc.data()!;
      if (data.containsKey('isOnline')) {
        return data['isOnline'] as bool? ?? true;
      }
      if (data['driverStats'] is Map &&
          (data['driverStats'] as Map).containsKey('isOnline')) {
        return (data['driverStats'] as Map)['isOnline'] as bool? ?? true;
      }
      return true;
    });
  }


  /// Delete Account permanently from Firebase Auth and Cloud Firestore
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      // 1. Delete Firestore user document
      try {
        await _firestore
            .collection(FirestoreCollections.users)
            .doc(uid)
            .delete();
      } catch (_) {}

      // 2. Disconnect Google Sign-In session if active
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}

      // 3. Delete Firebase Auth User
      await user.delete();
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      // Clear current device FCM token from the user document before signing out
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore
            .collection(FirestoreCollections.users)
            .doc(uid)
            .update({
          'fcmToken': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        }).catchError((_) {});
      }
    } catch (_) {}

    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}
