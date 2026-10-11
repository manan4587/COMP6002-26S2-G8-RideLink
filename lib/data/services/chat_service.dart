import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ridelink/data/models/firestore/firestore_collections.dart';
import 'package:ridelink/data/models/firestore/trip_model.dart';

/// Dedicated service for trip-related real-time chat between drivers and passengers
class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _chatMessagesRef(String tripId) =>
      _firestore
          .collection(FirestoreCollections.rides)
          .doc(tripId)
          .collection(FirestoreCollections.messages);

  /// Send a message in a trip's chat subcollection (`rides/{tripId}/messages`)
  Future<void> sendTripChatMessage({
    required String tripId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
  }) async {
    final docRef = _chatMessagesRef(tripId).doc();
    final msg = TripChatMessageModel(
      id: docRef.id,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      message: message.trim(),
      timestamp: DateTime.now(),
    );

    await docRef.set(msg.toMap());

    // Trigger in-app & push notification entry for the recipient
    try {
      final List<String> targetUserIds = [];
      final tripDoc = await _firestore
          .collection(FirestoreCollections.rides)
          .doc(tripId)
          .get();

      if (tripDoc.exists) {
        final data = tripDoc.data() ?? {};
        final driverId = data['driverId']?.toString() ?? '';

        if (senderId == driverId) {
          // Driver sent message -> notify accepted passengers on this trip
          final bookingsSnap = await _firestore
              .collection(FirestoreCollections.bookings)
              .where('tripId', isEqualTo: tripId)
              .where('status', isEqualTo: 'accepted')
              .get();
          for (final doc in bookingsSnap.docs) {
            final pId = doc.data()['passengerId']?.toString();
            if (pId != null &&
                pId.isNotEmpty &&
                pId != senderId &&
                !targetUserIds.contains(pId)) {
              targetUserIds.add(pId);
            }
          }
        } else {
          // Passenger sent message -> notify driver
          if (driverId.isNotEmpty && driverId != senderId) {
            targetUserIds.add(driverId);
          }
        }
      }

      for (final recipientId in targetUserIds) {
        String? token;
        try {
          final uDoc = await _firestore
              .collection(FirestoreCollections.users)
              .doc(recipientId)
              .get();
          token = uDoc.data()?['fcmToken']?.toString();
        } catch (_) {}

        await _firestore.collection(FirestoreCollections.notifications).add({
          'title': 'New Message from $senderName 💬',
          'body': message.trim(),
          'userId': recipientId,
          if (token != null && token.isNotEmpty) 'fcmToken': token,
          'status': 'pending',
          'data': {
            'type': 'trip_chat',
            'tripId': tripId,
            'senderId': senderId,
            'senderName': senderName,
          },
          'sound': 'default',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
  }

  /// Stream real-time chat messages for a specific trip
  Stream<List<TripChatMessageModel>> streamTripChatMessages(String tripId) {
    return _chatMessagesRef(tripId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TripChatMessageModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}

