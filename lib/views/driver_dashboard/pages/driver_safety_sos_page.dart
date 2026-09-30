import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_profile_controller.dart';
import 'package:ridelink/widgets/app_border_container.dart';
import 'package:ridelink/widgets/app_main_container.dart';

class DriverSafetySosPage extends GetView<DriverProfileController> {
  const DriverSafetySosPage({super.key});

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
                      'Driver Safety & SOS',
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
                        'EMERGENCY SOS',
                        style: AppTextStyle.text20Semibold.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      4.verticalSpace,
                      Text(
                        'Instant call to emergency services (000 / Police)',
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

                // Quick Assistance Action Cards
                Text(
                  'Quick Assistance',
                  style: AppTextStyle.text16Semibold.copyWith(
                    color: AppColors.primaryTextColor,
                  ),
                ),
                10.verticalSpace,

                // Safety Hotline (Phone Call)
                _QuickActionTile(
                  icon: CupertinoIcons.phone_fill,
                  iconColor: AppColors.primaryColor,
                  iconBg: const Color(0xFFEFF6FF),
                  title: 'RideLink 24/7 Safety Hotline',
                  subtitle: 'Direct phone dial to our incident response team',
                  actionText: 'Dial 1800 743 354',
                  onTap: controller.callSafetyHotline,
                ),
                10.verticalSpace,

                // Safety Email Reporting
                _QuickActionTile(
                  icon: CupertinoIcons.mail_solid,
                  iconColor: const Color(0xFF7C3AED),
                  iconBg: const Color(0xFFF5F3FF),
                  title: 'Report Incident via Email',
                  subtitle:
                      'Opens mail composer directly to safety@ridelink.com',
                  actionText: 'Send Email',
                  onTap: controller.sendSafetyEmail,
                ),

                18.verticalSpace,

                // Driver Safety Guidelines & Checklist
                AppBorderContainer(
                  margin: EdgeInsets.symmetric(horizontal: 0),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.shield_lefthalf_fill,
                          color: AppColors.primaryColor,
                          size: 18.sp,
                        ),
                        8.horizontalSpace,
                        Text(
                          'Safety Guidelines & Tips',
                          style: AppTextStyle.text14Semibold.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    12.verticalSpace,
                    _SafetyTipRow(
                      number: '1',
                      title: 'Verify Passenger Before Starting',
                      description:
                          'Check passenger name and destination in-app before unlocking doors.',
                    ),
                    10.verticalSpace,
                    _SafetyTipRow(
                      number: '2',
                      title: 'Cash Fare Security',
                      description:
                          'Keep reasonable change in vehicle. Collect cash upon trip arrival at destination.',
                    ),
                    10.verticalSpace,
                    _SafetyTipRow(
                      number: '3',
                      title: 'Zero Tolerance Policy',
                      description:
                          'If you feel uncomfortable or unsafe at any point, end trip safely at a public location and dial SOS.',
                    ),
                  ],
                ),

                20.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          leading: Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          title: Text(title, style: AppTextStyle.text14Semibold),
          subtitle: Text(
            subtitle,
            style: AppTextStyle.text12Regular.copyWith(
              color: AppColors.secondaryTextColor,
            ),
          ),
          trailing: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: iconBg,
              foregroundColor: iconColor,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              actionText,
              style: AppTextStyle.text12Semibold.copyWith(color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}

class _SafetyTipRow extends StatelessWidget {
  const _SafetyTipRow({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22.w,
          height: 22.h,
          decoration: const BoxDecoration(
            color: Color(0xFFDBEAFE),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: AppTextStyle.text10Medium.copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        10.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyle.text12Semibold),
              2.verticalSpace,
              Text(
                description,
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
