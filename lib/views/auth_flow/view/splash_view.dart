import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_assets.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/auth_flow/auth_controller.dart';
import 'package:ridelink/widgets/app_main_container.dart';

class SplashView extends GetView<AuthController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.onNavigateToScreens();
    return Scaffold(
      backgroundColor: AppColors.primaryBgColor,
      body: AppMainContainer(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(),

              // Brand Hero Section
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 140.h,
                    width: 140.h,
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.12),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Image.asset(AppAssets.appLogo, fit: BoxFit.contain),
                  ),
                  24.verticalSpace,
                  Text(
                    'RideLink',
                    style: AppTextStyle.text42Bold.copyWith(
                      color: AppColors.primaryTextColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  8.verticalSpace,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.containerFillColor,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      'AI Mobility & Carpool',
                      style: AppTextStyle.text12Semibold.copyWith(
                        color: AppColors.primaryColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  14.verticalSpace,
                  Text(
                    'Smart routes • Fair split • Trusted community',
                    style: AppTextStyle.text12Medium.copyWith(
                      color: AppColors.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // Bottom Indicator & Footer
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 22.w,
                    height: 22.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                    ),
                  ),
                  16.verticalSpace,
                  Text(
                    'Connecting your everyday journeys',
                    style: AppTextStyle.text12Regular.copyWith(
                      color: AppColors.hintTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
