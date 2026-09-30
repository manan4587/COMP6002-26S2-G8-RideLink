import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ridelink/data/models/firestore/firestore_collections.dart';
import 'package:ridelink/data/models/firestore/trip_model.dart';
import 'package:ridelink/data/services/chat_service.dart';

class TripService {
  TripService._();
  static final TripService instance = TripService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tripsRef =>
      _firestore.collection(FirestoreCollections.rides);

  CollectionReference<Map<String, dynamic>> get _bookingsRef =>
      _firestore.collection(FirestoreCollections.bookings);

  // -------------------------------------------------------------
  // TRIP CREATION & MANAGEMENT (DRIVER)
  // -------------------------------------------------------------

  /// Driver creates and publishes a new trip
  Future<String> createTrip(TripModel trip) async {
    final docRef = trip.id.isNotEmpty ? _tripsRef.doc(trip.id) : _tripsRef.doc();
    final tripId = docRef.id;

    final tripData = trip.toMap();
    tripData['id'] = tripId;

    await docRef.set(tripData);
    return tripId;
  }

  /// Update trip status ('scheduled' | 'active' | 'completed' | 'cancelled')
  Future<void> updateTripStatus(String tripId, String status) async {
    await _tripsRef.doc(tripId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream trips published by a specific driver in real-time
  Stream<List<TripModel>> streamDriverTrips(String driverId) {
    return _tripsRef
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .map((snapshot) {
      final trips = snapshot.docs
          .map((doc) => TripModel.fromMap(doc.data(), doc.id))
          .toList();
      trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return trips;
    });
  }

  /// Stream all available scheduled trips for passengers to search and book
  Stream<List<TripModel>> streamAvailableTrips() {
    return _tripsRef
        .where('status', isEqualTo: 'scheduled')
        .snapshots()
        .map((snapshot) {
      final trips = snapshot.docs
          .map((doc) => TripModel.fromMap(doc.data(), doc.id))
          .where((t) => t.availableSeats > 0)
          .toList();
      trips.sort((a, b) => a.departureTime.compareTo(b.departureTime));
      return trips;
    });
  }

  /// Stream a single trip document by tripId
  Stream<TripModel?> streamTrip(String tripId) {
    return _tripsRef.doc(tripId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return TripModel.fromMap(doc.data()!, doc.id);
    });
  }

  // -------------------------------------------------------------
  // TRIP BOOKING & REQUESTS (PASSENGER & DRIVER)
  // -------------------------------------------------------------

  /// Passenger creates a booking request for a trip
  Future<String> requestTripBooking(TripBookingModel booking) async {
    final docRef = _bookingsRef.doc();
    final bookingId = docRef.id;

    final data = booking.toMap();
    data['id'] = bookingId;

    await docRef.set(data);
    return bookingId;
  }

  /// Driver accepts a passenger booking request and updates available seats
  Future<void> acceptTripBooking({
    required String bookingId,
    required String tripId,
    required int seats,
  }) async {
    final batch = _firestore.batch();

    final bookingRef = _bookingsRef.doc(bookingId);
    batch.update(bookingRef, {
      'status': 'accepted',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final tripRef = _tripsRef.doc(tripId);
    batch.update(tripRef, {
      'bookedSeats': FieldValue.increment(seats),
      'availableSeats': FieldValue.increment(-seats),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Driver declines a passenger booking request
  Future<void> declineTripBooking(String bookingId) async {
    await _bookingsRef.doc(bookingId).update({
      'status': 'declined',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Passenger cancels their booking request
  Future<void> cancelTripBooking({
    required String bookingId,
    required String tripId,
    required int seats,
    required bool wasAccepted,
  }) async {
    final batch = _firestore.batch();
    final bookingRef = _bookingsRef.doc(bookingId);
    batch.update(bookingRef, {
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (wasAccepted) {
      final tripRef = _tripsRef.doc(tripId);
      batch.update(tripRef, {
        'bookedSeats': FieldValue.increment(-seats),
        'availableSeats': FieldValue.increment(seats),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Stream booking requests for a specific trip
  Stream<List<TripBookingModel>> streamTripBookings(String tripId) {
    return _bookingsRef
        .where('tripId', isEqualTo: tripId)
        .snapshots()
        .map((snapshot) {
      final bookings = snapshot.docs
          .map((doc) => TripBookingModel.fromMap(doc.data(), doc.id))
          .toList();
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return bookings;
    });
  }

  /// Stream passenger's booking requests & confirmed bookings
  Stream<List<TripBookingModel>> streamPassengerBookings(String passengerId) {
    return _bookingsRef
        .where('passengerId', isEqualTo: passengerId)
        .snapshots()
        .map((snapshot) {
      final bookings = snapshot.docs
          .map((doc) => TripBookingModel.fromMap(doc.data(), doc.id))
          .toList();
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return bookings;
    });
  }

  // -------------------------------------------------------------
  // TRIP REAL-TIME CHAT (Delegated to ChatService)
  // -------------------------------------------------------------

  /// Send a message in a trip's chat subcollection
  Future<void> sendTripChatMessage({
    required String tripId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
  }) =>
      ChatService.instance.sendTripChatMessage(
        tripId: tripId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        message: message,
      );

  /// Stream real-time chat messages for a specific trip
  Stream<List<TripChatMessageModel>> streamTripChatMessages(String tripId) =>
      ChatService.instance.streamTripChatMessages(tripId);
}
