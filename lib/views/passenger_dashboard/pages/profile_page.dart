import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class ProfilePage extends GetView<PassengerDashboardController> {
  const ProfilePage({super.key});

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
                    CircleAvatar(
                      radius: 30.r,
                      backgroundColor: const Color(0xFFDBEAFE),
                      child: Text(
                        'AM',
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
                          Text('Alex Morgan', style: AppTextStyle.text18Semibold),
                          SizedBox(height: 2.h),
                          Text(
                            'alex.morgan@email.com',
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
                                '4.95 Rating • 28 Trips',
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
                icon: CupertinoIcons.creditcard,
                title: 'Payment Methods',
                subtitle: 'Apple Pay, Visa ending in 4242',
                onTap: () {},
              ),
              _SettingsTile(
                icon: CupertinoIcons.placemark,
                title: 'Saved Locations',
                subtitle: 'Home, Monash Uni, Office',
                onTap: () {},
              ),
              _SettingsTile(
                icon: CupertinoIcons.shield,
                title: 'Safety & Emergency Contacts',
                subtitle: 'SOS, 2 Trusted contacts added',
                onTap: () {},
              ),
              _SettingsTile(
                icon: CupertinoIcons.bell,
                title: 'Notification Preferences',
                subtitle: 'Push, Email & SMS ride alerts',
                onTap: () {},
              ),
              _SettingsTile(
                icon: CupertinoIcons.question_circle,
                title: 'Help & Customer Support',
                subtitle: 'FAQs, Live Chat',
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
