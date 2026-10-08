import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class RequestApprovedPage extends GetView<PassengerDashboardController> {
  const RequestApprovedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ride = controller.currentSelectedRide.value ??
        (controller.availableRides.isNotEmpty
            ? controller.availableRides.first
            : null);

    if (ride == null) {
      return Scaffold(
        backgroundColor: AppColors.secondaryBgColor,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.checkmark_seal_fill, size: 48, color: Color(0xFF16A34A)),
                12.verticalSpace,
                Text('Booking Approved', style: AppTextStyle.text18Semibold),
                16.verticalSpace,
                ElevatedButton(
                  onPressed: () {
                    controller.currentTabIndex.value = 2; // Trips tab
                    Get.offAllNamed(AppRoutes.passengerDashboard);
                  },
                  child: const Text('View My Trips'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final int seatsNeeded = controller.requestedSeats.value;

    return Scaffold(
      backgroundColor: AppColors.secondaryBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              // Top Back button row
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

              20.verticalSpace,

              // Circular Green Checkmark Icon matching reference
              Container(
                width: 72.w,
                height: 72.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: const Color(0xFF16A34A),
                    size: 40.sp,
                  ),
                ),
              ),

              18.verticalSpace,

              Text(
                'Your Request Has Been\nApproved',
                textAlign: TextAlign.center,
                style: AppTextStyle.text24Semibold.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  color: AppColors.primaryTextColor,
                ),
              ),

              26.verticalSpace,

              // Driver Tile
              _ApprovedSummaryTile(
                icon: CupertinoIcons.person,
                title: 'Driver',
                subtitle: ride.driverName,
              ),

              12.verticalSpace,

              // Seats Approved Tile
              Obx(() {
                final pName = controller.passengerName.value.isNotEmpty
                    ? controller.passengerName.value
                    : (Preferences.userName.isNotEmpty
                        ? Preferences.userName
                        : 'You');
                final subtitle = seatsNeeded > 1
                    ? '$pName + ${seatsNeeded - 1} passenger${seatsNeeded > 2 ? 's' : ''} • $seatsNeeded seats'
                    : '$pName • $seatsNeeded seat';
                return _ApprovedSummaryTile(
                  icon: CupertinoIcons.car_detailed,
                  title: 'Seats Approved',
                  subtitle: subtitle,
                );
              }),

              12.verticalSpace,

              // Pickup Tile
              _ApprovedSummaryTile(
                icon: CupertinoIcons.location,
                title: 'Pickup',
                subtitle: '${ride.pickupSuggestion} • ${ride.departureTime}',
              ),

              12.verticalSpace,

              // Car Tile
              _ApprovedSummaryTile(
                icon: CupertinoIcons.car,
                title: 'Car',
                subtitle: '${ride.carModel} • ${ride.carPlate}',
              ),

              24.verticalSpace,

              // Start Live Trip CTA Button
              GestureDetector(
                onTap: () {
                  if (controller.currentSelectedRide.value == null) {
                    controller.currentSelectedRide.value = ride;
                  }
                  Get.toNamed(AppRoutes.liveTripTracking);
                },
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
                      Icon(
                        CupertinoIcons.location_fill,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      10.horizontalSpace,
                      Text(
                        'Start Live Trip',
                        style: AppTextStyle.text16Semibold.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              12.verticalSpace,

              // View in My Trips Secondary Button
              OutlinedButton(
                onPressed: () {
                  controller.currentTabIndex.value = 2; // Trips tab
                  controller.selectedTripsTab.value = 1; // Confirmed tab
                  Get.offAllNamed(AppRoutes.passengerDashboard);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48.h),
                  side: const BorderSide(color: AppColors.borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  'View in My Trips',
                  style: AppTextStyle.text14Semibold.copyWith(
                    color: AppColors.primaryTextColor,
                  ),
                ),
              ),

              20.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class _ApprovedSummaryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ApprovedSummaryTile({
    required this.icon,
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
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primaryColor,
              size: 18.sp,
            ),
          ),
          14.horizontalSpace,
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

