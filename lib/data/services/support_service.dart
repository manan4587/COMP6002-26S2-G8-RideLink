import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/data/models/firestore/firestore_collections.dart';

/// Dedicated service for Support Tickets and Customer Care
class SupportService {
  SupportService._();
  static final SupportService instance = SupportService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _ticketsRef =>
      _firestore.collection(FirestoreCollections.supportTickets);

  /// Create a support ticket in Firestore
  Future<void> createSupportTicket({
    required String ticketId,
    required String subject,
    required String category,
    required String message,
    required String userRole,
    required String userName,
    String? userEmail,
    String? userPhone,
  }) async {
    final user = _auth.currentUser;
    final uid = user?.uid ??
        (Preferences.userEmail.isNotEmpty ? Preferences.userEmail : 'anonymous');
    final email = (userEmail != null && userEmail.isNotEmpty)
        ? userEmail
        : (user?.email ?? Preferences.userEmail);
    final phone = (userPhone != null && userPhone.isNotEmpty)
        ? userPhone
        : Preferences.userPhone;
    final name = userName.trim().isNotEmpty
        ? userName.trim()
        : (user?.displayName ?? Preferences.userName);

    try {
      debugPrint('[SupportService] Writing ticket $ticketId to Firestore (uid: $uid)...');
      await _ticketsRef.doc(ticketId).set({
        'ticketId': ticketId,
        'userId': uid,
        'userName': name.isNotEmpty ? name : 'RideLink User',
        'userEmail': email,
        'userPhone': phone,
        'userRole': userRole,
        'subject': subject,
        'category': category,
        'message': message,
        'status': 'Open',
        'priority': 'Normal',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'messages': [
          {
            'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
            'senderRole': userRole,
            'senderName': name.isNotEmpty ? name : 'RideLink User',
            'message': message,
            'timestamp': DateTime.now().toIso8601String(),
          }
        ],
      });
      debugPrint('[SupportService] Ticket $ticketId successfully saved in Firestore.');
    } catch (e, stack) {
      debugPrint('[SupportService] FAILED to save support ticket $ticketId: $e\n$stack');
      rethrow;
    }
  }

  /// Add message to an existing support ticket
  Future<void> addSupportChatMessage({
    required String ticketId,
    required String message,
    required String senderRole,
    required String senderName,
  }) async {
    try {
      debugPrint('[SupportService] Appending message to ticket $ticketId in Firestore...');
      await _ticketsRef.doc(ticketId).update({
        'updatedAt': FieldValue.serverTimestamp(),
        'messages': FieldValue.arrayUnion([
          {
            'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
            'senderRole': senderRole,
            'senderName': senderName,
            'message': message,
            'timestamp': DateTime.now().toIso8601String(),
          }
        ]),
      });
      debugPrint('[SupportService] Message appended to ticket $ticketId successfully.');
    } catch (e, stack) {
      debugPrint('[SupportService] FAILED to append message to ticket $ticketId: $e\n$stack');
      rethrow;
    }
  }

  /// Mark support ticket as resolved in Firestore
  Future<void> resolveSupportTicket({
    required String ticketId,
  }) async {
    await _ticketsRef.doc(ticketId).update({
      'status': 'Resolved',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch user support tickets from Firestore (one-time)
  Future<List<Map<String, dynamic>>> fetchUserSupportTickets() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    try {
      final snapshot = await _ticketsRef
          .where('userId', isEqualTo: user.uid)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (_) {
      return [];
    }
  }

  /// Real-time stream of user's support tickets
  Stream<List<Map<String, dynamic>>> streamUserSupportTickets(String uid) {
    return _ticketsRef
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Real-time stream for a single ticket
  Stream<Map<String, dynamic>?> streamSupportTicket(String ticketId) {
    return _ticketsRef
        .doc(ticketId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }
}

