import 'dart:async';

import 'package:get/get.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/data/models/firestore/trip_model.dart';
import 'package:ridelink/data/models/passenger/passenger_models.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/trip_service.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/views/passenger_dashboard/controllers/passenger_search_controller.dart';

class PassengerTripsController extends GetxController {
  // Pending Booking Requests
  final RxList<PassengerPendingRequestModel> pendingRequests =
      <PassengerPendingRequestModel>[].obs;

  // Confirmed / Upcoming Bookings
  final RxList<BookingModel> myBookings = <BookingModel>[].obs;

  // Completed Trips History
  final RxList<CompletedTripModel> completedTrips =
      <CompletedTripModel>[].obs;

  // Selected Ride for Details View
  final Rx<RideModel?> selectedRide = Rx<RideModel?>(null);
  final Rx<RideModel?> currentSelectedRide = Rx<RideModel?>(null);

  // Trips tab selection (0: Confirmed/Upcoming, 1: Pending, 2: Completed)
  final RxInt selectedTripsTab = 0.obs;

  StreamSubscription? _availableTripsSubscription;
  StreamSubscription? _passengerBookingsSubscription;
  StreamSubscription? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    final user = AuthService.instance.currentUser;
    if (user != null) {
      subscribeToTripsAndBookings(user.uid);
    }

    _authSubscription = AuthService.instance.authStateChanges.listen((u) {
      if (u != null) {
        subscribeToTripsAndBookings(u.uid);
      } else {
        clearState();
      }
    });
  }

  void clearState() {
    _availableTripsSubscription?.cancel();
    _availableTripsSubscription = null;
    _passengerBookingsSubscription?.cancel();
    _passengerBookingsSubscription = null;
    pendingRequests.clear();
    myBookings.clear();
    completedTrips.clear();
    selectedRide.value = null;
    currentSelectedRide.value = null;
    selectedTripsTab.value = 0;
  }

  void switchTripsTab(int index) {
    selectedTripsTab.value = index;
  }

  void subscribeToTripsAndBookings(String uid) {
    _availableTripsSubscription?.cancel();
    _availableTripsSubscription =
        TripService.instance.streamAvailableTrips().listen((trips) {
      if (trips.isEmpty) return;

      final List<RideModel> mapped = trips.map((t) {
        return RideModel(
          id: t.id,
          driverId: t.driverId,
          driverName: t.driverName,
          driverAvatar: '',
          driverPhone: t.driverPhone,
          rating: t.driverRating,
          totalRides: t.driverTotalRides,
          carModel: t.carModel,
          carPlate: t.carPlate,
          origin: t.originName.isNotEmpty ? t.originName : t.originAddress,
          destination:
              t.destinationName.isNotEmpty ? t.destinationName : t.destinationAddress,
          originLat: t.originLat,
          originLng: t.originLng,
          destinationLat: t.destinationLat,
          destinationLng: t.destinationLng,
          departureTime:
              t.departureTimeString.isNotEmpty ? t.departureTimeString : '08:00 AM',
          estimatedDuration: '28 mins',
          pricePerSeat: t.pricePerSeat,
          seatsAvailable: t.availableSeats,
          matchPercentage: 96,
          detourMinutes: 4,
          pickupSuggestion: t.originName,
          dropOffPlan: '${t.originName} → ${t.destinationName}',
        );
      }).toList();

      if (Get.isRegistered<PassengerSearchController>()) {
        final searchCtrl = Get.find<PassengerSearchController>();
        for (final r in mapped) {
          final idx = searchCtrl.availableRides.indexWhere((x) => x.id == r.id);
          if (idx != -1) {
            searchCtrl.availableRides[idx] = r;
          } else {
            searchCtrl.availableRides.insert(0, r);
          }
        }
      }
    });

    _passengerBookingsSubscription?.cancel();
    _passengerBookingsSubscription =
        TripService.instance.streamPassengerBookings(uid).listen((bookings) {
      for (final b in bookings) {
        RideModel? ride;
        if (Get.isRegistered<PassengerSearchController>()) {
          ride = Get.find<PassengerSearchController>()
              .availableRides
              .firstWhereOrNull((r) => r.id == b.tripId);
        }
        ride ??= RideModel(
          id: b.tripId,
          driverName: 'Driver',
          driverAvatar: '',
          rating: 0.0,
          totalRides: 0,
          carModel: 'Vehicle',
          carPlate: 'Plate',
          origin: b.pickupAddress,
          destination: b.dropAddress,
          departureTime: 'Today',
          estimatedDuration: '30 mins',
          pricePerSeat: b.fare / (b.requestedSeats > 0 ? b.requestedSeats : 1),
          seatsAvailable: 2,
        );

        if (b.status == 'accepted') {
          pendingRequests.removeWhere((p) => p.bookingId == b.id || p.id == b.id);
          final existing =
              myBookings.firstWhereOrNull((x) => x.bookingId == b.id || x.id == b.id);
          if (existing == null) {
            myBookings.insert(
              0,
              BookingModel(
                id: b.id,
                bookingId: b.id,
                ride: ride,
                bookedSeats: b.requestedSeats,
                totalPrice: b.fare,
                status: 'Confirmed',
                bookingDate: 'Confirmed by Driver',
              ),
            );
          }
        } else if (b.status == 'pending') {
          final existingReq =
              pendingRequests.firstWhereOrNull((p) => p.bookingId == b.id || p.id == b.id);
          if (existingReq == null) {
            pendingRequests.insert(
              0,
              PassengerPendingRequestModel(
                id: b.id,
                bookingId: b.id,
                ride: ride,
                requestedSeats: b.requestedSeats,
                passengerLabel: b.passengerName,
                totalPrice: b.fare,
                requestTime: 'Pending approval',
                status: 'Waiting for driver approval',
              ),
            );
          }
        } else if (b.status == 'declined' || b.status == 'cancelled') {
          pendingRequests.removeWhere((p) => p.bookingId == b.id || p.id == b.id);
          myBookings.removeWhere((p) => p.bookingId == b.id || p.id == b.id);
        }
      }
    });
  }

  void openRideDetails(RideModel ride) {
    selectedRide.value = ride;
    currentSelectedRide.value = ride;
    Get.toNamed(AppRoutes.rideDetails);
  }

  void selectRideForDetails(RideModel ride) {
    openRideDetails(ride);
  }

  void requestToJoinRide(
    RideModel ride, {
    int? seats,
    String? notes,
  }) {
    final int seatCount = seats ?? 1;
    final bookingId = 'bk_${DateTime.now().millisecondsSinceEpoch}';
    final user = AuthService.instance.currentUser;
    final passengerUid = user?.uid ?? 'passenger_demo';
    final pName = Preferences.userName.isNotEmpty ? Preferences.userName : 'Passenger';
    final pPhone = Preferences.userPhone;

    final newReq = PassengerPendingRequestModel(
      id: bookingId,
      bookingId: bookingId,
      ride: ride,
      requestedSeats: seatCount,
      passengerLabel: '$pName + ${seatCount - 1}',
      totalPrice: ride.pricePerSeat * seatCount,
      requestTime: 'Just now',
    );
    pendingRequests.insert(0, newReq);

    TripService.instance.requestTripBooking(
      TripBookingModel(
        id: bookingId,
        tripId: ride.id,
        passengerId: passengerUid,
        passengerName: pName,
        passengerPhone: pPhone,
        passengerRating: 0.0,
        requestedSeats: seatCount,
        fare: ride.pricePerSeat * seatCount,
        pickupAddress: ride.origin,
        dropAddress: ride.destination,
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    );

    Get.toNamed(AppRoutes.requestSent);
  }

  void bookRide(RideModel ride, int seats) {
    final double total = ride.pricePerSeat * seats;
    final booking = BookingModel(
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      bookingId: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      ride: ride,
      bookedSeats: seats,
      totalPrice: total,
      status: 'Confirmed',
      bookingDate: 'Today, 8:00 AM',
    );
    myBookings.insert(0, booking);
    AppSnackBar.success(message: 'Ride booked successfully!');
  }

  void approvePendingRequest(String requestId) {
    final index = pendingRequests.indexWhere(
      (p) => p.id == requestId || p.bookingId == requestId,
    );
    if (index != -1) {
      final req = pendingRequests[index];
      pendingRequests.removeAt(index);
      final booking = BookingModel(
        id: req.id,
        bookingId: req.bookingId,
        ride: req.ride,
        bookedSeats: req.requestedSeats,
        totalPrice: req.totalPrice,
        status: 'Confirmed',
        bookingDate: 'Today, 8:00 AM',
      );
      myBookings.insert(0, booking);
      AppSnackBar.success(
        message: 'Driver accepted! Your booking is confirmed.',
      );
    }
  }

  void simulateDriverApproval() {
    if (currentSelectedRide.value != null) {
      final ride = currentSelectedRide.value!;
      final booking = BookingModel(
        id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
        bookingId: 'bk_${DateTime.now().millisecondsSinceEpoch}',
        ride: ride,
        bookedSeats: 2,
        totalPrice: ride.pricePerSeat * 2,
        status: 'Confirmed',
        bookingDate: 'Today, 8:00 AM',
      );
      myBookings.insert(0, booking);
    }
  }

  void cancelPendingRequest(dynamic req) {
    PassengerPendingRequestModel? model;
    String id;
    if (req is PassengerPendingRequestModel) {
      model = req;
      id = req.bookingId.isNotEmpty ? req.bookingId : req.id;
    } else {
      id = req.toString();
      model = pendingRequests.firstWhereOrNull((p) => p.id == id || p.bookingId == id);
    }
    if (model != null) {
      pendingRequests.remove(model);
      TripService.instance.cancelTripBooking(
        bookingId: model.bookingId.isNotEmpty ? model.bookingId : model.id,
        tripId: model.ride.id,
        seats: model.requestedSeats,
        wasAccepted: false,
      );
    }
    AppSnackBar.info(message: 'Request cancelled.');
  }

  void cancelBooking(dynamic booking) {
    BookingModel? model;
    String id;
    if (booking is BookingModel) {
      model = booking;
      id = booking.bookingId.isNotEmpty ? booking.bookingId : booking.id;
    } else {
      id = booking.toString();
      model = myBookings.firstWhereOrNull((b) => b.id == id || b.bookingId == id);
    }
    if (model != null) {
      myBookings.remove(model);
      TripService.instance.cancelTripBooking(
        bookingId: model.bookingId.isNotEmpty ? model.bookingId : model.id,
        tripId: model.ride.id,
        seats: model.bookedSeats,
        wasAccepted: true,
      );
    }
    AppSnackBar.info(message: 'Ride booking cancelled.');
  }

  void rateTrip(CompletedTripModel trip, double rating, String comment) {
    trip.rating.value = rating;
    trip.reviewComment.value = comment;
    trip.isRated.value = true;
    AppSnackBar.success(message: 'Thank you for rating your ride with ${trip.driverName}!');
  }

  void rateDriver({
    required String tripId,
    required double rating,
    String comment = '',
  }) {
    final tripIndex = completedTrips.indexWhere((t) => t.id == tripId);
    if (tripIndex != -1) {
      final trip = completedTrips[tripIndex];
      trip.rating.value = rating;
      trip.reviewComment.value = comment;
      trip.isRated.value = true;
      AppSnackBar.success(
        message: 'Review submitted. Thank you for rating ${trip.driverName}!',
      );
    }
  }

  @override
  void onClose() {
    _availableTripsSubscription?.cancel();
    _passengerBookingsSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }
}
