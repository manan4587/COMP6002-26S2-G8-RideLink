import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink/theme/app_text_style.dart';

import '../../theme/app_style.dart';
import '../constants/app_colors.dart';

class AppSnackBar {
  const AppSnackBar._();

  static void success({required String message}) {
    Get.snackbar(
      'Success',
      message,
      messageText: Text(message, style: AppTextStyle.error),
      borderRadius: defaultRadius,
      borderWidth: 1.4,
      shouldIconPulse: false,
      colorText: AppColors.black,
      snackStyle: SnackStyle.FLOATING,
      titleText: const SizedBox.shrink(),
      snackPosition: SnackPosition.TOP,
      borderColor: const Color(0xFF32BC32),
      backgroundColor: const Color(0xFFEAF8EA),
      icon: const Icon(
        CupertinoIcons.check_mark_circled,
        color: AppColors.black,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding,
      ).copyWith(top: defaultPadding / 2),
      margin: EdgeInsets.symmetric(
        horizontal: defaultPadding * 2,
      ).copyWith(bottom: defaultPadding / 2),
    );
  }

  static void info({
    required String message,
    void Function()? onPress,
    String? buttonText,
  }) {
    Get.snackbar(
      'Info',
      message,
      messageText: Text(message, style: AppTextStyle.error),
      borderRadius: defaultRadius,
      borderWidth: 1.4,
      shouldIconPulse: false,
      colorText: AppColors.black,
      snackStyle: SnackStyle.FLOATING,
      titleText: const SizedBox.shrink(),
      snackPosition: SnackPosition.TOP,
      borderColor: const Color(0xFF47AFFF),
      backgroundColor: const Color(0xFFEDF7FF),
      icon: const Icon(CupertinoIcons.info, color: AppColors.black),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding,
      ).copyWith(top: defaultPadding / 2),
      margin: EdgeInsets.symmetric(
        horizontal: defaultPadding * 2,
      ).copyWith(bottom: defaultPadding / 2),
      mainButton: onPress == null
          ? null
          : TextButton(onPressed: onPress, child: Text(buttonText ?? 'Open')),
    );
  }

  static void warning({
    required String message,
    void Function()? onPress,
    String? buttonText,
  }) {
    Get.snackbar(
      'Warning',
      message,
      messageText: Text(message, style: AppTextStyle.error),
      borderRadius: defaultRadius,
      borderWidth: 1.4,
      shouldIconPulse: false,
      colorText: AppColors.black,
      snackStyle: SnackStyle.FLOATING,
      titleText: const SizedBox.shrink(),
      snackPosition: SnackPosition.TOP,
      borderColor: const Color(0xFFFFB600),
      backgroundColor: const Color(0xFFFFF8E5),
      icon: const Icon(Icons.warning_amber_rounded),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding,
      ).copyWith(top: defaultPadding / 2),
      margin: EdgeInsets.symmetric(
        horizontal: defaultPadding * 2,
      ).copyWith(bottom: defaultPadding / 2),
      mainButton: onPress == null
          ? null
          : TextButton(onPressed: onPress, child: Text(buttonText ?? 'Open')),
    );
  }

  static void error({
    required String message,
    void Function()? onPress,
    String? buttonText,
  }) {
    Get.snackbar(
      'Error',
      message,
      messageText: Text(message, style: AppTextStyle.error),
      borderRadius: defaultRadius,
      borderWidth: 1.4,
      shouldIconPulse: false,
      colorText: AppColors.black,
      snackStyle: SnackStyle.FLOATING,
      titleText: const SizedBox.shrink(),
      snackPosition: SnackPosition.TOP,
      borderColor: const Color(0xFFFF3A30),
      backgroundColor: const Color(0xFFFFEBEA),
      icon: const Icon(CupertinoIcons.clear_circled, color: AppColors.black),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding,
      ).copyWith(top: defaultPadding / 2),
      margin: EdgeInsets.symmetric(
        horizontal: defaultPadding * 2,
      ).copyWith(bottom: defaultPadding / 2),
      mainButton: onPress == null
          ? null
          : TextButton(onPressed: onPress, child: Text(buttonText ?? 'Open')),
    );
  }
}
