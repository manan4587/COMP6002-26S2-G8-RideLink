import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/services/notification_service.dart';
import 'package:ridelink/theme/app_text_style.dart';

enum LocationCheckResult { granted, serviceDisabled, denied, deniedForever }

class DeviceLocationService {
  DeviceLocationService._();
  static final DeviceLocationService instance = DeviceLocationService._();

  // In-memory location and position caching
  LatLng? _cachedPosition;
  LatLng? get cachedPosition => _cachedPosition;

  Position? _cachedPositionData;
  Position? get cachedPositionData => _cachedPositionData;

  double _cachedHeading = 0.0;
  double get cachedHeading => _cachedHeading;

  DateTime? _lastFixTime;
  DateTime? get lastFixTime => _lastFixTime;

  // Single in-flight permission request guard to prevent concurrent platform channel deadlocks
  Future<LocationCheckResult>? _inFlightPermissionCheck;

  /// High-precision LocationSettings configured specifically for automotive navigation (Uber / Ola grade)
  LocationSettings getLocationSettings({
    LocationAccuracy accuracy = LocationAccuracy.bestForNavigation,
    int distanceFilter = 0,
    Duration? timeLimit,
  }) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        forceLocationManager:
            false, // MANDATORY: Use Google Play Services FusedLocationProviderClient for multi-sensor satellite/Wi-Fi fusion
        intervalDuration: const Duration(
          milliseconds: 1000,
        ), // 1 update per second
        timeLimit: timeLimit,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return AppleSettings(
        accuracy: accuracy,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: distanceFilter,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
        timeLimit: timeLimit,
      );
    } else {
      return LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        timeLimit: timeLimit,
      );
    }
  }

  /// Detailed permission and service check that actively requests permission if needed
  Future<LocationCheckResult> checkAndRequestPermissionDetails() async {
    if (_inFlightPermissionCheck != null) {
      return await _inFlightPermissionCheck!;
    }
    _inFlightPermissionCheck = _performPermissionCheck();
    try {
      return await _inFlightPermissionCheck!;
    } finally {
      _inFlightPermissionCheck = null;
    }
  }

  Future<LocationCheckResult> _performPermissionCheck() async {
    try {
      // Actively request notification permissions alongside location
      NotificationService.instance.init().catchError((_) {});

      // 1. Check current permission status first
      LocationPermission permission = await Geolocator.checkPermission();

      // 2. If denied, actively trigger the operating system permission dialog
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 3. If permanently denied / blocked in settings
      if (permission == LocationPermission.deniedForever) {
        return LocationCheckResult.deniedForever;
      }

      // 4. If user chose 'Don't allow'
      if (permission == LocationPermission.denied) {
        return LocationCheckResult.denied;
      }

      // 5. Permission is granted (whileInUse or always) - check if device GPS toggle is turned on
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationCheckResult.serviceDisabled;
      }

      return LocationCheckResult.granted;
    } catch (_) {
      return LocationCheckResult.denied;
    }
  }

  /// Check and request location permissions on the device
  Future<bool> checkAndRequestPermission() async {
    final status = await checkAndRequestPermissionDetails();
    return status == LocationCheckResult.granted;
  }

  /// Get the current high-precision GPS position (hardware-level satellite fix like Uber/Ola)
  Future<Position?> getCurrentPosition({
    bool forceFresh = true,
    Duration timeout = const Duration(seconds: 7),
  }) async {
    // If not forcing fresh and we have a very recent cache (< 10 seconds), return it
    if (!forceFresh &&
        _cachedPositionData != null &&
        _lastFixTime != null &&
        DateTime.now().difference(_lastFixTime!).inSeconds < 10) {
      return _cachedPositionData;
    }

    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return _cachedPositionData;

      // Request fresh hardware position using Fused Location Provider with bestForNavigation
      final position = await Geolocator.getCurrentPosition(
        locationSettings: getLocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: timeout,
        ),
      ).timeout(timeout);

      _updateCachedData(position);
      return position;
    } catch (e) {
      debugPrint(
        '[DeviceLocationService] Direct GPS fix timed out/failed: $e. Falling back to last known.',
      );
      // Only fall back to last known if fresh GPS timed out
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          _updateCachedData(lastKnown);
          return lastKnown;
        }
      } catch (_) {}
      return _cachedPositionData;
    }
  }

  /// Get current real GPS coordinates of the device (guaranteed accurate and fresh)
  Future<LatLng?> getCurrentDeviceLocation({
    bool forceFresh = true,
    Duration timeout = const Duration(seconds: 7),
  }) async {
    final pos = await getCurrentPosition(
      forceFresh: forceFresh,
      timeout: timeout,
    );
    return pos != null ? LatLng(pos.latitude, pos.longitude) : null;
  }

  void _updateCachedData(Position pos) {
    _cachedPosition = LatLng(pos.latitude, pos.longitude);
    _cachedPositionData = pos;
    _cachedHeading = pos.heading;
    _lastFixTime = DateTime.now();
  }

  /// Stream continuous high-precision GPS updates as the device moves
  Stream<Position> streamDevicePosition({
    int distanceFilterMeters = 0,
    LocationAccuracy accuracy = LocationAccuracy.bestForNavigation,
  }) async* {
    if (_cachedPositionData != null) {
      yield _cachedPositionData!;
    }

    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) return;

    yield* Geolocator.getPositionStream(
      locationSettings: getLocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilterMeters,
      ),
    ).map((pos) {
      _updateCachedData(pos);
      return pos;
    });
  }

  /// Stream continuous LatLng coordinates as the device moves
  Stream<LatLng> streamDeviceLocation({int distanceFilterMeters = 0}) {
    return streamDevicePosition(
      distanceFilterMeters: distanceFilterMeters,
    ).map((pos) => LatLng(pos.latitude, pos.longitude));
  }

  /// Displays a RideLink standard Bottom Sheet explaining that location permission is blocked
  void showLocationBlockedSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Container(
        padding: EdgeInsets.only(
          top: 12.h,
          left: 20.w,
          right: 20.w,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top drag handle pill
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
            20.verticalSpace,
            // Soft red circular icon container
            Container(
              width: 58.r,
              height: 58.r,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.location_slash_fill,
                color: Color(0xFFDC2626),
                size: 28,
              ),
            ),
            14.verticalSpace,
            Text(
              'Location Access is Blocked',
              style: AppTextStyle.text18Bold.copyWith(
                color: AppColors.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            8.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                'Location permission has been permanently blocked on your device. Please allow location access in App Settings so RideLink can detect your live position and provide accurate ride routes.',
                style: AppTextStyle.text14Regular.copyWith(
                  color: AppColors.secondaryTextColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            22.verticalSpace,
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      side: const BorderSide(color: AppColors.borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.text14Semibold.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      await Geolocator.openAppSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Open Settings',
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

  /// Displays a RideLink standard Bottom Sheet explaining that device GPS is turned off
  void showLocationServiceDisabledSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Container(
        padding: EdgeInsets.only(
          top: 12.h,
          left: 20.w,
          right: 20.w,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top drag handle pill
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
            20.verticalSpace,
            // Soft amber circular icon container
            Container(
              width: 58.r,
              height: 58.r,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.location_fill,
                color: Color(0xFFD97706),
                size: 28,
              ),
            ),
            14.verticalSpace,
            Text(
              'Device GPS is Turned Off',
              style: AppTextStyle.text18Bold.copyWith(
                color: AppColors.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            8.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                'Your device location services are currently turned off. Please turn on GPS so RideLink can accurately detect your live location.',
                style: AppTextStyle.text14Regular.copyWith(
                  color: AppColors.secondaryTextColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            22.verticalSpace,
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      side: const BorderSide(color: AppColors.borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.text14Semibold.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      await Geolocator.openLocationSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Turn On Location',
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
}
