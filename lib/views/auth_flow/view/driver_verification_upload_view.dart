import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_assets.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/auth_flow/auth_controller.dart';
import 'package:ridelink/widgets/app_button.dart';
import 'package:ridelink/widgets/app_main_container.dart';

class DriverVerificationUploadView extends GetView<AuthController> {
  const DriverVerificationUploadView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBgColor,
      body: AppMainContainer(
        alignment: AlignmentGeometry.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Navigation Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        CupertinoIcons.back,
                        size: 22.sp,
                        color: AppColors.primaryTextColor,
                      ),
                      splashRadius: 22.r,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.containerFillColor,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Step 2 of 2',
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        8.horizontalSpace,
                        TextButton(
                          onPressed: controller.onSkipDriverVerification,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Skip',
                            style: AppTextStyle.text14Semibold.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                8.verticalSpace,

                // Header Section
                Text(
                  'Driver Verification',
                  style: AppTextStyle.text24Semibold.copyWith(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                6.verticalSpace,
                Text(
                  'Upload valid documents to unlock your Verified Driver Badge and start publishing trips.',
                  style: AppTextStyle.text14Regular.copyWith(
                    color: AppColors.secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                20.verticalSpace,

                // Document Upload Cards List
                Obx(
                  () => _DriverDocsUploadCard(
                    label: 'Driving Licence',
                    description: 'Government-issued valid driver licence',
                    icon: AppAssets.drivingLicense,
                    isRequired: true,
                    uploadedFileName: controller.drivingLicencePath.value,
                    base64Data: controller.drivingLicenceBase64.value,
                    status: controller.drivingLicenceBase64.value.isNotEmpty
                        ? 'In Review'
                        : 'Not Uploaded',
                    onTap: controller.onSelectDrivingLicence,
                  ),
                ),
                12.verticalSpace,

                Obx(
                  () => _DriverDocsUploadCard(
                    label: 'Vehicle Registration',
                    description: 'Valid registration document for your car',
                    icon: AppAssets.vehicleRegistration,
                    isRequired: true,
                    uploadedFileName: controller.vehicleRegistrationPath.value,
                    base64Data: controller.vehicleRegistrationBase64.value,
                    status: controller.vehicleRegistrationBase64.value.isNotEmpty
                        ? 'In Review'
                        : 'Not Uploaded',
                    onTap: controller.onSelectVehicleRegistration,
                  ),
                ),
                12.verticalSpace,

                Obx(
                  () => _DriverDocsUploadCard(
                    label: 'Vehicle Insurance',
                    description: 'Current third-party or comprehensive policy',
                    icon: AppAssets.vehicleInsurance,
                    isRequired: true,
                    uploadedFileName: controller.vehicleInsurancePath.value,
                    base64Data: controller.vehicleInsuranceBase64.value,
                    status: controller.vehicleInsuranceBase64.value.isNotEmpty
                        ? 'In Review'
                        : 'Not Uploaded',
                    onTap: controller.onSelectVehicleInsurance,
                  ),
                ),
                12.verticalSpace,

                Obx(
                  () => _DriverDocsUploadCard(
                    label: 'Police Check',
                    description: 'National police certificate (Optional)',
                    icon: AppAssets.policCheck,
                    isRequired: false,
                    uploadedFileName: controller.policeCheckPath.value,
                    base64Data: controller.policeCheckBase64.value,
                    status: controller.policeCheckBase64.value.isNotEmpty
                        ? 'In Review'
                        : 'Not Uploaded',
                    onTap: controller.onSelectPoliceCheck,
                  ),
                ),

                18.verticalSpace,

                // Security & Privacy Note
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.containerFillColor,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.borderColor, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 20.sp,
                        color: AppColors.primaryColor,
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: Text(
                          'Your documents are strictly confidential and used solely for identity verification.',
                          style: AppTextStyle.text12Medium.copyWith(
                            color: AppColors.secondaryTextColor,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                22.verticalSpace,

                // Submit Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Obx(
                    () => AppButton(
                      onPressed: controller.onSubmitForVerification,
                      label: 'Submit for Verification',
                      isLoading: controller.isLoading.value,
                      icon: AppAssets.checkIcon,
                    ),
                  ),
                ),

                12.verticalSpace,

                // Skip Option for Uploading Later
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: OutlinedButton(
                    onPressed: controller.onSkipDriverVerification,
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48.h),
                      side: BorderSide(
                        color: AppColors.primaryColor.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      backgroundColor: AppColors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Skip for now',
                          style: AppTextStyle.text14Semibold.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                        6.horizontalSpace,
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16.sp,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),

                16.verticalSpace,

                // Note under button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 16.sp,
                      color: AppColors.primaryColor,
                    ),
                    6.horizontalSpace,
                    Text(
                      'Verified badge will be issued upon approval',
                      style: AppTextStyle.text12Medium.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),

                20.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DriverDocsUploadCard extends StatelessWidget {
  const _DriverDocsUploadCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.isRequired,
    required this.uploadedFileName,
    this.base64Data,
    this.status,
    required this.onTap,
  });

  final String label;
  final String description;
  final String icon;
  final bool isRequired;
  final String uploadedFileName;
  final String? base64Data;
  final String? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isUploaded = uploadedFileName.isNotEmpty;
    final bool hasBase64 = base64Data != null && base64Data!.isNotEmpty;
    final String normStatus = (status ?? '').trim().toLowerCase();
    final bool isInReview =
        isUploaded && (normStatus == 'pending' || normStatus == 'in review');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          width: isUploaded ? 1.5 : 1.2,
          color: isInReview
              ? const Color(0xFFF59E0B)
              : (isUploaded ? const Color(0xFF10B981) : AppColors.borderColor),
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: isInReview
                ? const Color(0xFFF59E0B).withValues(alpha: 0.06)
                : (isUploaded
                      ? const Color(0xFF10B981).withValues(alpha: 0.06)
                      : AppColors.primaryTextColor.withValues(alpha: 0.02)),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
      child: Column(
        children: [
          Row(
            children: [
              // Icon Badge or Document Preview
              if (hasBase64)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: SizedBox(
                    height: 48.h,
                    width: 48.w,
                    child: Utils.imageFromBase64(
                      base64Data!,
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        color: const Color(0xFFECFDF5),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.description_rounded,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 42.h,
                  width: 42.w,
                  padding: EdgeInsets.all(9.r),
                  decoration: BoxDecoration(
                    color: isUploaded
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isUploaded
                          ? const Color(0xFF10B981).withValues(alpha: 0.3)
                          : AppColors.borderColor,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    icon,
                    colorFilter: ColorFilter.mode(
                      isUploaded
                          ? const Color(0xFF059669)
                          : AppColors.primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              12.horizontalSpace,

              // Labels
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            style: AppTextStyle.text14Semibold.copyWith(
                              color: AppColors.primaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        8.horizontalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: isRequired
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            isRequired ? 'Required' : 'Optional',
                            style: AppTextStyle.text10Medium.copyWith(
                              color: isRequired
                                  ? AppColors.primaryColor
                                  : AppColors.secondaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isInReview) ...[
                          6.horizontalSpace,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: const Color(0xFFFDE68A),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.hourglass_bottom_rounded,
                                  size: 10.sp,
                                  color: const Color(0xFFD97706),
                                ),
                                3.horizontalSpace,
                                Text(
                                  'In Review',
                                  style: AppTextStyle.text10Medium.copyWith(
                                    color: const Color(0xFFD97706),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    3.verticalSpace,
                    Text(
                      description,
                      style: AppTextStyle.text12Regular.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          12.verticalSpace,

          // Upload Action Button / Attached State
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: isUploaded
                    ? const Color(0xFFECFDF5)
                    : AppColors.containerFillColor,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isUploaded
                      ? const Color(0xFF10B981)
                      : AppColors.borderColor,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isUploaded) ...[
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16.sp,
                      color: const Color(0xFF059669),
                    ),
                    8.horizontalSpace,
                    Flexible(
                      child: Text(
                        'Attached: $uploadedFileName',
                        style: AppTextStyle.text12Semibold.copyWith(
                          color: const Color(0xFF059669),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    8.horizontalSpace,
                    Text(
                      '• Tap to change',
                      style: AppTextStyle.text10Medium.copyWith(
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ] else ...[
                    SvgPicture.asset(
                      AppAssets.uploadIcon,
                      height: 14.h,
                      width: 14.w,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    8.horizontalSpace,
                    Text(
                      'Tap to Upload Document',
                      style: AppTextStyle.text12Semibold.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
