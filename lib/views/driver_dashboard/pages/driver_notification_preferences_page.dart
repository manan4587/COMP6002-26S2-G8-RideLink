import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_profile_controller.dart';
import 'package:ridelink/widgets/app_border_container.dart';
import 'package:ridelink/widgets/app_main_container.dart';

class DriverNotificationPreferencesPage
    extends GetView<DriverProfileController> {
  const DriverNotificationPreferencesPage({super.key});

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
                              'RideLink delivers all live trip requests and updates via direct push notifications. No cluttering email alerts.',
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
                  'Driver Activity Alerts',
                  style: AppTextStyle.text16Semibold.copyWith(
                    color: AppColors.primaryTextColor,
                  ),
                ),
                10.verticalSpace,

                AppBorderContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  children: [
                    Obx(
                      () => _NotificationSwitchTile(
                        title: 'New Passenger Booking Requests',
                        subtitle:
                            'Instant push notifications when passengers request seats on your ride',
                        icon: CupertinoIcons.person_badge_plus,
                        value: controller.pushRideRequests.value,
                        onChanged: (val) =>
                            controller.pushRideRequests.value = val,
                      ),
                    ),
                    const Divider(color: AppColors.borderColor, height: 1),
                    Obx(
                      () => _NotificationSwitchTile(
                        title: 'Trip Schedule & Reminders',
                        subtitle:
                            'Timely push alerts before your departure and route updates',
                        icon: CupertinoIcons.clock,
                        value: controller.pushTripStatusUpdates.value,
                        onChanged: (val) =>
                            controller.pushTripStatusUpdates.value = val,
                      ),
                    ),
                    const Divider(color: AppColors.borderColor, height: 1),
                    Obx(
                      () => _NotificationSwitchTile(
                        title: 'Passenger Messages & Chat',
                        subtitle:
                            'Direct push alerts for pickup coordination messages from riders',
                        icon: CupertinoIcons.chat_bubble_2,
                        value: controller.pushPassengerMessages.value,
                        onChanged: (val) =>
                            controller.pushPassengerMessages.value = val,
                      ),
                    ),
                  ],
                ),

                18.verticalSpace,

                Text(
                  'Security & Administration',
                  style: AppTextStyle.text16Semibold.copyWith(
                    color: AppColors.primaryTextColor,
                  ),
                ),
                10.verticalSpace,

                AppBorderContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  children: [
                    Obx(
                      () => _NotificationSwitchTile(
                        title: 'Urgent Safety & SOS Broadcasts',
                        subtitle:
                            'Critical real-time safety alerts and emergency broadcast notifications',
                        icon: CupertinoIcons.shield_fill,
                        value: controller.pushSafetyAlerts.value,
                        onChanged: (val) =>
                            controller.pushSafetyAlerts.value = val,
                      ),
                    ),
                    const Divider(color: AppColors.borderColor, height: 1),
                    Obx(
                      () => _NotificationSwitchTile(
                        title: 'Admin Verification Updates',
                        subtitle:
                            'Push notifications regarding your licence review and account approval',
                        icon: CupertinoIcons.doc_checkmark,
                        value: controller.pushAdminAnnouncements.value,
                        onChanged: (val) =>
                            controller.pushAdminAnnouncements.value = val,
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
