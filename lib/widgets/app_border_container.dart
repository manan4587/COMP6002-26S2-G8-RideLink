import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridelink/core/constants/app_colors.dart';

class AppBorderContainer extends StatelessWidget {
  const AppBorderContainer({
    super.key,
    required this.children,
    this.alignment = Alignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.padding,
    this.margin,
  });

  final List<Widget> children;
  final AlignmentGeometry alignment;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 8.w),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.borderColor, width: 1.2),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTextColor.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: padding ?? EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }
}
