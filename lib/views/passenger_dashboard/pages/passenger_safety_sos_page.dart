import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';
import 'package:ridelink/widgets/app_border_container.dart';
import 'package:ridelink/widgets/app_main_container.dart';

class PassengerSafetySosPage extends GetView<PassengerDashboardController> {
  const PassengerSafetySosPage({super.key});

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
                      'Safety & Emergency SOS',
                      style: AppTextStyle.text18Semibold.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                12.verticalSpace,

                // Big Emergency SOS Button Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 56.h,
                        width: 56.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emergency_rounded,
                          color: Colors.white,
                          size: 32.sp,
                        ),
                      ),
                      12.verticalSpace,
                      Text(
                        'PASSENGER SOS',
                        style: AppTextStyle.text20Semibold.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      4.verticalSpace,
                      Text(
                        'Direct dial to emergency services (000 / Police)',
                        style: AppTextStyle.text12Regular.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      16.verticalSpace,
                      ElevatedButton.icon(
                        onPressed: controller.callEmergencyServices,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFDC2626),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                        icon: const Icon(Icons.phone, size: 18),
                        label: Text(
                          'Call Emergency Services Now',
                          style: AppTextStyle.text14Semibold.copyWith(
                            color: const Color(0xFFDC2626),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                16.verticalSpace,

                Text(
                  'Safety Assistance',
                  style: AppTextStyle.text16Semibold.copyWith(
                    color: AppColors.primaryTextColor,
                  ),
                ),
                10.verticalSpace,

                // 24/7 Hotline
                _ActionCard(
                  title: 'RideLink 24/7 Safety Hotline',
                  subtitle:
                      'Speak immediately with our dedicated safety operations center for trip concerns or route diversions.',
                  badge: 'Toll-Free • 1800 743 354',
                  icon: CupertinoIcons.phone_fill,
                  iconColor: const Color(0xFF16A34A),
                  iconBg: const Color(0xFFDCFCE7),
                  buttonLabel: 'Call Hotline',
                  onTap: controller.callSafetyHotline,
                ),

                12.verticalSpace,

                // Safety Email
                _ActionCard(
                  title: 'Emergency Incident Desk',
                  subtitle:
                      'Email our safety compliance officer with ride details, driver behaviour reports, or lost property inquiries.',
                  badge: 'Direct Desk • safety@ridelink.com',
                  icon: CupertinoIcons.mail_solid,
                  iconColor: AppColors.primaryColor,
                  iconBg: const Color(0xFFEFF6FF),
                  buttonLabel: 'Send Safety Email',
                  onTap: controller.sendSafetyEmail,
                ),

                12.verticalSpace,

                // Manage Emergency Contacts Card
                Obx(
                  () => _ActionCard(
                    title: 'Trusted Emergency Contacts',
                    subtitle:
                        'Add friends, spouse, or parents. Contacts are visible to your driver ONLY while a ride is actively in progress.',
                    badge:
                        '${controller.emergencyContacts.length} Contacts Saved • Active Ride Only',
                    icon: CupertinoIcons.phone_badge_plus,
                    iconColor: const Color(0xFFD97706),
                    iconBg: const Color(0xFFFFFBEB),
                    buttonLabel: 'Manage Emergency Contacts',
                    onTap: () =>
                        Get.toNamed(AppRoutes.passengerEmergencyContacts),
                  ),
                ),

                18.verticalSpace,

                Text(
                  'Carpool Safety Tips for Passengers',
                  style: AppTextStyle.text16Semibold.copyWith(
                    color: AppColors.primaryTextColor,
                  ),
                ),
                10.verticalSpace,

                AppBorderContainer(
                  padding: EdgeInsets.all(14.w),
                  margin: EdgeInsets.symmetric(horizontal: 0),
                  children: [
                    _TipRow(
                      number: '1',
                      title: 'Verify vehicle plate before boarding',
                      detail:
                          'Always match the driver\'s car model and registration plate with your in-app booking details.',
                    ),
                    Divider(color: AppColors.borderColor, height: 16),
                    _TipRow(
                      number: '2',
                      title: 'Keep cash ready at arrival',
                      detail:
                          'Prepare the exact cash fare for destination arrival to ensure smooth, swift handoff.',
                    ),
                    Divider(color: AppColors.borderColor, height: 16),
                    _TipRow(
                      number: '3',
                      title: 'Share your live ride tracking',
                      detail:
                          'Send trip route tracking to trusted friends or family members directly from your active booking.',
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

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String buttonLabel;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20.sp),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.text14Semibold.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    2.verticalSpace,
                    Text(
                      badge,
                      style: AppTextStyle.text10Medium.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          10.verticalSpace,
          Text(
            subtitle,
            style: AppTextStyle.text12Regular.copyWith(
              color: AppColors.secondaryTextColor,
              height: 1.35,
            ),
          ),
          12.verticalSpace,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: iconColor),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                buttonLabel,
                style: AppTextStyle.text14Semibold.copyWith(color: iconColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String number;
  final String title;
  final String detail;

  const _TipRow({
    required this.number,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22.w,
          height: 22.w,
          decoration: BoxDecoration(
            color: AppColors.containerFillColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyle.text12Semibold.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
        10.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyle.text14Semibold.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              2.verticalSpace,
              Text(
                detail,
                style: AppTextStyle.text12Regular.copyWith(
                  color: AppColors.secondaryTextColor,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
