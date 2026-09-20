import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_assets.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_controller.dart';
import 'package:ridelink/widgets/app_border_container.dart';
import 'package:ridelink/widgets/app_main_container.dart';

class DriverVerificationDocumentsPage
    extends GetView<DriverDashboardController> {
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
                    Obx(
                      () => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: controller.isVerifiedByAdmin.value
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          controller.isVerifiedByAdmin.value
                              ? 'Verified'
                              : 'Pending Admin',
                          style: AppTextStyle.text10Medium.copyWith(
                            color: controller.isVerifiedByAdmin.value
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFD97706),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                12.verticalSpace,

                // Status Notice Callout
                Obx(() {
                  final isVerified = controller.isVerifiedByAdmin.value;
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: isVerified
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isVerified
                            ? const Color(0xFF86EFAC)
                            : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isVerified
                              ? Icons.verified_user_rounded
                              : Icons.hourglass_top_rounded,
                          size: 20.sp,
                          color: isVerified
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFD97706),
                        ),
                        10.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isVerified
                                    ? 'All Documents Verified by Admin'
                                    : 'Documents Pending Admin Approval',
                                style: AppTextStyle.text14Semibold.copyWith(
                                  color: isVerified
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFFB45309),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              4.verticalSpace,
                              Text(
                                isVerified
                                    ? 'Your driver credentials are approved. You can publish rides anytime.'
                                    : 'Admin verification is in progress (typical turnaround: 24-48 hours). You cannot create a new ride until approved.',
                                style: AppTextStyle.text12Regular.copyWith(
                                  color: isVerified
                                      ? const Color(0xFF166534)
                                      : const Color(0xFF92400E),
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
                        subtitle: 'Australian Driver Licence • Class C',
                        status: controller.dlStatus.value,
                        icon: AppAssets.drivingLicense,
                        isVerified: controller.isVerifiedByAdmin.value,
                      ),
                    ),
                    10.verticalSpace,

                    Obx(
                      () => _DocumentStatusTile(
                        title: 'Vehicle Registration (VR)',
                        subtitle: 'Plate: ${controller.vehicleNumber.value}',
                        status: controller.vrStatus.value,
                        icon: AppAssets.vehicleRegistration,
                        isVerified: controller.isVerifiedByAdmin.value,
                      ),
                    ),
                    10.verticalSpace,

                    Obx(
                      () => _DocumentStatusTile(
                        title: 'Vehicle Insurance (VI)',
                        subtitle: 'Comprehensive / CTP Policy',
                        status: controller.viStatus.value,
                        icon: AppAssets.vehicleInsurance,
                        isVerified: controller.isVerifiedByAdmin.value,
                      ),
                    ),
                    10.verticalSpace,

                    Obx(
                      () => _DocumentStatusTile(
                        title: 'Police Check (PC)',
                        subtitle: 'National criminal history check',
                        status: controller.pcStatus.value,
                        icon: AppAssets.policCheck,
                        isVerified: controller.isVerifiedByAdmin.value,
                      ),
                    ),
                  ],
                ),

                16.verticalSpace,

                // Admin Simulation Switch Card (For convenient demo/testing)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.containerFillColor,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Verification Toggle',
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          2.verticalSpace,
                          Text(
                            'Simulate admin approval for testing',
                            style: AppTextStyle.text10Medium.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () => CupertinoSwitch(
                          value: controller.isVerifiedByAdmin.value,
                          activeTrackColor: AppColors.primaryColor,
                          onChanged: (_) =>
                              controller.toggleAdminVerification(),
                        ),
                      ),
                    ],
                  ),
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

class _DocumentStatusTile extends StatelessWidget {
  const _DocumentStatusTile({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.icon,
    required this.isVerified,
  });

  final String title;
  final String subtitle;
  final String status;
  final String icon;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            height: 36.h,
            width: 36.w,
            padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(
              color: isVerified
                  ? const Color(0xFFDCFCE7)
                  : AppColors.containerFillColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(
                isVerified ? const Color(0xFF16A34A) : AppColors.primaryColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.text14Semibold),
                2.verticalSpace,
                Text(
                  subtitle,
                  style: AppTextStyle.text12Regular.copyWith(
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isVerified
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVerified
                      ? Icons.check_circle_rounded
                      : Icons.hourglass_bottom_rounded,
                  size: 12.sp,
                  color: isVerified
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFD97706),
                ),
                4.horizontalSpace,
                Text(
                  isVerified ? 'Approved' : 'In Review',
                  style: AppTextStyle.text10Medium.copyWith(
                    color: isVerified
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFD97706),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
