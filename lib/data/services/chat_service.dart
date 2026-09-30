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

