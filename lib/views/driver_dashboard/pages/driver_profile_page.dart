import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_controller.dart';

class DriverProfilePage extends GetView<DriverDashboardController> {
  const DriverProfilePage({super.key});

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
              Text('Driver Profile', style: AppTextStyle.text20Semibold),
              SizedBox(height: 12.h),

              // ADMIN VERIFICATION CONDITION BANNER
              Obx(() {
                if (controller.isVerifiedByAdmin.value) {
                  return const SizedBox.shrink();
                }

                return Container(
                  margin: EdgeInsets.only(bottom: 14.h),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: const Color(0xFFFDE68A),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFD97706),
                        size: 22,
                      ),
                      10.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Documents Pending Admin Review',
                              style: AppTextStyle.text14Semibold.copyWith(
                                color: const Color(0xFFB45309),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            4.verticalSpace,
                            Text(
                              "You cannot create or publish a new ride until your documents are verified by admin.",
                              style: AppTextStyle.text12Regular.copyWith(
                                color: const Color(0xFF92400E),
                                height: 1.35,
                              ),
                            ),
                            8.verticalSpace,
                            GestureDetector(
                              onTap: () => Get.toNamed(
                                AppRoutes.driverVerificationDocuments,
                              ),
                              child: Text(
                                'Check Verification Status →',
                                style: AppTextStyle.text12Semibold.copyWith(
                                  color: const Color(0xFFB45309),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Driver Header Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: Text(
                        'JM',
                        style: AppTextStyle.text20Semibold.copyWith(
                          color: AppColors.primaryColor,
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
                              Text(
                                'James Miller',
                                style: AppTextStyle.text18Semibold,
                              ),
                              SizedBox(width: 6.w),
                              Obx(
                                () => Icon(
                                  controller.isVerifiedByAdmin.value
                                      ? Icons.verified
                                      : Icons.hourglass_top_rounded,
                                  size: 16.sp,
                                  color: controller.isVerifiedByAdmin.value
                                      ? AppColors.primaryColor
                                      : const Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                          Obx(
                            () => Text(
                              '${controller.vehicleModel.value} • ${controller.vehicleColor.value}',
                              style: AppTextStyle.text12Regular.copyWith(
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 14.sp,
                                color: const Color(0xFFFFB900),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '4.90 Rating • 142 Driver Trips',
                                style: AppTextStyle.text12Semibold.copyWith(
                                  color: AppColors.primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                      const Color(0xFFDBEAFE).withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
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
                                CupertinoIcons.car_detailed,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Active Mode: DRIVER',
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
                      'You are currently managing published rides and earning as a driver. You can switch to Passenger mode anytime to find and book trips.',
                      style: AppTextStyle.text12Regular.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    GestureDetector(
                      onTap: controller.switchToPassengerMode,
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
                              CupertinoIcons.person_fill,
                              color: AppColors.primaryColor,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Switch to Passenger Mode',
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

              // Driver Settings List
              Text('Driver Management', style: AppTextStyle.text16Semibold),
              SizedBox(height: 10.h),

              Obx(
                () => _DriverSettingsTile(
                  icon: CupertinoIcons.car,
                  title: 'Vehicle & Registration',
                  subtitle:
                      '${controller.vehicleType.value} • Plate ${controller.vehicleNumber.value}',
                  onTap: () => Get.toNamed(AppRoutes.vehicleRegistration),
                ),
              ),
              Obx(
                () => _DriverSettingsTile(
                  icon: CupertinoIcons.doc_checkmark,
                  title: 'Verification Documents',
                  subtitle: controller.isVerifiedByAdmin.value
                      ? 'All Credentials Verified by Admin'
                      : 'Pending Admin Verification',
                  onTap: () =>
                      Get.toNamed(AppRoutes.driverVerificationDocuments),
                ),
              ),
              _DriverSettingsTile(
                icon: CupertinoIcons.money_dollar_circle,
                title: 'Trip Payments (Cash Only)',
                subtitle: 'Direct Cash Settlement with Passengers',
                onTap: () {
                  _showCashPayoutNotice(context);
                },
              ),
              _DriverSettingsTile(
                icon: CupertinoIcons.shield,
                title: 'Driver Safety & SOS',
                subtitle: 'Emergency assistance, call SOS & email support',
                onTap: () => Get.toNamed(AppRoutes.driverSafetySos),
              ),
              _DriverSettingsTile(
                icon: CupertinoIcons.question_circle,
                title: 'Help & Driver Support',
                subtitle: 'Submit queries to admin, support ticket history',
                onTap: () => Get.toNamed(AppRoutes.driverSupport),
              ),
              _DriverSettingsTile(
                icon: CupertinoIcons.bell,
                title: 'Notification Preferences',
                subtitle: 'Push Notifications Only • Instant Ride Alerts',
                onTap: () => Get.toNamed(AppRoutes.driverNotificationPreferences),
              ),

              SizedBox(height: 20.h),

              // Log Out Button with Confirmation
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

              // Delete Account Button with Confirmation
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

  void _showCashPayoutNotice(BuildContext context) {
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
              'RideLink operates purely on a direct cash settlement basis for all carpool trips.',
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
                    '• Collect exact cash fare directly from passengers upon arrival at the destination.',
                    style: AppTextStyle.text12Regular.copyWith(
                      color: AppColors.secondaryTextColor,
                      height: 1.4,
                    ),
                  ),
                  6.verticalSpace,
                  Text(
                    '• No digital payout accounts or banking integrations are required on your profile.',
                    style: AppTextStyle.text12Regular.copyWith(
                      color: AppColors.secondaryTextColor,
                      height: 1.4,
                    ),
                  ),
                  6.verticalSpace,
                  Text(
                    '• Keep a small amount of cash change in your vehicle for passenger convenience.',
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

class _DriverSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DriverSettingsTile({
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
