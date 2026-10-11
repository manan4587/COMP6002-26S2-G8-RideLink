import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class PassengerCommunityDetailsPage
    extends GetView<PassengerDashboardController> {
  const PassengerCommunityDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Obx(() {
          final community = controller.selectedCommunity.value ??
              (controller.communities.isNotEmpty
                  ? controller.communities.first
                  : null);

          if (community == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                  16.verticalSpace,
                  TextButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Get.back();
                      }
                    },
                    child: const Text('Back'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Top Bar with back button and centered Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            Get.back();
                          }
                        },
                        icon: Icon(
                          CupertinoIcons.back,
                          size: 22.sp,
                          color: AppColors.primaryTextColor,
                        ),
                        splashRadius: 22.r,
                      ),
                    ),
                    Text(
                      community.name,
                      style: AppTextStyle.text20Semibold.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Content Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 12.h),

                      // Main Community Hero Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 24.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(14.r),
                              decoration: BoxDecoration(
                                color: community.iconBgColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                community.icon,
                                color: community.iconColor,
                                size: 30.sp,
                              ),
                            ),
                            12.verticalSpace,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    community.name,
                                    style: AppTextStyle.text20Semibold.copyWith(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            8.verticalSpace,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: community.iconBgColor,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                community.categoryLabel,
                                style: AppTextStyle.text11Medium.copyWith(
                                  color: community.iconColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            12.verticalSpace,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.map_pin_ellipse,
                                  size: 15.sp,
                                  color: const Color(0xFF2563EB),
                                ),
                                6.horizontalSpace,
                                Flexible(
                                  child: Text(
                                    community.routeSummary,
                                    style: AppTextStyle.text14Semibold.copyWith(
                                      color: const Color(0xFF2563EB),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            14.verticalSpace,
                            // Dedicated Timing Banner
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.clock,
                                        size: 16.sp,
                                        color: const Color(0xFF2563EB),
                                      ),
                                      8.horizontalSpace,
                                      Flexible(
                                        child: Text(
                                          'Peak Commute: ${community.commonTime}',
                                          style: AppTextStyle.text12Semibold
                                              .copyWith(
                                                color: const Color(0xFF0F172A),
                                                fontWeight: FontWeight.bold,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (community.recurringOption.isNotEmpty) ...[
                                    8.verticalSpace,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.repeat,
                                          size: 14.sp,
                                          color: const Color(0xFF7C3AED),
                                        ),
                                        6.horizontalSpace,
                                        Flexible(
                                          child: Text(
                                            'Cadence: ${community.recurringOption}',
                                            style: AppTextStyle.text11Medium
                                                .copyWith(
                                                  color:
                                                      const Color(0xFF6D28D9),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (community.recurringDays.isNotEmpty) ...[
                                    8.verticalSpace,
                                    Wrap(
                                      spacing: 6.w,
                                      runSpacing: 4.h,
                                      alignment: WrapAlignment.center,
                                      children:
                                          community.recurringDays.map((day) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 2.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEDE9FE),
                                            borderRadius:
                                                BorderRadius.circular(6.r),
                                          ),
                                          child: Text(
                                            day,
                                            style: AppTextStyle.text10Medium
                                                .copyWith(
                                                  color:
                                                      const Color(0xFF5B21B6),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                  if (community.hasFixedTerminal) ...[
                                    10.verticalSpace,
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        border: Border.all(
                                          color: const Color(0xFFFDE68A),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            CupertinoIcons.placemark,
                                            size: 14.sp,
                                            color: const Color(0xFFD97706),
                                          ),
                                          6.horizontalSpace,
                                          Flexible(
                                            child: Text(
                                              'Fixed Terminal: ${community.fixedTerminalLabel}',
                                              style: AppTextStyle.text11Medium
                                                  .copyWith(
                                                    color:
                                                        const Color(0xFF92400E),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (community.description.isNotEmpty) ...[
                              12.verticalSpace,
                              Text(
                                community.description,
                                style: AppTextStyle.text12Regular.copyWith(
                                  color: const Color(0xFF475569),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Stats Row: Passengers & Drivers
                      Row(
                        children: [
                          // Passengers Card
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 16.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.r),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEFF6FF),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          CupertinoIcons.person,
                                          size: 16.sp,
                                          color: const Color(0xFF2563EB),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          'Passengers',
                                          style: AppTextStyle.text12Medium
                                              .copyWith(
                                                color: const Color(0xFF64748B),
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    '${community.passengersCount.value}',
                                    style: AppTextStyle.text20Semibold
                                        .copyWith(
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F172A),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Drivers Card
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 16.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.r),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEFF6FF),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          CupertinoIcons.person_badge_plus,
                                          size: 16.sp,
                                          color: const Color(0xFF2563EB),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          'Drivers',
                                          style: AppTextStyle.text12Medium
                                              .copyWith(
                                                color: const Color(0xFF64748B),
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    '${community.driversCount.value}',
                                    style: AppTextStyle.text20Semibold
                                        .copyWith(
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F172A),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Next Available Ride Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(18.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEFF6FF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.clock,
                                color: const Color(0xFF2563EB),
                                size: 22.sp,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Next Available Ride',
                                    style: AppTextStyle.text14Semibold.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '${community.nextRideTime} • ${community.nextRideSeatsOpen} seats open',
                                    style: AppTextStyle.text12Regular.copyWith(
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 28.h),

                      // Community membership status & dynamic action buttons
                      if (community.isJoined.value) ...[
                        // Status Banner: Member of this community
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.checkmark_seal_fill,
                                color: Color(0xFF10B981),
                                size: 20,
                              ),
                              8.horizontalSpace,
                              Text(
                                'You are a member of this community',
                                style: AppTextStyle.text14Medium.copyWith(
                                  color: const Color(0xFF047857),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        14.verticalSpace,

                        // Member Action: Join Next Ride
                        Container(
                          width: double.infinity,
                          height: 52.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20.r),
                              onTap: () {
                                final currentUid =
                                    AuthService.instance.currentUser?.uid ?? '';
                                final otherRides = controller.availableRides
                                    .where((r) => r.driverId != currentUid)
                                    .toList();

                                if (otherRides.isNotEmpty) {
                                  controller.selectRideForDetails(otherRides.first);
                                } else if (controller.availableRides.isNotEmpty) {
                                  // The only upcoming ride is the user's own published trip
                                  final matchRide = controller.availableRides.first;
                                  controller.selectRideForDetails(matchRide);
                                } else {
                                  Get.back();
                                  controller.switchTab(1); // Jump to Search
                                  AppSnackBar.info(
                                    message:
                                        'Looking for upcoming rides in ${community.name}...',
                                  );
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.checkmark_alt,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Join Next Ride',
                                    style: AppTextStyle.buttonText.copyWith(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        14.verticalSpace,

                        // Leave Community Button (Requires Confirmation Dialog)
                        OutlinedButton.icon(
                          onPressed: () =>
                              controller.confirmLeaveCommunity(context, community),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFECACA)),
                            minimumSize: Size(double.infinity, 48.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            backgroundColor: const Color(0xFFFEF2F2),
                          ),
                          icon: const Icon(
                            Icons.exit_to_app_rounded,
                            size: 18,
                            color: Color(0xFFDC2626),
                          ),
                          label: Text(
                            'Leave Community',
                            style: AppTextStyle.text14Semibold.copyWith(
                              color: const Color(0xFFDC2626),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ] else ...[
                        // Non-Member Primary Action: Join Community Button
                        Container(
                          width: double.infinity,
                          height: 52.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20.r),
                              onTap: () => controller.joinCommunity(community),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.person_badge_plus,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Join Community',
                                    style: AppTextStyle.buttonText.copyWith(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
