import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class ProfilePage extends GetView<PassengerDashboardController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.reloadProfile();
    });

    return Scaffold(
      backgroundColor: AppColors.secondaryBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Profile', style: AppTextStyle.text20Semibold),
              SizedBox(height: 16.h),

              // User Info Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  children: [
                    Obx(
                      () => CircleAvatar(
                        radius: 30.r,
                        backgroundColor: const Color(0xFFDBEAFE),
                        child: Text(
                          controller.passengerInitials,
                          style: AppTextStyle.text20Semibold.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Obx(
                                  () => Text(
                                    controller.passengerName.value.isNotEmpty
                                        ? controller.passengerName.value
                                        : (Preferences.userName.isNotEmpty
                                              ? Preferences.userName
                                              : 'N/A'),
                                    style: AppTextStyle.text18Semibold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.verified,
                                size: 16.sp,
                                color: AppColors.primaryColor,
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Obx(
                            () => Text(
                              controller.passengerEmail.value.isNotEmpty
                                  ? controller.passengerEmail.value
                                  : (Preferences.userEmail.isNotEmpty
                                        ? Preferences.userEmail
                                        : 'N/A'),
                              style: AppTextStyle.text12Regular.copyWith(
                                color: AppColors.secondaryTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Obx(
                            () => Text(
                              controller.passengerPhone.value.isNotEmpty
                                  ? controller.passengerPhone.value
                                  : (Preferences.userPhone.isNotEmpty
                                        ? Preferences.userPhone
                                        : 'N/A'),
                              style: AppTextStyle.text12Regular.copyWith(
                                color: AppColors.secondaryTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Obx(() {
                            final rating = controller.passengerRating.value;
                            final ratingStr = rating > 0
                                ? rating.toStringAsFixed(2)
                                : '0.0';
                            final trips = controller.tripsCount.value;
                            return Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14.sp,
                                  color: const Color(0xFFFFB900),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '$ratingStr Rating • $trips Trips',
                                  style: AppTextStyle.text12Semibold.copyWith(
                                    color: AppColors.primaryTextColor,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      onPressed: () =>
                          Get.toNamed(AppRoutes.editPassengerProfile),
                      icon: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 18.sp,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      tooltip: 'Edit Profile',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18.h),

              // ACTIVE PROFILE MODE SWITCHER CARD (Core Requirement)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFEFF6FF),
                      const Color(0xFFDBEAFE).withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.person_fill,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Active Mode: PASSENGER',
                              style: AppTextStyle.text14Semibold.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            'Active',
                            style: AppTextStyle.text10Medium.copyWith(
                              color: const Color(0xFF16A34A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'You are currently finding and booking rides as a passenger. You can switch to your Driver dashboard anytime to publish rides and earn.',
                      style: AppTextStyle.text12Regular.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    GestureDetector(
                      onTap: controller.switchToDriverMode,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: AppColors.primaryColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.car_detailed,
                              color: AppColors.primaryColor,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Switch to Driver Mode',
                              style: AppTextStyle.text14Semibold.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16.sp,
                              color: AppColors.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Settings Menu List
              Text('Account Settings', style: AppTextStyle.text16Semibold),
              SizedBox(height: 10.h),

              _SettingsTile(
                icon: CupertinoIcons.person_crop_circle,
                title: 'Personal Details (Edit Profile)',
                subtitle: 'Change your name, phone number, and email address',
                onTap: () => Get.toNamed(AppRoutes.editPassengerProfile),
              ),
              _SettingsTile(
                icon: CupertinoIcons.money_dollar_circle,
                title: 'Trip Payments (Cash Only)',
                subtitle: 'Direct Cash Settlement with Drivers',
                onTap: () => _showCashPaymentNotice(context),
              ),
              Obx(
                () => _SettingsTile(
                  icon: CupertinoIcons.placemark,
                  title: 'Saved Locations',
                  subtitle:
                      '${controller.savedLocations.length} Places Bookmarked (Home, Work, Uni)',
                  onTap: () => Get.toNamed(AppRoutes.passengerSavedLocations),
                ),
              ),
              Obx(
                () => _SettingsTile(
                  icon: CupertinoIcons.phone_badge_plus,
                  title: 'Emergency Contacts',
                  subtitle:
                      '${controller.emergencyContacts.length} Contacts Saved (Visible only during active trips)',
                  onTap: () =>
                      Get.toNamed(AppRoutes.passengerEmergencyContacts),
                ),
              ),
              _SettingsTile(
                icon: CupertinoIcons.shield,
                title: 'Safety & SOS Assistance',
                subtitle: 'Emergency assistance, call SOS & email desk',
                onTap: () => Get.toNamed(AppRoutes.passengerSafetySos),
              ),
              // _SettingsTile(
              //   icon: CupertinoIcons.bell,
              //   title: 'Notification Preferences',
              //   subtitle: 'Push Notifications Only • Instant Ride Alerts',
              //   onTap: () =>
              //       Get.toNamed(AppRoutes.passengerNotificationPreferences),
              // ),
              _SettingsTile(
                icon: CupertinoIcons.question_circle,
                title: 'Help & Customer Support',
                subtitle: 'Submit queries to admin, support ticket history',
                onTap: () => Get.toNamed(AppRoutes.passengerSupport),
              ),

              SizedBox(height: 20.h),

              // Logout Button with Bottom Sheet
              GestureDetector(
                onTap: () => controller.confirmLogout(context),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, color: Colors.red, size: 18),
                      SizedBox(width: 8.w),
                      Text(
                        'Log Out',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Delete Account Button with Bottom Sheet
              GestureDetector(
                onTap: () => controller.confirmDeleteAccount(context),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: AppColors.red.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.red.withValues(alpha: 0.8),
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Delete Account',
                        style: AppTextStyle.text12Semibold.copyWith(
                          color: AppColors.red.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showCashPaymentNotice(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          top: 12.h,
          left: 20.w,
          right: 20.w,
          bottom: MediaQuery.of(context).padding.bottom + 20.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            16.verticalSpace,
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    color: Color(0xFF16A34A),
                    size: 24,
                  ),
                ),
                12.horizontalSpace,
                Text(
                  'Cash Payments Only',
                  style: AppTextStyle.text18Semibold.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            14.verticalSpace,
            Text(
              'RideLink operates purely on a direct cash settlement basis for all passenger carpools.',
              style: AppTextStyle.text14Medium.copyWith(
                color: AppColors.primaryTextColor,
              ),
            ),
            10.verticalSpace,
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.containerFillColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• Pay the driver directly in cash upon arriving safely at your destination.',
                    style: AppTextStyle.text12Regular.copyWith(
                      color: AppColors.secondaryTextColor,
                      height: 1.4,
                    ),
                  ),
                  6.verticalSpace,
                  Text(
                    '• No credit cards, banking details, or digital top-ups are required in the app.',
                    style: AppTextStyle.text12Regular.copyWith(
                      color: AppColors.secondaryTextColor,
                      height: 1.4,
                    ),
                  ),
                  6.verticalSpace,
                  Text(
                    '• Please keep exact cash change ready before your scheduled ride.',
                    style: AppTextStyle.text12Regular.copyWith(
                      color: AppColors.secondaryTextColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            20.verticalSpace,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Understood'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          leading: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.containerFillColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 18.sp),
          ),
          title: Text(title, style: AppTextStyle.text14Semibold),
          subtitle: Text(
            subtitle,
            style: AppTextStyle.text12Regular.copyWith(
              color: AppColors.secondaryTextColor,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: AppColors.secondaryTextColor,
            size: 20.sp,
          ),
        ),
      ),
    );
  }
}
