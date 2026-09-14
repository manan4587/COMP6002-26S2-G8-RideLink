import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_controller.dart';

class DriverHomePage extends GetView<DriverDashboardController> {
  const DriverHomePage({super.key});

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
              // Driver Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46.w,
                        height: 46.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEFF6FF),
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'JM',
                            style: AppTextStyle.text16Semibold.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'James Miller',
                                style: AppTextStyle.text18Semibold,
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.verified,
                                size: 16.sp,
                                color: AppColors.primaryColor,
                              ),
                            ],
                          ),
                          Text(
                            'Verified Driver • 4.9 ★',
                            style: AppTextStyle.text12Regular.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Online / Offline Toggle
                  Obx(
                    () => GestureDetector(
                      onTap: controller.toggleOnlineStatus,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: controller.isOnline.value
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: controller.isOnline.value
                                ? const Color(0xFF16A34A)
                                : AppColors.borderColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: controller.isOnline.value
                                    ? const Color(0xFF16A34A)
                                    : AppColors.secondaryTextColor,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              controller.isOnline.value ? 'Online' : 'Offline',
                              style: AppTextStyle.text12Semibold.copyWith(
                                color: controller.isOnline.value
                                    ? const Color(0xFF16A34A)
                                    : AppColors.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Earnings Banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Earnings",
                      style: AppTextStyle.text14Medium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Obx(
                      () => Text(
                        '\$${controller.todayEarnings.value.toStringAsFixed(2)}',
                        style: AppTextStyle.text30Semibold.copyWith(
                          color: Colors.white,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatItem(
                          label: 'Completed Trips',
                          value: '${controller.completedTripsCount.value}',
                        ),
                        _StatItem(
                          label: 'Weekly Total',
                          value:
                              '\$${controller.weeklyEarnings.value.toStringAsFixed(0)}',
                        ),
                        _StatItem(label: 'Acceptance', value: '98%'),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 22.h),

              // Publish New Ride Quick Action
              GestureDetector(
                onTap: () => controller.switchTab(1),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.primaryColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.plus_circle_fill,
                        color: AppColors.primaryColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Publish a New Trip',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Scheduled Trips List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Published Trips', style: AppTextStyle.text18Semibold),
                  Obx(
                    () => Text(
                      '${controller.myTrips.length} Active',
                      style: AppTextStyle.text12Semibold.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              Obx(
                () => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.myTrips.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final trip = controller.myTrips[index];
                    return Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  trip.status,
                                  style: AppTextStyle.text10Medium.copyWith(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '\$${trip.pricePerSeat.toStringAsFixed(0)} / seat',
                                style: AppTextStyle.text14Semibold.copyWith(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            '${trip.from} → ${trip.to}',
                            style: AppTextStyle.text14Semibold,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            trip.time,
                            style: AppTextStyle.text12Regular.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Booked: ${trip.bookedSeats}/${trip.totalSeats} seats',
                                style: AppTextStyle.text12Semibold,
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 6.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                                child: Text(
                                  'Start Ride',
                                  style: AppTextStyle.buttonText.copyWith(
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyle.text16Semibold.copyWith(color: Colors.white),
        ),
        Text(
          label,
          style: AppTextStyle.text10Medium.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}
