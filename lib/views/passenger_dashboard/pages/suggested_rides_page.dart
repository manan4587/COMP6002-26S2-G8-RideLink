import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/utils.dart';
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

              16.verticalSpace,

              // Search Filter Bar (Date, Time, Seats)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
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
                    Row(
                      children: [
                        // Ride Date Chip / Button
                        Expanded(
                          child: InkWell(
                            onTap: () => controller.pickSearchDate(context),
                            borderRadius: BorderRadius.circular(10.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: const Color(0xFFBFDBFE),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.calendar,
                                    size: 15.sp,
                                    color: AppColors.primaryColor,
                                  ),
                                  6.horizontalSpace,
                                  Expanded(
                                    child: Obx(
                                      () => Text(
                                        controller.formattedSearchDate,
                                        style: AppTextStyle.text12Semibold
                                            .copyWith(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.chevron_down,
                                    size: 11.sp,
                                    color: AppColors.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        8.horizontalSpace,
                        // Preferred Time Chip / Button
                        Expanded(
                          child: InkWell(
                            onTap: () => controller.pickSearchTime(context),
                            borderRadius: BorderRadius.circular(10.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: const Color(0xFFBFDBFE),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.clock,
                                    size: 15.sp,
                                    color: AppColors.primaryColor,
                                  ),
                                  6.horizontalSpace,
                                  Expanded(
                                    child: Obx(
                                      () => Text(
                                        controller.formattedSearchTime,
                                        style: AppTextStyle.text12Semibold
                                            .copyWith(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.chevron_down,
                                    size: 11.sp,
                                    color: AppColors.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    10.verticalSpace,
                    // Quick Date Preset Chips in Suggested Rides
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Obx(() {
                        final activePreset = controller.activeDatePreset.value;
                        return Row(
                          children: [
                            _QuickFilterChip(
                              label: 'Today',
                              isSelected: activePreset == 'Today',
                              onTap: () => controller.selectToday(),
                            ),
                            6.horizontalSpace,
                            _QuickFilterChip(
                              label: 'Tomorrow',
                              isSelected: activePreset == 'Tomorrow',
                              onTap: () => controller.selectTomorrow(),
                            ),
                            6.horizontalSpace,
                            _QuickFilterChip(
                              label: 'This Weekend',
                              isSelected: activePreset == 'Weekend',
                              onTap: () => controller.selectWeekend(),
                            ),
                            6.horizontalSpace,
                            _QuickFilterChip(
                              label: 'Morning (8am)',
                              isSelected: controller.activeTimePreset.value == 'Morning',
                              onTap: () => controller.selectMorning(),
                            ),
                            6.horizontalSpace,
                            _QuickFilterChip(
                              label: 'Evening (5:30pm)',
                              isSelected: controller.activeTimePreset.value == 'Evening',
                              onTap: () => controller.selectEvening(),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),

              16.verticalSpace,

              // List of AI Suggested Rides
              Obx(() {
                final rides = controller.filteredRides;
                if (rides.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 36.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.car_detailed,
                            color: AppColors.primaryColor,
                            size: 36.sp,
                          ),
                        ),
                        16.verticalSpace,
                        Text(
                          'No Rides Available Right Now',
                          style: AppTextStyle.text16Semibold.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        6.verticalSpace,
                        Text(
                          'There are currently no active driver routes matching your criteria. Check back soon or try another route!',
                          style: AppTextStyle.text12Regular.copyWith(
                            color: AppColors.secondaryTextColor,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rides.length,
                  separatorBuilder: (context, index) => 14.verticalSpace,
                  itemBuilder: (context, index) {
                    final ride = rides[index];
                    return _SuggestedRideCard(
                      ride: ride,
                      requestedSeats: controller.requestedSeats.value,
                      onView: () => controller.selectRideForDetails(ride),
                    );
                  },
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
                '${Utils.formatPrice(ride.pricePerSeat)} each • Total ${Utils.formatPrice(totalPrice)}',
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

class _QuickFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyle.text11Medium.copyWith(
            color: isSelected ? Colors.white : AppColors.primaryTextColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
