import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_assets.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/auth_flow/auth_controller.dart';
import 'package:ridelink/widgets/app_border_container.dart';
import 'package:ridelink/widgets/app_button.dart';
import 'package:ridelink/widgets/app_main_container.dart';

class GetStartedView extends GetView<AuthController> {
  const GetStartedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBgColor,
      body: AppMainContainer(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                16.verticalSpace,

                // Top Logo & Branding
                Container(
                  height: 110.h,
                  width: 110.h,
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.borderColor,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(AppAssets.appLogo, fit: BoxFit.contain),
                ),
                16.verticalSpace,
                Text(
                  'RideLink',
                  style: AppTextStyle.text30Semibold.copyWith(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                4.verticalSpace,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.containerFillColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        'AI Mobility Platform',
                        style: AppTextStyle.text12Semibold.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),

                24.verticalSpace,

                // Feature Highlights Card
                AppBorderContainer(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FeaturePoint(
                      icon: Icons.directions_car_rounded,
                      title: 'Travel Together',
                      subtitle:
                          'Instant AI matching with verified commuters along your exact route.',
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: AppColors.primaryColor,
                    ),
                    18.verticalSpace,
                    _FeaturePoint(
                      icon: Icons.savings_rounded,
                      title: 'Save Together',
                      subtitle:
                          'Split fuel costs automatically with fair, transparent trip estimates.',
                      iconBg: const Color(0xFFECFDF5),
                      iconColor: const Color(0xFF059669),
                    ),
                    18.verticalSpace,
                    _FeaturePoint(
                      icon: Icons.verified_user_rounded,
                      title: 'Grow Together',
                      subtitle:
                          'Safe community with verified IDs, background checks & trusted reviews.',
                      iconBg: const Color(0xFFFAF5FF),
                      iconColor: const Color(0xFF9333EA),
                    ),
                  ],
                ),

                24.verticalSpace,

                // Action Buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: AppButton(
                    onPressed: () => Get.toNamed(AppRoutes.loginView),
                    label: 'Get Started',
                    icon: AppAssets.flashIcon,
                  ),
                ),

                16.verticalSpace,

                // Direct Sign In Link
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.loginView),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyle.text14Medium.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      Text(
                        'Sign In',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                16.verticalSpace,

                // Subtle Policy Footer
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    'By continuing, you agree to our Terms of Service & Privacy Policy',
                    style: AppTextStyle.text10Medium.copyWith(
                      color: AppColors.hintTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                12.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturePoint extends StatelessWidget {
  const _FeaturePoint({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38.w,
          height: 38.h,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: iconColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20.sp, color: iconColor),
        ),
        14.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyle.text16Semibold.copyWith(
                  color: AppColors.primaryTextColor,
                ),
              ),
              3.verticalSpace,
              Text(
                subtitle,
                style: AppTextStyle.text12Regular.copyWith(
                  color: AppColors.secondaryTextColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

