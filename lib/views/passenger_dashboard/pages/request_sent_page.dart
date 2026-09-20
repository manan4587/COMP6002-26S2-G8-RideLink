import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class RequestSentPage extends GetView<PassengerDashboardController> {
  const RequestSentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ride = controller.currentSelectedRide.value ?? controller.availableRides.first;
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

              // Circular Clock Icon matching reference
              Container(
                width: 72.w,
                height: 72.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFBEB),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.access_time_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 38.sp,
                  ),
                ),
              ),

              18.verticalSpace,

              Text(
                'Request Sent',
                style: AppTextStyle.text24Semibold.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryTextColor,
                ),
              ),
              6.verticalSpace,
              Text(
                'Waiting for driver approval.',
                style: AppTextStyle.text14Regular.copyWith(
                  color: AppColors.secondaryTextColor,
                ),
              ),

              26.verticalSpace,

              // Your Request Card
              _SummaryTile(
                icon: CupertinoIcons.car_detailed,
                title: 'Your Request',
                subtitle: 'Manan + 1 passenger • $seatsNeeded seats',
              ),

              12.verticalSpace,

              // Status Card
              _SummaryTile(
                icon: CupertinoIcons.bell,
                title: 'Status',
                subtitle: 'Awaiting driver approval',
              ),

              12.verticalSpace,

              // Pickup Card
              _SummaryTile(
                icon: CupertinoIcons.location,
                title: 'Pickup',
                subtitle: ride.pickupSuggestion,
              ),

              28.verticalSpace,

              // View My Trips CTA Button
              GestureDetector(
                onTap: () {
                  controller.switchTab(2); // Jump to Trips tab
                  controller.selectedTripsTab.value = 0; // Show Pending Requests tab
                  Get.offAllNamed(AppRoutes.passengerDashboard);
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
                      const Icon(
                        CupertinoIcons.car_detailed,
                        color: Colors.white,
                        size: 20,
                      ),
                      10.horizontalSpace,
                      Text(
                        'View My Trips',
                        style: AppTextStyle.text16Semibold.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              14.verticalSpace,

              // Test Simulator CTA for User / Admin demo
              TextButton(
                onPressed: controller.simulateDriverApproval,
                child: Text(
                  '⚡ Simulate Driver Approval (Demo) →',
                  style: AppTextStyle.text12Semibold.copyWith(
                    color: AppColors.primaryColor,
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

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SummaryTile({
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

