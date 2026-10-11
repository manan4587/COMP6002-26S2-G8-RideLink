import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_assets.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/enums/verification_status.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/routes/routes_name.dart';
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
                      final isAllVerified =
                          controller.dlStatus.value.isVerified &&
                          controller.vrStatus.value.isVerified &&
                          controller.viStatus.value.isVerified;

                      final hasPending =
                          controller.dlStatus.value.isPending ||
                          controller.vrStatus.value.isPending ||
                          controller.viStatus.value.isPending;

                      final hasRejected =
                          controller.dlStatus.value.isRejected ||
                          controller.vrStatus.value.isRejected ||
                          controller.viStatus.value.isRejected;

                      final String label = isAllVerified
                          ? 'Verified'
                          : (hasRejected
                                ? 'Rejected'
                                : (hasPending ? 'In Review' : 'Not Uploaded'));

                      final Color bg = isAllVerified
                          ? const Color(0xFFDCFCE7)
                          : (hasRejected
                                ? const Color(0xFFFEE2E2)
                                : (hasPending
                                      ? const Color(0xFFFEF3C7)
                                      : const Color(0xFFF1F5F9)));

                      final Color textColor = isAllVerified
                          ? const Color(0xFF16A34A)
                          : (hasRejected
                                ? const Color(0xFFDC2626)
                                : (hasPending
                                      ? const Color(0xFFD97706)
                                      : AppColors.secondaryTextColor));

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
                  final isAllVerified =
                      controller.dlStatus.value.isVerified &&
                      controller.vrStatus.value.isVerified &&
                      controller.viStatus.value.isVerified;

                  final hasPending =
                      controller.dlStatus.value.isPending ||
                      controller.vrStatus.value.isPending ||
                      controller.viStatus.value.isPending;

                  final hasRejected =
                      controller.dlStatus.value.isRejected ||
                      controller.vrStatus.value.isRejected ||
                      controller.viStatus.value.isRejected;

                  final Color bannerColor = isAllVerified
                      ? const Color(0xFFECFDF5)
                      : (hasRejected
                            ? const Color(0xFFFEF2F2)
                            : (hasPending
                                  ? const Color(0xFFFFFBEB)
                                  : AppColors.containerFillColor));
                  final Color borderColor = isAllVerified
                      ? const Color(0xFF86EFAC)
                      : (hasRejected
                            ? const Color(0xFFFECACA)
                            : (hasPending
                                  ? const Color(0xFFFDE68A)
                                  : AppColors.borderColor));
                  final Color iconColor = isAllVerified
                      ? const Color(0xFF16A34A)
                      : (hasRejected
                            ? const Color(0xFFDC2626)
                            : (hasPending
                                  ? const Color(0xFFD97706)
                                  : AppColors.primaryColor));
                  final Color titleColor = isAllVerified
                      ? const Color(0xFF15803D)
                      : (hasRejected
                            ? const Color(0xFFB91C1C)
                            : (hasPending
                                  ? const Color(0xFFB45309)
                                  : AppColors.primaryTextColor));
                  final Color textColor = isAllVerified
                      ? const Color(0xFF166534)
                      : (hasRejected
                            ? const Color(0xFF991B1B)
                            : (hasPending
                                  ? const Color(0xFF92400E)
                                  : AppColors.secondaryTextColor));

                  final String title = isAllVerified
                      ? 'All Documents Verified by Admin'
                      : (hasRejected
                            ? 'Action Required: Document(s) Rejected'
                            : (hasPending
                                  ? 'Documents In Review'
                                  : 'Action Required: Documents Not Uploaded'));

                  final String description = isAllVerified
                      ? 'All your documents are approved by admin. You can publish rides anytime.'
                      : (hasRejected
                            ? 'One or more documents were rejected by admin. Tap the rejected card below to view reason and re-upload.'
                            : (hasPending
                                  ? 'Admin verification is in progress for your uploaded documents (typical turnaround: 24-48 hours).'
                                  : 'Please upload all required documents to verify your driver profile.'));

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
                          isAllVerified
                              ? Icons.verified_user_rounded
                              : (hasRejected
                                    ? Icons.error_outline_rounded
                                    : (hasPending
                                          ? Icons.hourglass_top_rounded
                                          : Icons.warning_amber_rounded)),
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

                // Vehicle Details Status Card (Requirement: Vehicle details must be added before verifications)
                Obx(() {
                  final hasVehicle =
                      controller.vehicleNumber.value.isNotEmpty &&
                      controller.vehicleNumber.value != 'N/A';
                  final vehicleText = hasVehicle
                      ? '${controller.vehicleType.value != "N/A" ? controller.vehicleType.value : "Vehicle"} • Plate ${controller.vehicleNumber.value}'
                      : 'No vehicle registered yet';

                  return Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: hasVehicle
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: hasVehicle
                            ? const Color(0xFFE2E8F0)
                            : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: hasVehicle
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFFEF3C7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.car_detailed,
                            color: hasVehicle
                                ? AppColors.primaryColor
                                : const Color(0xFFD97706),
                            size: 18.sp,
                          ),
                        ),
                        10.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Vehicle Details',
                                    style: AppTextStyle.text14Semibold.copyWith(
                                      color: hasVehicle
                                          ? AppColors.primaryTextColor
                                          : const Color(0xFFB45309),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  6.horizontalSpace,
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: hasVehicle
                                          ? const Color(0xFFDCFCE7)
                                          : const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      hasVehicle ? 'Added' : 'Required First',
                                      style: AppTextStyle.text10Medium.copyWith(
                                        color: hasVehicle
                                            ? const Color(0xFF16A34A)
                                            : const Color(0xFFDC2626),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              2.verticalSpace,
                              Text(
                                hasVehicle
                                    ? vehicleText
                                    : 'Please enter vehicle details before uploading documents.',
                                style: AppTextStyle.text12Regular.copyWith(
                                  color: hasVehicle
                                      ? AppColors.secondaryTextColor
                                      : const Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Get.toNamed(AppRoutes.vehicleRegistration),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            controller.isVerifiedByAdmin.value
                                ? 'View (Locked)'
                                : (hasVehicle ? 'View / Edit' : 'Add Now'),
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: controller.isVerifiedByAdmin.value
                                  ? AppColors.secondaryTextColor
                                  : AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

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
                        subtitle: controller.dlStatus.value.isRejected
                            ? 'Rejected by Admin • Tap to review & re-upload'
                            : (controller.dlStatus.value.isVerified
                                ? 'Government-issued valid driving licence • Verified'
                                : (controller.drivingLicenceUrl.value.isNotEmpty
                                    ? 'Document uploaded and awaiting admin review'
                                    : 'Government-issued valid driving licence')),
                        status: controller.dlStatus.value,
                        fileName: controller.drivingLicenceDoc.value,
                        rejectionReason: controller.dlRejectionReason.value,
                        icon: AppAssets.drivingLicense,
                        isRequired: true,
                        isLocked: controller.isVerifiedByAdmin.value,
                        documentUrl: controller.drivingLicenceUrl.value,
                        isUploading: controller.isDocUploading(
                          DriverDocumentId.drivingLicence,
                        ),
                        onTap: () => _handleDocAction(
                          context,
                          'Driving Licence',
                          controller.drivingLicenceDoc.value,
                          controller.drivingLicenceUrl.value,
                          controller.dlStatus.value,
                          () => controller.uploadDocument(
                            DriverDocumentId.drivingLicence,
                          ),
                          docId: DriverDocumentId.drivingLicence,
                          rejectionReason: controller.dlRejectionReason.value,
                        ),
                      ),
                    ),
                    12.verticalSpace,

                    Obx(
                      () => _DocumentStatusTile(
                        title: 'Vehicle Registration (VR)',
                        subtitle: controller.vrStatus.value.isRejected
                            ? 'Rejected by Admin • Tap to review & re-upload'
                            : (controller.vrStatus.value.isVerified
                                ? (controller.vehicleNumber.value != 'N/A' &&
                                        controller.vehicleNumber.value.isNotEmpty
                                    ? 'Plate: ${controller.vehicleNumber.value} • Verified'
                                    : 'Registration certificate verified')
                                : (controller
                                        .vehicleRegistrationUrl
                                        .value
                                        .isNotEmpty
                                    ? (controller.vehicleNumber.value != 'N/A' &&
                                            controller
                                                .vehicleNumber
                                                .value
                                                .isNotEmpty
                                        ? 'Plate: ${controller.vehicleNumber.value} • Uploaded & in review'
                                        : 'Registration certificate uploaded & in review')
                                    : (controller.vehicleNumber.value != 'N/A' &&
                                            controller
                                                .vehicleNumber
                                                .value
                                                .isNotEmpty
                                        ? 'Plate: ${controller.vehicleNumber.value} • Not uploaded'
                                        : 'Official vehicle registration certificate'))),
                        status: controller.vrStatus.value,
                        fileName: controller.vehicleRegistrationDoc.value,
                        rejectionReason: controller.vrRejectionReason.value,
                        icon: AppAssets.vehicleRegistration,
                        isRequired: true,
                        isLocked: controller.isVerifiedByAdmin.value,
                        documentUrl: controller.vehicleRegistrationUrl.value,
                        isUploading: controller.isDocUploading(
                          DriverDocumentId.vehicleRegistration,
                        ),
                        onTap: () => _handleDocAction(
                          context,
                          'Vehicle Registration',
                          controller.vehicleRegistrationDoc.value,
                          controller.vehicleRegistrationUrl.value,
                          controller.vrStatus.value,
                          () => controller.uploadDocument(
                            DriverDocumentId.vehicleRegistration,
                          ),
                          docId: DriverDocumentId.vehicleRegistration,
                          rejectionReason: controller.vrRejectionReason.value,
                        ),
                      ),
                    ),
                    12.verticalSpace,

                    Obx(
                      () => _DocumentStatusTile(
                        title: 'Vehicle Insurance (VI)',
                        subtitle: controller.viStatus.value.isRejected
                            ? 'Rejected by Admin • Tap to review & re-upload'
                            : (controller.viStatus.value.isVerified
                                ? 'Vehicle insurance policy • Verified'
                                : (controller.vehicleInsuranceUrl.value.isNotEmpty
                                    ? 'Policy document uploaded and awaiting review'
                                    : 'Comprehensive or third-party vehicle policy')),
                        status: controller.viStatus.value,
                        fileName: controller.vehicleInsuranceDoc.value,
                        rejectionReason: controller.viRejectionReason.value,
                        icon: AppAssets.vehicleInsurance,
                        isRequired: true,
                        isLocked: controller.isVerifiedByAdmin.value,
                        documentUrl: controller.vehicleInsuranceUrl.value,
                        isUploading: controller.isDocUploading(
                          DriverDocumentId.vehicleInsurance,
                        ),
                        onTap: () => _handleDocAction(
                          context,
                          'Vehicle Insurance',
                          controller.vehicleInsuranceDoc.value,
                          controller.vehicleInsuranceUrl.value,
                          controller.viStatus.value,
                          () => controller.uploadDocument(
                            DriverDocumentId.vehicleInsurance,
                          ),
                          docId: DriverDocumentId.vehicleInsurance,
                          rejectionReason: controller.viRejectionReason.value,
                        ),
                      ),
                    ),
                    12.verticalSpace,

                    Obx(
                      () => _DocumentStatusTile(
                        title: 'Police Check (PC)',
                        subtitle: controller.pcStatus.value.isRejected
                            ? 'Rejected by Admin • Tap to review & re-upload'
                            : (controller.pcStatus.value.isVerified
                                ? 'Police certificate • Verified'
                                : (controller.policeCheckUrl.value.isNotEmpty
                                    ? 'Police certificate uploaded and awaiting review'
                                    : 'National criminal history check (Optional)')),
                        status: controller.pcStatus.value,
                        fileName: controller.policeCheckDoc.value,
                        rejectionReason: controller.pcRejectionReason.value,
                        icon: AppAssets.policCheck,
                        isRequired: false,
                        isLocked: controller.isVerifiedByAdmin.value,
                        documentUrl: controller.policeCheckUrl.value,
                        isUploading: controller.isDocUploading(
                          DriverDocumentId.policeCheck,
                        ),
                        onTap: () => _handleDocAction(
                          context,
                          'Police Check',
                          controller.policeCheckDoc.value,
                          controller.policeCheckUrl.value,
                          controller.pcStatus.value,
                          () => controller.uploadDocument(
                            DriverDocumentId.policeCheck,
                          ),
                          docId: DriverDocumentId.policeCheck,
                          rejectionReason: controller.pcRejectionReason.value,
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
    String documentUrl,
    DocumentVerificationStatus docStatus,
    VoidCallback onUpload, {
    String? docId,
    String? rejectionReason,
  }) {
    final hasVehicle = controller.vehicleNumber.value.isNotEmpty &&
        controller.vehicleNumber.value != 'N/A';
    if (!hasVehicle) {
      AppSnackBar.warning(
        message:
            'Please add your vehicle details before uploading verification documents.',
      );
      Get.toNamed(AppRoutes.vehicleRegistration);
      return;
    }

    if (docId != null && controller.isDocUploading(docId)) {
      AppSnackBar.info(message: '$docTitle is already uploading. Please wait.');
      return;
    }

    final bool isDocVerified =
        docStatus.isVerified || controller.isVerifiedByAdmin.value;

    if (documentUrl.isNotEmpty || docStatus.isRejected) {
      Get.bottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 12.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top drag handle pill
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.borderColor,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                14.verticalSpace,

                // Title and status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              docTitle,
                              style: AppTextStyle.text18Semibold.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          8.horizontalSpace,
                          if (isDocVerified)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 2.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(6.r),
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
                                    size: 11.sp,
                                    color: const Color(0xFF16A34A),
                                  ),
                                  3.horizontalSpace,
                                  Text(
                                    'Verified',
                                    style: AppTextStyle.text10Medium.copyWith(
                                      color: const Color(0xFF16A34A),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (docStatus.isRejected)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 2.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: const Color(0xFFFCA5A5),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.cancel_rounded,
                                    size: 11.sp,
                                    color: const Color(0xFFDC2626),
                                  ),
                                  3.horizontalSpace,
                                  Text(
                                    'Rejected',
                                    style: AppTextStyle.text10Medium.copyWith(
                                      color: const Color(0xFFDC2626),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (docStatus.isPending)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 2.5.h,
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
                                    Icons.hourglass_top_rounded,
                                    size: 11.sp,
                                    color: const Color(0xFFD97706),
                                  ),
                                  3.horizontalSpace,
                                  Text(
                                    'In Review',
                                    style: AppTextStyle.text10Medium.copyWith(
                                      color: const Color(0xFFB45309),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded),
                      splashRadius: 20.r,
                    ),
                  ],
                ),

                if (fileName.isNotEmpty &&
                        !fileName.endsWith('_doc.jpg') &&
                        !fileName.endsWith('.jpg') ||
                    (fileName.isNotEmpty && fileName.contains('image_picker')))
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      fileName,
                      style: AppTextStyle.text12Regular.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ),

                // Dedicated Rejection Reason Banner in the Sheet
                if (docStatus.isRejected) ...[
                  14.verticalSpace,
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: const Color(0xFFFECACA),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6.r),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFEE2E2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.exclamationmark_triangle_fill,
                                color: const Color(0xFFDC2626),
                                size: 16.sp,
                              ),
                            ),
                            10.horizontalSpace,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Document Rejected by Admin',
                                    style: AppTextStyle.text14Semibold.copyWith(
                                      color: const Color(0xFFB91C1C),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  2.verticalSpace,
                                  Text(
                                    'Action required: Please review feedback below',
                                    style: AppTextStyle.text11Medium.copyWith(
                                      color: const Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (rejectionReason != null &&
                            rejectionReason.trim().isNotEmpty) ...[
                          10.verticalSpace,
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: const Color(0xFFFCA5A5),
                                width: 0.8,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.chat_bubble_text_fill,
                                      size: 13.sp,
                                      color: const Color(0xFFDC2626),
                                    ),
                                    6.horizontalSpace,
                                    Text(
                                      'Admin Feedback / Rejection Reason',
                                      style: AppTextStyle.text11Medium.copyWith(
                                        color: const Color(0xFF991B1B),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                6.verticalSpace,
                                Text(
                                  rejectionReason.trim(),
                                  style: AppTextStyle.text13Regular.copyWith(
                                    color: const Color(0xFF7F1D1D),
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        8.verticalSpace,
                        Text(
                          'Please ensure the replacement document is clearly readable, well-lit, shows all four corners, and is not expired.',
                          style: AppTextStyle.text11Medium.copyWith(
                            color: const Color(0xFF991B1B),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (documentUrl.isNotEmpty) ...[
                  14.verticalSpace,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: Container(
                      width: double.infinity,
                      height: 200.h,
                      decoration: BoxDecoration(
                        color: AppColors.containerFillColor,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: documentUrl.startsWith('http://') ||
                              documentUrl.startsWith('https://')
                          ? Image.network(
                              documentUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: AppColors.containerFillColor,
                                alignment: Alignment.center,
                                child: Text(
                                  'Document Preview Unavailable',
                                  style: AppTextStyle.text12Medium,
                                ),
                              ),
                            )
                          : Utils.imageFromBase64(
                              documentUrl,
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
                ],

                16.verticalSpace,
                if (isDocVerified)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 14.w,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF16A34A),
                          size: 16,
                        ),
                        8.horizontalSpace,
                        Text(
                          'Verified by Admin • Read Only',
                          style: AppTextStyle.text12Semibold.copyWith(
                            color: const Color(0xFF15803D),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        onUpload();
                      },
                      icon: Icon(
                        docStatus.isRejected
                            ? CupertinoIcons.arrow_clockwise_circle_fill
                            : Icons.refresh_rounded,
                      ),
                      label: Text(
                        docStatus.isRejected
                            ? 'Re-upload Document Now'
                            : 'Re-upload / Replace Document',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: docStatus.isRejected
                            ? const Color(0xFFDC2626)
                            : AppColors.primaryColor,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: docStatus.isRejected ? 2 : 0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    } else {
      if (isDocVerified) {
        AppSnackBar.info(
          message:
              '$docTitle cannot be modified because your driver account is verified.',
        );
        return;
      }
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
    this.isRequired = true,
    this.isLocked = false,
    this.documentUrl,
    this.fileName,
    this.rejectionReason,
    this.isUploading = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final DocumentVerificationStatus status;
  final String icon;
  final bool isRequired;
  final bool isLocked;
  final String? documentUrl;
  final String? fileName;
  final String? rejectionReason;
  final bool isUploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasAttachedImage =
        documentUrl != null && documentUrl!.trim().isNotEmpty;
    final bool hasFileName = fileName != null && fileName!.trim().isNotEmpty;
    final bool isApproved = status.isVerified;
    final bool isRejected = status.isRejected;
    final bool isInReview = status.isPending;

    final Color borderColor = status.cardBorderColor;
    final Color shadowColor = status.cardShadowColor;

    return GestureDetector(
      onTap: isUploading ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            width: isApproved || isRejected || isInReview ? 1.5 : 1.2,
            color: borderColor,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
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
                // Icon Badge or Document Preview
                if (hasAttachedImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: SizedBox(
                      height: 48.h,
                      width: 48.w,
                      child:
                          documentUrl!.startsWith('http://') ||
                              documentUrl!.startsWith('https://')
                          ? Image.network(
                              documentUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: const Color(0xFFECFDF5),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.description_rounded,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                            )
                          : Utils.imageFromBase64(
                              documentUrl!,
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
                      color: isApproved || isRejected || isInReview
                          ? status.backgroundColor
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isApproved || isRejected || isInReview
                            ? status.cardBorderColor.withValues(alpha: 0.3)
                            : AppColors.borderColor,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      icon,
                      colorFilter: ColorFilter.mode(
                        isApproved || isRejected || isInReview
                            ? status.primaryColor
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
                      Text(
                        title,
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: AppColors.primaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
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

                // Right Corner Badge (Verified, Rejected, In Review, or Uploading)
                if (isUploading) ...[
                  8.horizontalSpace,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: const Color(0xFFBFDBFE),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 10.w,
                          height: 10.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 1.8,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        5.horizontalSpace,
                        Text(
                          'Uploading...',
                          style: AppTextStyle.text11Medium.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isApproved || isLocked) ...[
                  8.horizontalSpace,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: isApproved
                          ? status.backgroundColor
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isApproved
                            ? status.borderColor
                            : const Color(0xFF86EFAC),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 13.sp,
                          color: isApproved
                              ? status.primaryColor
                              : const Color(0xFF16A34A),
                        ),
                        4.horizontalSpace,
                        Text(
                          isApproved ? status.label : 'Verified',
                          style: AppTextStyle.text11Medium.copyWith(
                            color: isApproved
                                ? status.primaryColor
                                : const Color(0xFF16A34A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isRejected) ...[
                  8.horizontalSpace,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: status.backgroundColor,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: status.borderColor, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 13.sp,
                          color: status.primaryColor,
                        ),
                        4.horizontalSpace,
                        Text(
                          status.label,
                          style: AppTextStyle.text11Medium.copyWith(
                            color: status.primaryColor,
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
                      color: status.backgroundColor,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: status.borderColor, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.hourglass_bottom_rounded,
                          size: 11.sp,
                          color: status.primaryColor,
                        ),
                        3.horizontalSpace,
                        Text(
                          status.label,
                          style: AppTextStyle.text10Medium.copyWith(
                            color: status.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            // Only show the bottom action button if the document is NOT yet approved and NOT locked!
            if (!isApproved && !isLocked) ...[
              12.verticalSpace,
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: isUploading
                      ? const Color(0xFFEFF6FF)
                      : (isRejected || isInReview
                            ? status.backgroundColor
                            : AppColors.containerFillColor),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isUploading
                        ? const Color(0xFFBFDBFE)
                        : (isRejected || isInReview
                              ? status.borderColor
                              : AppColors.borderColor),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isUploading) ...[
                      SizedBox(
                        width: 14.w,
                        height: 14.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      8.horizontalSpace,
                      Text(
                        'Document is uploading...',
                        style: AppTextStyle.text12Semibold.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ] else if (isRejected) ...[
                      Icon(
                        Icons.refresh_rounded,
                        size: 15.sp,
                        color: status.primaryColor,
                      ),
                      8.horizontalSpace,
                      Flexible(
                        child: Text(
                          'Rejected by Admin • Tap to review & re-upload',
                          style: AppTextStyle.text12Semibold.copyWith(
                            color: status.primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else if (isInReview) ...[
                      Icon(
                        Icons.hourglass_bottom_rounded,
                        size: 15.sp,
                        color: status.primaryColor,
                      ),
                      8.horizontalSpace,
                      Flexible(
                        child: Text(
                          hasFileName
                              ? 'Attached: ${fileName!}'
                              : 'Document In Review',
                          style: AppTextStyle.text12Semibold.copyWith(
                            color: status.primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      8.horizontalSpace,
                      Text(
                        '• Tap to change',
                        style: AppTextStyle.text10Medium.copyWith(
                          color: status.primaryColor,
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
