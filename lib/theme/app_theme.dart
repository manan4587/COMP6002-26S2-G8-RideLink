import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';

/// App Theme Management
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.primaryBgColor,
    disabledColor: AppColors.disableColor,
    splashFactory: InkRipple.splashFactory,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    highlightColor: Colors.transparent,
    scrollbarTheme: ScrollbarThemeData(
      radius: Radius.circular(50),
      thumbColor: WidgetStateProperty.all(AppColors.primaryColor),
    ),

    /// Appbar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryBgColor,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: AppColors.primaryColor),
    ),

    /// Text theme
    textTheme: buildTextTheme(Typography.material2021().black),
    primaryTextTheme: buildTextTheme(Typography.material2021().black),

    /// Bottom Sheet theme
    bottomSheetTheme: const BottomSheetThemeData(
      surfaceTintColor: Colors.transparent,
    ),

    /// Button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        disabledBackgroundColor: AppColors.disabledActionColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: AppTextStyle.buttonText,
      ),
    ),

    /// Color scheme
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryColor,
      onSurface: AppColors.white,
      surface: AppColors.white,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.black,
      dayStyle: AppTextStyle.text14Medium,
      weekdayStyle: AppTextStyle.text14Medium.copyWith(color: AppColors.white),
      yearStyle: AppTextStyle.text14Medium,
      headerHelpStyle: AppTextStyle.text20Semibold,
      headerHeadlineStyle: AppTextStyle.text20Semibold,
      locale: const Locale('en', 'US'),
    ),
    tabBarTheme: TabBarThemeData(indicatorColor: AppColors.primaryColor),
    canvasColor: AppColors.primaryBgColor,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.primaryBgColor,
    disabledColor: AppColors.disableColor,
    splashFactory: InkRipple.splashFactory,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    highlightColor: Colors.transparent,

    /// Appbar theme
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: Colors.transparent,
      elevation: 4,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black12,
      iconTheme: IconThemeData(color: AppColors.primaryColor),
    ),

    /// Text theme
    // textTheme: buildTextTheme(Typography.material2021().white),
    // primaryTextTheme: buildTextTheme(Typography.material2021().white),

    /// Bottom Sheet theme
    bottomSheetTheme: const BottomSheetThemeData(
      surfaceTintColor: Colors.transparent,
    ),

    /// Button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        disabledBackgroundColor: AppColors.disabledActionColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    /// Color scheme
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryColor,
      onSurface: AppColors.primaryBgColor,
      surface: AppColors.primaryBgColor,
    ),
    tabBarTheme: TabBarThemeData(indicatorColor: AppColors.primaryColor),
  );
}

TextTheme buildTextTheme(TextTheme base) {
  return base.copyWith(
    // Define a custom TextTheme that matches your design system.
    headlineMedium: TextStyle(
      fontSize: 28.sp,
      height: 1.5,
      letterSpacing: 0,
      fontFamily: 'Poppins',
      color: AppColors.black,
    ),

    headlineSmall: TextStyle(
      fontSize: 24.sp,
      height: 1.5,
      letterSpacing: 0,
      fontFamily: 'Poppins',
      color: AppColors.black,
    ),

    titleLarge: TextStyle(
      fontSize: 22.sp,
      height: 1.5,
      letterSpacing: 0,
      fontFamily: 'Poppins',
      color: AppColors.black,
    ),

    titleMedium: TextStyle(
      fontSize: 16.sp,
      height: 1.5,
      letterSpacing: 0,
      fontFamily: 'Poppins',
      color: AppColors.black,
    ),

    titleSmall: TextStyle(
      fontSize: 14.sp,
      height: 1.5,
      letterSpacing: .1,
      fontFamily: 'Poppins',
      color: AppColors.black,
    ),

    bodyMedium: TextStyle(
      fontSize: 14.sp,
      height: 1.5,
      letterSpacing: 0,
      fontFamily: 'Poppins',
    ),

    bodySmall: TextStyle(
      fontSize: 12.sp,
      height: 1.5,
      letterSpacing: 0,
      fontFamily: 'Poppins',
      color: AppColors.black,
    ),

    labelSmall: TextStyle(
      fontSize: 10.sp,
      height: 1.5,
      letterSpacing: 0,
      fontFamily: 'Poppins',
      color: AppColors.black,
    ),
  );
}

/// | NAME           | SIZE |  HEIGHT |  WEIGHT |  SPACING |             |
/// |----------------|------|---------|---------|----------|-------------|
/// | displayLarge   | 57.0 |   64.0  | regular | -0.25    |             |
/// | displayMedium  | 45.0 |   52.0  | regular |  0.0     |             |
/// | displaySmall   | 36.0 |   44.0  | regular |  0.0     |             |
/// | headlineLarge  | 32.0 |   40.0  | regular |  0.0     |             |
/// | headlineMedium | 28.0 |   36.0  | regular |  0.0     |      -      |
/// | headlineSmall  | 24.0 |   32.0  | regular |  0.0     |      -      |
/// | titleLarge     | 22.0 |   28.0  | regular |  0.0     |      -      |
/// | titleMedium    | 16.0 |   24.0  | medium  |  0.15    |      -      |
/// | titleSmall     | 14.0 |   20.0  | medium  |  0.1     |      -      |
/// | bodyLarge      | 16.0 |   24.0  | regular |  0.5     |             |
/// | bodyMedium     | 14.0 |   20.0  | regular |  0.25    |      -      |
/// | bodySmall      | 12.0 |   16.0  | regular |  0.4     |      -      |
/// | labelLarge     | 14.0 |   20.0  | medium  |  0.1     |             |
/// | labelMedium    | 12.0 |   16.0  | medium  |  0.5     |             |
/// | labelSmall     | 11.0 |   16.0  | medium  |  0.5     |      -      |
