import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/theme/app_text_style.dart';

/// Unified and elegant Document Upload Bottom Sheet
/// Used across both post-signup Driver Verification and Profile Verification screens
class DocumentUploadPickerSheet {
  DocumentUploadPickerSheet._();

  static Future<void> show({
    required String title,
    required void Function(String fileName, String filePath) onSelected,
  }) async {
    await Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.hintTextColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Text(
                'Upload $title',
                style: AppTextStyle.text18Semibold.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              8.verticalSpace,
              Text(
                'Please provide a clear and legible photo or scan of your $title.',
                style: AppTextStyle.text12Regular.copyWith(
                  color: AppColors.secondaryTextColor,
                ),
              ),
              16.verticalSpace,
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.camera_fill,
                    color: AppColors.primaryColor,
                  ),
                ),
                title: Text(
                  'Take Photo',
                  style: AppTextStyle.text14Medium,
                ),
                subtitle: Text(
                  'Use your camera to take a photo',
                  style: AppTextStyle.text10Regular.copyWith(
                    color: AppColors.secondaryTextColor,
                  ),
                ),
                onTap: () async {
                  if (Get.isBottomSheetOpen == true) {
                    Get.back();
                  }
                  final image = await Utils.pickImage(ImageSource.camera);
                  if (image != null && image.path.isNotEmpty) {
                    final normalizedId = title.toLowerCase().replaceAll(' ', '_');
                    final name = image.name.isNotEmpty
                        ? image.name
                        : '$normalizedId.jpg';
                    onSelected(name, image.path);
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.photo_fill,
                    color: AppColors.primaryColor,
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: AppTextStyle.text14Medium,
                ),
                subtitle: Text(
                  'Upload an image from your photo library',
                  style: AppTextStyle.text10Regular.copyWith(
                    color: AppColors.secondaryTextColor,
                  ),
                ),
                onTap: () async {
                  if (Get.isBottomSheetOpen == true) {
                    Get.back();
                  }
                  final image = await Utils.pickImage(ImageSource.gallery);
                  if (image != null && image.path.isNotEmpty) {
                    final normalizedId = title.toLowerCase().replaceAll(' ', '_');
                    final name = image.name.isNotEmpty
                        ? image.name
                        : '$normalizedId.jpg';
                    onSelected(name, image.path);
                  }
                },
              ),
              12.verticalSpace,
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

