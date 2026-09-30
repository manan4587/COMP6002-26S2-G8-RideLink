import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/data/models/driver/driver_models.dart';
import 'package:ridelink/data/models/firestore/trip_model.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/community_service.dart';
import 'package:ridelink/data/services/trip_service.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_home_controller.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_profile_controller.dart';

class DriverTripsController extends GetxController {
  // Trips published by driver
  final RxList<DriverTripModel> myTrips = <DriverTripModel>[].obs;

  // Selected Trip for Viewing Passenger Requests
  final Rx<DriverTripModel?> selectedTripForRequests =
      Rx<DriverTripModel?>(null);
  Rx<DriverTripModel?> get currentSelectedTripForRequests =>
      selectedTripForRequests;

  // Selected Request for Viewing Details
  final Rx<PassengerRequestModel?> selectedRequest =
      Rx<PassengerRequestModel?>(null);

  // Status Filter for Trips Tab
  final RxString selectedTripFilter = 'All'.obs;

  // Live Trip Observables
  final Rx<DriverTripModel?> liveTrip = Rx<DriverTripModel?>(null);
  final Rx<PassengerRequestModel?> livePassenger =
      Rx<PassengerRequestModel?>(null);

  // Available communities from database
  final RxList<String> availableCommunitiesForDriver = <String>[
    'Curtin Community',
    'Monash Clayton Carpool',
    'Perth CBD Professionals',
    'Fiona Stanley Shift Workers',
    'ECU Joondalup Campus Carpool',
    'Fremantle & Coastal Route',
  ].obs;

  // Global pending requests list
  final RxList<PassengerRequestModel> pendingRequests =
      <PassengerRequestModel>[].obs;

  int get totalTripRequestsCount {
    int count = pendingRequests.length;
    for (final t in myTrips) {
      count += t.requests.length;
    }
    return count;
  }

  List<DriverTripModel> get filteredTrips {
    if (selectedTripFilter.value == 'All') {
      return myTrips;
    }
    return myTrips
        .where((t) =>
            t.status.value.toLowerCase() ==
            selectedTripFilter.value.toLowerCase())
        .toList();
  }

  // Publish Trip Form Controllers & Observables
  final TextEditingController publishFromController = TextEditingController();
  final TextEditingController publishToController = TextEditingController();
  final TextEditingController departureTimeController =
      TextEditingController(text: '08:00 AM');

  final RxDouble publishFromLat = (-31.8156).obs;
  final RxDouble publishFromLng = (115.8452).obs;
  final RxDouble publishToLat = (-32.0044).obs;
  final RxDouble publishToLng = (115.8947).obs;

  final RxDouble publishPrice = 7.50.obs;
  final RxInt publishSeats = 3.obs;
  final RxBool allowLuggage = true.obs;
  final RxBool allowPets = false.obs;
  final RxString departureDate = 'Tomorrow, Oct 6'.obs;
  final RxString selectedCommunityForPublish = 'Curtin Community'.obs;

  StreamSubscription? _driverTripsSubscription;
  StreamSubscription? _communitiesSubscription;
  final Map<String, StreamSubscription> _tripBookingsSubscriptions = {};
  StreamSubscription? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    final user = AuthService.instance.currentUser;
    if (user != null) {
      subscribeToDriverTrips(user.uid);
    }

    _authSubscription = AuthService.instance.authStateChanges.listen((u) {
      if (u != null) {
        subscribeToDriverTrips(u.uid);
      } else {
        clearState();
      }
    });

    _communitiesSubscription =
        CommunityService.instance.streamCommunities().listen((comms) {
      if (comms.isNotEmpty) {
        final names = comms.map((c) => c.name).toList();
        availableCommunitiesForDriver.assignAll(names);
        if (!names.contains(selectedCommunityForPublish.value)) {
          selectedCommunityForPublish.value = names.first;
        }
      }
    });
  }

  void clearState() {
    _driverTripsSubscription?.cancel();
    for (final sub in _tripBookingsSubscriptions.values) {
      sub.cancel();
    }
    _tripBookingsSubscriptions.clear();
    myTrips.clear();
    pendingRequests.clear();
    selectedTripForRequests.value = null;
    selectedRequest.value = null;
    liveTrip.value = null;
    livePassenger.value = null;
    publishFromController.clear();
    publishToController.clear();
  }

  void subscribeToDriverTrips(String uid) {
    _driverTripsSubscription?.cancel();
    _driverTripsSubscription =
        TripService.instance.streamDriverTrips(uid).listen((trips) {
      if (trips.isEmpty) return;

      for (final trip in trips) {
        final existing = myTrips.firstWhereOrNull((t) => t.id == trip.id);
        if (existing != null) {
          existing.status.value =
              trip.status == 'scheduled' ? 'Scheduled' : trip.status;
          existing.bookedSeats.value = trip.bookedSeats;
          existing.totalSeats.value = trip.totalSeats;
        } else {
          final newTripModel = DriverTripModel(
            id: trip.id,
            from: trip.originName.isNotEmpty
                ? trip.originName
                : trip.originAddress,
            to: trip.destinationName.isNotEmpty
                ? trip.destinationName
                : trip.destinationAddress,
            fromLat: trip.originLat,
            fromLng: trip.originLng,
            toLat: trip.destinationLat,
            toLng: trip.destinationLng,
            time: trip.departureTimeString,
            pricePerSeat: trip.pricePerSeat,
            totalSeats: trip.totalSeats,
            bookedSeats: trip.bookedSeats,
            status: trip.status == 'scheduled' ? 'Scheduled' : trip.status,
          );
          myTrips.insert(0, newTripModel);
          _listenToBookingsForTrip(newTripModel);
        }
      }
    });
  }

  void _listenToBookingsForTrip(DriverTripModel trip) {
    _tripBookingsSubscriptions[trip.id]?.cancel();
    _tripBookingsSubscriptions[trip.id] =
        TripService.instance.streamTripBookings(trip.id).listen((bookings) {
      for (final booking in bookings) {
        final existingReq =
            trip.requests.firstWhereOrNull((r) => r.id == booking.id);
        final statusCapital = booking.status == 'accepted'
            ? 'Accepted'
            : booking.status == 'declined'
                ? 'Declined'
                : 'Pending';

        if (existingReq != null) {
          existingReq.status.value = statusCapital;
        } else if (booking.status == 'pending') {
          final req = PassengerRequestModel(
            id: booking.id,
            tripId: trip.id,
            passengerId: booking.passengerId,
            passengerName: booking.passengerName,
            rating: booking.passengerRating,
            from: booking.pickupAddress,
            to: booking.dropAddress,
            seats: booking.requestedSeats,
            fare: booking.fare,
            time: trip.time.value,
            travellingWith: booking.requestedSeats > 1
                ? '+${booking.requestedSeats - 1} passenger'
                : 'Solo',
            emergencyContactPhone: booking.passengerPhone,
            status: statusCapital,
          );
          trip.requests.add(req);
        }
      }
    });
  }

  void publishNewTrip() {
    bool isVerified = true;
    String dName = 'Driver';
    String dPhone = '+61 412 345 678';
    String vModel = 'Toyota Camry';
    String vPlate = '1ABC234';
    String vColor = 'Silver';

    if (Get.isRegistered<DriverProfileController>()) {
      final p = Get.find<DriverProfileController>();
      isVerified = p.isVerifiedByAdmin.value;
      dName = p.driverName.value;
      dPhone = p.driverPhone.value;
      if (p.vehicleModel.value.isNotEmpty) vModel = p.vehicleModel.value;
      if (p.vehicleNumber.value.isNotEmpty) vPlate = p.vehicleNumber.value;
      vColor = p.vehicleColor.value;
    }

    if (!isVerified) {
      AppSnackBar.error(
        message:
            "You cannot create a new ride until your documents are verified by admin.",
      );
      return;
    }

    final from = publishFromController.text.trim();
    final to = publishToController.text.trim();

    if (from.isEmpty || to.isEmpty) {
      AppSnackBar.warning(
        message: 'Please enter pickup and drop-off locations.',
      );
      return;
    }

    final tripId = 'dt_${DateTime.now().millisecondsSinceEpoch}';
    final user = AuthService.instance.currentUser;
    final driverUid = user?.uid ?? 'driver_demo';

    final newTrip = DriverTripModel(
      id: tripId,
      from: from,
      to: to,
      fromLat: publishFromLat.value,
      fromLng: publishFromLng.value,
      toLat: publishToLat.value,
      toLng: publishToLng.value,
      time: '${departureTimeController.text} (${departureDate.value})',
      pricePerSeat: publishPrice.value,
      totalSeats: publishSeats.value,
      bookedSeats: 0,
      status: 'Scheduled',
    );

    myTrips.insert(0, newTrip);
    _listenToBookingsForTrip(newTrip);

    final driverProfileCtrl = Get.isRegistered<DriverProfileController>()
        ? Get.find<DriverProfileController>()
        : null;
    final dRating = driverProfileCtrl?.driverRating.value ?? 0.0;
    final dTotalRides = driverProfileCtrl?.driverTripsCount.value ?? 0;

    // Save to Firestore in background
    TripService.instance.createTrip(
      TripModel(
        id: tripId,
        driverId: driverUid,
        driverName: dName,
        driverPhone: dPhone,
        driverRating: dRating,
        driverTotalRides: dTotalRides,
        carModel: vModel,
        carPlate: vPlate,
        carColor: vColor,
        originName: from,
        originAddress: from,
        originLat: publishFromLat.value,
        originLng: publishFromLng.value,
        destinationName: to,
        destinationAddress: to,
        destinationLat: publishToLat.value,
        destinationLng: publishToLng.value,
        departureTime: DateTime.now().add(const Duration(hours: 12)),
        departureTimeString:
            '${departureTimeController.text} (${departureDate.value})',
        totalSeats: publishSeats.value,
        availableSeats: publishSeats.value,
        bookedSeats: 0,
        pricePerSeat: publishPrice.value,
        communityName: selectedCommunityForPublish.value,
        status: 'scheduled',
        allowLuggage: allowLuggage.value,
        allowPets: allowPets.value,
        createdAt: DateTime.now(),
      ),
    );

    publishFromController.clear();
    publishToController.clear();

    AppSnackBar.success(message: 'Your trip has been published successfully!');
    if (Get.currentRoute == AppRoutes.driverPublishRide) {
      Get.back();
    }
    openTripRequests(newTrip);
  }

  void acceptRideRequest(DriverTripModel trip, PassengerRequestModel req) {
    if (trip.bookedSeats.value + req.seats > trip.totalSeats.value) {
      AppSnackBar.error(
        message: 'Cannot accept request. Not enough seats remaining in this vehicle.',
      );
      return;
    }

    req.status.value = 'Accepted';
    trip.requests.remove(req);
    trip.acceptedPassengers.add(req);
    trip.bookedSeats.value += req.seats;

    if (Get.isRegistered<DriverHomeController>()) {
      Get.find<DriverHomeController>().todayEarnings.value += req.fare;
    }

    TripService.instance.acceptTripBooking(
      bookingId: req.id,
      tripId: trip.id,
      seats: req.seats,
    );

    AppSnackBar.success(
      message: 'Accepted ${req.passengerName}! Seats booked: ${trip.bookedSeats.value}/${trip.totalSeats.value}',
    );
  }

  void declineRideRequest(DriverTripModel trip, PassengerRequestModel req) {
    req.status.value = 'Declined';
    trip.requests.remove(req);

    TripService.instance.declineTripBooking(req.id);
    AppSnackBar.info(message: 'Declined request for ${req.passengerName}.');
  }

  void acceptRequest(PassengerRequestModel req) {
    pendingRequests.remove(req);
    if (Get.isRegistered<DriverHomeController>()) {
      Get.find<DriverHomeController>().todayEarnings.value += req.fare;
    }
    AppSnackBar.success(message: 'Accepted booking request for ${req.passengerName}!');
  }

  void declineRequest(PassengerRequestModel req) {
    pendingRequests.remove(req);
    AppSnackBar.info(message: 'Declined request for ${req.passengerName}.');
  }

  void selectCommunityForPublish(String communityName) {
    selectedCommunityForPublish.value = communityName;
  }

  void swapPickupAndDrop() {
    final tempText = publishFromController.text;
    publishFromController.text = publishToController.text;
    publishToController.text = tempText;

    final tempLat = publishFromLat.value;
    final tempLng = publishFromLng.value;
    publishFromLat.value = publishToLat.value;
    publishFromLng.value = publishToLng.value;
    publishToLat.value = tempLat;
    publishToLng.value = tempLng;
  }

  void openTripRequests(DriverTripModel trip) {
    selectedTripForRequests.value = trip;
    Get.toNamed(AppRoutes.driverRideRequests);
  }

  void openAllTripRequests() {
    selectedTripForRequests.value = null;
    Get.toNamed(AppRoutes.driverRideRequests);
  }

  void openRequestDetails(DriverTripModel trip, PassengerRequestModel request) {
    selectedTripForRequests.value = trip;
    selectedRequest.value = request;
    Get.toNamed(AppRoutes.driverRequestDetails);
  }

  void openLiveTrip(DriverTripModel trip) {
    liveTrip.value = trip;
    Get.toNamed(AppRoutes.driverLiveTrip, arguments: trip);
  }

  void toggleTripStatus(DriverTripModel trip) {
    if (trip.status.value == 'Scheduled') {
      trip.status.value = 'In Progress';
      TripService.instance.updateTripStatus(trip.id, 'in_progress');
      liveTrip.value = trip;
      Get.toNamed(AppRoutes.driverLiveTrip, arguments: trip);
    } else if (trip.status.value == 'In Progress' || trip.status.value == 'Active') {
      trip.status.value = 'Completed';
      TripService.instance.updateTripStatus(trip.id, 'completed');
      if (Get.isRegistered<DriverHomeController>()) {
        Get.find<DriverHomeController>().completedTripsCount.value++;
      }
      AppSnackBar.success(message: 'Trip marked as completed!');
    }
  }

  void openDriverChat({PassengerRequestModel? passenger, String? route}) {
    if (passenger != null) {
      AppSnackBar.info(
        message: 'Opening chat with ${passenger.passengerName}...',
      );
    } else {
      AppSnackBar.info(message: 'Opening passenger chat...');
    }
  }

  void submitPassengerRating({
    required String passengerId,
    required String passengerName,
    required double rating,
    String? comment,
    DriverTripModel? trip,
  }) {
    if (trip != null) {
      trip.status.value = 'Completed';
      TripService.instance.updateTripStatus(trip.id, 'completed');
    }
    if (Get.isRegistered<DriverHomeController>()) {
      Get.find<DriverHomeController>().completedTripsCount.value++;
    }
    AppSnackBar.success(
      message: 'Rating of ${rating.toStringAsFixed(1)}★ submitted for $passengerName. Thank you!',
    );
  }

  void confirmCancelTrip(BuildContext context, DriverTripModel trip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Trip'),
        content: Text('Are you sure you want to cancel the trip from ${trip.from} to ${trip.to}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Back'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              trip.status.value = 'Cancelled';
              TripService.instance.updateTripStatus(trip.id, 'cancelled');
              AppSnackBar.info(message: 'Trip has been cancelled.');
            },
            child: const Text('Cancel Trip', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void showEditTripDialog(BuildContext context, DriverTripModel trip) {
    final priceController = TextEditingController(
        text: trip.pricePerSeat.value.toStringAsFixed(2));
    final seatsController =
        TextEditingController(text: trip.totalSeats.value.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Trip Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price Per Seat (\$)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: seatsController,
              decoration: const InputDecoration(labelText: 'Total Seats'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPrice = double.tryParse(priceController.text.trim()) ??
                  trip.pricePerSeat.value;
              final newSeats = int.tryParse(seatsController.text.trim()) ??
                  trip.totalSeats.value;
              trip.pricePerSeat.value = newPrice;
              trip.totalSeats.value = newSeats;
              Navigator.pop(ctx);
              AppSnackBar.success(message: 'Trip details updated successfully!');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void updateTripStatus(DriverTripModel trip, String newStatus) {
    trip.status.value = newStatus;
    TripService.instance.updateTripStatus(trip.id, newStatus.toLowerCase());
    AppSnackBar.info(message: 'Trip status updated to $newStatus');
  }

  @override
  void onClose() {
    _driverTripsSubscription?.cancel();
    _communitiesSubscription?.cancel();
    for (final s in _tripBookingsSubscriptions.values) {
      s.cancel();
    }
    _tripBookingsSubscriptions.clear();
    _authSubscription?.cancel();
    publishFromController.dispose();
    publishToController.dispose();
    departureTimeController.dispose();
    super.onClose();
  }
}

