import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_controller.dart';

class DriverRequestsPage extends GetView<DriverTripsController> {
  const DriverRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Passenger Requests', style: AppTextStyle.text20Semibold),
              SizedBox(height: 6.h),
              Text(
                'Review incoming bookings from passengers along your route.',
                style: AppTextStyle.text14Regular.copyWith(
                  color: AppColors.secondaryTextColor,
                ),
              ),

              SizedBox(height: 18.h),

              Expanded(
                child: Obx(() {
                  if (controller.pendingRequests.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.checkmark_seal,
                            size: 48.sp,
                            color: AppColors.secondaryTextColor,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'No pending requests',
                            style: AppTextStyle.text16Semibold,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'All passenger requests have been reviewed.',
                            style: AppTextStyle.text12Regular.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.pendingRequests.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 14.h),
                    itemBuilder: (context, index) {
                      final req = controller.pendingRequests[index];
                      return Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20.r,
                                  backgroundColor: const Color(0xFFEFF6FF),
                                  child: Text(
                                    req.passengerName[0],
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
                                        req.passengerName,
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
                                            '${req.rating} Passenger Rating',
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
                                  '\$${req.fare.toStringAsFixed(2)}',
                                  style: AppTextStyle.text18Semibold.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12.h),
                            const Divider(
                              color: AppColors.borderColor,
                              height: 1,
                            ),
                            SizedBox(height: 12.h),

                            // Requested Route
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16.sp,
                                  color: AppColors.primaryColor,
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    '${req.from} → ${req.to}',
                                    style: AppTextStyle.text12Semibold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              '${req.seats} Seat requested • Departure ${req.time}',
                              style: AppTextStyle.text12Regular.copyWith(
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: AppColors.borderColor.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.lock_shield,
                                    size: 13.sp,
                                    color: AppColors.secondaryTextColor,
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      'Emergency contact unlocks when ride starts',
                                      style: AppTextStyle.text10Medium.copyWith(
                                        color: AppColors.secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 14.h),

                            // Accept / Decline Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        controller.declineRequest(req),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.borderColor,
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                    ),
                                    child: Text(
                                      'Decline',
                                      style: AppTextStyle.text12Semibold.copyWith(
                                        color: AppColors.secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        controller.acceptRequest(req),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                    ),
                                    child: Text(
                                      'Accept Booking',
                                      style: AppTextStyle.buttonText.copyWith(
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
