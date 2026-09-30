import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_profile_controller.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_trips_controller.dart';
import 'package:ridelink/widgets/app_button.dart';
import 'package:ridelink/widgets/google_places_search_field.dart';

class CreateRidePage extends GetView<DriverTripsController> {
  const CreateRidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final DriverProfileController profileController =
        Get.find<DriverProfileController>();
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
                  if (Navigator.of(context).canPop()) ...[
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

              // Admin Verification Warning Banner
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

              // Target Community Selector
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
                            CupertinoIcons.person_2_fill,
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
                                'Post ride into Community',
                                style: AppTextStyle.text14Semibold.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Matched verified community members get priority.',
                                style: AppTextStyle.text10Medium.copyWith(
                                  color: AppColors.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Obx(
                      () => Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: controller.availableCommunitiesForDriver.map((comm) {
                          final isSelected =
                              controller.selectedCommunityForPublish.value == comm;
                          return ChoiceChip(
                            label: Text(comm),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                controller.selectCommunityForPublish(comm);
                              }
                            },
                            selectedColor: AppColors.primaryColor,
                            backgroundColor: const Color(0xFFF1F5F9),
                            labelStyle: AppTextStyle.text12Medium.copyWith(
                              color: isSelected ? Colors.white : AppColors.primaryTextColor,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
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
                                  hintText: 'Search pickup suburb, street or station',
                                  onPlaceSelected: (details) {
                                    controller.publishFromLat.value = details.latitude;
                                    controller.publishFromLng.value = details.longitude;
                                  },
                                ),

                                10.verticalSpace,

                                // Drop-off Destination Google Places Input Box
                                GooglePlacesSearchField(
                                  controller: controller.publishToController,
                                  label: 'DROP-OFF DESTINATION',
                                  labelColor: AppColors.primaryColor,
                                  hintText: 'Search drop-off destination or campus',
                                  onPlaceSelected: (details) {
                                    controller.publishToLat.value = details.latitude;
                                    controller.publishToLng.value = details.longitude;
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
                                  .publishFromController.text.isEmpty) {
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
                                  .publishFromController.text.isEmpty) {
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

              // Date & Time Selectors
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date', style: AppTextStyle.text10Medium.copyWith(color: AppColors.secondaryTextColor)),
                          SizedBox(height: 4.h),
                          Obx(
                            () => Text(
                              controller.departureDate.value,
                              style: AppTextStyle.text14Semibold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Departure Time', style: AppTextStyle.text10Medium.copyWith(color: AppColors.secondaryTextColor)),
                          SizedBox(height: 4.h),
                          TextField(
                            controller: controller.departureTimeController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: AppTextStyle.text14Semibold,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                        Text('Available Passenger Seats', style: AppTextStyle.text14Semibold),
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
                      children: [
                        Text('Price Per Seat', style: AppTextStyle.text14Semibold),
                        Obx(
                          () => Text(
                            '\$${controller.publishPrice.value.toStringAsFixed(0)}',
                            style: AppTextStyle.text18Semibold.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
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
                        title: Text('Luggage Space Available', style: AppTextStyle.text14Semibold),
                        subtitle: Text('Passengers can bring small baggage/backpacks', style: AppTextStyle.text12Regular.copyWith(color: AppColors.secondaryTextColor)),
                        value: controller.allowLuggage.value,
                        activeThumbColor: AppColors.primaryColor,
                        onChanged: (v) => controller.allowLuggage.value = v,
                      ),
                    ),
                    const Divider(color: AppColors.borderColor, height: 1),
                    Obx(
                      () => SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Pets Allowed', style: AppTextStyle.text14Semibold),
                        subtitle: Text('Allow small caged pets inside vehicle', style: AppTextStyle.text12Regular.copyWith(color: AppColors.secondaryTextColor)),
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
              Obx(
                () => AppButton(
                  onPressed: controller.publishNewTrip,
                  label: profileController.isVerifiedByAdmin.value
                      ? 'Publish Ride Now'
                      : 'Verification Pending (Cannot Publish)',
                  backgroundColor: profileController.isVerifiedByAdmin.value
                      ? AppColors.primaryColor
                      : const Color(0xFF9CA3AF),
                ),
              ),

              SizedBox(height: 20.h),
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

  const _QuickLocationChip({
    required this.label,
    required this.onTap,
  });

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
