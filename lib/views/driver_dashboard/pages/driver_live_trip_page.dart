import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_controller.dart';

class DriverLiveTripPage extends StatefulWidget {
  const DriverLiveTripPage({super.key});

  @override
  State<DriverLiveTripPage> createState() => _DriverLiveTripPageState();
}

class _DriverLiveTripPageState extends State<DriverLiveTripPage> {
  final DriverTripsController tripsController =
      Get.find<DriverTripsController>();
  final DriverProfileController profileController =
      Get.find<DriverProfileController>();

  GoogleMapController? _mapController;
  Timer? _timer;

  // Route Coordinates (Landsdale -> Perth -> Curtin University corridor)
  static const LatLng _pickup = LatLng(-31.8156, 115.8452);
  static const LatLng _waypoint1 = LatLng(-31.8600, 115.8600);
  static const LatLng _waypoint2 = LatLng(-31.9100, 115.8700);
  static const LatLng _waypoint3 = LatLng(-31.9500, 115.8600);
  static const LatLng _dropoff = LatLng(-32.0044, 115.8947);

  final List<LatLng> _fullRoute = [
    _pickup,
    _waypoint1,
    _waypoint2,
    _waypoint3,
    _dropoff,
  ];

  late LatLng _currentDriverLocation;
  int _step = 0;
  int _minutesToArrival = 6;

  @override
  void initState() {
    super.initState();
    _currentDriverLocation = _pickup;

    // Simulate real-time vehicle movement along the route polyline
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        _step = (_step + 1) % _fullRoute.length;
        _currentDriverLocation = _fullRoute[_step];
        if (_minutesToArrival > 1) {
          _minutesToArrival--;
        } else {
          _minutesToArrival = 6;
        }
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentDriverLocation),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _showRatePassengerSheet(
    DriverTripModel trip,
    PassengerRequestModel passenger,
  ) {
    double selectedRating = 5.0;
    final List<String> availableBadges = [
      'Punctual',
      'Polite & Respectful',
      'Great Communication',
      'Clean & Quiet',
      'Followed Safety Rules',
    ];
    final Set<String> selectedBadges = {'Punctual', 'Polite & Respectful'};
    final TextEditingController commentController = TextEditingController();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  16.verticalSpace,
                  Text(
                    'Trip Completed! 🎉',
                    style: AppTextStyle.text20Semibold.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  6.verticalSpace,
                  Text(
                    'Rate your passenger experience with ${passenger.passengerName}',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.text14Regular.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  18.verticalSpace,

                  // Passenger Avatar & Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50.r,
                        height: 50.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            passenger.passengerName.isNotEmpty
                                ? passenger.passengerName[0]
                                : 'P',
                            style: AppTextStyle.text20Semibold.copyWith(
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      12.horizontalSpace,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            passenger.passengerName,
                            style: AppTextStyle.text16Semibold.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${passenger.seats} Seat(s) • \$${passenger.fare.toStringAsFixed(0)} AUD collected',
                            style: AppTextStyle.text12Regular.copyWith(
                              color: const Color(0xFF16A34A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  16.verticalSpace,

                  // Star Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (starIndex) {
                      final starValue = starIndex + 1.0;
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            selectedRating = starValue;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: Icon(
                            starIndex < selectedRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 38.sp,
                          ),
                        ),
                      );
                    }),
                  ),

                  8.verticalSpace,
                  Text(
                    '${selectedRating.toStringAsFixed(1)} Stars',
                    style: AppTextStyle.text14Semibold.copyWith(
                      color: const Color(0xFFD97706),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  16.verticalSpace,

                  // Badges
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    alignment: WrapAlignment.center,
                    children: availableBadges.map((badge) {
                      final isSelected = selectedBadges.contains(badge);
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            if (isSelected) {
                              selectedBadges.remove(badge);
                            } else {
                              selectedBadges.add(badge);
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 7.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20.r),
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
                    }).toList(),
                  ),

                  16.verticalSpace,

                  // Comment Input
                  TextField(
                    controller: commentController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Add an optional note about this passenger...',
                      hintStyle: AppTextStyle.text12Regular.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: EdgeInsets.all(12.w),
                    ),
                  ),

                  20.verticalSpace,

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // close bottom sheet
                        tripsController.submitPassengerRating(
                          passengerId: passenger.id,
                          passengerName: passenger.passengerName,
                          rating: selectedRating,
                          comment: commentController.text.trim(),
                          trip: trip,
                        );
                        Get.back(); // return to driver dashboard/trips
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'Submit Rating & Finish',
                        style: AppTextStyle.text16Semibold.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = tripsController.liveTrip.value ?? tripsController.myTrips.first;
    final passenger =
        tripsController.livePassenger.value ??
        (trip.acceptedPassengers.isNotEmpty
            ? trip.acceptedPassengers.first
            : (trip.requests.isNotEmpty
                  ? trip.requests.first
                  : PassengerRequestModel(
                      id: 'req_demo',
                      passengerName: 'Manan Patel',
                      rating: 0.0,
                      from: trip.from,
                      to: trip.to,
                      seats: 2,
                      fare: 14.0,
                      time: '08:00 AM',
                      emergencyContactName: 'Sarah Jenkins',
                      emergencyContactRelation: 'Mother',
                      emergencyContactPhone: '+61 412 345 678',
                    )));

    final double totalFare = passenger.fare;

    return Scaffold(
      body: Stack(
        children: [
          // Full Screen Google Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _waypoint2,
              zoom: 11.5,
            ),
            onMapCreated: (map) => _mapController = map,
            markers: {
              const Marker(
                markerId: MarkerId('pickup_marker'),
                position: _pickup,
                infoWindow: InfoWindow(title: 'Passenger Pickup'),
              ),
              Marker(
                markerId: const MarkerId('driver_vehicle'),
                position: _currentDriverLocation,
                infoWindow: InfoWindow(
                  title: 'Your Vehicle (${profileController.vehicleModel.value})',
                  snippet: 'Live Vehicle Location',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
              ),
              const Marker(
                markerId: MarkerId('dropoff_marker'),
                position: _dropoff,
                infoWindow: InfoWindow(title: 'Drop-off Location'),
              ),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId('active_trip_route'),
                points: _fullRoute,
                color: const Color(0xFF2563EB),
                width: 5,
              ),
            },
            myLocationEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Top Header Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.back,
                      color: AppColors.primaryTextColor,
                      size: 20,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      8.horizontalSpace,
                      Text(
                        'Live Trip In Progress',
                        style: AppTextStyle.text12Semibold.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.driverSafetySos),
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      color: Color(0xFFDC2626),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Slide Card: Passenger Details & Trip Controls
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: MediaQuery.of(context).padding.bottom + 14.h,
            child: Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Passenger Header Row
                  Row(
                    children: [
                      Container(
                        width: 46.r,
                        height: 46.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            passenger.passengerName.isNotEmpty
                                ? passenger.passengerName[0]
                                : 'P',
                            style: AppTextStyle.text18Semibold.copyWith(
                              color: AppColors.primaryColor,
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
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    passenger.passengerName,
                                    style: AppTextStyle.text16Semibold.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                6.horizontalSpace,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: const Color(0xFFD97706),
                                        size: 13.sp,
                                      ),
                                      2.horizontalSpace,
                                      Text(
                                        passenger.rating.toStringAsFixed(2),
                                        style: AppTextStyle.text10Medium
                                            .copyWith(
                                              color: const Color(0xFF92400E),
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            3.verticalSpace,
                            Text(
                              '${passenger.seats} Seat(s) • ${trip.from} → ${trip.to}',
                              style: AppTextStyle.text12Regular.copyWith(
                                color: AppColors.secondaryTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'ETA $_minutesToArrival mins',
                          style: AppTextStyle.text12Semibold.copyWith(
                            color: const Color(0xFF16A34A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  12.verticalSpace,

                  // Emergency Contact Section (Unlocked strictly during active trip)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: const Color(0xFFFECACA),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEE2E2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.shield_fill,
                            color: const Color(0xFFDC2626),
                            size: 16.sp,
                          ),
                        ),
                        10.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Passenger Emergency Contact',
                                    style: AppTextStyle.text10Medium.copyWith(
                                      color: const Color(0xFF991B1B),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              2.verticalSpace,
                              Text(
                                '${passenger.emergencyContactName} (${passenger.emergencyContactRelation})',
                                style: AppTextStyle.text12Regular.copyWith(
                                  color: const Color(0xFFB91C1C),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            CupertinoIcons.phone_fill,
                            color: Color(0xFFDC2626),
                            size: 18,
                          ),
                          onPressed: () async {
                            try {
                              await Utils.launchURL(
                                'tel:${passenger.emergencyContactPhone}',
                              );
                            } catch (_) {
                              AppSnackBar.info(
                                message:
                                    'Calling emergency contact ${passenger.emergencyContactPhone}...',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  12.verticalSpace,

                  // Cash Settlement Banner
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.containerFillColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.payments_rounded,
                              color: Color(0xFF16A34A),
                              size: 18,
                            ),
                            8.horizontalSpace,
                            Text(
                              'Fare To Collect (Cash)',
                              style: AppTextStyle.text12Regular.copyWith(
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '\$${totalFare.toStringAsFixed(0)} AUD',
                          style: AppTextStyle.text14Semibold.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  14.verticalSpace,

                  // Actions: Chat, Call, Complete Ride
                  Row(
                    children: [
                      // Chat Passenger
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => tripsController.openDriverChat(
                            passenger: passenger,
                            route: '${trip.from} → ${trip.to}',
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.borderColor,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 11.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          icon: const Icon(
                            CupertinoIcons.chat_bubble_2_fill,
                            size: 17,
                          ),
                          label: Text(
                            'Chat',
                            style: AppTextStyle.text14Semibold.copyWith(
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                        ),
                      ),
                      8.horizontalSpace,
                      // Call Passenger
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              await Utils.launchURL(
                                'tel:${passenger.emergencyContactPhone}',
                              );
                            } catch (_) {
                              AppSnackBar.info(
                                message:
                                    'Dialing passenger ${passenger.passengerName}...',
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF93C5FD)),
                            backgroundColor: const Color(0xFFEFF6FF),
                            padding: EdgeInsets.symmetric(vertical: 11.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          icon: const Icon(
                            CupertinoIcons.phone_fill,
                            color: Color(0xFF2563EB),
                            size: 17,
                          ),
                          label: Text(
                            'Call',
                            style: AppTextStyle.text14Semibold.copyWith(
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ),
                      8.horizontalSpace,
                      // Complete Ride
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showRatePassengerSheet(trip, passenger),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 11.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          icon: const Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            size: 17,
                          ),
                          label: Text(
                            'Complete Ride',
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
          ),
        ],
      ),
    );
  }
}
