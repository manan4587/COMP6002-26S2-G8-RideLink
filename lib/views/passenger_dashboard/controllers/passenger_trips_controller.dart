import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/data/models/firestore/trip_model.dart';
import 'package:ridelink/data/models/passenger/passenger_models.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/trip_service.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/views/passenger_dashboard/controllers/passenger_profile_controller.dart';
import 'package:ridelink/views/passenger_dashboard/controllers/passenger_search_controller.dart';

class PassengerTripsController extends GetxController {
  // Pending Booking Requests
  final RxList<PassengerPendingRequestModel> pendingRequests =
      <PassengerPendingRequestModel>[].obs;

  // Confirmed / Upcoming Bookings
  final RxList<BookingModel> myBookings = <BookingModel>[].obs;

  // Loading state for bookings
  final RxBool isLoadingBookings = true.obs;

  // Completed Trips History
  final RxList<CompletedTripModel> completedTrips = <CompletedTripModel>[].obs;

  // Selected Ride for Details View
  final Rx<RideModel?> selectedRide = Rx<RideModel?>(null);
  final Rx<RideModel?> currentSelectedRide = Rx<RideModel?>(null);

  // Trips tab selection (0: Confirmed/Upcoming, 1: Pending, 2: Completed)
  final RxInt selectedTripsTab = 0.obs;

  // Search filter query for trips tab
  final RxString searchQuery = ''.obs;

  // Track the most recent booking made by passenger
  final RxString lastCreatedBookingId = ''.obs;

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
    isLoadingBookings.value = true;
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

  Future<void> reloadTrips() async {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      subscribeToTripsAndBookings(user.uid);
    }
  }

  void subscribeToTripsAndBookings(String uid) {
    _availableTripsSubscription?.cancel();
    _availableTripsSubscription = TripService.instance
        .streamAvailableTrips()
        .listen(
          (trips) {
            if (trips.isEmpty) {
              if (Get.isRegistered<PassengerSearchController>()) {
                Get.find<PassengerSearchController>().availableRides.clear();
              }
              return;
            }

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
                origin: t.originName.isNotEmpty
                    ? t.originName
                    : t.originAddress,
                destination: t.destinationName.isNotEmpty
                    ? t.destinationName
                    : t.destinationAddress,
                originLat: t.originLat,
                originLng: t.originLng,
                destinationLat: t.destinationLat,
                destinationLng: t.destinationLng,
                departureTime: t.departureTimeString.isNotEmpty
                    ? t.departureTimeString
                    : '08:00 AM',
                estimatedDuration: '28 mins',
                pricePerSeat: t.pricePerSeat,
                seatsAvailable: t.availableSeats,
                matchPercentage: 96,
                detourMinutes: 4,
                pickupSuggestion: t.originName,
                dropOffPlan: '${t.originName} → ${t.destinationName}',
                departureDateTime: t.departureTime,
              );
            }).toList();

            if (Get.isRegistered<PassengerSearchController>()) {
              final searchCtrl = Get.find<PassengerSearchController>();
              searchCtrl.availableRides.assignAll(mapped);
            }
          },
          onError: (err) {
            debugPrint(
              '[PassengerTripsController] Available trips stream error: $err',
            );
          },
        );

    _passengerBookingsSubscription?.cancel();
    _passengerBookingsSubscription = TripService.instance
        .streamPassengerBookings(uid)
        .listen(
          (bookings) async {
            try {
              final remoteBookingIds = bookings.map((b) => b.id).toSet();
              pendingRequests.removeWhere(
                (p) =>
                    !remoteBookingIds.contains(p.id) &&
                    !remoteBookingIds.contains(p.bookingId),
              );
              myBookings.removeWhere(
                (b) =>
                    !remoteBookingIds.contains(b.id) &&
                    !remoteBookingIds.contains(b.bookingId),
              );

              for (final b in bookings) {
                RideModel? ride;
                if (Get.isRegistered<PassengerSearchController>()) {
                  ride = Get.find<PassengerSearchController>().availableRides
                      .firstWhereOrNull((r) => r.id == b.tripId);
                }

                TripModel? tripDoc;
                // Always query genuine TripModel from Firestore if coordinates are missing or uninitialized
                if (ride == null ||
                    (ride.originLat == 0.0 && ride.originLng == 0.0)) {
                  tripDoc = await TripService.instance.getTrip(b.tripId);
                  if (tripDoc != null) {
                    ride = RideModel(
                      id: tripDoc.id,
                      driverId: tripDoc.driverId,
                      driverName: tripDoc.driverName,
                      driverAvatar: '',
                      driverPhone: tripDoc.driverPhone,
                      rating: tripDoc.driverRating,
                      totalRides: tripDoc.driverTotalRides,
                      carModel: tripDoc.carModel,
                      carPlate: tripDoc.carPlate,
                      origin: tripDoc.originName.isNotEmpty
                          ? tripDoc.originName
                          : tripDoc.originAddress,
                      destination: tripDoc.destinationName.isNotEmpty
                          ? tripDoc.destinationName
                          : tripDoc.destinationAddress,
                      originLat: tripDoc.originLat,
                      originLng: tripDoc.originLng,
                      destinationLat: tripDoc.destinationLat,
                      destinationLng: tripDoc.destinationLng,
                      currentDriverLat: tripDoc.currentDriverLat,
                      currentDriverLng: tripDoc.currentDriverLng,
                      currentDriverHeading: tripDoc.currentDriverHeading,
                      currentDriverSpeed: tripDoc.currentDriverSpeed,
                      departureTime: tripDoc.departureTimeString.isNotEmpty
                          ? tripDoc.departureTimeString
                          : 'Today',
                      estimatedDuration: '30 mins',
                      pricePerSeat: tripDoc.pricePerSeat > 0
                          ? tripDoc.pricePerSeat
                          : (b.fare /
                                (b.requestedSeats > 0 ? b.requestedSeats : 1)),
                      seatsAvailable: tripDoc.availableSeats,
                      pickupSuggestion: b.pickupAddress.isNotEmpty
                          ? b.pickupAddress
                          : tripDoc.originName,
                      dropOffPlan: b.dropAddress.isNotEmpty
                          ? b.dropAddress
                          : tripDoc.destinationName,
                      searchedPickupAddress: b.pickupAddress,
                      searchedDropAddress: b.dropAddress,
                    );
                  }
                }

                ride ??= RideModel(
                  id: b.tripId,
                  driverId: b.driverId,
                  driverName: 'Driver',
                  driverAvatar: '',
                  rating: 5.0,
                  totalRides: 0,
                  carModel: 'Vehicle',
                  carPlate: 'Plate',
                  origin: b.pickupAddress,
                  destination: b.dropAddress,
                  originLat: b.pickupLat,
                  originLng: b.pickupLng,
                  destinationLat: b.dropLat,
                  destinationLng: b.dropLng,
                  departureTime: 'Today',
                  estimatedDuration: '30 mins',
                  pricePerSeat:
                      b.fare / (b.requestedSeats > 0 ? b.requestedSeats : 1),
                  seatsAvailable: 2,
                  pickupSuggestion: b.pickupAddress,
                  dropOffPlan: b.dropAddress,
                  searchedPickupAddress: b.pickupAddress,
                  searchedDropAddress: b.dropAddress,
                );

                if (tripDoc == null &&
                    b.status != 'completed' &&
                    b.passengerStatus != 'dropped_off' &&
                    b.tripId.isNotEmpty) {
                  tripDoc = await TripService.instance.getTrip(b.tripId);
                }

                final bool isTripCompleted = (tripDoc != null &&
                    tripDoc.status.toLowerCase().trim() == 'completed');
                final bool isBookingCompleted =
                    (b.status == 'completed' ||
                        b.passengerStatus == 'dropped_off' ||
                        isTripCompleted);

                if (isBookingCompleted) {
                  pendingRequests.removeWhere(
                    (p) =>
                        p.bookingId == b.id ||
                        p.id == b.id ||
                        p.ride.id == b.tripId,
                  );
                  myBookings.removeWhere(
                    (p) =>
                        p.bookingId == b.id ||
                        p.id == b.id ||
                        p.ride.id == b.tripId,
                  );

                  final existingCompleted = completedTrips.firstWhereOrNull(
                    (c) => c.id == b.id || c.id == b.tripId,
                  );
                  if (existingCompleted == null) {
                    completedTrips.insert(
                      0,
                      CompletedTripModel(
                        id: b.tripId.isNotEmpty ? b.tripId : b.id,
                        bookingId: b.id,
                        driverId: b.driverId.isNotEmpty ? b.driverId : ride.driverId,
                        driverName: ride.driverName,
                        carModel: ride.carModel,
                        carPlate: ride.carPlate,
                        route: '${ride.origin} → ${ride.destination}',
                        date: 'Today • Dropped Off',
                        fare: '\$${b.fare.toStringAsFixed(2)} AUD',
                        isRated: b.isPassengerRated,
                        rating: b.passengerRatingToDriver ?? 5.0,
                        reviewComment: b.passengerReviewToDriver ?? '',
                      ),
                    );
                  } else {
                    if (b.isPassengerRated) {
                      existingCompleted.isRated.value = true;
                      if (b.passengerRatingToDriver != null) {
                        existingCompleted.rating.value =
                            b.passengerRatingToDriver!;
                      }
                      if (b.passengerReviewToDriver != null) {
                        existingCompleted.reviewComment.value =
                            b.passengerReviewToDriver!;
                      }
                    }
                  }
                } else if (b.status == 'accepted') {
                  pendingRequests.removeWhere(
                    (p) =>
                        p.bookingId == b.id ||
                        p.id == b.id ||
                        p.ride.id == b.tripId,
                  );
                  final existing = myBookings.firstWhereOrNull(
                    (x) => x.bookingId == b.id || x.id == b.id,
                  );
                  if (existing == null) {
                    myBookings.insert(
                      0,
                      BookingModel(
                        id: b.id,
                        bookingId: b.id,
                        ride: ride,
                        bookedSeats: b.requestedSeats,
                        totalPrice: b.fare,
                        status: b.passengerStatus.toLowerCase() == 'onboard'
                            ? 'Onboard'
                            : 'Confirmed',
                        bookingDate: b.passengerStatus.toLowerCase() == 'onboard'
                            ? 'Onboard with Driver'
                            : 'Confirmed by Driver',
                        pickupOtp: b.pickupOtp.isNotEmpty
                            ? b.pickupOtp
                            : (Preferences.rideOtp.isNotEmpty
                                ? Preferences.rideOtp
                                : (AuthService.instance.currentUser?.uid != null &&
                                        AuthService.instance.currentUser!.uid.isNotEmpty
                                    ? (AuthService.instance.currentUser!.uid.hashCode.abs() %
                                                9000 +
                                            1000)
                                        .toString()
                                    : '4829')),
                        passengerStatus: b.passengerStatus,
                      ),
                    );
                  } else {
                    final idx = myBookings.indexOf(existing);
                    myBookings[idx] = BookingModel(
                      id: existing.id,
                      bookingId: existing.bookingId,
                      ride: ride,
                      bookedSeats: existing.bookedSeats,
                      totalPrice: existing.totalPrice,
                      status: b.passengerStatus.toLowerCase() == 'onboard'
                          ? 'Onboard'
                          : existing.status,
                      bookingDate: b.passengerStatus.toLowerCase() == 'onboard'
                          ? 'Onboard with Driver'
                          : existing.bookingDate,
                      pickupOtp: b.pickupOtp.isNotEmpty
                          ? b.pickupOtp
                          : existing.pickupOtp,
                      passengerStatus: b.passengerStatus,
                    );
                  }
                  if (lastCreatedBookingId.value == b.id &&
                      Get.currentRoute == AppRoutes.requestSent) {
                    Get.offNamed(AppRoutes.requestApproved);
                    AppSnackBar.success(
                      message:
                          'Your ride request was approved by the driver! 🎉',
                    );
                  }
                } else if (b.status == 'pending') {
                  final existingReq = pendingRequests.firstWhereOrNull(
                    (p) => p.bookingId == b.id || p.id == b.id,
                  );
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
                  } else {
                    final idx = pendingRequests.indexOf(existingReq);
                    pendingRequests[idx] = PassengerPendingRequestModel(
                      id: existingReq.id,
                      bookingId: existingReq.bookingId,
                      ride: ride,
                      requestedSeats: existingReq.requestedSeats,
                      passengerLabel: existingReq.passengerLabel,
                      totalPrice: existingReq.totalPrice,
                      requestTime: existingReq.requestTime,
                      status: existingReq.status.value,
                    );
                  }
                } else if (b.status == 'declined' || b.status == 'cancelled') {
                  pendingRequests.removeWhere(
                    (p) => p.bookingId == b.id || p.id == b.id,
                  );
                  myBookings.removeWhere(
                    (p) => p.bookingId == b.id || p.id == b.id,
                  );
                }
              }
              pendingRequests.refresh();
              myBookings.refresh();
              completedTrips.refresh();
            } finally {
              isLoadingBookings.value = false;
            }
          },
          onError: (err) {
            debugPrint(
              '[PassengerTripsController] Bookings stream error: $err',
            );
            isLoadingBookings.value = false;
          },
        );
  }

  void openRideDetails(RideModel ride) {
    selectedRide.value = ride;
    currentSelectedRide.value = ride;
    Get.toNamed(AppRoutes.rideDetails);
  }

  void selectRideForDetails(RideModel ride) {
    openRideDetails(ride);
  }

  void requestToJoinRide(RideModel ride, {int? seats, String? notes}) {
    final user = AuthService.instance.currentUser;
    final passengerUid = user?.uid ?? 'passenger_demo';

    if (passengerUid.isNotEmpty && ride.driverId == passengerUid) {
      AppSnackBar.info(
        message: "You can't request a ride on your own published trip.",
      );
      return;
    }

    final int seatCount = seats ?? 1;
    currentSelectedRide.value = ride;
    if (Get.isRegistered<PassengerSearchController>()) {
      Get.find<PassengerSearchController>().requestedSeats.value = seatCount;
    }
    final bookingId = 'bk_${DateTime.now().millisecondsSinceEpoch}';
    final pName = Preferences.userName.isNotEmpty
        ? Preferences.userName
        : (user?.displayName ?? 'Passenger');
    final pPhone = Preferences.userPhone;

    final double effectivePricePerSeat = ride.enRouteSubFare ?? ride.pricePerSeat;
    final double totalFare = effectivePricePerSeat * seatCount;

    final pickupAddr = ride.searchedPickupAddress.isNotEmpty
        ? ride.searchedPickupAddress
        : ride.origin;
    final dropAddr = ride.searchedDropAddress.isNotEmpty
        ? ride.searchedDropAddress
        : ride.destination;

    final pLat = ride.searchedPickupLat != 0.0 ? ride.searchedPickupLat : ride.originLat;
    final pLng = ride.searchedPickupLng != 0.0 ? ride.searchedPickupLng : ride.originLng;
    final dLat = ride.searchedDropLat != 0.0 ? ride.searchedDropLat : ride.destinationLat;
    final dLng = ride.searchedDropLng != 0.0 ? ride.searchedDropLng : ride.destinationLng;

    final newReq = PassengerPendingRequestModel(
      id: bookingId,
      bookingId: bookingId,
      ride: ride,
      requestedSeats: seatCount,
      passengerLabel: seatCount > 1 ? '$pName + ${seatCount - 1}' : pName,
      totalPrice: totalFare,
      requestTime: 'Just now',
    );
    lastCreatedBookingId.value = bookingId;
    pendingRequests.insert(0, newReq);

    TripService.instance.requestTripBooking(
      TripBookingModel(
        id: bookingId,
        tripId: ride.id,
        driverId: ride.driverId,
        passengerId: passengerUid,
        passengerName: pName,
        passengerPhone: pPhone,
        passengerRating: (Get.isRegistered<PassengerProfileController>() &&
                Get.find<PassengerProfileController>().passengerRating.value > 0)
            ? Get.find<PassengerProfileController>().passengerRating.value
            : 5.0,
        requestedSeats: seatCount,
        fare: totalFare,
        pickupAddress: pickupAddr,
        dropAddress: dropAddr,
        pickupLat: pLat,
        pickupLng: pLng,
        dropLat: dLat,
        dropLng: dLng,
        passengerStatus: 'to_pickup',
        pickupOtp: Preferences.rideOtp.isNotEmpty
            ? Preferences.rideOtp
            : (passengerUid.isNotEmpty
                ? (passengerUid.hashCode.abs() % 9000 + 1000).toString()
                : '4829'),
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    );

    if (Get.currentRoute == AppRoutes.rideDetails) {
      Get.offNamed(AppRoutes.requestSent);
    } else if (Get.currentRoute != AppRoutes.requestSent) {
      Get.toNamed(AppRoutes.requestSent);
    }
  }

  void bookRide(RideModel ride, int seats) {
    requestToJoinRide(ride, seats: seats);
  }

  void cancelPendingRequest(
    dynamic req, {
    String reason = 'Cancelled by passenger',
  }) {
    PassengerPendingRequestModel? model;
    String id;
    if (req is PassengerPendingRequestModel) {
      model = req;
      id = req.bookingId.isNotEmpty ? req.bookingId : req.id;
    } else {
      id = req.toString();
      model = pendingRequests.firstWhereOrNull(
        (p) => p.id == id || p.bookingId == id,
      );
    }
    if (model != null) {
      pendingRequests.remove(model);
      final user = AuthService.instance.currentUser;
      final pName = Preferences.userName.isNotEmpty
          ? Preferences.userName
          : (user?.displayName ?? 'Passenger');
      TripService.instance.cancelTripBooking(
        bookingId: model.bookingId.isNotEmpty ? model.bookingId : model.id,
        tripId: model.ride.id,
        driverId: model.ride.driverId,
        passengerName: pName,
        seats: model.requestedSeats,
        wasAccepted: false,
        reason: reason,
      );
    }
    AppSnackBar.info(message: 'Ride request cancelled.');
  }

  void cancelBooking(
    dynamic booking, {
    String reason = 'Cancelled by passenger',
  }) {
    BookingModel? model;
    String id;
    if (booking is BookingModel) {
      model = booking;
      id = booking.bookingId.isNotEmpty ? booking.bookingId : booking.id;
    } else {
      id = booking.toString();
      model = myBookings.firstWhereOrNull(
        (b) => b.id == id || b.bookingId == id,
      );
    }
    if (model != null) {
      if (model.isOnboard) {
        AppSnackBar.warning(
          message: 'You have already onboarded this ride and cannot cancel.',
        );
        return;
      }
      myBookings.remove(model);
      final user = AuthService.instance.currentUser;
      final pName = Preferences.userName.isNotEmpty
          ? Preferences.userName
          : (user?.displayName ?? 'Passenger');
      TripService.instance.cancelTripBooking(
        bookingId: model.bookingId.isNotEmpty ? model.bookingId : model.id,
        tripId: model.ride.id,
        driverId: model.ride.driverId,
        passengerName: pName,
        seats: model.bookedSeats,
        wasAccepted: true,
        reason: reason,
      );
    }
    AppSnackBar.info(
      message: 'Ride booking cancelled. The driver has been notified.',
    );
  }

  void rateTrip(CompletedTripModel trip, double rating, String comment) {
    trip.rating.value = rating;
    trip.reviewComment.value = comment;
    trip.isRated.value = true;

    TripService.instance.submitPassengerRatingToDriver(
      tripId: trip.id,
      driverId: trip.driverId,
      bookingId: trip.bookingId,
      rating: rating,
      comment: comment,
    );

    AppSnackBar.success(
      message: 'Thank you for rating your ride with ${trip.driverName}!',
    );
  }

  void rateDriver({
    required String tripId,
    required double rating,
    String comment = '',
    String driverId = '',
    String? bookingId,
  }) {
    final tripIndex = completedTrips.indexWhere(
      (t) =>
          t.id == tripId ||
          t.id.contains(tripId) ||
          (bookingId != null && bookingId.isNotEmpty && t.bookingId == bookingId),
    );
    if (tripIndex != -1) {
      final trip = completedTrips[tripIndex];
      trip.rating.value = rating;
      trip.reviewComment.value = comment;
      trip.isRated.value = true;
    }

    TripService.instance.submitPassengerRatingToDriver(
      tripId: tripId,
      driverId: driverId,
      rating: rating,
      comment: comment,
      bookingId: bookingId,
    );

    AppSnackBar.success(
      message: 'Review submitted. Thank you for rating!',
    );
  }

  @override
  void onClose() {
    _availableTripsSubscription?.cancel();
    _passengerBookingsSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }
}
