import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridelink/core/constants/app_colors.dart';

class AppTextStyle {
  AppTextStyle._();

  static const _fontFamily = 'Inter';

  static TextStyle text42Bold = TextStyle(
    fontSize: 42.sp,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
  );

  static TextStyle text20Medium = TextStyle(
    fontSize: 20.sp,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w500,
    height: 28.h / 20.sp,
    fontFamily: _fontFamily,
  );

  static TextStyle text16Medium = TextStyle(
    fontSize: 16.sp,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w500,
    height: 24.h / 16.sp,
    fontFamily: _fontFamily,
  );

  static TextStyle text14Medium = TextStyle(
    fontSize: 14.sp,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w500,
    height: 20.h / 14.sp,
    fontFamily: _fontFamily,
  );

  static TextStyle text12MediumOrSmall = TextStyle(
    fontSize: 12.sp,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w500,
    height: 16.h / 12.sp,
    fontFamily: _fontFamily,
  );
  static TextStyle text10Medium = TextStyle(
    fontSize: 10.sp,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w500,
    height: 14.h / 10.sp,
    fontFamily: _fontFamily,
  );
  static TextStyle text12Semibold = TextStyle(
    fontSize: 12.sp,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w600,
    height: 16.h / 12.sp,
    fontFamily: _fontFamily,
  );

  static TextStyle text30Semibold = TextStyle(
    fontSize: 30.sp,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w600,
    height: 36.h / 30.sp,
    fontFamily: _fontFamily,
  );

  static TextStyle text24Semibold = TextStyle(
    fontSize: 24.sp,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w600,
    height: 32.h / 24.sp,
  );

  static TextStyle text20Semibold = TextStyle(
    fontSize: 20.sp,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w600,
    height: 28.h / 20.sp,
    fontFamily: _fontFamily,
  );
  static TextStyle text18Semibold = TextStyle(
    fontSize: 18.sp,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w600,
    height: 28.h / 18.sp,
    fontFamily: _fontFamily,
  );

  static TextStyle text16Semibold = TextStyle(
    fontSize: 16.sp,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w600,
    height: 24.h / 16.sp,
  );

  static TextStyle text14Semibold = TextStyle(
    fontSize: 14.sp,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w600,
    height: 20.h / 14.sp,
    fontFamily: _fontFamily,
  );

  static TextStyle text14Regular = TextStyle(
    fontSize: 14.sp,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w400,
    height: 20.h / 14.sp,
    fontFamily: _fontFamily,
  );
  static TextStyle text16Regular = TextStyle(
    fontSize: 16.sp,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w400,
    height: 24.h / 16.sp,
  );
  static TextStyle text12Regular = TextStyle(
    fontSize: 12.sp,
    color: AppColors.primaryTextColor,
    fontWeight: FontWeight.w400,
    height: 16.h / 12.sp,
    fontFamily: _fontFamily,
  );

  static TextStyle headlineMedium_28 = TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.w600,
    fontFamily: _fontFamily,
    color: AppColors.primaryTextColor,
  );

  static TextStyle buttonText = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    fontFamily: _fontFamily,
    color: AppColors.white,
  );

  static TextStyle error = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.primaryTextColor,
  );
}
