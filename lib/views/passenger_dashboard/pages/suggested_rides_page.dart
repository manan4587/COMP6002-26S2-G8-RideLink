import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class SuggestedRidesPage extends GetView<PassengerDashboardController> {
  const SuggestedRidesPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  Column(
                    children: [
                      Text(
                        'Suggested Rides',
                        style: AppTextStyle.text20Semibold.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      2.verticalSpace,
                      Text(
                        'Best matches with enough seats',
                        style: AppTextStyle.text12Regular.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              18.verticalSpace,

              // List of AI Suggested Rides
              Obx(
                () => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.availableRides.length,
                  separatorBuilder: (context, index) => 14.verticalSpace,
                  itemBuilder: (context, index) {
                    final ride = controller.availableRides[index];
                    return _SuggestedRideCard(
                      ride: ride,
                      requestedSeats: controller.requestedSeats.value,
                      onView: () => controller.selectRideForDetails(ride),
                    );
                  },
                ),
              ),

              24.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestedRideCard extends StatelessWidget {
  final RideModel ride;
  final int requestedSeats;
  final VoidCallback onView;

  const _SuggestedRideCard({
    required this.ride,
    required this.requestedSeats,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final double totalPrice = ride.pricePerSeat * requestedSeats;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver Info Row
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.car_detailed,
                  color: AppColors.primaryColor,
                  size: 20.sp,
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
                      'Trust Rating: ${ride.rating.toStringAsFixed(2)} ★',
                      style: AppTextStyle.text12Regular.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          14.verticalSpace,

          // Tags Row: Match, Detour, Seats available
          Row(
            children: [
              Text(
                'Match ${ride.matchPercentage}%',
                style: AppTextStyle.text12Semibold.copyWith(
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                ),
              ),
              8.horizontalSpace,
              Text(
                'Detour +${ride.detourMinutes} min',
                style: AppTextStyle.text12Regular.copyWith(
                  color: AppColors.secondaryTextColor,
                ),
              ),
              8.horizontalSpace,
              Text(
                'Seats ${ride.seatsAvailable} available',
                style: AppTextStyle.text12Semibold.copyWith(
                  color: const Color(0xFF16A34A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          14.verticalSpace,

          // Price & View CTA Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '\$${ride.pricePerSeat.toStringAsFixed(0)} each • Total \$${totalPrice.toStringAsFixed(0)}',
                style: AppTextStyle.text14Semibold.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTextColor,
                ),
              ),
              GestureDetector(
                onTap: onView,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFFDBEAFE),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'View',
                    style: AppTextStyle.text12Semibold.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
