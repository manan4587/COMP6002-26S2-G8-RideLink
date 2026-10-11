import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/data/models/firestore/firestore_collections.dart';
import 'package:ridelink/data/models/firestore/trip_model.dart';
import 'package:ridelink/data/models/firestore/user_profile_model.dart';
import 'package:ridelink/data/models/passenger/passenger_models.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/community_service.dart';
import 'package:ridelink/data/services/device_location_service.dart';
import 'package:ridelink/data/services/google_places_service.dart';
import 'package:ridelink/data/services/trip_service.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_controller.dart';
import 'package:ridelink/widgets/google_places_search_field.dart';

class DriverTripsController extends GetxController {
  // Trips published by driver
  final RxList<DriverTripModel> myTrips = <DriverTripModel>[].obs;

  // Selected Trip for Viewing Passenger Requests
  final Rx<DriverTripModel?> selectedTripForRequests = Rx<DriverTripModel?>(
    null,
  );
  Rx<DriverTripModel?> get currentSelectedTripForRequests =>
      selectedTripForRequests;

  // Selected Request for Viewing Details
  final Rx<PassengerRequestModel?> selectedRequest = Rx<PassengerRequestModel?>(
    null,
  );

  // Status Filter for Trips Tab
  final RxString selectedTripFilter = 'All'.obs;

  // Live Trip Observables
  final Rx<DriverTripModel?> liveTrip = Rx<DriverTripModel?>(null);
  final Rx<PassengerRequestModel?> livePassenger = Rx<PassengerRequestModel?>(
    null,
  );

  // Available communities from database
  final RxList<String> availableCommunitiesForDriver = <String>[].obs;
  final RxList<CommunityModel> availableCommunityModels = <CommunityModel>[].obs;

  // Global pending requests list
  final RxList<PassengerRequestModel> pendingRequests =
      <PassengerRequestModel>[].obs;

  int get totalTripRequestsCount {
    final Set<String> ids = {};
    for (final r in pendingRequests) {
      if (r.status.value.toLowerCase() == 'pending') {
        ids.add(r.id);
      }
    }
    for (final t in myTrips) {
      final s = t.status.value.toLowerCase().trim();
      if (s != 'completed' && s != 'cancelled') {
        for (final r in t.requests) {
          if (r.status.value.toLowerCase() == 'pending') {
            ids.add(r.id);
          }
        }
      }
    }
    return ids.length;
  }

  List<DriverTripModel> get filteredTrips {
    if (selectedTripFilter.value == 'All') {
      return myTrips;
    }
    return myTrips
        .where(
          (t) =>
              t.status.value.toLowerCase() ==
              selectedTripFilter.value.toLowerCase(),
        )
        .toList();
  }

  // Publish Trip Form Controllers & Observables
  final TextEditingController publishFromController = TextEditingController();
  final TextEditingController publishToController = TextEditingController();
  final TextEditingController departureTimeController = TextEditingController(
    text: '08:00 AM',
  );

  final RxDouble publishFromLat = (0.0).obs;
  final RxDouble publishFromLng = (0.0).obs;
  final RxDouble publishToLat = (0.0).obs;
  final RxDouble publishToLng = (0.0).obs;

  final RxDouble publishPrice = 7.50.obs;
  final TextEditingController priceInputController = TextEditingController(
    text: '7.50',
  );
  final RxInt publishSeats = 3.obs;
  final RxBool allowLuggage = true.obs;
  final RxBool allowPets = false.obs;
  final RxString departureDate = 'Tomorrow'.obs;
  final RxString selectedCommunityForPublish = ''.obs;
  final RxBool isPublishingTrip = false.obs;

  // Schedule mode: single specific date vs recurring day-wise
  final RxBool isRecurringRide = false.obs;
  final Rx<DateTime> selectedRideDate = DateTime.now()
      .add(const Duration(days: 1))
      .obs;
  final Rx<TimeOfDay> selectedRideTime = const TimeOfDay(
    hour: 8,
    minute: 0,
  ).obs;
  final RxList<String> recurringDays = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
  ].obs;

  static const List<String> availableWeekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  String get formattedRideTime {
    final time = selectedRideTime.value;
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  String get formattedRideDate {
    final date = selectedRideDate.value;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) {
      return 'Today (${DateFormat('d MMM').format(date)})';
    } else if (diff == 1) {
      return 'Tomorrow (${DateFormat('d MMM').format(date)})';
    }
    return DateFormat('EEE, d MMM yyyy').format(date);
  }

  String get formattedScheduleSummary {
    if (isRecurringRide.value) {
      if (recurringDays.length == 7) {
        return 'Every day at $formattedRideTime';
      }
      if (recurringDays.length == 5 &&
          !recurringDays.contains('Sat') &&
          !recurringDays.contains('Sun')) {
        return 'Every weekday (Mon-Fri) at $formattedRideTime';
      }
      if (recurringDays.length == 2 &&
          recurringDays.contains('Sat') &&
          recurringDays.contains('Sun')) {
        return 'Every weekend (Sat-Sun) at $formattedRideTime';
      }
      return 'Repeats ${recurringDays.join(', ')} at $formattedRideTime';
    } else {
      return '$formattedRideDate at $formattedRideTime';
    }
  }

  Future<void> pickRideDate(BuildContext context) async {
    final now = DateTime.now();
    final initial = selectedRideDate.value.isBefore(now)
        ? now
        : selectedRideDate.value;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select Ride Date',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedRideDate.value = picked;
      departureDate.value = formattedRideDate;
    }
  }

  Future<void> pickRideTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedRideTime.value,
      helpText: 'Select Start / Departure Time',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final now = DateTime.now();
      final isToday =
          selectedRideDate.value.year == now.year &&
          selectedRideDate.value.month == now.month &&
          selectedRideDate.value.day == now.day;
      if (isToday) {
        final pickedMinutes = picked.hour * 60 + picked.minute;
        final currentMinutes = now.hour * 60 + now.minute;
        if (pickedMinutes < currentMinutes) {
          AppSnackBar.error(
            message:
                'Cannot select a time in the past. Please choose an upcoming departure time.',
          );
          return;
        }
      }
      selectedRideTime.value = picked;
      departureTimeController.text = formattedRideTime;
    }
  }

  void toggleRecurringDay(String day) {
    if (recurringDays.contains(day)) {
      if (recurringDays.length > 1) {
        recurringDays.remove(day);
      } else {
        AppSnackBar.warning(
          message: 'Please keep at least one day selected for recurring rides.',
        );
      }
    } else {
      recurringDays.add(day);
      recurringDays.sort(
        (a, b) => availableWeekDays
            .indexOf(a)
            .compareTo(availableWeekDays.indexOf(b)),
      );
    }
  }

  void selectRecurringPreset(String preset) {
    if (preset == 'weekdays') {
      recurringDays.assignAll(['Mon', 'Tue', 'Wed', 'Thu', 'Fri']);
    } else if (preset == 'all') {
      recurringDays.assignAll(availableWeekDays);
    } else if (preset == 'weekend') {
      recurringDays.assignAll(['Sat', 'Sun']);
    }
  }

  void setPrice(double price) {
    if (price < 0) return;
    publishPrice.value = double.parse(price.toStringAsFixed(2));
    final formatted = publishPrice.value % 1 == 0
        ? publishPrice.value.toInt().toString()
        : publishPrice.value.toStringAsFixed(2);
    if (priceInputController.text != formatted) {
      priceInputController.text = formatted;
    }
  }

  void incrementPrice([double step = 1.0]) {
    final next = (publishPrice.value + step).clamp(1.0, 500.0);
    setPrice(next);
  }

  void decrementPrice([double step = 1.0]) {
    final next = (publishPrice.value - step).clamp(1.0, 500.0);
    setPrice(next);
  }

  void updatePriceFromInput(String value) {
    final clean = value.replaceAll(RegExp(r'[^0-9.]'), '');
    final parsed = double.tryParse(clean);
    if (parsed != null && parsed >= 0) {
      publishPrice.value = parsed;
    }
  }

  double get estimatedMaxEarnings => publishPrice.value * publishSeats.value;

  StreamSubscription? _driverTripsSubscription;
  StreamSubscription? _driverBookingsSubscription;
  StreamSubscription? _communitiesSubscription;
  final Map<String, StreamSubscription> _tripBookingsSubscriptions = {};
  StreamSubscription? _authSubscription;
  StreamSubscription<UserProfileModel?>? _passengerProfileSub;
  String? _currentSyncedPassengerId;

  @override
  void onInit() {
    super.onInit();
    final user = AuthService.instance.currentUser;
    if (user != null) {
      subscribeToDriverTrips(user.uid);
      _listenToCommunities();
    }

    _authSubscription = AuthService.instance.authStateChanges.listen((u) {
      if (u != null) {
        subscribeToDriverTrips(u.uid);
        _listenToCommunities();
      } else {
        clearState();
      }
    });
  }

  void _listenToCommunities() {
    _communitiesSubscription?.cancel();
    _communitiesSubscription = CommunityService.instance
        .streamCommunities()
        .listen(
          (comms) {
            availableCommunityModels.assignAll(comms);
            final names = comms.map((c) => c.name).toList();
            availableCommunitiesForDriver.assignAll(names);
            // Only clear if a community was selected but is no longer in the list
            if (selectedCommunityForPublish.value.isNotEmpty &&
                !names.contains(selectedCommunityForPublish.value)) {
              selectedCommunityForPublish.value = '';
            } else if (selectedCommunityForPublish.value.isNotEmpty) {
              _applyCommunityFixedLocations();
            }
          },
          onError: (err) {
            debugPrint(
              '[DriverTripsController] Communities stream error: $err',
            );
          },
        );
  }

  Future<void> reloadDriverTrips() async {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      subscribeToDriverTrips(user.uid);
      _listenToCommunities();
    }
  }

  void clearState() {
    _communitiesSubscription?.cancel();
    _communitiesSubscription = null;
    _passengerProfileSub?.cancel();
    _passengerProfileSub = null;
    _currentSyncedPassengerId = null;
    _driverTripsSubscription?.cancel();
    _driverBookingsSubscription?.cancel();
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
    publishFromLat.value = 0.0;
    publishFromLng.value = 0.0;
    publishToLat.value = 0.0;
    publishToLng.value = 0.0;
  }

  void subscribeToDriverTrips(String uid) {
    _driverTripsSubscription?.cancel();
    _driverTripsSubscription = TripService.instance
        .streamDriverTrips(uid)
        .listen(
          (trips) {
            final remoteTripIds = trips.map((t) => t.id).toSet();
            myTrips.removeWhere((t) => !remoteTripIds.contains(t.id));

            for (final trip in trips) {
              final s = trip.status.toLowerCase().trim();
              final normalizedStatus = (s == 'in_progress' || s == 'active')
                  ? 'Active'
                  : (s == 'completed')
                  ? 'Completed'
                  : (s == 'cancelled')
                  ? 'Cancelled'
                  : 'Scheduled';

              final existing = myTrips.firstWhereOrNull((t) => t.id == trip.id);
              if (existing != null) {
                existing.status.value = normalizedStatus;
                existing.bookedSeats.value = trip.bookedSeats;
                existing.totalSeats.value = trip.totalSeats;
                existing.pricePerSeat.value = trip.pricePerSeat;
                existing.time.value = trip.departureTimeString;
                existing.from = trip.originName.isNotEmpty
                    ? trip.originName
                    : trip.originAddress;
                existing.to = trip.destinationName.isNotEmpty
                    ? trip.destinationName
                    : trip.destinationAddress;
                existing.fromLat = trip.originLat;
                existing.fromLng = trip.originLng;
                existing.toLat = trip.destinationLat;
                existing.toLng = trip.destinationLng;
                existing.departureDateTime = trip.departureTime;
                if (trip.currentDriverLat != 0.0) {
                  existing.currentDriverLat.value = trip.currentDriverLat;
                  existing.currentDriverLng.value = trip.currentDriverLng;
                }
                existing.isDriverRated.value = trip.isDriverRated;
                if (trip.driverRatingToPassenger != null) {
                  existing.driverRatingGiven.value =
                      trip.driverRatingToPassenger!;
                }
                _listenToBookingsForTrip(existing);
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
                  currentDriverLat: trip.currentDriverLat,
                  currentDriverLng: trip.currentDriverLng,
                  time: trip.departureTimeString,
                  pricePerSeat: trip.pricePerSeat,
                  totalSeats: trip.totalSeats,
                  bookedSeats: trip.bookedSeats,
                  status: normalizedStatus,
                  isRecurring: trip.isRecurring,
                  recurringDays: trip.recurringDays,
                  communityName: trip.communityName,
                  departureDateTime: trip.departureTime,
                  isDriverRated: trip.isDriverRated,
                  driverRatingGiven: trip.driverRatingToPassenger ?? 5.0,
                );
                myTrips.add(newTripModel);
                _listenToBookingsForTrip(newTripModel);
              }
            }

            myTrips.refresh();

            final completedCount = trips
                .where((t) => t.status.toLowerCase().trim() == 'completed')
                .length;
            if (Get.isRegistered<DriverProfileController>()) {
              final p = Get.find<DriverProfileController>();
              p.driverTripsCount.value = completedCount;
            }
            if (Get.isRegistered<DriverHomeController>()) {
              final h = Get.find<DriverHomeController>();
              h.completedTripsCount.value = completedCount;
            }
          },
          onError: (err) {
            debugPrint(
              '[DriverTripsController] Driver trips stream error: $err',
            );
          },
        );

    // Also stream all incoming bookings for this driver directly
    _driverBookingsSubscription?.cancel();
    _driverBookingsSubscription = TripService.instance
        .streamDriverBookings(uid)
        .listen(
          (bookings) {
            final remoteBookingIds = bookings.map((b) => b.id).toSet();
            pendingRequests.removeWhere(
              (r) => !remoteBookingIds.contains(r.id),
            );

            for (final booking in bookings) {
              _syncBookingToDriverState(booking);
            }
            pendingRequests.refresh();
            myTrips.refresh();
          },
          onError: (err) {
            debugPrint(
              '[DriverTripsController] Driver bookings stream error: $err',
            );
          },
        );
  }

  void _syncBookingToDriverState(TripBookingModel booking) {
    final statusCapital = booking.status == 'accepted'
        ? 'Accepted'
        : booking.status == 'declined'
        ? 'Declined'
        : booking.status == 'cancelled'
        ? 'Cancelled'
        : (booking.status == 'completed' ? 'Completed' : 'Pending');

    // 1. Sync to the specific trip if present in myTrips
    final trip = myTrips.firstWhereOrNull((t) => t.id == booking.tripId);
    if (trip != null) {
      final existingReq = trip.requests.firstWhereOrNull(
        (r) => r.id == booking.id,
      );
      final existingAccepted = trip.acceptedPassengers.firstWhereOrNull(
        (r) => r.id == booking.id,
      );

      if (statusCapital == 'Accepted' || statusCapital == 'Completed') {
        if (existingReq != null) {
          existingReq.status.value = statusCapital;
          if (booking.passengerRating > 0) {
            existingReq.rating.value = booking.passengerRating;
          }
          if (statusCapital == 'Completed') {
            existingReq.passengerStatus.value = 'dropped_off';
          }
          existingReq.isRated.value = booking.isDriverRated;
          if (booking.driverRatingToPassenger != null) {
            existingReq.passengerRatingGiven.value =
                booking.driverRatingToPassenger!;
          }
          trip.requests.remove(existingReq);
          if (existingAccepted == null) {
            trip.acceptedPassengers.add(existingReq);
          }
        } else if (existingAccepted == null) {
          final req = _createPassengerRequestFromBooking(
            booking,
            trip.time.value,
          );
          if (statusCapital == 'Completed') {
            req.passengerStatus.value = 'dropped_off';
          }
          trip.acceptedPassengers.add(req);
        } else {
          existingAccepted.passengerStatus.value =
              (statusCapital == 'Completed' ||
                  booking.passengerStatus == 'dropped_off')
              ? 'dropped_off'
              : booking.passengerStatus;
          existingAccepted.isRated.value = booking.isDriverRated;
          if (booking.passengerRating > 0) {
            existingAccepted.rating.value = booking.passengerRating;
          }
          if (booking.driverRatingToPassenger != null) {
            existingAccepted.passengerRatingGiven.value =
                booking.driverRatingToPassenger!;
          }
        }
        if (booking.isDriverRated) {
          trip.isDriverRated.value = true;
          if (booking.driverRatingToPassenger != null) {
            trip.driverRatingGiven.value = booking.driverRatingToPassenger!;
          }
        }
      } else if (statusCapital == 'Declined' || statusCapital == 'Cancelled') {
        if (existingReq != null) {
          trip.requests.remove(existingReq);
        }
        if (existingAccepted != null) {
          trip.acceptedPassengers.remove(existingAccepted);
        }
      } else if (statusCapital == 'Pending') {
        if (existingReq != null) {
          existingReq.status.value = 'Pending';
          if (booking.passengerRating > 0) {
            existingReq.rating.value = booking.passengerRating;
          }
        } else {
          final req = _createPassengerRequestFromBooking(
            booking,
            trip.time.value,
          );
          trip.requests.add(req);
        }
      }
    }

    // 2. Sync to global pendingRequests list
    final existingGlobal = pendingRequests.firstWhereOrNull(
      (r) => r.id == booking.id,
    );
    if (statusCapital == 'Pending') {
      if (existingGlobal == null) {
        final req = _createPassengerRequestFromBooking(booking, 'Upcoming');
        pendingRequests.insert(0, req);
      } else {
        if (booking.passengerRating > 0) {
          existingGlobal.rating.value = booking.passengerRating;
        }
      }
    } else {
      if (existingGlobal != null) {
        pendingRequests.remove(existingGlobal);
      }
    }
  }

  PassengerRequestModel _createPassengerRequestFromBooking(
    TripBookingModel booking,
    String time,
  ) {
    final statusCapital = booking.status == 'accepted'
        ? 'Accepted'
        : booking.status == 'declined'
        ? 'Declined'
        : booking.status == 'cancelled'
        ? 'Cancelled'
        : (booking.status == 'completed' ? 'Completed' : 'Pending');

    final req = PassengerRequestModel(
      id: booking.id,
      tripId: booking.tripId,
      passengerId: booking.passengerId,
      passengerName: booking.passengerName,
      rating: booking.passengerRating > 0 ? booking.passengerRating : 5.0,
      from: booking.pickupAddress,
      to: booking.dropAddress,
      pickupLat: booking.pickupLat,
      pickupLng: booking.pickupLng,
      dropLat: booking.dropLat,
      dropLng: booking.dropLng,
      passengerStatus: booking.passengerStatus,
      seats: booking.requestedSeats,
      fare: booking.fare,
      time: time,
      travellingWith: booking.requestedSeats > 1
          ? '+${booking.requestedSeats - 1} passenger'
          : 'Solo',
      emergencyContactPhone: booking.passengerPhone,
      pickupOtp: booking.pickupOtp.isNotEmpty ? booking.pickupOtp : '1234',
      status: statusCapital,
      isRated: booking.isDriverRated,
      passengerRatingGiven: booking.driverRatingToPassenger ?? 5.0,
    );

    if (booking.passengerId.isNotEmpty) {
      AuthService.instance
          .getUserProfile(booking.passengerId)
          .then((prof) {
            if (prof != null) {
              req.rating.value = prof.rating > 0 ? prof.rating : 5.0;
              req.pastTrips.value = prof.tripsCompleted;
            }
          })
          .catchError((_) {});
    }

    return req;
  }

  void _listenToBookingsForTrip(DriverTripModel trip) {
    if (_tripBookingsSubscriptions.containsKey(trip.id)) return;
    _tripBookingsSubscriptions[trip.id] = TripService.instance
        .streamTripBookings(trip.id)
        .listen(
          (bookings) {
            final remoteBookingIds = bookings.map((b) => b.id).toSet();
            trip.requests.removeWhere((r) => !remoteBookingIds.contains(r.id));
            trip.acceptedPassengers.removeWhere(
              (p) => !remoteBookingIds.contains(p.id),
            );
            pendingRequests.removeWhere(
              (r) => r.tripId == trip.id && !remoteBookingIds.contains(r.id),
            );

            for (final booking in bookings) {
              _syncBookingToDriverState(booking);
            }
            pendingRequests.refresh();
            myTrips.refresh();
          },
          onError: (err) {
            debugPrint(
              '[DriverTripsController] Trip bookings stream error for ${trip.id}: $err',
            );
          },
        );
  }

  Future<void> publishNewTrip() async {
    if (isPublishingTrip.value) return;
    isPublishingTrip.value = true;
    try {
      // 1. Role check: Only registered drivers are allowed to publish rides
      if (Preferences.userRole != 'driver') {
        AppSnackBar.error(
          message: 'Only registered drivers are allowed to publish rides.',
        );
        return;
      }

      bool isVerified = false;
      String dName = Preferences.userName.isNotEmpty
          ? Preferences.userName
          : 'Driver';
      String dPhone = Preferences.userPhone.isNotEmpty
          ? Preferences.userPhone
          : '+61 412 345 678';
      String vModel = Preferences.vehicleModel.isNotEmpty
          ? Preferences.vehicleModel
          : 'Toyota Camry';
      String vPlate = Preferences.vehicleNumber.isNotEmpty
          ? Preferences.vehicleNumber
          : '1ABC234';
      String vColor = Preferences.vehicleColor.isNotEmpty
          ? Preferences.vehicleColor
          : 'Silver';

      if (Get.isRegistered<DriverProfileController>()) {
        final p = Get.find<DriverProfileController>();
        isVerified = p.isVerifiedByAdmin.value;
        if (p.driverName.value.isNotEmpty && p.driverName.value != 'N/A') {
          dName = p.driverName.value;
        }
        if (p.driverPhone.value.isNotEmpty && p.driverPhone.value != 'N/A') {
          dPhone = p.driverPhone.value;
        }
        if (p.vehicleModel.value.isNotEmpty && p.vehicleModel.value != 'N/A') {
          vModel = p.vehicleModel.value;
        }
        if (p.vehicleNumber.value.isNotEmpty &&
            p.vehicleNumber.value != 'N/A') {
          vPlate = p.vehicleNumber.value;
        }
        if (p.vehicleColor.value.isNotEmpty && p.vehicleColor.value != 'N/A') {
          vColor = p.vehicleColor.value;
        }
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

      // Geocode locations if coordinates are unselected or invalid
      if (!GooglePlacesService.instance.isValidCoordinate(
        LatLng(publishFromLat.value, publishFromLng.value),
      )) {
        final geo = await GooglePlacesService.instance.getCoordinatesForAddress(
          from,
        );
        if (geo != null &&
            GooglePlacesService.instance.isValidCoordinate(
              LatLng(geo.latitude, geo.longitude),
            )) {
          publishFromLat.value = geo.latitude;
          publishFromLng.value = geo.longitude;
        }
      }
      if (!GooglePlacesService.instance.isValidCoordinate(
        LatLng(publishToLat.value, publishToLng.value),
      )) {
        final geo = await GooglePlacesService.instance.getCoordinatesForAddress(
          to,
        );
        if (geo != null &&
            GooglePlacesService.instance.isValidCoordinate(
              LatLng(geo.latitude, geo.longitude),
            )) {
          publishToLat.value = geo.latitude;
          publishToLng.value = geo.longitude;
        }
      }

      if (isRecurringRide.value && recurringDays.isEmpty) {
        AppSnackBar.warning(
          message:
              'Please select at least one recurring day for your ride schedule.',
        );
        return;
      }

      final formattedTime = formattedRideTime;
      final formattedDate = formattedRideDate;
      final depTimeString = isRecurringRide.value
          ? '$formattedTime • ${recurringDays.join(', ')}'
          : '$formattedTime ($formattedDate)';

      DateTime departureDateTime;
      if (!isRecurringRide.value) {
        final d = selectedRideDate.value;
        final t = selectedRideTime.value;
        departureDateTime = DateTime(d.year, d.month, d.day, t.hour, t.minute);
        if (departureDateTime.isBefore(DateTime.now())) {
          AppSnackBar.warning(
            message:
                'Departure time cannot be in the past. Please select an upcoming departure time.',
          );
          return;
        }
      } else {
        final now = DateTime.now();
        final t = selectedRideTime.value;
        final dayMap = {
          'Mon': DateTime.monday,
          'Tue': DateTime.tuesday,
          'Wed': DateTime.wednesday,
          'Thu': DateTime.thursday,
          'Fri': DateTime.friday,
          'Sat': DateTime.saturday,
          'Sun': DateTime.sunday,
        };
        final targetWeekdayNums = recurringDays
            .map((d) => dayMap[d])
            .whereType<int>()
            .toSet();

        DateTime? nextTarget;
        for (int i = 0; i <= 7; i++) {
          final candidate = now.add(Duration(days: i));
          if (targetWeekdayNums.contains(candidate.weekday)) {
            final candidateTime = DateTime(
              candidate.year,
              candidate.month,
              candidate.day,
              t.hour,
              t.minute,
            );
            if (candidateTime.isAfter(now)) {
              nextTarget = candidateTime;
              break;
            }
          }
        }
        departureDateTime = nextTarget ?? now.add(const Duration(hours: 12));
      }

      final tripId = 'dt_${DateTime.now().millisecondsSinceEpoch}';
      final user = AuthService.instance.currentUser;
      final driverUid = user?.uid ?? 'driver_demo';

      // Check live device coordinates for driver (never default to pickup/from location)
      double initialDriverLat = 0.0;
      double initialDriverLng = 0.0;
      if (Get.isRegistered<DriverDashboardController>()) {
        final dashCtrl = Get.find<DriverDashboardController>();
        if (dashCtrl.driverCurrentLat.value != 0.0 &&
            dashCtrl.driverCurrentLng.value != 0.0) {
          initialDriverLat = dashCtrl.driverCurrentLat.value;
          initialDriverLng = dashCtrl.driverCurrentLng.value;
        }
      }
      if (initialDriverLat == 0.0) {
        final devLoc = await DeviceLocationService.instance
            .getCurrentDeviceLocation();
        if (devLoc != null) {
          initialDriverLat = devLoc.latitude;
          initialDriverLng = devLoc.longitude;
        }
      }

      final newTrip = DriverTripModel(
        id: tripId,
        from: from,
        to: to,
        fromLat: publishFromLat.value,
        fromLng: publishFromLng.value,
        toLat: publishToLat.value,
        toLng: publishToLng.value,
        currentDriverLat: initialDriverLat,
        currentDriverLng: initialDriverLng,
        time: depTimeString,
        pricePerSeat: publishPrice.value,
        totalSeats: publishSeats.value,
        bookedSeats: 0,
        status: 'Scheduled',
        isRecurring: isRecurringRide.value,
        recurringDays: isRecurringRide.value
            ? recurringDays.toList()
            : const [],
        communityName: selectedCommunityForPublish.value,
        departureDateTime: departureDateTime,
      );

      myTrips.insert(0, newTrip);
      _listenToBookingsForTrip(newTrip);

      final driverProfileCtrl = Get.isRegistered<DriverProfileController>()
          ? Get.find<DriverProfileController>()
          : null;
      final dRating =
          (driverProfileCtrl?.driverRating.value != null &&
              driverProfileCtrl!.driverRating.value > 0)
          ? driverProfileCtrl.driverRating.value
          : 5.0;
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
          currentDriverLat: initialDriverLat,
          currentDriverLng: initialDriverLng,
          departureTime: departureDateTime,
          departureTimeString: depTimeString,
          totalSeats: publishSeats.value,
          availableSeats: publishSeats.value,
          bookedSeats: 0,
          pricePerSeat: publishPrice.value,
          communityName: selectedCommunityForPublish.value,
          status: 'scheduled',
          allowLuggage: allowLuggage.value,
          allowPets: allowPets.value,
          isRecurring: isRecurringRide.value,
          recurringDays: isRecurringRide.value
              ? recurringDays.toList()
              : const [],
          createdAt: DateTime.now(),
        ),
      );

      publishFromController.clear();
      publishToController.clear();
      publishFromLat.value = 0.0;
      publishFromLng.value = 0.0;
      publishToLat.value = 0.0;
      publishToLng.value = 0.0;

      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      if (Get.isRegistered<DriverDashboardController>()) {
        Get.find<DriverDashboardController>().switchTab(1);
      }

      if (Get.currentRoute == AppRoutes.driverPublishRide) {
        Get.back();
      } else if (Get.key.currentState?.canPop() == true) {
        Get.back();
      } else {
        Get.offAllNamed(AppRoutes.driverDashboard);
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        AppSnackBar.success(
          message: 'Your ride has been published successfully!',
        );
      });
    } finally {
      isPublishingTrip.value = false;
    }
  }

  void acceptRideRequest(DriverTripModel trip, PassengerRequestModel req) {
    if (trip.bookedSeats.value + req.seats > trip.totalSeats.value) {
      AppSnackBar.error(
        message:
            'Cannot accept request. Not enough seats remaining in this vehicle.',
      );
      return;
    }

    req.status.value = 'Accepted';
    trip.requests.remove(req);
    pendingRequests.removeWhere((r) => r.id == req.id);
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
      message:
          'Accepted ${req.passengerName}! Seats booked: ${trip.bookedSeats.value}/${trip.totalSeats.value}',
    );
  }

  void declineRideRequest(DriverTripModel trip, PassengerRequestModel req) {
    req.status.value = 'Declined';
    trip.requests.remove(req);
    pendingRequests.removeWhere((r) => r.id == req.id);

    TripService.instance.declineTripBooking(req.id);
    AppSnackBar.info(message: 'Declined request for ${req.passengerName}.');
  }

  void acceptRequest(PassengerRequestModel req) {
    final trip = myTrips.firstWhereOrNull((t) => t.id == req.tripId);
    if (trip != null) {
      acceptRideRequest(trip, req);
      return;
    }

    pendingRequests.remove(req);
    req.status.value = 'Accepted';
    if (Get.isRegistered<DriverHomeController>()) {
      Get.find<DriverHomeController>().todayEarnings.value += req.fare;
    }
    TripService.instance.acceptTripBooking(
      bookingId: req.id,
      tripId: req.tripId ?? '',
      seats: req.seats,
    );
    AppSnackBar.success(
      message: 'Accepted booking request for ${req.passengerName}!',
    );
  }

  void declineRequest(PassengerRequestModel req) {
    final trip = myTrips.firstWhereOrNull((t) => t.id == req.tripId);
    if (trip != null) {
      declineRideRequest(trip, req);
      return;
    }

    pendingRequests.remove(req);
    req.status.value = 'Declined';
    TripService.instance.declineTripBooking(req.id);
    AppSnackBar.info(message: 'Declined request for ${req.passengerName}.');
  }

  CommunityModel? get selectedCommunityModel {
    if (selectedCommunityForPublish.value.isEmpty) return null;
    return availableCommunityModels.firstWhereOrNull(
      (c) =>
          c.name.toLowerCase().trim() ==
          selectedCommunityForPublish.value.toLowerCase().trim(),
    );
  }

  bool get isDropOffFixedByCommunity {
    final comm = selectedCommunityModel;
    if (comm == null) return false;
    return comm.isFixedDropOff ||
        comm.fixedLocationType == 'dropoff' ||
        comm.fixedLocationType == 'both' ||
        comm.dropOffLocation.trim().isNotEmpty ||
        (comm.fixedLocation.trim().isNotEmpty && comm.fixedLocationType != 'pickup');
  }

  String get communityFixedDropOffLocation {
    final comm = selectedCommunityModel;
    if (comm == null) return '';
    if (comm.dropOffLocation.trim().isNotEmpty) return comm.dropOffLocation.trim();
    if (comm.fixedLocation.trim().isNotEmpty && comm.fixedLocationType != 'pickup') {
      return comm.fixedLocation.trim();
    }
    if (comm.routeSummary.contains('→')) {
      final parts = comm.routeSummary.split('→');
      if (parts.length >= 2 && parts[1].trim().isNotEmpty) {
        return parts[1].trim();
      }
    } else if (comm.routeSummary.contains('⇄')) {
      final parts = comm.routeSummary.split('⇄');
      if (parts.length >= 2 && parts[1].trim().isNotEmpty) {
        return parts[1].trim();
      }
    }
    return '';
  }

  void selectCommunityForPublish(
    String communityName, {
    CommunityModel? communityModel,
  }) {
    selectedCommunityForPublish.value = communityName;
    if (communityModel != null) {
      final idx = availableCommunityModels.indexWhere(
        (c) =>
            c.name.toLowerCase().trim() ==
            communityModel.name.toLowerCase().trim(),
      );
      if (idx >= 0) {
        availableCommunityModels[idx] = communityModel;
      } else {
        availableCommunityModels.add(communityModel);
      }
      if (!availableCommunitiesForDriver.contains(communityModel.name)) {
        availableCommunitiesForDriver.add(communityModel.name);
      }
    }
    _applyCommunityFixedLocations();
  }

  void _applyCommunityFixedLocations() {
    final comm = selectedCommunityModel;
    if (comm == null) return;

    final fixedDrop = communityFixedDropOffLocation;
    if (fixedDrop.isNotEmpty) {
      publishToController.text = fixedDrop;
      if (comm.dropOffLat != 0.0 && comm.dropOffLng != 0.0) {
        publishToLat.value = comm.dropOffLat;
        publishToLng.value = comm.dropOffLng;
      } else {
        // Geocode fixed drop-off address to coordinates in background if lat/lng are 0.0
        GooglePlacesService.instance
            .getCoordinatesForAddress(fixedDrop)
            .then((geo) {
          if (geo != null &&
              GooglePlacesService.instance.isValidCoordinate(
                LatLng(geo.latitude, geo.longitude),
              )) {
            publishToLat.value = geo.latitude;
            publishToLng.value = geo.longitude;
          }
        });
      }
    }
  }

  void clearCommunityForPublish() {
    selectedCommunityForPublish.value = '';
  }

  final RxBool isFetchingCurrentLocation = false.obs;

  /// Fetch driver's live GPS coordinates and reverse geocode to pickup input
  Future<void> useCurrentLocationAsPickup({
    BuildContext? context,
    bool showFeedback = true,
  }) async {
    isFetchingCurrentLocation.value = true;
    try {
      final permResult = await DeviceLocationService.instance
          .checkAndRequestPermissionDetails();

      final sheetContext = context ?? Get.context;

      if (permResult == LocationCheckResult.deniedForever) {
        if (sheetContext != null && sheetContext.mounted) {
          DeviceLocationService.instance.showLocationBlockedSheet(sheetContext);
        } else if (showFeedback) {
          AppSnackBar.warning(
            message:
                'Location access is blocked. Please allow location permissions in device Settings.',
          );
        }
        return;
      }

      if (permResult == LocationCheckResult.serviceDisabled) {
        if (sheetContext != null && sheetContext.mounted) {
          DeviceLocationService.instance.showLocationServiceDisabledSheet(
            sheetContext,
          );
        } else if (showFeedback) {
          AppSnackBar.warning(
            message:
                'Device GPS is turned off. Please enable location in settings.',
          );
        }
        return;
      }

      if (permResult == LocationCheckResult.denied) {
        if (showFeedback) {
          AppSnackBar.warning(
            message:
                'Location permission was denied. Please allow location access to use Current GPS.',
          );
        }
        return;
      }

      final loc = await DeviceLocationService.instance.getCurrentDeviceLocation(
        forceFresh: true,
        timeout: const Duration(seconds: 8),
      );
      if (loc == null) {
        if (showFeedback) {
          AppSnackBar.warning(
            message:
                'Unable to detect GPS position. Please ensure GPS has a clear signal.',
          );
        }
        return;
      }

      publishFromLat.value = loc.latitude;
      publishFromLng.value = loc.longitude;

      // Reverse geocode to address
      final address = await GooglePlacesService.instance
          .getAddressFromCoordinates(loc.latitude, loc.longitude);

      if (address != null && address.isNotEmpty) {
        publishFromController.text = address;
      } else {
        publishFromController.text =
            'Current Location (${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)})';
      }

      if (showFeedback) {
        AppSnackBar.success(
          message: 'Pickup set to your current live location.',
        );
      }
    } catch (e) {
      if (showFeedback) {
        AppSnackBar.error(message: 'Failed to detect location: $e');
      }
    } finally {
      isFetchingCurrentLocation.value = false;
    }
  }

  void swapPickupAndDrop() {
    if (isDropOffFixedByCommunity) {
      AppSnackBar.info(
        message: 'Drop-off destination is fixed by the community corridor.',
      );
      return;
    }
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
    _currentSyncedPassengerId = null;
    syncPassengerLiveRating(request);
    Get.toNamed(AppRoutes.driverRequestDetails);
  }

  Future<void> syncPassengerLiveRating(PassengerRequestModel req) async {
    String pId = req.passengerId ?? '';
    if (pId.isEmpty && req.id.isNotEmpty) {
      try {
        final bSnap = await FirebaseFirestore.instance
            .collection(FirestoreCollections.bookings)
            .doc(req.id)
            .get();
        if (bSnap.exists && bSnap.data()?['passengerId'] is String) {
          pId = bSnap.data()!['passengerId'] as String;
        }
      } catch (_) {}
    }
    if (pId.isEmpty) return;

    if (_currentSyncedPassengerId == pId && _passengerProfileSub != null) {
      return;
    }
    _currentSyncedPassengerId = pId;

    try {
      final profile = await AuthService.instance.getUserProfile(pId);
      if (profile != null) {
        req.rating.value = profile.rating > 0 ? profile.rating : 5.0;
        req.pastTrips.value = profile.tripsCompleted;
      }
    } catch (_) {}

    _passengerProfileSub?.cancel();
    _passengerProfileSub = AuthService.instance.streamUserProfile(pId).listen((
      profile,
    ) {
      if (profile != null) {
        req.rating.value = profile.rating > 0 ? profile.rating : 5.0;
        req.pastTrips.value = profile.tripsCompleted;
      }
    });
  }

  void openLiveTrip(DriverTripModel trip) {
    liveTrip.value = trip;

    // Use cached location immediately if available
    LatLng? currentLoc = DeviceLocationService.instance.cachedPosition;
    if (currentLoc == null && Get.isRegistered<DriverDashboardController>()) {
      currentLoc =
          Get.find<DriverDashboardController>().currentDriverLocation.value;
    }

    if (currentLoc != null) {
      trip.currentDriverLat.value = currentLoc.latitude;
      trip.currentDriverLng.value = currentLoc.longitude;
      if (trip.id.isNotEmpty) {
        TripService.instance.updateDriverLocation(
          trip.id,
          currentLoc.latitude,
          currentLoc.longitude,
          heading: DeviceLocationService.instance.cachedHeading,
          force: true,
        );
      }
    } else {
      // Warm up in background asynchronously without blocking UI navigation
      DeviceLocationService.instance.getCurrentDeviceLocation().then((loc) {
        if (loc != null) {
          trip.currentDriverLat.value = loc.latitude;
          trip.currentDriverLng.value = loc.longitude;
          if (trip.id.isNotEmpty) {
            TripService.instance.updateDriverLocation(
              trip.id,
              loc.latitude,
              loc.longitude,
              heading: DeviceLocationService.instance.cachedHeading,
              force: true,
            );
          }
        }
      });
    }

    Get.toNamed(AppRoutes.driverLiveTrip, arguments: trip);
  }

  void toggleTripStatus(DriverTripModel trip) {
    final s = trip.status.value.toLowerCase().trim();
    if (s == 'completed' || s == 'cancelled') {
      return;
    }

    if (s == 'scheduled') {
      if (!trip.canStartRide) {
        AppSnackBar.warning(
          message:
              'Ride can only be started up to 15 minutes before the departure time (${trip.time.value}).',
        );
        return;
      }

      trip.status.value = 'Active';
      TripService.instance.updateTripStatus(trip.id, 'active');
      liveTrip.value = trip;

      LatLng? currentLoc = DeviceLocationService.instance.cachedPosition;
      if (currentLoc == null && Get.isRegistered<DriverDashboardController>()) {
        currentLoc =
            Get.find<DriverDashboardController>().currentDriverLocation.value;
      }

      if (currentLoc != null) {
        trip.currentDriverLat.value = currentLoc.latitude;
        trip.currentDriverLng.value = currentLoc.longitude;
        if (trip.id.isNotEmpty) {
          TripService.instance.updateDriverLocation(
            trip.id,
            currentLoc.latitude,
            currentLoc.longitude,
            heading: DeviceLocationService.instance.cachedHeading,
            force: true,
          );
        }
      } else {
        DeviceLocationService.instance.getCurrentDeviceLocation().then((loc) {
          if (loc != null) {
            trip.currentDriverLat.value = loc.latitude;
            trip.currentDriverLng.value = loc.longitude;
            if (trip.id.isNotEmpty) {
              TripService.instance.updateDriverLocation(
                trip.id,
                loc.latitude,
                loc.longitude,
                heading: DeviceLocationService.instance.cachedHeading,
                force: true,
              );
            }
          }
        });
      }

      Get.toNamed(AppRoutes.driverLiveTrip, arguments: trip);
    } else if (s == 'in progress' || s == 'active') {
      trip.status.value = 'Completed';
      final driverUid = AuthService.instance.currentUser?.uid ?? '';
      TripService.instance.completeEntireTrip(
        tripId: trip.id,
        driverId: driverUid,
      );
      liveTrip.value = null;
      livePassenger.value = null;
      myTrips.refresh();
      if (Get.isRegistered<DriverHomeController>()) {
        Get.find<DriverHomeController>().completedTripsCount.value++;
      }
      if (Get.isRegistered<DriverDashboardController>()) {
        Get.find<DriverDashboardController>().switchTab(0);
      }
      AppSnackBar.success(message: 'Trip completed successfully!');
      Get.offAllNamed(AppRoutes.driverDashboard);
    }
  }

  void openDriverChat({
    PassengerRequestModel? passenger,
    String? tripId,
    String? route,
  }) {
    final effectiveTripId =
        tripId ??
        passenger?.tripId ??
        liveTrip.value?.id ??
        selectedTripForRequests.value?.id ??
        '';

    final targetTrip =
        myTrips.firstWhereOrNull((t) => t.id == effectiveTripId) ??
        liveTrip.value;
    final tripStatus = targetTrip?.status.value.toLowerCase().trim() ?? '';
    final isTripStarted =
        tripStatus == 'active' ||
        tripStatus == 'started' ||
        tripStatus == 'in_progress';

    if (!isTripStarted) {
      AppSnackBar.info(
        message: 'Chat will be available once the ride has started.',
      );
      return;
    }

    if (passenger != null &&
        passenger.status.value.toLowerCase() != 'accepted') {
      AppSnackBar.info(
        message:
            'Chat will be available once the passenger request is accepted.',
      );
      return;
    }

    final effectiveRoute =
        route ??
        (liveTrip.value != null
            ? '${liveTrip.value!.from} → ${liveTrip.value!.to}'
            : (selectedTripForRequests.value != null
                  ? '${selectedTripForRequests.value!.from} → ${selectedTripForRequests.value!.to}'
                  : 'Trip Route'));

    Get.toNamed(
      AppRoutes.driverRideChat,
      arguments: {
        'tripId': effectiveTripId,
        'passengerName': passenger?.passengerName ?? 'Passenger',
        'route': effectiveRoute,
        'passengerPhone': passenger?.emergencyContactPhone ?? '',
      },
    );
  }

  /// Driver updates status for a passenger ('to_pickup' | 'arrived' | 'onboard' | 'dropped_off')
  Future<void> updatePassengerTripStatus({
    required PassengerRequestModel passenger,
    required String newStatus,
  }) async {
    passenger.passengerStatus.value = newStatus;
    if (passenger.id.isNotEmpty) {
      await TripService.instance.updateBookingPassengerStatus(
        bookingId: passenger.id,
        passengerStatus: newStatus,
      );
    }
  }

  /// Direct boarding confirmation without requiring RidePIN
  Future<void> confirmPassengerBoardingDirectly(
    PassengerRequestModel passenger,
  ) async {
    await updatePassengerTripStatus(passenger: passenger, newStatus: 'onboard');
  }

  /// Verify passenger's 4-digit pickup OTP and set status to onboard
  Future<bool> verifyPassengerPickupOtp({
    required PassengerRequestModel passenger,
    required String enteredOtp,
  }) async {
    final entered = enteredOtp.trim();
    final validOtp = passenger.pickupOtp.isNotEmpty
        ? passenger.pickupOtp.trim()
        : '1234';

    if (entered == validOtp) {
      await updatePassengerTripStatus(
        passenger: passenger,
        newStatus: 'onboard',
      );
      return true;
    }

    // Also check passenger's stored static profile PIN in Firestore
    final String pId =
        (passenger.passengerId != null && passenger.passengerId!.isNotEmpty)
        ? passenger.passengerId!
        : passenger.id;
    if (pId.isNotEmpty) {
      try {
        final profile = await AuthService.instance.getUserProfile(pId);
        if (profile != null &&
            profile.rideOtp.isNotEmpty &&
            entered == profile.rideOtp.trim()) {
          await updatePassengerTripStatus(
            passenger: passenger,
            newStatus: 'onboard',
          );
          return true;
        }
      } catch (_) {}
    }

    // Default fallback
    if (entered == '1234') {
      await updatePassengerTripStatus(
        passenger: passenger,
        newStatus: 'onboard',
      );
      return true;
    }

    return false;
  }

  Future<void> submitPassengerRating({
    required String passengerId,
    required String passengerName,
    required double rating,
    String? comment,
    DriverTripModel? trip,
    String? bookingId,
    double? fare,
    String paymentMethod = 'cash',
    bool isAlreadyCompleted = false,
  }) async {
    final user = AuthService.instance.currentUser;
    final driverUid = user?.uid ?? '';

    final cleanBookingId =
        bookingId ??
        (trip != null && trip.acceptedPassengers.isNotEmpty
            ? trip.acceptedPassengers.first.id
            : (trip != null && trip.requests.isNotEmpty
                  ? trip.requests.first.id
                  : ''));

    // 1. Update reactive state for passenger and trip
    if (trip != null) {
      trip.isDriverRated.value = true;
      trip.driverRatingGiven.value = rating;
      if (trip.id.isNotEmpty) {
        FirebaseFirestore.instance
            .collection(FirestoreCollections.rides)
            .doc(trip.id)
            .update({
              'isDriverRated': true,
              'driverRatingToPassenger': rating,
            })
            .catchError((e) {
              debugPrint('Error updating trip isDriverRated: $e');
            });
      }
      final targetPassenger = trip.acceptedPassengers.firstWhereOrNull(
        (p) => p.id == cleanBookingId || p.passengerId == passengerId,
      );
      if (targetPassenger != null) {
        targetPassenger.passengerStatus.value = 'dropped_off';
        targetPassenger.isRated.value = true;
        targetPassenger.passengerRatingGiven.value = rating;
      }
      final inRequests = trip.requests.firstWhereOrNull(
        (p) => p.id == cleanBookingId || p.passengerId == passengerId,
      );
      if (inRequests != null) {
        inRequests.passengerStatus.value = 'dropped_off';
        inRequests.isRated.value = true;
        inRequests.passengerRatingGiven.value = rating;
      }
    }

    if (selectedRequest.value != null &&
        (selectedRequest.value!.id == cleanBookingId ||
            selectedRequest.value!.passengerId == passengerId)) {
      selectedRequest.value!.passengerStatus.value = 'dropped_off';
      selectedRequest.value!.isRated.value = true;
      selectedRequest.value!.passengerRatingGiven.value = rating;
    }

    final inPending = pendingRequests.firstWhereOrNull(
      (p) => p.id == cleanBookingId || p.passengerId == passengerId,
    );
    if (inPending != null) {
      inPending.passengerStatus.value = 'dropped_off';
      inPending.isRated.value = true;
      inPending.passengerRatingGiven.value = rating;
    }

    pendingRequests.refresh();
    myTrips.refresh();

    // 2. Persist rating in database
    if (cleanBookingId.isNotEmpty || passengerId.isNotEmpty) {
      await TripService.instance.submitDriverRatingToPassenger(
        bookingId: cleanBookingId,
        passengerId: passengerId,
        rating: rating,
        comment: comment,
      );
    }

    // 3. If trip is in-progress, settle dropoff & credit driver earnings in database
    if (!isAlreadyCompleted && trip != null) {
      final targetFare =
          fare ??
          (trip.acceptedPassengers.isNotEmpty
              ? trip.acceptedPassengers.first.fare
              : trip.pricePerSeat.value);

      if (cleanBookingId.isNotEmpty && trip.id.isNotEmpty) {
        await TripService.instance.completePassengerDropoff(
          bookingId: cleanBookingId,
          tripId: trip.id,
          driverId: driverUid,
          passengerId: passengerId,
          passengerName: passengerName,
          fare: targetFare,
          paymentMethod: paymentMethod,
        );
      }

      // Check if all accepted passengers have been dropped off
      final bool allDroppedOff =
          trip.acceptedPassengers.isEmpty ||
          trip.acceptedPassengers.every((p) => p.isDroppedOff);

      if (allDroppedOff) {
        trip.status.value = 'Completed';
        await TripService.instance.completeEntireTrip(
          tripId: trip.id,
          driverId: driverUid,
        );
        if (Get.isRegistered<DriverHomeController>()) {
          Get.find<DriverHomeController>().completedTripsCount.value++;
        }
      }
      myTrips.refresh();
    }

    AppSnackBar.success(
      message:
          'Rating of ${rating.toStringAsFixed(1)}★ submitted for $passengerName. Thank you!',
    );
  }

  /// Rate passenger bottom sheet for completed trips & post-ride feedback
  void showRatePassengerSheet({
    required BuildContext context,
    required DriverTripModel trip,
    PassengerRequestModel? passenger,
  }) {
    final targetPassenger =
        passenger ??
        trip.acceptedPassengers.firstWhereOrNull((p) => !p.isRated.value) ??
        (trip.acceptedPassengers.isNotEmpty
            ? trip.acceptedPassengers.first
            : PassengerRequestModel(
                id: 'comp_${trip.id}',
                tripId: trip.id,
                passengerId: '',
                passengerName: 'Passenger',
                rating: 5.0,
                from: trip.from,
                to: trip.to,
                seats: trip.bookedSeats.value > 0 ? trip.bookedSeats.value : 1,
                fare:
                    (trip.bookedSeats.value > 0 ? trip.bookedSeats.value : 1) *
                    trip.pricePerSeat.value,
                time: trip.time.value,
              ));

    if (trip.acceptedPassengers.isEmpty) {
      trip.acceptedPassengers.add(targetPassenger);
    }

    final RxDouble selectedRating = 5.0.obs;
    final TextEditingController commentController = TextEditingController();
    final RxList<String> selectedBadges = <String>[
      'Punctual',
      'Polite & Respectful',
    ].obs;
    final RxBool isSubmitting = false.obs;

    final List<String> availableBadges = [
      'Punctual',
      'Polite & Respectful',
      'Great Communication',
      'Clean & Quiet',
      'Followed Safety Rules',
      'Friendly',
    ];

    String getRatingLabel(double rating) {
      if (rating >= 5.0) return '5.0 ★ Exceptional Passenger!';
      if (rating >= 4.0) return '4.0 ★ Great Passenger';
      if (rating >= 3.0) return '3.0 ★ Good Experience';
      if (rating >= 2.0) return '2.0 ★ Fair';
      return '1.0 ★ Needs Improvement';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.88,
          ),
          padding: EdgeInsets.only(
            top: 14.h,
            left: 20.w,
            right: 20.w,
            bottom: MediaQuery.of(ctx).padding.bottom + 20.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.borderColor,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                16.verticalSpace,

                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFFBEB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFF59E0B),
                        size: 26,
                      ),
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rate Passenger',
                            style: AppTextStyle.text18Semibold.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          2.verticalSpace,
                          Text(
                            'Trip: ${trip.from} → ${trip.to}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.text12Regular.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                16.verticalSpace,

                // Passenger info tile
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42.r,
                        height: 42.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            targetPassenger.passengerName.isNotEmpty
                                ? targetPassenger.passengerName[0].toUpperCase()
                                : 'P',
                            style: AppTextStyle.text18Semibold.copyWith(
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              targetPassenger.passengerName,
                              style: AppTextStyle.text14Semibold.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            2.verticalSpace,
                            Text(
                              '${targetPassenger.seats} Seat(s) • ${Utils.formatPrice(targetPassenger.fare)} AUD settled',
                              style: AppTextStyle.text12Regular.copyWith(
                                color: const Color(0xFF16A34A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                18.verticalSpace,

                // Star Selector
                Center(
                  child: Obx(
                    () => Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (starIndex) {
                            final starValue = starIndex + 1.0;
                            return GestureDetector(
                              onTap: () {
                                selectedRating.value = starValue;
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                child: Icon(
                                  starValue <= selectedRating.value
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  color: starValue <= selectedRating.value
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFFCBD5E1),
                                  size: 38.sp,
                                ),
                              ),
                            );
                          }),
                        ),
                        6.verticalSpace,
                        Text(
                          getRatingLabel(selectedRating.value),
                          style: AppTextStyle.text14Medium.copyWith(
                            color: const Color(0xFFB45309),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                16.verticalSpace,
                Text(
                  'Passenger feedback tags',
                  style: AppTextStyle.text12Semibold.copyWith(
                    color: AppColors.primaryTextColor,
                  ),
                ),
                8.verticalSpace,

                // Badges
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: availableBadges.map((badge) {
                    return Obx(() {
                      final isSelected = selectedBadges.contains(badge);
                      return GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            selectedBadges.remove(badge);
                          } else {
                            selectedBadges.add(badge);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            badge,
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: isSelected
                                  ? const Color(0xFF1D4ED8)
                                  : const Color(0xFF475569),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    });
                  }).toList(),
                ),

                14.verticalSpace,

                // Comment Text Field
                TextField(
                  controller: commentController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Add an optional note about this passenger...',
                    hintStyle: AppTextStyle.text12Regular.copyWith(
                      color: AppColors.hintTextColor,
                    ),
                    filled: true,
                    fillColor: AppColors.secondaryBgColor,
                    contentPadding: EdgeInsets.all(12.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: AppColors.borderColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: AppColors.borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),

                20.verticalSpace,

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    final submitting = isSubmitting.value;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primaryColor
                            .withValues(alpha: 0.6),
                        disabledForegroundColor: Colors.white70,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      onPressed: submitting
                          ? null
                          : () async {
                              isSubmitting.value = true;
                              Get.back();
                              final combinedComment = [
                                if (selectedBadges.isNotEmpty)
                                  selectedBadges.join(', '),
                                if (commentController.text.trim().isNotEmpty)
                                  commentController.text.trim(),
                              ].join(' • ');

                              await submitPassengerRating(
                                passengerId:
                                    targetPassenger.passengerId ??
                                    targetPassenger.id,
                                passengerName: targetPassenger.passengerName,
                                rating: selectedRating.value,
                                comment: combinedComment,
                                trip: trip,
                                bookingId: targetPassenger.id,
                                fare: targetPassenger.fare,
                                paymentMethod: 'cash',
                                isAlreadyCompleted:
                                    trip.status.value.toLowerCase() ==
                                    'completed',
                              );
                            },
                      child: submitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16.r,
                                  height: 16.r,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                8.horizontalSpace,
                                Text(
                                  'Submitting Rating...',
                                  style: AppTextStyle.text14Semibold.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Submit Rating',
                              style: AppTextStyle.text14Semibold.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void confirmCancelTrip(BuildContext context, DriverTripModel trip) {
    final RxBool isCancelling = false.obs;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetCtx).size.height * 0.88,
        ),
        padding: EdgeInsets.only(
          top: 12.h,
          left: 20.w,
          right: 20.w,
          bottom: MediaQuery.of(sheetCtx).padding.bottom + 20.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              18.verticalSpace,
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF2F2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cancel_outlined,
                      color: const Color(0xFFDC2626),
                      size: 22.sp,
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cancel Trip?',
                          style: AppTextStyle.text18Semibold.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        2.verticalSpace,
                        Text(
                          trip.time.value,
                          style: AppTextStyle.text12Medium.copyWith(
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              14.verticalSpace,
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.trip_origin,
                          size: 14.sp,
                          color: AppColors.primaryColor,
                        ),
                        8.horizontalSpace,
                        Expanded(
                          child: Text(
                            trip.from,
                            style: AppTextStyle.text13Semibold,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 6.w),
                      child: Container(
                        width: 2.w,
                        height: 12.h,
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14.sp,
                          color: const Color(0xFFEF4444),
                        ),
                        8.horizontalSpace,
                        Expanded(
                          child: Text(
                            trip.to,
                            style: AppTextStyle.text13Semibold,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              12.verticalSpace,
              Text(
                'Are you sure you want to cancel this trip? Any accepted passenger requests will be automatically cancelled and notifications will be sent.',
                style: AppTextStyle.text13Regular.copyWith(
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              20.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: const BorderSide(color: AppColors.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Keep Trip',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Obx(() {
                      final cancelling = isCancelling.value;
                      return ElevatedButton(
                        onPressed: cancelling
                            ? null
                            : () {
                                isCancelling.value = true;
                                Get.back();
                                trip.status.value = 'Cancelled';
                                final driverUid =
                                    AuthService.instance.currentUser?.uid ?? '';
                                TripService.instance.cancelTripAsDriver(
                                  tripId: trip.id,
                                  driverId: driverUid,
                                );
                                myTrips.refresh();
                                AppSnackBar.info(
                                  message: 'Trip has been cancelled.',
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(
                            0xFFDC2626,
                          ).withValues(alpha: 0.6),
                          disabledForegroundColor: Colors.white70,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: cancelling
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 14.r,
                                    height: 14.r,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  8.horizontalSpace,
                                  Text(
                                    'Cancelling...',
                                    style: AppTextStyle.text14Semibold.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Cancel Trip',
                                style: AppTextStyle.text14Semibold.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showEditTripDialog(BuildContext context, DriverTripModel trip) =>
      showEditTripSheet(context, trip);

  void showEditTripSheet(BuildContext context, DriverTripModel trip) {
    // 1. Pre-fill all fields from the existing trip model
    final fromController = TextEditingController(text: trip.from);
    final toController = TextEditingController(text: trip.to);
    double editFromLat = trip.fromLat;
    double editFromLng = trip.fromLng;
    double editToLat = trip.toLat;
    double editToLng = trip.toLng;

    DateTime editDate = trip.departureDateTime ?? DateTime.now();
    TimeOfDay editTime = trip.departureDateTime != null
        ? TimeOfDay.fromDateTime(trip.departureDateTime!)
        : const TimeOfDay(hour: 8, minute: 0);

    // If departureDateTime was null, attempt to extract time from trip.time.value
    if (trip.departureDateTime == null && trip.time.value.isNotEmpty) {
      try {
        final match = RegExp(
          r'(\d{1,2}):(\d{2})\s*(AM|PM)',
          caseSensitive: false,
        ).firstMatch(trip.time.value);
        if (match != null) {
          int hour = int.parse(match.group(1)!);
          final minute = int.parse(match.group(2)!);
          final isPm = match.group(3)!.toUpperCase() == 'PM';
          if (isPm && hour < 12) hour += 12;
          if (!isPm && hour == 12) hour = 0;
          editTime = TimeOfDay(hour: hour, minute: minute);
        }
      } catch (_) {}
    }

    int editSeats = trip.totalSeats.value;
    final int bookedSeats = trip.bookedSeats.value;
    final priceController = TextEditingController(
      text: trip.pricePerSeat.value % 1 == 0
          ? trip.pricePerSeat.value.toInt().toString()
          : trip.pricePerSeat.value.toStringAsFixed(2),
    );

    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          final now = DateTime.now();
          final formattedDate = DateFormat('EEE, d MMM yyyy').format(editDate);
          final formattedTime = editTime.format(context);
          final bool isTripDropFixed = trip.communityName.isNotEmpty &&
              availableCommunityModels.any(
                (c) =>
                    c.name.toLowerCase().trim() ==
                        trip.communityName.toLowerCase().trim() &&
                    (c.isFixedDropOff ||
                        c.fixedLocationType == 'dropoff' ||
                        c.fixedLocationType == 'both' ||
                        c.dropOffLocation.trim().isNotEmpty ||
                        (c.fixedLocation.trim().isNotEmpty &&
                            c.fixedLocationType != 'pickup')),
              );

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetCtx).size.height * 0.88,
            ),
            padding: EdgeInsets.only(
              top: 12.h,
              left: 20.w,
              right: 20.w,
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Drag Handle Pill
                  Center(
                    child: Container(
                      width: 44.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.borderColor,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  16.verticalSpace,

                  // Header with Icon, Title, and Close
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit_road_rounded,
                          color: AppColors.primaryColor,
                          size: 22.sp,
                        ),
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Trip Details',
                              style: AppTextStyle.text18Semibold.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            2.verticalSpace,
                            Text(
                              'Update route, schedule, seats & fare',
                              style: AppTextStyle.text12Medium.copyWith(
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetCtx).pop(),
                        icon: const Icon(Icons.close_rounded),
                        splashRadius: 20.r,
                      ),
                    ],
                  ),

                  // Booked seats warning if any passengers already joined
                  if (bookedSeats > 0) ...[
                    14.verticalSpace,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 9.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16.sp,
                            color: const Color(0xFFD97706),
                          ),
                          8.horizontalSpace,
                          Expanded(
                            child: Text(
                              '$bookedSeats seat(s) already booked. Total seats cannot be reduced below $bookedSeats.',
                              style: AppTextStyle.text11Medium.copyWith(
                                color: const Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  18.verticalSpace,

                  // 1. ROUTE SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ROUTE LOCATIONS',
                        style: AppTextStyle.text11Medium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      // Quick Swap Locations Button
                      InkWell(
                        onTap: () {
                          if (isTripDropFixed) {
                            AppSnackBar.info(
                              message:
                                  'Drop-off destination is fixed by the community corridor.',
                            );
                            return;
                          }
                          setModalState(() {
                            final tempText = fromController.text;
                            fromController.text = toController.text;
                            toController.text = tempText;

                            final tempLat = editFromLat;
                            final tempLng = editFromLng;
                            editFromLat = editToLat;
                            editFromLng = editToLng;
                            editToLat = tempLat;
                            editToLng = tempLng;
                          });
                        },
                        borderRadius: BorderRadius.circular(6.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isTripDropFixed
                                    ? Icons.lock_outline_rounded
                                    : CupertinoIcons.arrow_2_circlepath,
                                size: 12.sp,
                                color: isTripDropFixed
                                    ? const Color(0xFF94A3B8)
                                    : AppColors.primaryColor,
                              ),
                              4.horizontalSpace,
                              Text(
                                isTripDropFixed ? 'Drop Fixed' : 'Swap',
                                style: AppTextStyle.text11Medium.copyWith(
                                  color: isTripDropFixed
                                      ? const Color(0xFF94A3B8)
                                      : AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  8.verticalSpace,

                  // Pickup Location Google Places Input
                  GooglePlacesSearchField(
                    controller: fromController,
                    label: 'PICKUP LOCATION',
                    labelColor: const Color(0xFF16A34A),
                    hintText: 'Search or enter pickup location',
                    onPlaceSelected: (details) {
                      setModalState(() {
                        editFromLat = details.latitude;
                        editFromLng = details.longitude;
                      });
                    },
                  ),

                  10.verticalSpace,

                  // Drop-off Destination Google Places Input
                  GooglePlacesSearchField(
                    controller: toController,
                    label: 'DROP-OFF DESTINATION',
                    labelColor: AppColors.primaryColor,
                    hintText: 'Search or enter drop-off destination',
                    readOnly: isTripDropFixed,
                    fixedBadgeText: isTripDropFixed ? 'Fixed Drop-off' : null,
                    onPlaceSelected: (details) {
                      setModalState(() {
                        editToLat = details.latitude;
                        editToLng = details.longitude;
                      });
                    },
                  ),

                  18.verticalSpace,

                  // 2. DEPARTURE SCHEDULE SECTION
                  Text(
                    'DEPARTURE SCHEDULE',
                    style: AppTextStyle.text11Medium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  8.verticalSpace,

                  Row(
                    children: [
                      // Date Selector Card
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: sheetCtx,
                              initialDate: editDate.isBefore(now)
                                  ? now
                                  : editDate,
                              firstDate: now.subtract(const Duration(days: 1)),
                              lastDate: now.add(const Duration(days: 365)),
                              helpText: 'Select Departure Date',
                              confirmText: 'SELECT',
                              cancelText: 'CANCEL',
                            );
                            if (picked != null) {
                              setModalState(() {
                                editDate = picked;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.calendar,
                                      size: 14.sp,
                                      color: AppColors.primaryColor,
                                    ),
                                    6.horizontalSpace,
                                    Text(
                                      'Date',
                                      style: AppTextStyle.text10Medium.copyWith(
                                        color: AppColors.secondaryTextColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                4.verticalSpace,
                                Text(
                                  formattedDate,
                                  style: AppTextStyle.text13Semibold.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      10.horizontalSpace,

                      // Time Selector Card
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: sheetCtx,
                              initialTime: editTime,
                              helpText: 'Select Departure Time',
                              confirmText: 'SELECT',
                              cancelText: 'CANCEL',
                            );
                            if (picked != null) {
                              setModalState(() {
                                editTime = picked;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.clock,
                                      size: 14.sp,
                                      color: AppColors.primaryColor,
                                    ),
                                    6.horizontalSpace,
                                    Text(
                                      'Time',
                                      style: AppTextStyle.text10Medium.copyWith(
                                        color: AppColors.secondaryTextColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                4.verticalSpace,
                                Text(
                                  formattedTime,
                                  style: AppTextStyle.text13Semibold.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  18.verticalSpace,

                  // 3. SEATS & FARE SECTION
                  Row(
                    children: [
                      // Total Seats Available Counter
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL SEATS',
                              style: AppTextStyle.text11Medium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            8.verticalSpace,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap:
                                        editSeats <= bookedSeats ||
                                            editSeats <= 1
                                        ? null
                                        : () {
                                            setModalState(() {
                                              editSeats--;
                                            });
                                          },
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Container(
                                      padding: EdgeInsets.all(6.r),
                                      decoration: BoxDecoration(
                                        color:
                                            editSeats <= bookedSeats ||
                                                editSeats <= 1
                                            ? Colors.transparent
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFFCBD5E1),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.remove,
                                        size: 16.sp,
                                        color:
                                            editSeats <= bookedSeats ||
                                                editSeats <= 1
                                            ? const Color(0xFFCBD5E1)
                                            : AppColors.primaryTextColor,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '$editSeats',
                                        style: AppTextStyle.text16Semibold
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF0F172A),
                                            ),
                                      ),
                                      Text(
                                        'seats',
                                        style: AppTextStyle.text10Medium
                                            .copyWith(
                                              color:
                                                  AppColors.secondaryTextColor,
                                            ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: editSeats >= 8
                                        ? null
                                        : () {
                                            setModalState(() {
                                              editSeats++;
                                            });
                                          },
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Container(
                                      padding: EdgeInsets.all(6.r),
                                      decoration: BoxDecoration(
                                        color: editSeats >= 8
                                            ? Colors.transparent
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFFCBD5E1),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        size: 16.sp,
                                        color: editSeats >= 8
                                            ? const Color(0xFFCBD5E1)
                                            : AppColors.primaryTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      12.horizontalSpace,

                      // Price Per Seat Input Box
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PRICE PER SEAT',
                              style: AppTextStyle.text11Medium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            8.verticalSpace,
                            TextField(
                              controller: priceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              style: AppTextStyle.text16Semibold.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                              decoration: InputDecoration(
                                prefixText: '\$ ',
                                prefixStyle: AppTextStyle.text16Semibold
                                    .copyWith(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 12.h,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                    width: 1.2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  24.verticalSpace,

                  // 4. ACTION BUTTONS (Cancel & Save)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSaving
                              ? null
                              : () => Navigator.of(sheetCtx).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 13.h),
                            side: const BorderSide(
                              color: Color(0xFFCBD5E1),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyle.text14Semibold.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  final fromText = fromController.text.trim();
                                  final toText = toController.text.trim();

                                  if (fromText.isEmpty || toText.isEmpty) {
                                    AppSnackBar.warning(
                                      message:
                                          'Please enter both pickup and drop-off locations.',
                                    );
                                    return;
                                  }

                                  final newPrice =
                                      double.tryParse(
                                        priceController.text.trim(),
                                      ) ??
                                      trip.pricePerSeat.value;
                                  if (newPrice <= 0) {
                                    AppSnackBar.warning(
                                      message:
                                          'Please enter a valid price per seat greater than \$0.',
                                    );
                                    return;
                                  }

                                  if (editSeats < bookedSeats) {
                                    AppSnackBar.warning(
                                      message:
                                          'Cannot set total seats lower than already booked seats ($bookedSeats).',
                                    );
                                    return;
                                  }

                                  final newDepDateTime = DateTime(
                                    editDate.year,
                                    editDate.month,
                                    editDate.day,
                                    editTime.hour,
                                    editTime.minute,
                                  );

                                  if (!trip.isRecurring &&
                                      trip.status.value.toLowerCase() !=
                                          'active' &&
                                      newDepDateTime.isBefore(now)) {
                                    AppSnackBar.warning(
                                      message:
                                          'Departure time cannot be in the past. Please select an upcoming departure time.',
                                    );
                                    return;
                                  }

                                  setModalState(() {
                                    isSaving = true;
                                  });

                                  // Geocode pickup if coordinates are missing or invalid
                                  if (!GooglePlacesService.instance
                                      .isValidCoordinate(
                                        LatLng(editFromLat, editFromLng),
                                      )) {
                                    final geo = await GooglePlacesService
                                        .instance
                                        .getCoordinatesForAddress(fromText);
                                    if (geo != null &&
                                        GooglePlacesService.instance
                                            .isValidCoordinate(
                                              LatLng(
                                                geo.latitude,
                                                geo.longitude,
                                              ),
                                            )) {
                                      editFromLat = geo.latitude;
                                      editFromLng = geo.longitude;
                                    }
                                  }

                                  // Geocode drop-off if coordinates are missing or invalid
                                  if (!GooglePlacesService.instance
                                      .isValidCoordinate(
                                        LatLng(editToLat, editToLng),
                                      )) {
                                    final geo = await GooglePlacesService
                                        .instance
                                        .getCoordinatesForAddress(toText);
                                    if (geo != null &&
                                        GooglePlacesService.instance
                                            .isValidCoordinate(
                                              LatLng(
                                                geo.latitude,
                                                geo.longitude,
                                              ),
                                            )) {
                                      editToLat = geo.latitude;
                                      editToLng = geo.longitude;
                                    }
                                  }

                                  final timeStr = DateFormat(
                                    'hh:mm a',
                                  ).format(newDepDateTime);
                                  final dateStr = DateFormat(
                                    'EEE, d MMM',
                                  ).format(newDepDateTime);
                                  final depTimeString = trip.isRecurring
                                      ? '$timeStr • ${trip.recurringDays.join(', ')}'
                                      : '$timeStr ($dateStr)';

                                  // Update local trip model
                                  trip.from = fromText;
                                  trip.to = toText;
                                  trip.fromLat = editFromLat;
                                  trip.fromLng = editFromLng;
                                  trip.toLat = editToLat;
                                  trip.toLng = editToLng;
                                  trip.departureDateTime = newDepDateTime;
                                  trip.time.value = depTimeString;
                                  trip.pricePerSeat.value = newPrice;
                                  trip.totalSeats.value = editSeats;
                                  myTrips.refresh();

                                  // Update Firestore trip document
                                  final availableSeats =
                                      (editSeats - bookedSeats).clamp(
                                        0,
                                        editSeats,
                                      );
                                  try {
                                    await TripService.instance
                                        .updateTripDetails(
                                          tripId: trip.id,
                                          origin: fromText,
                                          originLat: editFromLat,
                                          originLng: editFromLng,
                                          destination: toText,
                                          destinationLat: editToLat,
                                          destinationLng: editToLng,
                                          departureTime: newDepDateTime,
                                          departureTimeString: depTimeString,
                                          pricePerSeat: newPrice,
                                          totalSeats: editSeats,
                                          availableSeats: availableSeats,
                                        );
                                  } catch (e) {
                                    debugPrint(
                                      '[DriverTripsController] updateTripDetails error: $e',
                                    );
                                  }

                                  if (context.mounted) {
                                    Navigator.of(sheetCtx).pop();
                                    AppSnackBar.success(
                                      message:
                                          'Trip details updated successfully!',
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 13.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: isSaving
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Save Changes',
                                  style: AppTextStyle.text14Semibold.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
    _passengerProfileSub?.cancel();
    _driverTripsSubscription?.cancel();
    _driverBookingsSubscription?.cancel();
    _communitiesSubscription?.cancel();
    for (final s in _tripBookingsSubscriptions.values) {
      s.cancel();
    }
    _tripBookingsSubscriptions.clear();
    _authSubscription?.cancel();
    publishFromController.dispose();
    publishToController.dispose();
    departureTimeController.dispose();
    priceInputController.dispose();
    super.onClose();
  }
}
