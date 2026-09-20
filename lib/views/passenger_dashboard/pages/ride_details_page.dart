import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class RideDetailsPage extends GetView<PassengerDashboardController> {
  const RideDetailsPage({super.key});

  static const LatLng _pickupPoint = LatLng(-31.8156, 115.8452); // Landsdale
  static const LatLng _dropoffPoint = LatLng(-32.0044, 115.8947); // Curtin University
  static const LatLng _driverMidPoint = LatLng(-31.9100, 115.8700);

  @override
  Widget build(BuildContext context) {
    final ride = controller.currentSelectedRide.value ?? controller.availableRides.first;
    final int seatsNeeded = controller.requestedSeats.value;
    final double totalPrice = ride.pricePerSeat * seatsNeeded;

    return Scaffold(
      backgroundColor: AppColors.secondaryBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Back Navigation & Centered Title
              Stack(
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
                    'Ride Details',
                    style: AppTextStyle.text20Semibold.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                ],
              ),

              18.verticalSpace,

              // Interactive Google Map Card with Route & Markers
              Container(
                height: 190.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(-31.9100, 115.8700),
                          zoom: 10.5,
                        ),
                        markers: {
                          const Marker(
                            markerId: MarkerId('pickup'),
                            position: _pickupPoint,
                            infoWindow: InfoWindow(title: 'Pickup: Landsdale'),
                          ),
                          const Marker(
                            markerId: MarkerId('driver'),
                            position: _driverMidPoint,
                            infoWindow: InfoWindow(title: 'Driver Live Vehicle'),
                          ),
                          const Marker(
                            markerId: MarkerId('dropoff'),
                            position: _dropoffPoint,
                            infoWindow: InfoWindow(title: 'Drop-off: Curtin'),
                          ),
                        },
                        polylines: {
                          Polyline(
                            polylineId: const PolylineId('route_preview'),
                            points: const [
                              _pickupPoint,
                              _driverMidPoint,
                              _dropoffPoint,
                            ],
                            color: const Color(0xFF2563EB),
                            width: 4,
                          ),
                        },
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                      ),

                      // Overlay Badge to clearly denote Live Route
                      Positioned(
                        top: 12.h,
                        left: 12.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF16A34A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              6.horizontalSpace,
                              Text(
                                'Live Corridor Preview',
                                style: AppTextStyle.text10Medium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              16.verticalSpace,

              // Driver Card
              _DetailCard(
                icon: CupertinoIcons.shield_lefthalf_fill,
                iconColor: const Color(0xFF2563EB),
                iconBg: const Color(0xFFEFF6FF),
                title: '${ride.driverName} • Verified Driver',
                subtitle:
                    '${ride.carModel} • ${ride.carPlate}\nTrust Rating ${ride.rating.toStringAsFixed(2)} ★',
              ),

              12.verticalSpace,

              // Your Request Card
              _DetailCard(
                icon: CupertinoIcons.car_detailed,
                iconColor: AppColors.primaryColor,
                iconBg: const Color(0xFFEFF6FF),
                title: 'Your Request',
                subtitle:
                    '${controller.seatsNote.value}\nSeats Needed: $seatsNeeded • Total: \$${totalPrice.toStringAsFixed(0)}',
              ),

              12.verticalSpace,

              // Pickup Suggestion Card
              _DetailCard(
                icon: CupertinoIcons.location,
                iconColor: AppColors.primaryColor,
                iconBg: const Color(0xFFEFF6FF),
                title: 'Pickup Suggestion',
                subtitle: ride.pickupSuggestion,
              ),

              12.verticalSpace,

              // Drop-off Plan Card
              _DetailCard(
                icon: CupertinoIcons.arrow_branch,
                iconColor: AppColors.primaryColor,
                iconBg: const Color(0xFFEFF6FF),
                title: 'Drop-off Plan',
                subtitle: ride.dropOffPlan,
              ),

              16.verticalSpace,

              // Cost & Detour Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.money_dollar_circle,
                            color: AppColors.primaryColor,
                            size: 18.sp,
                          ),
                          10.horizontalSpace,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cost Each',
                                style: AppTextStyle.text10Medium.copyWith(
                                  color: AppColors.secondaryTextColor,
                                ),
                              ),
                              2.verticalSpace,
                              Text(
                                '\$${ride.pricePerSeat.toStringAsFixed(0)}',
                                style: AppTextStyle.text16Semibold.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  12.horizontalSpace,

                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.clock,
                            color: AppColors.primaryColor,
                            size: 18.sp,
                          ),
                          10.horizontalSpace,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detour',
                                style: AppTextStyle.text10Medium.copyWith(
                                  color: AppColors.secondaryTextColor,
                                ),
                              ),
                              2.verticalSpace,
                              Text(
                                '${ride.detourMinutes} min',
                                style: AppTextStyle.text16Semibold.copyWith(
                                  fontWeight: FontWeight.bold,
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

              20.verticalSpace,

              // Dynamic Request Button State: Disabled if already requested/pending
              Obx(() {
                final bool isPending = controller.pendingRequests
                    .any((p) => p.ride.id == ride.id);
                final bool isConfirmed = controller.myBookings
                    .any((b) => b.ride.id == ride.id);

                if (isPending) {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                            8.horizontalSpace,
                            Text(
                              'Request Pending Approval',
                              style: AppTextStyle.text16Semibold.copyWith(
                                color: const Color(0xFFB45309),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      8.verticalSpace,
                      Text(
                        'You have already requested this ride. Waiting for driver approval.',
                        style: AppTextStyle.text12Regular.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }

                if (isConfirmed) {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF16A34A),
                              size: 20,
                            ),
                            8.horizontalSpace,
                            Text(
                              'Ride Already Confirmed',
                              style: AppTextStyle.text16Semibold.copyWith(
                                color: const Color(0xFF15803D),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      10.verticalSpace,
                      OutlinedButton.icon(
                        onPressed: () {
                          controller.currentSelectedRide.value = ride;
                          Get.toNamed(AppRoutes.liveTripTracking);
                        },
                        icon: const Icon(
                          CupertinoIcons.location_fill,
                          size: 16,
                          color: AppColors.primaryColor,
                        ),
                        label: Text(
                          'Track Live Trip on Map',
                          style: AppTextStyle.text14Semibold.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 44.h),
                          side: const BorderSide(color: AppColors.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return GestureDetector(
                  onTap: () => controller.requestToJoinRide(ride),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        8.horizontalSpace,
                        Text(
                          'Request to Join',
                          style: AppTextStyle.text16Semibold.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              24.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;

  const _DetailCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.text14Semibold.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                3.verticalSpace,
                Text(
                  subtitle,
                  style: AppTextStyle.text12Regular.copyWith(
                    color: AppColors.secondaryTextColor,
                    height: 1.35,
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

