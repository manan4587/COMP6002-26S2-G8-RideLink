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
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class LiveTripTrackingPage extends StatefulWidget {
  const LiveTripTrackingPage({super.key});

  @override
  State<LiveTripTrackingPage> createState() => _LiveTripTrackingPageState();
}

class _LiveTripTrackingPageState extends State<LiveTripTrackingPage> {
  final PassengerDashboardController controller =
      Get.find<PassengerDashboardController>();

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
  int _minutesToArrival = 7;

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
          _minutesToArrival = 7;
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

  @override
  Widget build(BuildContext context) {
    final ride =
        controller.currentSelectedRide.value ?? controller.availableRides.first;

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
                infoWindow: InfoWindow(title: 'Pickup Location'),
              ),
              Marker(
                markerId: const MarkerId('driver_vehicle'),
                position: _currentDriverLocation,
                infoWindow: InfoWindow(
                  title: '${ride.driverName} (${ride.carModel})',
                  snippet: 'Live Carpool Location',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
              ),
              const Marker(
                markerId: MarkerId('dropoff_marker'),
                position: _dropoff,
                infoWindow: InfoWindow(title: 'Drop-off: Curtin University'),
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
                  onTap: () => Get.toNamed(AppRoutes.passengerSafetySos),
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

          // Bottom Slide Card: Driver details, live ETA, and actions
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: MediaQuery.of(context).padding.bottom + 16.h,
            child: Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            ride.driverName.substring(0, 1),
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
                            Text(
                              ride.driverName,
                              style: AppTextStyle.text16Semibold.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            2.verticalSpace,
                            Text(
                              '${ride.carModel} • ${ride.carPlate}',
                              style: AppTextStyle.text12Regular.copyWith(
                                color: AppColors.secondaryTextColor,
                              ),
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

                  14.verticalSpace,
                  const Divider(color: AppColors.borderColor, height: 1),
                  14.verticalSpace,

                  // Cash Settlement Callout
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
                              'Fare (Cash Only)',
                              style: AppTextStyle.text12Regular.copyWith(
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '\$${(ride.pricePerSeat * controller.requestedSeats.value).toStringAsFixed(0)} AUD',
                          style: AppTextStyle.text14Semibold.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  16.verticalSpace,

                  // Action Buttons: Chat & Call Driver
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.toNamed(
                              AppRoutes.rideChat,
                              arguments: {
                                'driverName': ride.driverName,
                                'carModel': ride.carModel,
                                'route': '${ride.origin} → ${ride.destination}',
                              },
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.borderColor,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          icon: const Icon(
                            CupertinoIcons.chat_bubble_2_fill,
                            size: 18,
                          ),
                          label: Text(
                            'Chat Driver',
                            style: AppTextStyle.text14Semibold.copyWith(
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                        ),
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await Utils.launchURL('tel:0412345678');
                            } catch (_) {
                              AppSnackBar.info(
                                message: 'Dialing driver phone...',
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          icon: const Icon(CupertinoIcons.phone_fill, size: 18),
                          label: Text(
                            'Call Driver',
                            style: AppTextStyle.text14Semibold.copyWith(
                              color: Colors.white,
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
