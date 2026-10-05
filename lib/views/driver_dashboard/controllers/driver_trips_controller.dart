import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/data/models/firestore/trip_model.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/community_service.dart';
import 'package:ridelink/data/services/device_location_service.dart';
import 'package:ridelink/data/services/google_places_service.dart';
import 'package:ridelink/data/services/trip_service.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_controller.dart';

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
    final Set<String> ids = {};
    for (final r in pendingRequests) {
      ids.add(r.id);
    }
    for (final t in myTrips) {
      for (final r in t.requests) {
        ids.add(r.id);
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
    _communitiesSubscription = CommunityService.instance.streamCommunities().listen(
      (comms) {
        if (comms.isNotEmpty) {
          final names = comms.map((c) => c.name).toList();
          availableCommunitiesForDriver.assignAll(names);
          // Only clear if a community was selected but is no longer in the list
          if (selectedCommunityForPublish.value.isNotEmpty &&
              !names.contains(selectedCommunityForPublish.value)) {
            selectedCommunityForPublish.value = '';
          }
        }
      },
      onError: (err) {
        debugPrint('[DriverTripsController] Communities stream error: $err');
      },
    );
  }

  void reloadDriverTrips() {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      subscribeToDriverTrips(user.uid);
      _listenToCommunities();
    }
  }

  void clearState() {
    _communitiesSubscription?.cancel();
    _communitiesSubscription = null;
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
  }

  void subscribeToDriverTrips(String uid) {
    _driverTripsSubscription?.cancel();
    _driverTripsSubscription = TripService.instance
        .streamDriverTrips(uid)
        .listen(
          (trips) {
            for (final trip in trips) {
              final normalizedStatus =
                  (trip.status == 'in_progress' ||
                      trip.status == 'active' ||
                      trip.status == 'Active')
                  ? 'Active'
                  : (trip.status == 'completed' || trip.status == 'Completed')
                  ? 'Completed'
                  : 'Scheduled';

              final existing = myTrips.firstWhereOrNull((t) => t.id == trip.id);
              if (existing != null) {
                existing.status.value = normalizedStatus;
                existing.bookedSeats.value = trip.bookedSeats;
                existing.totalSeats.value = trip.totalSeats;
                if (trip.currentDriverLat != 0.0) {
                  existing.currentDriverLat.value = trip.currentDriverLat;
                  existing.currentDriverLng.value = trip.currentDriverLng;
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
                );
                myTrips.add(newTripModel);
                _listenToBookingsForTrip(newTripModel);
              }
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
            for (final booking in bookings) {
              _syncBookingToDriverState(booking);
            }
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
        : 'Pending';

    // 1. Sync to the specific trip if present in myTrips
    final trip = myTrips.firstWhereOrNull((t) => t.id == booking.tripId);
    if (trip != null) {
      final existingReq = trip.requests.firstWhereOrNull(
        (r) => r.id == booking.id,
      );
      final existingAccepted = trip.acceptedPassengers.firstWhereOrNull(
        (r) => r.id == booking.id,
      );

      if (statusCapital == 'Accepted') {
        if (existingReq != null) {
          existingReq.status.value = 'Accepted';
          trip.requests.remove(existingReq);
          if (existingAccepted == null) {
            trip.acceptedPassengers.add(existingReq);
          }
        } else if (existingAccepted == null) {
          final req = _createPassengerRequestFromBooking(
            booking,
            trip.time.value,
          );
          trip.acceptedPassengers.add(req);
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
        : 'Pending';

    return PassengerRequestModel(
      id: booking.id,
      tripId: booking.tripId,
      passengerId: booking.passengerId,
      passengerName: booking.passengerName,
      rating: booking.passengerRating,
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
    );
  }

  void _listenToBookingsForTrip(DriverTripModel trip) {
    if (_tripBookingsSubscriptions.containsKey(trip.id)) return;
    _tripBookingsSubscriptions[trip.id] = TripService.instance
        .streamTripBookings(trip.id)
        .listen(
          (bookings) {
            for (final booking in bookings) {
              _syncBookingToDriverState(booking);
            }
          },
          onError: (err) {
            debugPrint(
              '[DriverTripsController] Trip bookings stream error for ${trip.id}: $err',
            );
          },
        );
  }

  Future<void> publishNewTrip() async {
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
      if (p.vehicleNumber.value.isNotEmpty && p.vehicleNumber.value != 'N/A') {
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

    // Geocode locations if default or unselected coordinates
    if ((publishFromLat.value == 0.0 && publishFromLng.value == 0.0) ||
        (publishFromLat.value == -31.8156 &&
            publishFromLng.value == 115.8452)) {
      final geo = await GooglePlacesService.instance.getCoordinatesForAddress(
        from,
      );
      if (geo != null) {
        publishFromLat.value = geo.latitude;
        publishFromLng.value = geo.longitude;
      }
    }
    if ((publishToLat.value == 0.0 && publishToLng.value == 0.0) ||
        (publishToLat.value == -32.0044 && publishToLng.value == 115.8947)) {
      final geo = await GooglePlacesService.instance.getCoordinatesForAddress(
        to,
      );
      if (geo != null) {
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
      recurringDays: isRecurringRide.value ? recurringDays.toList() : const [],
      communityName: selectedCommunityForPublish.value,
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

    AppSnackBar.success(message: 'Your trip has been published successfully!');
    if (Get.isRegistered<DriverDashboardController>()) {
      Get.find<DriverDashboardController>().switchTab(1);
    }
    if (Get.currentRoute == AppRoutes.driverPublishRide) {
      Get.back();
    } else {
      Get.offAllNamed(AppRoutes.driverDashboard);
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

  void selectCommunityForPublish(String communityName) {
    selectedCommunityForPublish.value = communityName;
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
        if (sheetContext != null) {
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
        if (sheetContext != null) {
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

      final loc = await DeviceLocationService.instance
          .getCurrentDeviceLocation(
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
              );
            }
          }
        });
      }

      Get.toNamed(AppRoutes.driverLiveTrip, arguments: trip);
    } else if (s == 'in progress' || s == 'active') {
      trip.status.value = 'Completed';
      final driverUid = AuthService.instance.currentUser?.uid ?? '';
      TripService.instance.completeEntireTrip(tripId: trip.id, driverId: driverUid);
      liveTrip.value = null;
      livePassenger.value = null;
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

  /// Verify passenger's 4-digit pickup OTP and set status to onboard
  Future<bool> verifyPassengerPickupOtp({
    required PassengerRequestModel passenger,
    required String enteredOtp,
  }) async {
    final validOtp = passenger.pickupOtp.isNotEmpty ? passenger.pickupOtp : '1234';
    if (enteredOtp.trim() == validOtp.trim()) {
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
  }) async {
    final user = AuthService.instance.currentUser;
    final driverUid = user?.uid ?? '';

    // 1. Mark passenger dropped off, confirm payment settlement & credit driver earnings in database
    if (trip != null) {
      final cleanBookingId =
          bookingId ??
          (trip.acceptedPassengers.isNotEmpty
              ? trip.acceptedPassengers.first.id
              : (trip.requests.isNotEmpty ? trip.requests.first.id : ''));
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

        final targetPassenger = trip.acceptedPassengers.firstWhereOrNull(
          (p) => p.id == cleanBookingId,
        );
        if (targetPassenger != null) {
          targetPassenger.passengerStatus.value = 'dropped_off';
        }
      }

      // Check if all accepted passengers have been dropped off
      final bool allDroppedOff = trip.acceptedPassengers.isEmpty ||
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
    }

    AppSnackBar.success(
      message:
          'Payment collected! Rating of ${rating.toStringAsFixed(1)}★ submitted for $passengerName. Trip completed successfully!',
    );
  }

  void confirmCancelTrip(BuildContext context, DriverTripModel trip) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Container(
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
                    onPressed: () => Navigator.pop(sheetCtx),
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
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      trip.status.value = 'Cancelled';
                      TripService.instance.updateTripStatus(
                        trip.id,
                        'cancelled',
                      );
                      AppSnackBar.info(message: 'Trip has been cancelled.');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Cancel Trip',
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
  }

  void showEditTripDialog(BuildContext context, DriverTripModel trip) =>
      showEditTripSheet(context, trip);

  void showEditTripSheet(BuildContext context, DriverTripModel trip) {
    final priceController = TextEditingController(
      text: trip.pricePerSeat.value % 1 == 0
          ? trip.pricePerSeat.value.toInt().toString()
          : trip.pricePerSeat.value.toStringAsFixed(2),
    );
    final seatsController = TextEditingController(
      text: trip.totalSeats.value.toString(),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Container(
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
                        'Update fare per seat and vehicle passenger capacity',
                        style: AppTextStyle.text12Medium.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            18.verticalSpace,
            Text('Price Per Seat (\$)', style: AppTextStyle.text13Semibold),
            6.verticalSpace,
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: AppTextStyle.text16Semibold.copyWith(
                  color: AppColors.primaryColor,
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            14.verticalSpace,
            Text('Total Seats Available', style: AppTextStyle.text13Semibold),
            6.verticalSpace,
            TextField(
              controller: seatsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.event_seat_outlined,
                  color: AppColors.secondaryTextColor,
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            22.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetCtx),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: const BorderSide(color: AppColors.borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
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
                    onPressed: () {
                      final newPrice =
                          double.tryParse(priceController.text.trim()) ??
                          trip.pricePerSeat.value;
                      final newSeats =
                          int.tryParse(seatsController.text.trim()) ??
                          trip.totalSeats.value;
                      if (newSeats < trip.bookedSeats.value) {
                        AppSnackBar.warning(
                          message:
                              'Cannot set total seats lower than already booked seats (${trip.bookedSeats.value}).',
                        );
                        return;
                      }
                      trip.pricePerSeat.value = newPrice;
                      trip.totalSeats.value = newSeats;
                      Navigator.pop(sheetCtx);
                      AppSnackBar.success(
                        message: 'Trip details updated successfully!',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
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
  }

  void updateTripStatus(DriverTripModel trip, String newStatus) {
    trip.status.value = newStatus;
    TripService.instance.updateTripStatus(trip.id, newStatus.toLowerCase());
    AppSnackBar.info(message: 'Trip status updated to $newStatus');
  }

  @override
  void onClose() {
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
