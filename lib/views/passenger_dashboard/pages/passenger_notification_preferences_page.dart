import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';
import 'package:ridelink/widgets/app_border_container.dart';
import 'package:ridelink/widgets/app_main_container.dart';

class PassengerNotificationPreferencesPage
    extends GetView<PassengerDashboardController> {
  const PassengerNotificationPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBgColor,
      body: AppMainContainer(
        alignment: AlignmentGeometry.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Navigation Bar
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        CupertinoIcons.back,
                        size: 22.sp,
                        color: AppColors.primaryTextColor,
                      ),
                      splashRadius: 22.r,
                    ),
                    Text(
                      'Notification Preferences',
                      style: AppTextStyle.text18Semibold.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                12.verticalSpace,

                // Informative Push Only Callout
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.containerFillColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.bell_fill,
                          color: AppColors.primaryColor,
                          size: 18.sp,
                        ),
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Push Notifications Only',
                              style: AppTextStyle.text14Semibold.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            2.verticalSpace,
                            Text(
                              'RideLink delivers ride booking updates and driver arrival alerts directly via instant push notifications. No cluttering email alerts.',
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
                ),

                18.verticalSpace,

                Text(
                  'Ride Alerts & Updates',
                  style: AppTextStyle.text16Semibold.copyWith(
                    color: AppColors.primaryTextColor,
                  ),
                ),
                10.verticalSpace,

                AppBorderContainer(
                  margin: EdgeInsets.symmetric(horizontal: 0),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  children: [
                    Obx(
                      () => _NotificationSwitchTile(
                        title: 'Booking Confirmations & Status',
                        subtitle:
                            'Push alerts when a driver accepts or schedules your ride request',
                        icon: CupertinoIcons.check_mark_circled,
                        value: controller.pushBookingConfirmations.value,
                        onChanged: (val) =>
                            controller.pushBookingConfirmations.value = val,
                      ),
                    ),
                    const Divider(color: AppColors.borderColor, height: 1),
                    Obx(
                      () => _NotificationSwitchTile(
                        title: 'Driver Arrival & Proximity Alerts',
                        subtitle:
                            'Real-time push alerts when your driver is 5 mins away from pickup',
                        icon: CupertinoIcons.car_detailed,
                        value: controller.pushDriverArrivalAlerts.value,
                        onChanged: (val) =>
                            controller.pushDriverArrivalAlerts.value = val,
                      ),
                    ),
                    const Divider(color: AppColors.borderColor, height: 1),
                    Obx(
                      () => _NotificationSwitchTile(
                        title: 'Trip Schedule & Reminders',
                        subtitle:
                            'Upcoming ride departure reminders and cash fare reminders',
                        icon: CupertinoIcons.clock,
                        value: controller.pushTripStatusUpdates.value,
                        onChanged: (val) =>
                            controller.pushTripStatusUpdates.value = val,
                      ),
                    ),
                  ],
                ),

                18.verticalSpace,

                Text(
                  'Communications & Safety',
                  style: AppTextStyle.text16Semibold.copyWith(
                    color: AppColors.primaryTextColor,
                  ),
                ),
                10.verticalSpace,

                AppBorderContainer(
                  margin: EdgeInsets.symmetric(horizontal: 0),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  children: [
                    Obx(
                      () => _NotificationSwitchTile(
                        title: 'Driver Chat Messages',
                        subtitle:
                            'Instant push messages when your driver contacts you for pickup',
                        icon: CupertinoIcons.chat_bubble_2,
                        value: controller.pushDriverChatMessages.value,
                        onChanged: (val) =>
                            controller.pushDriverChatMessages.value = val,
                      ),
                    ),
                    const Divider(color: AppColors.borderColor, height: 1),
                    Obx(
                      () => _NotificationSwitchTile(
                        title: 'Urgent Safety & Emergency Alerts',
                        subtitle:
                            'Critical real-time safety notifications and vehicle broadcast advisories',
                        icon: CupertinoIcons.shield_fill,
                        value: controller.pushSafetyAlerts.value,
                        onChanged: (val) =>
                            controller.pushSafetyAlerts.value = val,
                      ),
                    ),
                  ],
                ),

                24.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationSwitchTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.containerFillColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 18.sp),
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.text14Semibold.copyWith(
                    color: AppColors.primaryTextColor,
                  ),
                ),
                2.verticalSpace,
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
          8.horizontalSpace,
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
