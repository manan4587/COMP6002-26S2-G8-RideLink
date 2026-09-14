import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
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
              SizedBox(height: 16.h),

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
                              Text('James Miller', style: AppTextStyle.text18Semibold),
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.verified,
                                size: 16.sp,
                                color: AppColors.primaryColor,
                              ),
                            ],
                          ),
                          Text(
                            'Toyota Camry Hybrid • White',
                            style: AppTextStyle.text12Regular.copyWith(
                              color: AppColors.secondaryTextColor,
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

              _DriverSettingsTile(
                icon: CupertinoIcons.car,
                title: 'Vehicle & Registration',
                subtitle: 'Toyota Camry 2022 • Plate 1AB-2CD',
                onTap: () {},
              ),
              _DriverSettingsTile(
                icon: CupertinoIcons.doc_checkmark,
                title: 'Verification Documents',
                subtitle: 'DL, Insurance & Police Check Verified',
                onTap: () {},
              ),
              _DriverSettingsTile(
                icon: CupertinoIcons.money_dollar_circle,
                title: 'Payout Bank Account',
                subtitle: 'Direct Deposit (NAB • ••3489)',
                onTap: () {},
              ),
              _DriverSettingsTile(
                icon: CupertinoIcons.shield,
                title: 'Driver Safety & SOS',
                subtitle: 'Emergency assistance & trip logs',
                onTap: () {},
              ),
              _DriverSettingsTile(
                icon: CupertinoIcons.question_circle,
                title: 'Help & Driver Support',
                subtitle: 'Driver guide, Contact support',
                onTap: () {},
              ),

              SizedBox(height: 18.h),

              // Logout Button
              GestureDetector(
                onTap: controller.onLogout,
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

              SizedBox(height: 24.h),
            ],
          ),
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
      child: ListTile(
        onTap: onTap,
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
    );
  }
}
