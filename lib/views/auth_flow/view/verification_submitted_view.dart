import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_assets.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/auth_flow/auth_controller.dart';
import 'package:ridelink/widgets/app_border_container.dart';
import 'package:ridelink/widgets/app_button.dart';
import 'package:ridelink/widgets/app_main_container.dart';

class VerificationSubmittedView extends GetView<AuthController> {
  const VerificationSubmittedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.primaryBgColor,
        body: AppMainContainer(
        alignment: AlignmentGeometry.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                16.verticalSpace,

                // Celebratory Hero Illustration
                SvgPicture.asset(
                  AppAssets.verification,
                  height: 116.h,
                  width: 116.w,
                ),

                20.verticalSpace,

                // Title & Subtitle
                Text(
                  'Verification Submitted',
                  style: AppTextStyle.text24Semibold.copyWith(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),

                6.verticalSpace,

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'Your documents are being checked by our trust & safety team.',
                    style: AppTextStyle.text14Regular.copyWith(
                      color: AppColors.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                16.verticalSpace,

                // Estimated Review Timeline Callout
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.containerFillColor,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18.sp,
                        color: AppColors.primaryColor,
                      ),
                      8.horizontalSpace,
                      Text(
                        'Estimated review: 24 – 48 Hours',
                        style: AppTextStyle.text12Semibold.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                24.verticalSpace,

                // Benefits / What you'll get section
                AppBorderContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 18.h,
                  ),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What you'll unlock upon approval:",
                      style: AppTextStyle.text14Semibold.copyWith(
                        color: AppColors.primaryTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    14.verticalSpace,
                    _FeatureTile(
                      icon: AppAssets.verifiedDriverBadge,
                      label: 'Verified Driver Badge',
                      description: 'Displayed on your public profile & trips',
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: AppColors.primaryColor,
                    ),
                    12.verticalSpace,
                    _FeatureTile(
                      icon: AppAssets.rating,
                      label: 'Higher Trust Rating',
                      description: 'Helps passengers book with confidence',
                      iconBg: const Color(0xFFFEF9C3),
                      iconColor: const Color(0xFFA16207),
                    ),
                    12.verticalSpace,
                    _FeatureTile(
                      icon: AppAssets.createRide,
                      label: 'Publish & Offer Rides',
                      description:
                          'Create scheduled trips and split fuel costs',
                      iconBg: const Color(0xFFECFDF5),
                      iconColor: const Color(0xFF059669),
                    ),
                  ],
                ),

                28.verticalSpace,

                // Action Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: AppButton(
                    onPressed: controller.onVerificationSubmited,
                    label: 'Continue to Dashboard',
                    icon: AppAssets.checkIcon,
                  ),
                ),

                16.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.label,
    required this.icon,
    required this.description,
    required this.iconBg,
    required this.iconColor,
  });

  final String label;
  final String description;
  final String icon;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(width: 1, color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(14.r),
      ),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      child: Row(
        children: [
          SvgPicture.asset(icon, height: 40.h, width: 40.w),
          12.horizontalSpace,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyle.text14Semibold.copyWith(
                    color: AppColors.primaryTextColor,
                  ),
                ),
                2.verticalSpace,
                Text(
                  description,
                  style: AppTextStyle.text12Regular.copyWith(
                    color: AppColors.secondaryTextColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
