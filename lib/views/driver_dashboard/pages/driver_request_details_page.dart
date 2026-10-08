import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_controller.dart';

class DriverRequestDetailsPage extends GetView<DriverTripsController> {
  const DriverRequestDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Obx(() {
          final trip = controller.selectedTripForRequests.value;
          final req = controller.selectedRequest.value;

          if (trip == null || req == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No request selected'),
                  12.verticalSpace,
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Back'),
                  ),
                ],
              ),
            );
          }

          final bool isAccepted = req.status.value == 'Accepted';
          final bool isDeclined = req.status.value == 'Declined';

          return Column(
            children: [
              // Screen 25 Top Bar: Back button and Centered "Request Details"
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          CupertinoIcons.back,
                          size: 22.sp,
                          color: AppColors.primaryTextColor,
                        ),
                        splashRadius: 22.r,
                      ),
                    ),
                    Text(
                      'Request Details',
                      style: AppTextStyle.text18Bold.copyWith(
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFDBEAFE),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          tooltip: 'Chat with passenger',
                          onPressed: () => controller.openDriverChat(
                            passenger: req,
                            tripId: trip.id,
                            route: '${trip.from} → ${trip.to}',
                          ),
                          icon: Icon(
                            CupertinoIcons.chat_bubble_2_fill,
                            size: 18.sp,
                            color: const Color(0xFF2563EB),
                          ),
                          splashRadius: 20.r,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                  child: Column(
                    children: [
                      // Card 1: Requested by
                      _DetailCard(
                        icon: CupertinoIcons.person,
                        title: 'Requested by',
                        subtitle:
                            '${req.passengerName} • Trust Rating ${req.rating.toStringAsFixed(2)} ★',
                      ),

                      12.verticalSpace,

                      // Card 2: Travelling With
                      _DetailCard(
                        icon: CupertinoIcons.person_2,
                        title: 'Travelling With',
                        subtitle:
                            '${req.travellingWith} • ${req.seats} seats needed',
                      ),

                      12.verticalSpace,

                      // Card 3: Pickup
                      _DetailCard(
                        icon: CupertinoIcons.location_solid,
                        title: 'Pickup',
                        subtitle: req.from,
                      ),

                      12.verticalSpace,

                      // Card 4: Drop-off
                      _DetailCard(
                        icon: CupertinoIcons.map,
                        title: 'Drop-off',
                        subtitle: req.to,
                      ),

                      12.verticalSpace,

                      // Card 5: Side-by-Side Metric Cards Row
                      Row(
                        children: [
                          // Past Trips
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star_outline_rounded,
                                        size: 18.sp,
                                        color: const Color(0xFF2563EB),
                                      ),
                                      6.horizontalSpace,
                                      Text(
                                        'Past Trips',
                                        style: AppTextStyle.text12Regular
                                            .copyWith(
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  8.verticalSpace,
                                  Text(
                                    '${req.pastTrips}',
                                    style: AppTextStyle.text16Semibold.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          12.horizontalSpace,
                          // After Accept Seats
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.car_detailed,
                                        size: 18.sp,
                                        color: const Color(0xFF2563EB),
                                      ),
                                      6.horizontalSpace,
                                      Text(
                                        'After Accept',
                                        style: AppTextStyle.text12Regular
                                            .copyWith(
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  8.verticalSpace,
                                  Obx(
                                    () {
                                      final afterAccept = isAccepted
                                          ? trip.bookedSeats.value
                                          : (trip.bookedSeats.value +
                                              req.seats);
                                      return Text(
                                        '$afterAccept/${trip.totalSeats.value} seats',
                                        style: AppTextStyle.text16Semibold
                                            .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      12.verticalSpace,

                      // Card 6: AI Detour Check
                      _DetailCard(
                        icon: CupertinoIcons.bolt_fill,
                        title: 'AI Detour Check',
                        subtitle: _calculateDynamicDetour(trip, req),
                      ),

                      20.verticalSpace,
                    ],
                  ),
                ),
              ),

              // Bottom Fixed Action Bar: Accept and Decline Buttons (Screen 25)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border(
                    top: BorderSide(color: AppColors.borderColor, width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: isAccepted
                      ? Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Center(
                            child: Text(
                              'Request Already Accepted ✓',
                              style: AppTextStyle.text14Semibold.copyWith(
                                color: const Color(0xFF15803D),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : isDeclined
                          ? Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: const Color(0xFFFECACA)),
                              ),
                              child: Center(
                                child: Text(
                                  'Request Declined',
                                  style: AppTextStyle.text14Semibold.copyWith(
                                    color: const Color(0xFFDC2626),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : Row(
                              children: [
                                // Accept Button (Blue Pill / Primary)
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      controller.acceptRideRequest(trip, req);
                                      Get.back();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                      ),
                                    ),
                                    icon: const Icon(
                                      CupertinoIcons.checkmark_alt,
                                      size: 18,
                                    ),
                                    label: Text(
                                      'Accept',
                                      style: AppTextStyle.text14Semibold
                                          .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                12.horizontalSpace,
                                // Decline Button (Red Solid)
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      controller.declineRideRequest(trip, req);
                                      Get.back();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFDC2626),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.warning_amber_rounded,
                                      size: 18,
                                    ),
                                    label: Text(
                                      'Decline',
                                      style: AppTextStyle.text14Semibold
                                          .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _calculateDynamicDetour(
    DriverTripModel trip,
    PassengerRequestModel req,
  ) {
    if (trip.fromLat == 0.0 ||
        trip.toLat == 0.0 ||
        req.pickupLat == 0.0 ||
        req.dropLat == 0.0) {
      if (req.detour.isNotEmpty && req.detour != '+4 minutes only') {
        return req.detour;
      }
      return '+2 mins detour (Direct commute corridor)';
    }

    final directDist = Geolocator.distanceBetween(
      trip.fromLat,
      trip.fromLng,
      trip.toLat,
      trip.toLng,
    );
    final detourDist = Geolocator.distanceBetween(
          trip.fromLat,
          trip.fromLng,
          req.pickupLat,
          req.pickupLng,
        ) +
        Geolocator.distanceBetween(
          req.pickupLat,
          req.pickupLng,
          req.dropLat,
          req.dropLng,
        ) +
        Geolocator.distanceBetween(
          req.dropLat,
          req.dropLng,
          trip.toLat,
          trip.toLng,
        );

    final extraMeters = (detourDist - directDist).clamp(0.0, 50000.0);
    final extraKm = extraMeters / 1000.0;
    final extraMins = (extraKm / 35.0 * 60).round();

    if (extraMins <= 1) {
      return '+1 min detour (~${extraKm.toStringAsFixed(1)} km extra • Optimal Route)';
    }
    return '+$extraMins mins detour (~${extraKm.toStringAsFixed(1)} km extra route)';
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2563EB),
              size: 20.sp,
            ),
          ),
          14.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.text12Medium.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                4.verticalSpace,
                Text(
                  subtitle,
                  style: AppTextStyle.text14Medium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

