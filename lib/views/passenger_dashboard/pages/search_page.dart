import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';
import 'package:ridelink/views/passenger_dashboard/widgets/ride_details_sheet.dart';

class SearchPage extends GetView<PassengerDashboardController> {
  const SearchPage({super.key});

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
              Text('Search Rides', style: AppTextStyle.text20Semibold),
              SizedBox(height: 14.h),

              // Inputs Card
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  children: [
                    // From
                    Row(
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.h,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextField(
                            controller: controller.fromLocationController,
                            decoration: InputDecoration(
                              hintText: 'Pickup Location',
                              hintStyle: AppTextStyle.text14Regular.copyWith(
                                color: AppColors.hintTextColor,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: AppTextStyle.text14Medium,
                          ),
                        ),
                        IconButton(
                          onPressed: controller.swapLocations,
                          icon: Icon(
                            CupertinoIcons.arrow_up_arrow_down,
                            size: 18.sp,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),

                    const Divider(color: AppColors.borderColor, height: 1),

                    // To
                    Row(
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.h,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextField(
                            controller: controller.toLocationController,
                            decoration: InputDecoration(
                              hintText: 'Destination',
                              hintStyle: AppTextStyle.text14Regular.copyWith(
                                color: AppColors.hintTextColor,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: AppTextStyle.text14Medium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // Date & Seats Filter Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.calendar,
                            size: 16.sp,
                            color: AppColors.primaryColor,
                          ),
                          SizedBox(width: 8.w),
                          Obx(
                            () => Text(
                              controller.selectedDate.value,
                              style: AppTextStyle.text12Semibold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.person_2,
                                size: 16.sp,
                                color: AppColors.primaryColor,
                              ),
                              SizedBox(width: 8.w),
                              Obx(
                                () => Text(
                                  '${controller.requestedSeats.value} Seat',
                                  style: AppTextStyle.text12Semibold,
                                ),
                              ),
                            ],
                          ),
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                if (controller.requestedSeats.value >= 4) {
                                  controller.requestedSeats.value = 1;
                                } else {
                                  controller.requestedSeats.value++;
                                }
                              },
                              child: Text(
                                '+ Add',
                                style: AppTextStyle.text10Medium.copyWith(
                                  color: AppColors.primaryColor,
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
              ),

              SizedBox(height: 16.h),

              // Quick Filter Tags
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _FilterChip(title: 'All Rides', isSelected: true),
                    _FilterChip(title: 'Verified Drivers', isSelected: false),
                    _FilterChip(title: 'Under \$15', isSelected: false),
                    _FilterChip(title: 'AC Car', isSelected: false),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Results Count
              Obx(
                () => Text(
                  'Matching Rides (${controller.availableRides.length})',
                  style: AppTextStyle.text16Semibold,
                ),
              ),

              SizedBox(height: 10.h),

              // Results List
              Obx(
                () => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.availableRides.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final ride = controller.availableRides[index];
                    return GestureDetector(
                      onTap: () => RideDetailsSheet.show(context, ride),
                      child: Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18.r,
                                  backgroundColor: const Color(0xFFEFF6FF),
                                  child: Text(
                                    ride.driverName[0],
                                    style: AppTextStyle.text14Semibold.copyWith(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ride.driverName,
                                        style: AppTextStyle.text14Semibold,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 13.sp,
                                            color: const Color(0xFFFFB900),
                                          ),
                                          SizedBox(width: 3.w),
                                          Text(
                                            '${ride.rating} (${ride.totalRides})',
                                            style: AppTextStyle.text10Medium
                                                .copyWith(
                                                  color: AppColors
                                                      .secondaryTextColor,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${ride.pricePerSeat.toStringAsFixed(0)}',
                                  style: AppTextStyle.text18Semibold.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${ride.origin} → ${ride.destination}',
                                    style: AppTextStyle.text12MediumOrSmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  ride.departureTime,
                                  style: AppTextStyle.text12Semibold.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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

class _FilterChip extends StatelessWidget {
  final String title;
  final bool isSelected;

  const _FilterChip({required this.title, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor : AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
        ),
      ),
      child: Text(
        title,
        style: AppTextStyle.text12MediumOrSmall.copyWith(
          color: isSelected ? Colors.white : AppColors.primaryTextColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}
