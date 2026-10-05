import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ridelink/data/models/firestore/firestore_collections.dart';
import 'package:ridelink/data/models/firestore/trip_model.dart';
import 'package:ridelink/data/services/chat_service.dart';

class _TripLocationCache {
  double lat;
  double lng;
  DateTime lastSentAt;

  _TripLocationCache({
    required this.lat,
    required this.lng,
    required this.lastSentAt,
  });
}

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

  // In-memory cache of last reported location & timestamp per trip
  final Map<String, _TripLocationCache> _tripLocationCaches = {};

  /// Update driver's live device location in Firestore for active tracking.
  /// Applies smart stationary filtering:
  /// - If stationary (moved < 8 meters), suppresses wasteful writes.
  /// - Automatically sends a heartbeat ping if stationary for > 45 seconds so passengers know the driver is online.
  /// - Throttles updates to a max of once per 2.5 seconds.
  /// - Pass [force] = true to bypass checks (e.g. initial start, arriving at stop, or ending trip).
  Future<void> updateDriverLocation(
    String tripId,
    double lat,
    double lng, {
    bool force = false,
  }) async {
    if (tripId.isEmpty) return;

    final now = DateTime.now();
    final cached = _tripLocationCaches[tripId];

    if (!force && cached != null) {
      final elapsedMs = now.difference(cached.lastSentAt).inMilliseconds;

      // Throttle: don't write to Firestore more frequently than once every 2.5 seconds
      if (elapsedMs < 2500) {
        return;
      }

      final double distanceMeters = Geolocator.distanceBetween(
        cached.lat,
        cached.lng,
        lat,
        lng,
      );

      // If driver is stationary or GPS jitter (< 8 meters) AND under 45-sec heartbeat, skip DB write
      if (distanceMeters < 8.0 && elapsedMs < 45000) {
        return;
      }
    }

    // Update in-memory cache
    if (cached != null) {
      cached.lat = lat;
      cached.lng = lng;
      cached.lastSentAt = now;
    } else {
      _tripLocationCaches[tripId] = _TripLocationCache(
        lat: lat,
        lng: lng,
        lastSentAt: now,
      );
    }

    try {
      await _tripsRef.doc(tripId).update({
        'currentDriverLat': lat,
        'currentDriverLng': lng,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
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

  /// Stream all available scheduled and active trips for passengers to search and book
  Stream<List<TripModel>> streamAvailableTrips() {
    return _tripsRef
        .where('status', whereIn: ['scheduled', 'active'])
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

  /// Fetch a single trip document by tripId once
  Future<TripModel?> getTrip(String tripId) async {
    if (tripId.isEmpty) return null;
    try {
      final doc = await _tripsRef.doc(tripId).get();
      if (!doc.exists || doc.data() == null) return null;
      return TripModel.fromMap(doc.data()!, doc.id);
    } catch (_) {
      return null;
    }
  }

  /// Passenger creates a booking request for a trip
  Future<String> requestTripBooking(TripBookingModel booking) async {
    final docRef = booking.id.isNotEmpty
        ? _bookingsRef.doc(booking.id)
        : _bookingsRef.doc();
    final bookingId = docRef.id;

    // Look up driverId if not provided on the booking model
    String targetDriverId = booking.driverId;
    if (targetDriverId.isEmpty && booking.tripId.isNotEmpty) {
      try {
        final tripDoc = await _tripsRef.doc(booking.tripId).get();
        if (tripDoc.exists) {
          targetDriverId = tripDoc.data()?['driverId']?.toString() ?? '';
        }
      } catch (_) {}
    }

    final data = booking.toMap();
    data['id'] = bookingId;
    data['driverId'] = targetDriverId;

    await docRef.set(data);

    // Send push notification entry to notifications collection for the driver
    if (targetDriverId.isNotEmpty) {
      try {
        await _firestore.collection(FirestoreCollections.notifications).add({
          'title': 'New Ride Request! 🚗',
          'body':
              '${booking.passengerName} requested ${booking.requestedSeats} seat${booking.requestedSeats > 1 ? 's' : ''} for your trip (${booking.pickupAddress} → ${booking.dropAddress}).',
          'userId': targetDriverId,
          'status': 'pending',
          'data': {
            'type': 'ride_request',
            'tripId': booking.tripId,
            'bookingId': bookingId,
            'passengerId': booking.passengerId,
            'passengerName': booking.passengerName,
            'seats': booking.requestedSeats.toString(),
          },
          'sound': 'default',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }

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

    // Send push notification entry to notifications collection for the passenger
    try {
      final bookingDoc = await _bookingsRef.doc(bookingId).get();
      if (bookingDoc.exists) {
        final bData = bookingDoc.data();
        final passengerId = bData?['passengerId']?.toString();
        if (passengerId != null && passengerId.isNotEmpty) {
          await _firestore.collection(FirestoreCollections.notifications).add({
            'title': 'Ride Request Approved! 🎉',
            'body':
                'Your ride request has been approved by the driver! Pack your bags and get ready.',
            'userId': passengerId,
            'status': 'pending',
            'data': {
              'type': 'booking_accepted',
              'tripId': tripId,
              'bookingId': bookingId,
            },
            'sound': 'default',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (_) {}
  }

  /// Driver updates a passenger's status along the route ('to_pickup' | 'arrived' | 'onboard' | 'dropped_off')
  Future<void> updateBookingPassengerStatus({
    required String bookingId,
    required String passengerStatus,
  }) async {
    if (bookingId.isEmpty) return;
    try {
      await _bookingsRef.doc(bookingId).update({
        'passengerStatus': passengerStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  /// Driver declines a passenger booking request
  Future<void> declineTripBooking(String bookingId) async {
    await _bookingsRef.doc(bookingId).update({
      'status': 'declined',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Send push notification entry to notifications collection for the passenger
    try {
      final bookingDoc = await _bookingsRef.doc(bookingId).get();
      if (bookingDoc.exists) {
        final bData = bookingDoc.data();
        final passengerId = bData?['passengerId']?.toString();
        final tripId = bData?['tripId']?.toString() ?? '';
        if (passengerId != null && passengerId.isNotEmpty) {
          await _firestore.collection(FirestoreCollections.notifications).add({
            'title': 'Ride Request Declined',
            'body':
                'Unfortunately, the driver was unable to accept your ride request.',
            'userId': passengerId,
            'status': 'pending',
            'data': {
              'type': 'booking_declined',
              'tripId': tripId,
              'bookingId': bookingId,
            },
            'sound': 'default',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (_) {}
  }

  /// Passenger cancels their booking request (pending or active/accepted)
  Future<void> cancelTripBooking({
    required String bookingId,
    required String tripId,
    required int seats,
    required bool wasAccepted,
    String? driverId,
    String? passengerName,
    String reason = 'Ride cancelled by passenger',
  }) async {
    final batch = _firestore.batch();
    final bookingRef = _bookingsRef.doc(bookingId);
    batch.update(bookingRef, {
      'status': 'cancelled',
      'cancellationReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (wasAccepted && tripId.isNotEmpty && seats > 0) {
      final tripRef = _tripsRef.doc(tripId);
      batch.update(tripRef, {
        'bookedSeats': FieldValue.increment(-seats),
        'availableSeats': FieldValue.increment(seats),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    // Send push notification to driver if ride was active/confirmed or driverId is provided
    try {
      String targetDriverId = driverId ?? '';
      String pName = passengerName ?? '';

      // If driverId or passengerName wasn't passed directly, look it up from booking or trip
      if (targetDriverId.isEmpty || pName.isEmpty) {
        final bSnap = await bookingRef.get();
        if (bSnap.exists) {
          final bData = bSnap.data();
          if (targetDriverId.isEmpty) {
            targetDriverId = bData?['driverId']?.toString() ?? '';
          }
          if (pName.isEmpty) {
            pName = bData?['passengerName']?.toString() ?? '';
          }
        }
      }

      if (targetDriverId.isEmpty && tripId.isNotEmpty) {
        final tSnap = await _tripsRef.doc(tripId).get();
        if (tSnap.exists) {
          targetDriverId = tSnap.data()?['driverId']?.toString() ?? '';
        }
      }

      final String displayName = pName.isNotEmpty ? pName : 'A passenger';

      if (targetDriverId.isNotEmpty) {
        final String notifTitle = wasAccepted
            ? 'Booking Cancelled by Passenger ⚠️'
            : 'Ride Request Cancelled';
        final String notifBody = wasAccepted
            ? '$displayName has cancelled their confirmed booking ($seats seat${seats > 1 ? 's' : ''}). The seat has been restored.'
            : '$displayName has withdrawn their ride request.';

        await _firestore.collection(FirestoreCollections.notifications).add({
          'title': notifTitle,
          'body': notifBody,
          'userId': targetDriverId,
          'status': 'pending',
          'data': {
            'type': 'booking_cancelled',
            'tripId': tripId,
            'bookingId': bookingId,
            'reason': reason,
            'wasAccepted': wasAccepted.toString(),
          },
          'sound': 'default',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
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

  /// Stream all booking requests belonging to a driver in real-time
  Stream<List<TripBookingModel>> streamDriverBookings(String driverId) {
    return _bookingsRef
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .map((snapshot) {
      final bookings = snapshot.docs
          .map((doc) => TripBookingModel.fromMap(doc.data(), doc.id))
          .toList();
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return bookings;
    });
  }



  /// Drop off passenger, record payment settlement, credit driver stats & notify passenger
  Future<void> completePassengerDropoff({
    required String bookingId,
    required String tripId,
    required String driverId,
    required String passengerId,
    required String passengerName,
    required double fare,
    required String paymentMethod, // 'cash' | 'card' | 'in-app'
  }) async {
    final batch = _firestore.batch();

    // 1. Mark booking as completed & paid
    final bookingRef = _bookingsRef.doc(bookingId);
    batch.update(bookingRef, {
      'status': 'completed',
      'paymentStatus': 'paid',
      'isPaid': true,
      'paymentMethod': paymentMethod,
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 2. Increment driver's completed trips & earnings in users collection
    if (driverId.isNotEmpty) {
      final driverUserRef = _firestore
          .collection(FirestoreCollections.users)
          .doc(driverId);
      batch.set(driverUserRef, {
        'driverStats': {
          'tripsCompleted': FieldValue.increment(1),
          'totalEarnings': FieldValue.increment(fare),
          'todayEarnings': FieldValue.increment(fare),
          'lastTripCompletedAt': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    // 3. Increment passenger's completed trips in users collection
    if (passengerId.isNotEmpty) {
      final passengerUserRef = _firestore
          .collection(FirestoreCollections.users)
          .doc(passengerId);
      batch.set(passengerUserRef, {
        'passengerStats': {
          'tripsCompleted': FieldValue.increment(1),
          'lastTripCompletedAt': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();

    // 4. Send instant push notification to passenger that they arrived safely and payment is confirmed
    if (passengerId.isNotEmpty) {
      try {
        await _firestore.collection(FirestoreCollections.notifications).add({
          'title': 'You Have Arrived! 🏁',
          'body':
              'You have been dropped off safely. \$${fare.toStringAsFixed(2)} AUD payment confirmed via ${paymentMethod.toUpperCase()}. Please take a moment to rate your driver!',
          'userId': passengerId,
          'status': 'pending',
          'data': {
            'type': 'trip_completed',
            'tripId': tripId,
            'bookingId': bookingId,
            'fare': fare.toString(),
            'paymentMethod': paymentMethod,
          },
          'sound': 'default',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }
  }

  /// Mark the whole trip completed when driver finishes route
  Future<void> completeEntireTrip({
    required String tripId,
    required String driverId,
  }) async {
    await updateTripStatus(tripId, 'completed');
    if (driverId.isNotEmpty) {
      try {
        await _firestore
            .collection(FirestoreCollections.users)
            .doc(driverId)
            .set({
          'driverStats': {
            'tripsCompleted': FieldValue.increment(1),
            'lastTripCompletedAt': FieldValue.serverTimestamp(),
          },
          'tripsCompleted': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }
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
