import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/device_location_service.dart';
import 'package:ridelink/data/services/trip_service.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_community_controller.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_home_controller.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_profile_controller.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_support_controller.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_trips_controller.dart';

export 'package:ridelink/data/models/driver/driver_models.dart';
export 'package:ridelink/views/driver_dashboard/controllers/driver_community_controller.dart';
export 'package:ridelink/views/driver_dashboard/controllers/driver_home_controller.dart';
export 'package:ridelink/views/driver_dashboard/controllers/driver_profile_controller.dart';
export 'package:ridelink/views/driver_dashboard/controllers/driver_support_controller.dart';
export 'package:ridelink/views/driver_dashboard/controllers/driver_trips_controller.dart';

class DriverDashboardController extends GetxController {
  // Navigation
  final RxInt currentTabIndex = 0.obs;

  // Domain Sub-Controllers
  late final DriverHomeController homeController;
  late final DriverTripsController tripsController;
  late final DriverCommunityController communityController;
  late final DriverSupportController supportController;
  late final DriverProfileController profileController;

  // Live Driver Location Tracking (Active whenever driver is on the app)
  final Rx<LatLng?> currentDriverLocation = Rx<LatLng?>(null);
  final RxDouble driverCurrentLat = 0.0.obs;
  final RxDouble driverCurrentLng = 0.0.obs;
  final RxDouble driverCurrentHeading = 0.0.obs;
  final RxDouble driverCurrentSpeed = 0.0.obs;
  final RxDouble driverCurrentAccuracy = 0.0.obs;
  final RxBool isTrackingLocation = false.obs;

  // Location Permission State
  final Rx<LocationCheckResult?> locationPermissionStatus =
      Rx<LocationCheckResult?>(null);
  final RxBool hasLocationPermission = false.obs;

  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    homeController = Get.isRegistered<DriverHomeController>()
        ? Get.find<DriverHomeController>()
        : Get.put<DriverHomeController>(DriverHomeController());

    tripsController = Get.isRegistered<DriverTripsController>()
        ? Get.find<DriverTripsController>()
        : Get.put<DriverTripsController>(DriverTripsController());

    communityController = Get.isRegistered<DriverCommunityController>()
        ? Get.find<DriverCommunityController>()
        : Get.put<DriverCommunityController>(DriverCommunityController());

    supportController = Get.isRegistered<DriverSupportController>()
        ? Get.find<DriverSupportController>()
        : Get.put<DriverSupportController>(DriverSupportController());

    profileController = Get.isRegistered<DriverProfileController>()
        ? Get.find<DriverProfileController>()
        : Get.put<DriverProfileController>(DriverProfileController());

    // Automatically check permissions and start location streaming when in driver mode
    startDriverLiveLocationTracking(showPermissionSheet: false);

    _authSubscription = AuthService.instance.authStateChanges.listen((user) {
      if (user != null) {
        startDriverLiveLocationTracking(showPermissionSheet: false);
      } else {
        stopDriverLiveLocationTracking();
      }
    });
  }

  /// Start continuous live GPS location tracking for the driver and request permission if needed
  Future<void> startDriverLiveLocationTracking({
    BuildContext? context,
    bool showPermissionSheet = true,
  }) async {
    isTrackingLocation.value = true;

    // Check permission details and prompt OS dialog if not yet granted
    final permResult = await DeviceLocationService.instance
        .checkAndRequestPermissionDetails();
    locationPermissionStatus.value = permResult;
    hasLocationPermission.value = (permResult == LocationCheckResult.granted);

    if (permResult != LocationCheckResult.granted) {
      if (showPermissionSheet) {
        final sheetContext = context ?? Get.context;
        if (sheetContext != null && sheetContext.mounted) {
          if (permResult == LocationCheckResult.deniedForever) {
            DeviceLocationService.instance.showLocationBlockedSheet(sheetContext);
          } else if (permResult == LocationCheckResult.serviceDisabled) {
            DeviceLocationService.instance
                .showLocationServiceDisabledSheet(sheetContext);
          }
        }
      }
      return;
    }

    // 1. Fetch fresh hardware GPS device location immediately on app entry
    final initialPos =
        await DeviceLocationService.instance.getCurrentPosition(forceFresh: true);
    if (initialPos != null) {
      _handleNewDriverPosition(initialPos, forceSync: true);
    }

    // 2. Stream real-time GPS location updates as the driver moves (Uber / Ola precision)
    _locationSubscription?.cancel();
    _locationSubscription = DeviceLocationService.instance
        .streamDevicePosition(distanceFilterMeters: 0)
        .listen(
      (pos) {
        _handleNewDriverPosition(pos);
      },
      onError: (err) {
        debugPrint('[DriverDashboardController] Location stream error: $err');
      },
    );
  }

  /// Request or re-prompt location permission
  Future<void> requestLocationPermissionPrompt({BuildContext? context}) async {
    await startDriverLiveLocationTracking(
      context: context,
      showPermissionSheet: true,
    );
  }

  /// Stop live location streaming
  void stopDriverLiveLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    isTrackingLocation.value = false;
  }

  void _handleNewDriverPosition(Position pos, {bool forceSync = false}) {
    final loc = LatLng(pos.latitude, pos.longitude);
    currentDriverLocation.value = loc;
    driverCurrentLat.value = pos.latitude;
    driverCurrentLng.value = pos.longitude;
    if (pos.heading >= 0.0) {
      driverCurrentHeading.value = pos.heading;
    }
    driverCurrentSpeed.value = pos.speed;
    driverCurrentAccuracy.value = pos.accuracy;

    // 1. Update live location in driver's user document in Firestore (filtered)
    AuthService.instance.updateDriverLocation(
      latitude: pos.latitude,
      longitude: pos.longitude,
      force: forceSync,
    );

    // 2. If any trip is started/active, update live location data to driver lat/long on trips
    syncLocationToStartedTrips(loc, forceSync: forceSync);
  }

  /// Sync live location coordinates to any active / started trips
  void syncLocationToStartedTrips(LatLng pos, {bool forceSync = false}) {
    if (!Get.isRegistered<DriverTripsController>()) return;

    final activeTrips = <DriverTripModel>[];

    // Check myTrips for started / active trips
    for (final trip in tripsController.myTrips) {
      final status = trip.status.value.toLowerCase().trim();
      if (status == 'active' ||
          status == 'in progress' ||
          status == 'in_progress') {
        activeTrips.add(trip);
      }
    }

    // Also check liveTrip (actively being viewed / tracked by driver)
    final liveTrip = tripsController.liveTrip.value;
    if (liveTrip != null && !activeTrips.any((t) => t.id == liveTrip.id)) {
      activeTrips.add(liveTrip);
    }

    // Update in-memory models and sync to Firestore trip documents
    for (final trip in activeTrips) {
      trip.currentDriverLat.value = pos.latitude;
      trip.currentDriverLng.value = pos.longitude;
      if (trip.id.isNotEmpty) {
        TripService.instance.updateDriverLocation(
          trip.id,
          pos.latitude,
          pos.longitude,
          force: forceSync,
        );
      }
    }
  }

  void switchTab(int index) {
    currentTabIndex.value = index;
  }

  /// Cancels all active Firestore listeners across child controllers
  void cleanupAll() {
    stopDriverLiveLocationTracking();
    if (Get.isRegistered<DriverHomeController>()) {
      homeController.clearState();
    }
    if (Get.isRegistered<DriverTripsController>()) {
      tripsController.clearState();
    }
    if (Get.isRegistered<DriverCommunityController>()) {
      communityController.clearState();
    }
    if (Get.isRegistered<DriverSupportController>()) {
      supportController.clearState();
    }
    if (Get.isRegistered<DriverProfileController>()) {
      profileController.clearState();
    }
  }

  @override
  void onClose() {
    cleanupAll();
    _locationSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }
}
