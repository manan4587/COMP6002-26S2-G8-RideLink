import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ridelink/core/utils/app_loader.dart';
import 'package:ridelink/theme/app_text_style.dart';

import '../core/constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final bool disable;
  final String? icon;
  final String? rightIcon;
  final int height;
  final int iconSize;
  final Color backgroundColor;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.rightIcon,
    this.isLoading = false,
    this.disable = false,
    this.height = 48,
    this.iconSize = 18,
    this.backgroundColor = AppColors.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (isLoading) {
      child = const CircularLoader(color: AppColors.white);
    } else if (icon != null || rightIcon != null) {
      child = Row(
        children: [
          20.horizontalSpace,
          if (icon != null) ...[
            SvgPicture.asset(
              icon!,
              width: iconSize.w,
              height: iconSize.h,
              colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
            ),
          ] else ...[
            SizedBox(width: iconSize.w),
          ],
          Expanded(
            child: Center(
              child: Text(
                label,
                style: AppTextStyle.buttonText,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (rightIcon != null) ...[
            SvgPicture.asset(
              rightIcon!,
              width: iconSize.w,
              height: iconSize.h,
              colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
            ),
          ] else ...[
            SizedBox(width: iconSize.w),
          ],
          20.horizontalSpace,
        ],
      );
    } else {
      child = Text(label, style: AppTextStyle.buttonText);
    }

    Widget button = GestureDetector(
      onTap: isLoading
          ? () {}
          : disable
          ? null
          : onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          gradient: LinearGradient(
            begin: AlignmentGeometry.topLeft,
            end: AlignmentGeometry.bottomRight,
            colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
          ),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );

    // Widget button = ElevatedButton(
    //   onPressed: isLoading
    //       ? () {}
    //       : disable
    //       ? null
    //       : onPressed,
    //   style: ElevatedButton.styleFrom(
    //     enableFeedback: false,
    //     fixedSize: Size(Get.width, height.h),
    //     minimumSize: Size(Get.width, height.h),
    //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(18.r),
    //     ),
    //     backgroundColor: backgroundColor,

    //     foregroundColor: backgroundColor,
    //     shadowColor: AppColors.borderColor.withAlpha((255.0 * .2).round()),
    //     elevation: 0,
    //     disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.5),
    //   ),
    //   child: child,
    // );

    return button;
  }
}
