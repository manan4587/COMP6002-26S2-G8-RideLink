import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_assets.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_profile_controller.dart';
import 'package:ridelink/widgets/app_border_container.dart';
import 'package:ridelink/widgets/app_main_container.dart';

class DriverVerificationDocumentsPage extends GetView<DriverProfileController> {
  const DriverVerificationDocumentsPage({super.key});

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Navigation Bar
                Row(
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
                    Expanded(
                      child: Text(
                        'Verifications',
                        style: AppTextStyle.text18Semibold.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Obx(() {
                      final isDlVerified =
                          controller.dlStatus.value.trim().toLowerCase() ==
                          'verified';
                      final isVrVerified =
                          controller.vrStatus.value.trim().toLowerCase() ==
                          'verified';
                      final isViVerified =
                          controller.viStatus.value.trim().toLowerCase() ==
                          'verified';
                      final allVerified =
                          isDlVerified && isVrVerified && isViVerified;

                      final hasMissing =
                          controller.dlStatus.value == 'Not Uploaded' ||
                          controller.vrStatus.value == 'Not Uploaded' ||
                          controller.viStatus.value == 'Not Uploaded';

                      final hasPending =
                          controller.dlStatus.value.trim().toLowerCase() ==
                              'pending' ||
                          controller.vrStatus.value.trim().toLowerCase() ==
                              'pending' ||
                          controller.viStatus.value.trim().toLowerCase() ==
                              'pending' ||
                          controller.dlStatus.value.trim().toLowerCase() ==
                              'in review' ||
                          controller.vrStatus.value.trim().toLowerCase() ==
                              'in review' ||
                          controller.viStatus.value.trim().toLowerCase() ==
                              'in review';

                      final String label = allVerified
                          ? 'Verified'
                          : (hasPending
                                ? 'In Review'
                                : (hasMissing
                                      ? 'Not Uploaded'
                                      : 'Pending Admin'));
                      final Color bg = allVerified
                          ? const Color(0xFFDCFCE7)
                          : (hasMissing && !hasPending
                                ? const Color(0xFFFEE2E2)
                                : const Color(0xFFFEF3C7));
                      final Color textColor = allVerified
                          ? const Color(0xFF16A34A)
                          : (hasMissing && !hasPending
                                ? const Color(0xFFDC2626)
                                : const Color(0xFFD97706));

                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          label,
                          style: AppTextStyle.text10Medium.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                12.verticalSpace,

                // Status Notice Callout
                Obx(() {
                  final isDlVerified =
                      controller.dlStatus.value.trim().toLowerCase() ==
                      'verified';
                  final isVrVerified =
                      controller.vrStatus.value.trim().toLowerCase() ==
                      'verified';
                  final isViVerified =
                      controller.viStatus.value.trim().toLowerCase() ==
                      'verified';
                  final allVerified =
                      isDlVerified && isVrVerified && isViVerified;

                  final hasMissingRequired =
                      controller.dlStatus.value == 'Not Uploaded' ||
                      controller.vrStatus.value == 'Not Uploaded' ||
                      controller.viStatus.value == 'Not Uploaded';

                  final hasPending =
                      controller.dlStatus.value.trim().toLowerCase() ==
                          'pending' ||
                      controller.vrStatus.value.trim().toLowerCase() ==
                          'pending' ||
                      controller.viStatus.value.trim().toLowerCase() ==
                          'pending' ||
                      controller.dlStatus.value.trim().toLowerCase() ==
                          'in review' ||
                      controller.vrStatus.value.trim().toLowerCase() ==
                          'in review' ||
                      controller.viStatus.value.trim().toLowerCase() ==
                          'in review';

                  final Color bannerColor = allVerified
                      ? const Color(0xFFECFDF5)
                      : (hasMissingRequired && !hasPending
                            ? const Color(0xFFFEF2F2)
                            : const Color(0xFFFFFBEB));
                  final Color borderColor = allVerified
                      ? const Color(0xFF86EFAC)
                      : (hasMissingRequired && !hasPending
                            ? const Color(0xFFFECACA)
                            : const Color(0xFFFDE68A));
                  final Color iconColor = allVerified
                      ? const Color(0xFF16A34A)
                      : (hasMissingRequired && !hasPending
                            ? const Color(0xFFDC2626)
                            : const Color(0xFFD97706));
                  final Color titleColor = allVerified
                      ? const Color(0xFF15803D)
                      : (hasMissingRequired && !hasPending
                            ? const Color(0xFFB91C1C)
                            : const Color(0xFFB45309));
                  final Color textColor = allVerified
                      ? const Color(0xFF166534)
                      : (hasMissingRequired && !hasPending
                            ? const Color(0xFF991B1B)
                            : const Color(0xFF92400E));

                  final String title = allVerified
                      ? 'All Documents Verified by Admin'
                      : (hasMissingRequired && !hasPending
                            ? 'Action Required: Documents Not Uploaded'
                            : 'Documents In Review');

                  final String description = allVerified
                      ? 'All your documents are approved by admin. You can publish rides anytime.'
                      : (hasMissingRequired && !hasPending
                            ? 'You have missing required documents. Tap any document card below to upload photo from Camera or Gallery.'
                            : 'Admin verification is in progress for your uploaded documents (typical turnaround: 24-48 hours). Each document will be verified individually.');

                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: bannerColor,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          allVerified
                              ? Icons.verified_user_rounded
                              : (hasMissingRequired && !hasPending
                                    ? Icons.warning_amber_rounded
                                    : Icons.hourglass_top_rounded),
                          size: 20.sp,
                          color: iconColor,
                        ),
                        10.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTextStyle.text14Semibold.copyWith(
                                  color: titleColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              4.verticalSpace,
                              Text(
                                description,
                                style: AppTextStyle.text12Regular.copyWith(
                                  color: textColor,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                16.verticalSpace,

                // Documents List
                AppBorderContainer(
                  margin: EdgeInsets.symmetric(horizontal: 0),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 16.h,
                  ),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submitted Credentials',
                      style: AppTextStyle.text14Semibold.copyWith(
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    12.verticalSpace,

                    Obx(
                      () => _DocumentStatusTile(
                        title: 'Driving Licence (DL)',
                        subtitle:
                            controller.dlStatus.value.trim().toLowerCase() ==
                                'verified'
                            ? 'Government-issued valid driving licence • Verified'
                            : (controller.drivingLicenceBase64.value.isNotEmpty
                                  ? 'Document uploaded and awaiting admin review'
                                  : 'Government-issued valid driving licence'),
                        status: controller.dlStatus.value,
                        fileName: controller.drivingLicenceDoc.value,
                        icon: AppAssets.drivingLicense,
                        isRequired: true,
                        isVerified:
                            controller.dlStatus.value.trim().toLowerCase() ==
                            'verified',
                        base64Data: controller.drivingLicenceBase64.value,
                        onTap: () => _handleDocAction(
                          context,
                          'Driving Licence',
                          controller.drivingLicenceDoc.value,
                          controller.drivingLicenceBase64.value,
                          () => controller.uploadDocument('Driving Licence'),
                        ),
                      ),
                    ),
                    12.verticalSpace,

                    Obx(
                      () => _DocumentStatusTile(
                        title: 'Vehicle Registration (VR)',
                        subtitle:
                            controller.vrStatus.value.trim().toLowerCase() ==
                                'verified'
                            ? (controller.vehicleNumber.value != 'N/A' &&
                                      controller.vehicleNumber.value.isNotEmpty
                                  ? 'Plate: ${controller.vehicleNumber.value} • Verified'
                                  : 'Registration certificate verified')
                            : (controller
                                      .vehicleRegistrationBase64
                                      .value
                                      .isNotEmpty
                                  ? (controller.vehicleNumber.value != 'N/A' &&
                                            controller
                                                .vehicleNumber
                                                .value
                                                .isNotEmpty
                                        ? 'Plate: ${controller.vehicleNumber.value} • Uploaded'
                                        : 'Registration certificate uploaded')
                                  : (controller.vehicleNumber.value != 'N/A' &&
                                            controller
                                                .vehicleNumber
                                                .value
                                                .isNotEmpty
                                        ? 'Plate: ${controller.vehicleNumber.value} • Not uploaded'
                                        : 'Official vehicle registration certificate')),
                        status: controller.vrStatus.value,
                        fileName: controller.vehicleRegistrationDoc.value,
                        icon: AppAssets.vehicleRegistration,
                        isRequired: true,
                        isVerified:
                            controller.vrStatus.value.trim().toLowerCase() ==
                            'verified',
                        base64Data: controller.vehicleRegistrationBase64.value,
                        onTap: () => _handleDocAction(
                          context,
                          'Vehicle Registration',
                          controller.vehicleRegistrationDoc.value,
                          controller.vehicleRegistrationBase64.value,
                          () =>
                              controller.uploadDocument('Vehicle Registration'),
                        ),
                      ),
                    ),
                    12.verticalSpace,

                    Obx(
                      () => _DocumentStatusTile(
                        title: 'Vehicle Insurance (VI)',
                        subtitle:
                            controller.viStatus.value.trim().toLowerCase() ==
                                'verified'
                            ? 'Vehicle insurance policy • Verified'
                            : (controller
                                      .vehicleInsuranceBase64
                                      .value
                                      .isNotEmpty
                                  ? 'Policy document uploaded and awaiting review'
                                  : 'Comprehensive or third-party vehicle policy'),
                        status: controller.viStatus.value,
                        fileName: controller.vehicleInsuranceDoc.value,
                        icon: AppAssets.vehicleInsurance,
                        isRequired: true,
                        isVerified:
                            controller.viStatus.value.trim().toLowerCase() ==
                            'verified',
                        base64Data: controller.vehicleInsuranceBase64.value,
                        onTap: () => _handleDocAction(
                          context,
                          'Vehicle Insurance',
                          controller.vehicleInsuranceDoc.value,
                          controller.vehicleInsuranceBase64.value,
                          () => controller.uploadDocument('Vehicle Insurance'),
                        ),
                      ),
                    ),
                    12.verticalSpace,

                    Obx(
                      () => _DocumentStatusTile(
                        title: 'Police Check (PC)',
                        subtitle:
                            controller.pcStatus.value.trim().toLowerCase() ==
                                'verified'
                            ? 'Police certificate • Verified'
                            : (controller.policeCheckBase64.value.isNotEmpty
                                  ? 'Police certificate uploaded and awaiting review'
                                  : 'National criminal history check (Optional)'),
                        status: controller.pcStatus.value,
                        fileName: controller.policeCheckDoc.value,
                        icon: AppAssets.policCheck,
                        isRequired: false,
                        isVerified:
                            controller.pcStatus.value.trim().toLowerCase() ==
                            'verified',
                        base64Data: controller.policeCheckBase64.value,
                        onTap: () => _handleDocAction(
                          context,
                          'Police Check',
                          controller.policeCheckDoc.value,
                          controller.policeCheckBase64.value,
                          () => controller.uploadDocument('Police Check'),
                        ),
                      ),
                    ),
                  ],
                ),

                16.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleDocAction(
    BuildContext context,
    String docTitle,
    String fileName,
    String base64Data,
    VoidCallback onUpload,
  ) {
    if (base64Data.isNotEmpty) {
      Get.bottomSheet(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    docTitle,
                    style: AppTextStyle.text18Semibold.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              if (fileName.isNotEmpty &&
                      !fileName.endsWith('_doc.jpg') &&
                      !fileName.endsWith('.jpg') ||
                  (fileName.isNotEmpty && fileName.contains('image_picker')))
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    fileName,
                    style: AppTextStyle.text12Regular.copyWith(
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                ),
              12.verticalSpace,
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox(
                  width: double.infinity,
                  height: 220.h,
                  child: Utils.imageFromBase64(
                    base64Data,
                    fit: BoxFit.contain,
                    errorWidget: Container(
                      color: AppColors.containerFillColor,
                      alignment: Alignment.center,
                      child: Text(
                        'Document Preview Unavailable',
                        style: AppTextStyle.text12Medium,
                      ),
                    ),
                  ),
                ),
              ),
              16.verticalSpace,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    onUpload();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Re-upload / Replace Document'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      onUpload();
    }
  }
}

class _DocumentStatusTile extends StatelessWidget {
  const _DocumentStatusTile({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.icon,
    required this.isVerified,
    this.isRequired = true,
    this.base64Data,
    this.fileName,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String status;
  final String icon;
  final bool isVerified;
  final bool isRequired;
  final String? base64Data;
  final String? fileName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasAttachedImage =
        base64Data != null && base64Data!.trim().isNotEmpty;
    final bool hasFileName = fileName != null && fileName!.trim().isNotEmpty;
    final bool hasDocumentData = hasAttachedImage || hasFileName;

    final normalizedStatus = status.trim().toLowerCase();
    final bool isApproved = normalizedStatus == 'verified';

    // Show in review if document actually has uploaded data and is not approved
    final bool isInReview =
        hasDocumentData &&
        !isApproved &&
        (normalizedStatus == 'pending' ||
            normalizedStatus == 'in review' ||
            normalizedStatus.isEmpty);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            width: isApproved || isInReview ? 1.5 : 1.2,
            color: isApproved
                ? const Color(0xFF10B981)
                : (isInReview
                      ? const Color(0xFFF59E0B)
                      : AppColors.borderColor),
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: isApproved
                  ? const Color(0xFF10B981).withValues(alpha: 0.06)
                  : (isInReview
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.06)
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Badge or Document Preview (Matching DriverVerificationUploadView)
                if (hasAttachedImage)
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
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      icon,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryColor,
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
                              title,
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
                        ],
                      ),
                      3.verticalSpace,
                      Text(
                        subtitle,
                        style: AppTextStyle.text12Regular.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Corner Badge (Verified or In Review)
                if (isApproved) ...[
                  8.horizontalSpace,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: const Color(0xFF86EFAC),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 13.sp,
                          color: const Color(0xFF16A34A),
                        ),
                        4.horizontalSpace,
                        Text(
                          'Verified',
                          style: AppTextStyle.text11Medium.copyWith(
                            color: const Color(0xFF16A34A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isInReview) ...[
                  8.horizontalSpace,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 3.h,
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
                          size: 11.sp,
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

            // Only show the bottom action button if the document is NOT yet approved!
            if (!isApproved) ...[
              12.verticalSpace,
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: isInReview
                      ? const Color(0xFFFEF3C7)
                      : AppColors.containerFillColor,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isInReview
                        ? const Color(0xFFFDE68A)
                        : AppColors.borderColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isInReview) ...[
                      Icon(
                        Icons.hourglass_bottom_rounded,
                        size: 15.sp,
                        color: const Color(0xFFD97706),
                      ),
                      8.horizontalSpace,
                      Flexible(
                        child: Text(
                          hasFileName
                              ? 'Attached: ${fileName!}'
                              : 'Document In Review',
                          style: AppTextStyle.text12Semibold.copyWith(
                            color: const Color(0xFFD97706),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      8.horizontalSpace,
                      Text(
                        '• Tap to change',
                        style: AppTextStyle.text10Medium.copyWith(
                          color: const Color(0xFFD97706),
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
            ],
          ],
        ),
      ),
    );
  }
}
