import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_profile_controller.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_trips_controller.dart';
import 'package:ridelink/widgets/app_button.dart';
import 'package:ridelink/widgets/google_places_search_field.dart';

class CreateRidePage extends GetView<DriverTripsController> {
  const CreateRidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDriver = Preferences.userRole == 'driver';
    final DriverProfileController profileController =
        Get.isRegistered<DriverProfileController>()
        ? Get.find<DriverProfileController>()
        : Get.put<DriverProfileController>(DriverProfileController());

    return Scaffold(
      backgroundColor: AppColors.secondaryBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (Get.key.currentState?.canPop() == true) ...[
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(CupertinoIcons.back),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    10.horizontalSpace,
                  ],
                  Text('Publish a Ride', style: AppTextStyle.text20Semibold),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                'Share your commute, reduce traffic, and cover petrol costs.',
                style: AppTextStyle.text14Regular.copyWith(
                  color: AppColors.secondaryTextColor,
                ),
              ),

              // Role & Verification Warning Banners
              if (!isDriver) ...[
                Container(
                  margin: EdgeInsets.only(top: 14.h),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.block_rounded,
                        color: Color(0xFFDC2626),
                        size: 22,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Driver Account Required',
                              style: AppTextStyle.text14Semibold.copyWith(
                                color: const Color(0xFFB91C1C),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "You are currently logged in as a passenger. Only registered and approved drivers are allowed to publish rides.",
                              style: AppTextStyle.text12Regular.copyWith(
                                color: const Color(0xFF7F1D1D),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Obx(() {
                  if (profileController.isVerifiedByAdmin.value) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    margin: EdgeInsets.only(top: 14.h),
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFDC2626),
                          size: 22,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verification Required',
                                style: AppTextStyle.text14Semibold.copyWith(
                                  color: const Color(0xFFB91C1C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "You cannot publish new rides until your documents are verified by admin. Please complete your verification profile.",
                                style: AppTextStyle.text12Regular.copyWith(
                                  color: const Color(0xFF7F1D1D),
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
              ],

              // Trip Audience & Community Selector
              Container(
                margin: EdgeInsets.only(top: 14.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.borderColor),
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
                            CupertinoIcons.person_2_square_stack,
                            size: 16.sp,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Trip Audience & Community',
                                style: AppTextStyle.text14Semibold.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Publish a standard public trip or target a community group.',
                                style: AppTextStyle.text10Medium.copyWith(
                                  color: AppColors.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Mode Toggle: No Community vs With Community
                    Obx(() {
                      final hasCommunity = controller
                          .selectedCommunityForPublish
                          .value
                          .isNotEmpty;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Option 1: No Community (Normal / Public Trip)
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    controller.clearCommunityForPublish();
                                  },
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.h,
                                      horizontal: 8.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !hasCommunity
                                          ? const Color(0xFFEFF6FF)
                                          : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: !hasCommunity
                                            ? AppColors.primaryColor
                                            : const Color(0xFFE2E8F0),
                                        width: !hasCommunity ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          CupertinoIcons.globe,
                                          size: 18.sp,
                                          color: !hasCommunity
                                              ? AppColors.primaryColor
                                              : const Color(0xFF64748B),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'No Community',
                                          style: AppTextStyle.text12Semibold
                                              .copyWith(
                                                color: !hasCommunity
                                                    ? AppColors.primaryColor
                                                    : AppColors
                                                          .primaryTextColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          'Normal Public Trip',
                                          style: AppTextStyle.text10Medium
                                              .copyWith(
                                                color: !hasCommunity
                                                    ? const Color(0xFF1D4ED8)
                                                    : AppColors
                                                          .secondaryTextColor,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              // Option 2: With Community
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    if (!hasCommunity) {
                                      if (controller
                                          .availableCommunitiesForDriver
                                          .isNotEmpty) {
                                        controller.selectCommunityForPublish(
                                          controller
                                              .availableCommunitiesForDriver
                                              .first,
                                        );
                                      }
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.h,
                                      horizontal: 8.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: hasCommunity
                                          ? const Color(0xFFEFF6FF)
                                          : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: hasCommunity
                                            ? AppColors.primaryColor
                                            : const Color(0xFFE2E8F0),
                                        width: hasCommunity ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          CupertinoIcons.person_2_fill,
                                          size: 18.sp,
                                          color: hasCommunity
                                              ? AppColors.primaryColor
                                              : const Color(0xFF64748B),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'With Community',
                                          style: AppTextStyle.text12Semibold
                                              .copyWith(
                                                color: hasCommunity
                                                    ? AppColors.primaryColor
                                                    : AppColors
                                                          .primaryTextColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          'Verified Corridor',
                                          style: AppTextStyle.text10Medium
                                              .copyWith(
                                                color: hasCommunity
                                                    ? const Color(0xFF1D4ED8)
                                                    : AppColors
                                                          .secondaryTextColor,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12.h),

                          if (!hasCommunity) ...[
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.info_circle_fill,
                                    size: 15,
                                    color: Color(0xFF64748B),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'Open to all commuters across RideLink without community restrictions.',
                                      style: AppTextStyle.text12Regular
                                          .copyWith(
                                            color: const Color(0xFF475569),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Choose Community Corridor:',
                                  style: AppTextStyle.text12Semibold.copyWith(
                                    color: const Color(0xFF334155),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      controller.clearCommunityForPublish(),
                                  child: Text(
                                    'Clear (No Community)',
                                    style: AppTextStyle.text12Regular.copyWith(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: controller.availableCommunitiesForDriver
                                  .map((comm) {
                                    final isSelected =
                                        controller
                                            .selectedCommunityForPublish
                                            .value ==
                                        comm;
                                    return ChoiceChip(
                                      label: Text(comm),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        if (selected) {
                                          controller.selectCommunityForPublish(
                                            comm,
                                          );
                                        } else {
                                          controller.clearCommunityForPublish();
                                        }
                                      },
                                      selectedColor: AppColors.primaryColor,
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      labelStyle: AppTextStyle.text12Medium
                                          .copyWith(
                                            color: isSelected
                                                ? Colors.white
                                                : AppColors.primaryTextColor,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                        side: BorderSide(
                                          color: isSelected
                                              ? AppColors.primaryColor
                                              : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                            ),
                          ],
                        ],
                      );
                    }),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Enhanced Route Input Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Swap Route button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                CupertinoIcons.map_pin_ellipse,
                                size: 16.sp,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            8.horizontalSpace,
                            Text(
                              'Trip Route',
                              style: AppTextStyle.text14Semibold.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: controller.swapPickupAndDrop,
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.arrow_up_arrow_down,
                                  size: 13.sp,
                                  color: AppColors.primaryColor,
                                ),
                                5.horizontalSpace,
                                Text(
                                  'Swap Points',
                                  style: AppTextStyle.text10Medium.copyWith(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    14.verticalSpace,

                    // Pickup & Drop Fields with Visual Route Line Connector
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Route Indicator Visual (Origin circle -> Vertical line -> Pin)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 22.w,
                                height: 22.h,
                                margin: EdgeInsets.only(top: 14.h),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFDCFCE7),
                                  border: Border.all(
                                    color: const Color(0xFF16A34A),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 8.w,
                                    height: 8.h,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: 2.w,
                                  margin: EdgeInsets.symmetric(vertical: 4.h),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFF16A34A),
                                        AppColors.primaryColor,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                              ),
                              Container(
                                width: 22.w,
                                height: 22.h,
                                margin: EdgeInsets.only(bottom: 14.h),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFEFF6FF),
                                  border: Border.all(
                                    color: AppColors.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.location_on,
                                    size: 13.sp,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          12.horizontalSpace,

                          // Right Form Inputs Column
                          Expanded(
                            child: Column(
                              children: [
                                // Pickup Location Google Places Input Box
                                GooglePlacesSearchField(
                                  controller: controller.publishFromController,
                                  label: 'PICKUP LOCATION',
                                  labelColor: const Color(0xFF16A34A),
                                  hintText:
                                      'Search pickup suburb, street or station',
                                  trailing: Obx(
                                    () => GestureDetector(
                                      onTap: controller.isFetchingCurrentLocation.value
                                          ? null
                                          : () => controller.useCurrentLocationAsPickup(
                                                context: context,
                                              ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.my_location_rounded,
                                              size: 11.sp,
                                              color: const Color(0xFF16A34A),
                                            ),
                                            4.horizontalSpace,
                                            Text(
                                              controller.isFetchingCurrentLocation.value
                                                  ? 'Locating...'
                                                  : 'Current GPS',
                                              style: AppTextStyle.text10Medium.copyWith(
                                                color: const Color(0xFF15803D),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  onPlaceSelected: (details) {
                                    controller.publishFromLat.value =
                                        details.latitude;
                                    controller.publishFromLng.value =
                                        details.longitude;
                                  },
                                ),

                                10.verticalSpace,

                                // Drop-off Destination Google Places Input Box
                                GooglePlacesSearchField(
                                  controller: controller.publishToController,
                                  label: 'DROP-OFF DESTINATION',
                                  labelColor: AppColors.primaryColor,
                                  hintText:
                                      'Search drop-off destination or campus',
                                  onPlaceSelected: (details) {
                                    controller.publishToLat.value =
                                        details.latitude;
                                    controller.publishToLng.value =
                                        details.longitude;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    14.verticalSpace,

                    // Quick Location Suggestions
                    Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 14.sp,
                          color: const Color(0xFFF59E0B),
                        ),
                        4.horizontalSpace,
                        Text(
                          'Quick Suggestions:',
                          style: AppTextStyle.text10Medium.copyWith(
                            color: AppColors.secondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    6.verticalSpace,
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _QuickLocationChip(
                            label: 'Flinders St',
                            onTap: () {
                              if (controller
                                  .publishFromController
                                  .text
                                  .isEmpty) {
                                controller.publishFromController.text =
                                    'Flinders St Station';
                              } else {
                                controller.publishToController.text =
                                    'Flinders St Station';
                              }
                            },
                          ),
                          8.horizontalSpace,
                          _QuickLocationChip(
                            label: 'Curtin Uni',
                            onTap: () {
                              controller.publishToController.text =
                                  'Curtin University';
                            },
                          ),
                          8.horizontalSpace,
                          _QuickLocationChip(
                            label: 'Clayton Campus',
                            onTap: () {
                              controller.publishToController.text =
                                  'Monash University Clayton';
                            },
                          ),
                          8.horizontalSpace,
                          _QuickLocationChip(
                            label: 'Melbourne CBD',
                            onTap: () {
                              if (controller
                                  .publishFromController
                                  .text
                                  .isEmpty) {
                                controller.publishFromController.text =
                                    'Melbourne CBD';
                              } else {
                                controller.publishToController.text =
                                    'Melbourne CBD';
                              }
                            },
                          ),
                          8.horizontalSpace,
                          _QuickLocationChip(
                            label: 'Landsdale',
                            onTap: () {
                              controller.publishFromController.text =
                                  'Landsdale';
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Ride Schedule Type & Pickers (Single Date vs Recurring Day-wise)
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ride Schedule',
                          style: AppTextStyle.text14Semibold,
                        ),
                        Obx(
                          () => Text(
                            controller.isRecurringRide.value
                                ? 'Repeats weekly'
                                : 'One-time trip',
                            style: AppTextStyle.text12Medium.copyWith(
                              color: controller.isRecurringRide.value
                                  ? const Color(0xFF4F46E5)
                                  : AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // Schedule Mode Selector Segment (Single Ride vs Recurring)
                    Obx(
                      () => Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            // Single Ride Tab
                            Expanded(
                              child: InkWell(
                                onTap: () =>
                                    controller.isRecurringRide.value = false,
                                borderRadius: BorderRadius.circular(10.r),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: !controller.isRecurringRide.value
                                        ? AppColors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10.r),
                                    boxShadow: !controller.isRecurringRide.value
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.06,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.calendar,
                                        size: 15.sp,
                                        color: !controller.isRecurringRide.value
                                            ? AppColors.primaryColor
                                            : AppColors.secondaryTextColor,
                                      ),
                                      6.horizontalSpace,
                                      Text(
                                        'Single Ride',
                                        style: AppTextStyle.text12Medium
                                            .copyWith(
                                              fontWeight:
                                                  !controller
                                                      .isRecurringRide
                                                      .value
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color:
                                                  !controller
                                                      .isRecurringRide
                                                      .value
                                                  ? AppColors.primaryTextColor
                                                  : AppColors
                                                        .secondaryTextColor,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Recurring Ride Tab
                            Expanded(
                              child: InkWell(
                                onTap: () =>
                                    controller.isRecurringRide.value = true,
                                borderRadius: BorderRadius.circular(10.r),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: controller.isRecurringRide.value
                                        ? AppColors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10.r),
                                    boxShadow: controller.isRecurringRide.value
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.06,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.arrow_2_circlepath,
                                        size: 15.sp,
                                        color: controller.isRecurringRide.value
                                            ? const Color(0xFF4F46E5)
                                            : AppColors.secondaryTextColor,
                                      ),
                                      6.horizontalSpace,
                                      Text(
                                        'Recurring Commute',
                                        style: AppTextStyle.text12Medium
                                            .copyWith(
                                              fontWeight:
                                                  controller
                                                      .isRecurringRide
                                                      .value
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color:
                                                  controller
                                                      .isRecurringRide
                                                      .value
                                                  ? const Color(0xFF4F46E5)
                                                  : AppColors
                                                        .secondaryTextColor,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Content depends on selected mode
                    Obx(() {
                      if (!controller.isRecurringRide.value) {
                        // SINGLE RIDE MODE: Date Picker + Time Picker
                        return Row(
                          children: [
                            // Date Picker Card
                            Expanded(
                              child: InkWell(
                                onTap: () => controller.pickRideDate(context),
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                        child: Icon(
                                          CupertinoIcons.calendar,
                                          color: AppColors.primaryColor,
                                          size: 18.sp,
                                        ),
                                      ),
                                      10.horizontalSpace,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'RIDE DATE',
                                              style: AppTextStyle.text10Medium
                                                  .copyWith(
                                                    color: AppColors
                                                        .secondaryTextColor,
                                                    letterSpacing: 0.5,
                                                  ),
                                            ),
                                            2.verticalSpace,
                                            Text(
                                              controller.formattedRideDate,
                                              style:
                                                  AppTextStyle.text13Semibold,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            // Time Picker Card
                            Expanded(
                              child: InkWell(
                                onTap: () => controller.pickRideTime(context),
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                        child: Icon(
                                          CupertinoIcons.time,
                                          color: AppColors.primaryColor,
                                          size: 18.sp,
                                        ),
                                      ),
                                      10.horizontalSpace,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'START TIME',
                                              style: AppTextStyle.text10Medium
                                                  .copyWith(
                                                    color: AppColors
                                                        .secondaryTextColor,
                                                    letterSpacing: 0.5,
                                                  ),
                                            ),
                                            2.verticalSpace,
                                            Text(
                                              controller.formattedRideTime,
                                              style:
                                                  AppTextStyle.text13Semibold,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        // RECURRING COMMUTE MODE: Time Picker + Day-wise Selector
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time Picker Card (Full Width)
                            InkWell(
                              onTap: () => controller.pickRideTime(context),
                              borderRadius: BorderRadius.circular(12.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF4F46E5,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Icon(
                                        CupertinoIcons.time,
                                        color: const Color(0xFF4F46E5),
                                        size: 20.sp,
                                      ),
                                    ),
                                    12.horizontalSpace,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'START TIME (EVERY SCHEDULED DAY)',
                                            style: AppTextStyle.text10Medium
                                                .copyWith(
                                                  color: AppColors
                                                      .secondaryTextColor,
                                                  letterSpacing: 0.5,
                                                ),
                                          ),
                                          2.verticalSpace,
                                          Text(
                                            controller.formattedRideTime,
                                            style: AppTextStyle.text14Semibold
                                                .copyWith(
                                                  color: const Color(
                                                    0xFF1E293B,
                                                  ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                      ),
                                      child: Text(
                                        'Change',
                                        style: AppTextStyle.text10Medium
                                            .copyWith(
                                              color: const Color(0xFF4F46E5),
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 14.h),

                            // Day Selector Header with quick presets
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Select Repeat Days',
                                  style: AppTextStyle.text12Medium.copyWith(
                                    color: AppColors.secondaryTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => controller
                                          .selectRecurringPreset('weekdays'),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 3.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                        ),
                                        child: Text(
                                          'Weekdays',
                                          style: AppTextStyle.text10Medium
                                              .copyWith(
                                                color: AppColors.primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                    6.horizontalSpace,
                                    GestureDetector(
                                      onTap: () => controller
                                          .selectRecurringPreset('all'),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 3.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                        ),
                                        child: Text(
                                          'All Days',
                                          style: AppTextStyle.text10Medium
                                              .copyWith(
                                                color: AppColors.primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: 10.h),

                            // 7 Day Chips Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: DriverTripsController.availableWeekDays
                                  .map((day) {
                                    final isSelected = controller.recurringDays
                                        .contains(day);
                                    return GestureDetector(
                                      onTap: () =>
                                          controller.toggleRecurringDay(day),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        width: 40.w,
                                        height: 40.w,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF4F46E5)
                                              : const Color(0xFFF8FAFC),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF4F46E5)
                                                : const Color(0xFFCBD5E1),
                                            width: isSelected ? 1.5 : 1,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFF4F46E5,
                                                    ).withValues(alpha: 0.25),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          day,
                                          style: AppTextStyle.text11Medium
                                              .copyWith(
                                                color: isSelected
                                                    ? Colors.white
                                                    : AppColors
                                                          .secondaryTextColor,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                            ),

                            SizedBox(height: 10.h),

                            // Summary of recurring schedule
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: const Color(0xFFC7D2FE),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.info_circle_fill,
                                    size: 13.sp,
                                    color: const Color(0xFF4F46E5),
                                  ),
                                  6.horizontalSpace,
                                  Expanded(
                                    child: Text(
                                      controller.formattedScheduleSummary,
                                      style: AppTextStyle.text11Medium.copyWith(
                                        color: const Color(0xFF3730A3),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    }),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Seats & Price Row
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  children: [
                    // Available seats counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available Passenger Seats',
                          style: AppTextStyle.text14Semibold,
                        ),
                        Obx(
                          () => Row(
                            children: [
                              IconButton(
                                onPressed: controller.publishSeats.value > 1
                                    ? () => controller.publishSeats.value--
                                    : null,
                                icon: const Icon(CupertinoIcons.minus_circle),
                                color: AppColors.primaryColor,
                              ),
                              Text(
                                '${controller.publishSeats.value}',
                                style: AppTextStyle.text16Semibold,
                              ),
                              IconButton(
                                onPressed: controller.publishSeats.value < 6
                                    ? () => controller.publishSeats.value++
                                    : null,
                                icon: const Icon(CupertinoIcons.plus_circle),
                                color: AppColors.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(color: AppColors.borderColor, height: 1),
                    SizedBox(height: 10.h),

                    // Price per seat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price Per Seat',
                              style: AppTextStyle.text14Semibold,
                            ),
                            2.verticalSpace,
                            Text(
                              'Driver fare per booked seat',
                              style: AppTextStyle.text11Medium.copyWith(
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        // Editable price display
                        Obx(
                          () => GestureDetector(
                            onTap: () =>
                                _showPriceInputSheet(context, controller),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: const Color(0xFFBFDBFE),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '\$${controller.publishPrice.value % 1 == 0 ? controller.publishPrice.value.toInt() : controller.publishPrice.value.toStringAsFixed(2)}',
                                    style: AppTextStyle.text15Semibold
                                        .copyWith(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  6.horizontalSpace,
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 14.sp,
                                    color: AppColors.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    // Quick price presets row
                    Obx(
                      () => Row(
                        children: [
                          Text(
                            'Quick presets:',
                            style: AppTextStyle.text11Medium.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                          6.horizontalSpace,
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [5.0, 7.50, 10.0, 12.0, 15.0, 20.0].map((
                                  preset,
                                ) {
                                  final isSelected =
                                      (controller.publishPrice.value - preset)
                                          .abs() <
                                      0.01;
                                  return Padding(
                                    padding: EdgeInsets.only(right: 6.w),
                                    child: GestureDetector(
                                      onTap: () => controller.setPrice(preset),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 9.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primaryColor
                                              : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primaryColor
                                                : const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        child: Text(
                                          '\$${preset % 1 == 0 ? preset.toInt() : preset.toStringAsFixed(2)}',
                                          style: AppTextStyle.text11Medium
                                              .copyWith(
                                                color: isSelected
                                                    ? Colors.white
                                                    : AppColors
                                                          .primaryTextColor,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Trip Preferences Toggles
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  children: [
                    Obx(
                      () => SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Luggage Space Available',
                          style: AppTextStyle.text14Semibold,
                        ),
                        subtitle: Text(
                          'Passengers can bring small baggage/backpacks',
                          style: AppTextStyle.text12Regular.copyWith(
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                        value: controller.allowLuggage.value,
                        activeThumbColor: AppColors.primaryColor,
                        onChanged: (v) => controller.allowLuggage.value = v,
                      ),
                    ),
                    const Divider(color: AppColors.borderColor, height: 1),
                    Obx(
                      () => SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Pets Allowed',
                          style: AppTextStyle.text14Semibold,
                        ),
                        subtitle: Text(
                          'Allow small caged pets inside vehicle',
                          style: AppTextStyle.text12Regular.copyWith(
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                        value: controller.allowPets.value,
                        activeThumbColor: AppColors.primaryColor,
                        onChanged: (v) => controller.allowPets.value = v,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Publish CTA
              Obx(() {
                final canPublish =
                    isDriver && profileController.isVerifiedByAdmin.value;
                return AppButton(
                  onPressed: canPublish
                      ? controller.publishNewTrip
                      : () {
                          if (!isDriver) {
                            AppSnackBar.error(
                              message:
                                  'Only registered drivers can publish rides.',
                            );
                          } else {
                            AppSnackBar.warning(
                              message:
                                  'Your driver documents are pending verification by admin.',
                            );
                          }
                        },
                  label: !isDriver
                      ? 'Driver Account Required (Cannot Publish)'
                      : profileController.isVerifiedByAdmin.value
                      ? 'Publish Ride Now'
                      : 'Verification Pending (Cannot Publish)',
                  backgroundColor: canPublish
                      ? AppColors.primaryColor
                      : const Color(0xFF9CA3AF),
                );
              }),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showPriceInputSheet(
    BuildContext context,
    DriverTripsController controller,
  ) {
    final textCtrl = TextEditingController(
      text: controller.publishPrice.value % 1 == 0
          ? controller.publishPrice.value.toInt().toString()
          : controller.publishPrice.value.toStringAsFixed(2),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            top: 12.h,
            left: 20.w,
            right: 20.w,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              18.verticalSpace,
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.payments_outlined,
                      color: AppColors.primaryColor,
                      size: 22.sp,
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set Price Per Seat',
                          style: AppTextStyle.text18Semibold.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        2.verticalSpace,
                        Text(
                          'Driver fare per booked passenger seat',
                          style: AppTextStyle.text12Medium.copyWith(
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              16.verticalSpace,
              Text('Enter Amount (\$)', style: AppTextStyle.text13Semibold),
              6.verticalSpace,
              TextField(
                controller: textCtrl,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: AppTextStyle.text16Semibold.copyWith(
                    color: AppColors.primaryColor,
                  ),
                  hintText: 'e.g. 8.50',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              14.verticalSpace,
              Text(
                'Quick presets:',
                style: AppTextStyle.text12Medium.copyWith(
                  color: AppColors.secondaryTextColor,
                ),
              ),
              8.verticalSpace,
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [5.0, 7.50, 10.0, 12.0, 15.0, 20.0].map((preset) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: GestureDetector(
                        onTap: () {
                          textCtrl.text = preset % 1 == 0
                              ? preset.toInt().toString()
                              : preset.toStringAsFixed(2);
                          setSheetState(() {});
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            '\$${preset % 1 == 0 ? preset.toInt() : preset.toStringAsFixed(2)}',
                            style: AppTextStyle.text12Medium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              22.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: const BorderSide(color: AppColors.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final val = double.tryParse(textCtrl.text.trim());
                        if (val != null && val >= 1.0 && val <= 500.0) {
                          controller.setPrice(val);
                          Get.back();
                        } else {
                          AppSnackBar.warning(
                            message:
                                'Please enter a valid price between \$1 and \$500.',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Save Price',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickLocationChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickLocationChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.place_outlined,
              size: 12.sp,
              color: AppColors.primaryColor,
            ),
            4.horizontalSpace,
            Text(
              label,
              style: AppTextStyle.text12Medium.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
