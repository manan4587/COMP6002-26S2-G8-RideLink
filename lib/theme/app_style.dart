import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridelink/core/constants/app_colors.dart';

double get defaultPadding => 14.h;
double get defaultRadius => 8.r;

double get defaultTopPadding => ScreenUtil().statusBarHeight + defaultPadding;
double get defaultBottomPadding => ScreenUtil().bottomBarHeight == 0.0
    ? defaultPadding
    : (ScreenUtil().bottomBarHeight + 8.h);

class AppDecoration {
  static Decoration textFieldDecoration = ShapeDecoration(
    gradient: LinearGradient(
      begin: Alignment(0.50, -0.00),
      end: Alignment(0.98, 1.00),
      colors: [
        AppColors.white.withValues(alpha: 0),
        AppColors.gradientGreen.withValues(alpha: 0.1),
      ],
    ),
    shape: RoundedRectangleBorder(
      side: BorderSide(
        width: 1,
        color: AppColors.gradientGreen.withValues(alpha: 0.2),
      ),
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static LinearGradient appLinearGradient = LinearGradient(
    begin: Alignment(0.50, -0.00),
    end: Alignment(0.98, 1.00),
    colors: [
      AppColors.white.withValues(alpha: 0),
      AppColors.gradientGreen.withValues(alpha: 0.1),
    ],
  );

  static LinearGradient appPaidGradient = LinearGradient(
    begin: Alignment(-1.0, 0),
    end: Alignment(3.0, 5),
    colors: [AppColors.white, Color(0xFFC9FFE3).withValues(alpha: 0.3)],
  );
}
