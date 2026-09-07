import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            SvgPicture.asset(
              icon!,
              width: iconSize.w,
              height: iconSize.h,
              colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
            ),
            8.horizontalSpace,
          ],
          Text(label, style: AppTextStyle.buttonText),
          if (rightIcon != null) ...[
            8.horizontalSpace,
            SvgPicture.asset(
              rightIcon!,
              width: iconSize.w,
              height: iconSize.h,
              colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
            ),
          ],
        ],
      );
    } else {
      child = Text(label, style: AppTextStyle.buttonText);
    }

    Widget button = ElevatedButton(
      onPressed: isLoading
          ? () {}
          : disable
          ? null
          : onPressed,
      style: ElevatedButton.styleFrom(
        enableFeedback: false,
        fixedSize: Size(Get.width, height.h),
        minimumSize: Size(Get.width, height.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: backgroundColor,
        shadowColor: AppColors.borderColor.withAlpha((255.0 * .2).round()),
        elevation: 0,
        disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.5),
      ),
      child: child,
    );

    return button;
  }
}
