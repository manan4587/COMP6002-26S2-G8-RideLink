import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/simmer_utils.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';
import 'package:ridelink/views/passenger_dashboard/widgets/ride_details_sheet.dart';
import 'package:ridelink/widgets/google_places_search_field.dart';

class SearchPage extends GetView<PassengerDashboardController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBgColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () async {
            await controller.tripsController.reloadTrips();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title Centered (Matching Design Reference)
              Center(
                child: Text(
                  'Search Ride',
                  style: AppTextStyle.text24Semibold.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryTextColor,
                  ),
                ),
              ),

              18.verticalSpace,

              // Main Search Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(26.r),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.025),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pickup Location with Google Places Autocomplete
                    GooglePlacesSearchField(
                      controller: controller.fromLocationController,
                      label: 'PICKUP LOCATION',
                      labelColor: const Color(0xFF16A34A),
                      hintText: 'Search pickup suburb, street or station',
                      onPlaceSelected: (details) {
                        controller.fromLat.value = details.latitude;
                        controller.fromLng.value = details.longitude;
                      },
                    ),

                    12.verticalSpace,

                    // Destination with Google Places Autocomplete
                    GooglePlacesSearchField(
                      controller: controller.toLocationController,
                      label: 'DESTINATION',
                      labelColor: AppColors.primaryColor,
                      hintText: 'Search drop-off destination or university',
                      onPlaceSelected: (details) {
                        controller.toLat.value = details.latitude;
                        controller.toLng.value = details.longitude;
                      },
                    ),

                    14.verticalSpace,

                    // Ride Schedule & Preferred Timing Section
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.calendar_badge_plus,
                                size: 16.sp,
                                color: AppColors.primaryColor,
                              ),
                              8.horizontalSpace,
                              Text(
                                'DATE & PREFERRED TIME',
                                style: AppTextStyle.text11Medium.copyWith(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                          12.verticalSpace,

                          // Date Option Quick Chips
                          Text(
                            'Date Options',
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: AppColors.primaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          6.verticalSpace,
                          Obx(() {
                            final activePreset = controller.activeDatePreset.value;
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  _DateFilterChip(
                                    label: 'Today',
                                    isSelected: activePreset == 'Today',
                                    onTap: () => controller.selectToday(),
                                  ),
                                  8.horizontalSpace,
                                  _DateFilterChip(
                                    label: 'Tomorrow',
                                    isSelected: activePreset == 'Tomorrow',
                                    onTap: () => controller.selectTomorrow(),
                                  ),
                                  8.horizontalSpace,
                                  _DateFilterChip(
                                    label: 'This Weekend',
                                    isSelected: activePreset == 'Weekend',
                                    onTap: () => controller.selectWeekend(),
                                  ),
                                  8.horizontalSpace,
                                  _DateFilterChip(
                                    label: activePreset == 'Custom'
                                        ? controller.formattedSearchDate
                                        : 'Pick Date 📅',
                                    isSelected: activePreset == 'Custom',
                                    onTap: () => controller.pickSearchDate(context),
                                  ),
                                ],
                              ),
                            );
                          }),

                          12.verticalSpace,

                          // Time Option Quick Chips
                          Text(
                            'Time Options',
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: AppColors.primaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          6.verticalSpace,
                          Obx(() {
                            final activePreset = controller.activeTimePreset.value;
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  _DateFilterChip(
                                    label: 'Morning (8:00 AM)',
                                    isSelected: activePreset == 'Morning',
                                    onTap: () => controller.selectMorning(),
                                  ),
                                  8.horizontalSpace,
                                  _DateFilterChip(
                                    label: 'Noon (12:30 PM)',
                                    isSelected: activePreset == 'Noon',
                                    onTap: () => controller.selectNoon(),
                                  ),
                                  8.horizontalSpace,
                                  _DateFilterChip(
                                    label: 'Evening (5:30 PM)',
                                    isSelected: activePreset == 'Evening',
                                    onTap: () => controller.selectEvening(),
                                  ),
                                  8.horizontalSpace,
                                  _DateFilterChip(
                                    label: activePreset == 'Custom'
                                        ? controller.formattedSearchTime
                                        : 'Exact Clock ⏰',
                                    isSelected: activePreset == 'Custom',
                                    onTap: () => controller.pickSearchTime(context),
                                  ),
                                ],
                              ),
                            );
                          }),

                          14.verticalSpace,

                          // Active Selected Date & Time Cards
                          Row(
                            children: [
                              // Ride Date Card
                              Expanded(
                                child: InkWell(
                                  onTap: () => controller.pickSearchDate(context),
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 10.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(7.w),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryColor
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Icon(
                                            CupertinoIcons.calendar,
                                            color: AppColors.primaryColor,
                                            size: 16.sp,
                                          ),
                                        ),
                                        8.horizontalSpace,
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'SELECTED DATE',
                                                style: AppTextStyle.text10Medium
                                                    .copyWith(
                                                  color:
                                                      AppColors.secondaryTextColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              2.verticalSpace,
                                              Obx(
                                                () => Text(
                                                  controller.formattedSearchDate,
                                                  style: AppTextStyle.text12Semibold,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              8.horizontalSpace,
                              // Preferred Time Card
                              Expanded(
                                child: InkWell(
                                  onTap: () => _showTimePicker(context),
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 10.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(7.w),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryColor
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Icon(
                                            CupertinoIcons.clock,
                                            color: AppColors.primaryColor,
                                            size: 16.sp,
                                          ),
                                        ),
                                        8.horizontalSpace,
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'PREFERRED TIME',
                                                style: AppTextStyle.text10Medium
                                                    .copyWith(
                                                  color:
                                                      AppColors.secondaryTextColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              2.verticalSpace,
                                              Obx(
                                                () => Text(
                                                  controller.formattedSearchTime,
                                                  style: AppTextStyle.text12Semibold,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
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
                          ),
                        ],
                      ),
                    ),

                    14.verticalSpace,

                    // Time Flexibility & Seats Needed Row
                    Row(
                      children: [
                        // Time Flexibility
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FormFieldLabel(label: 'Time Flexibility'),
                              6.verticalSpace,
                              GestureDetector(
                                onTap: () => _showFlexibilityPicker(context),
                                child: _InputFieldContainer(
                                  icon: CupertinoIcons.slider_horizontal_3,
                                  child: Obx(
                                    () => Text(
                                      controller.timeFlexibility.value,
                                      style: AppTextStyle.text14Medium
                                          .copyWith(
                                        color: AppColors.primaryTextColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        10.horizontalSpace,
                        // Seats Needed
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FormFieldLabel(label: 'Seats Needed'),
                              6.verticalSpace,
                              GestureDetector(
                                onTap: () => _showSeatsPicker(context),
                                child: _InputFieldContainer(
                                  icon: CupertinoIcons.car_detailed,
                                  child: Obx(
                                    () => Text(
                                      controller.seatsNote.value.isNotEmpty
                                          ? controller.seatsNote.value
                                          : '${controller.requestedSeats.value} Seat${controller.requestedSeats.value > 1 ? 's' : ''}',
                                      style: AppTextStyle.text14Medium
                                          .copyWith(
                                        color: AppColors.primaryTextColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    20.verticalSpace,

                    // Find Rides Gradient Button
                    GestureDetector(
                      onTap: () {
                        controller.performSearch();
                        Get.toNamed(AppRoutes.suggestedRides);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2563EB),
                              Color(0xFF38BDF8),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.search,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                            10.horizontalSpace,
                            Text(
                              'Find Rides',
                              style: AppTextStyle.text16Semibold.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              18.verticalSpace,

              // AI Info Banner Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.bolt_fill,
                        color: AppColors.primaryColor,
                        size: 20.sp,
                      ),
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI only shows suitable rides',
                            style: AppTextStyle.text14Semibold.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                          4.verticalSpace,
                          Text(
                            'Driver must have enough seats for your group.',
                            style: AppTextStyle.text12Regular.copyWith(
                              color: AppColors.secondaryTextColor,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Dynamic Search Results Section (Revealed when Find Rides is pressed or default view)
              Obx(() {
                if (!controller.hasSearched.value) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    22.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Matching Rides (${controller.filteredRides.length})',
                          style: AppTextStyle.text16Semibold.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Direct Cash Fares',
                          style: AppTextStyle.text12Regular.copyWith(
                            color: const Color(0xFF16A34A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    12.verticalSpace,

                    if (controller.isSearching.value)
                      _buildShimmerSearchResults()
                    else if (controller.filteredRides.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 24.h,
                          horizontal: 16.w,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          'No rides found matching your exact route. Try adjusting your search criteria.',
                          textAlign: TextAlign.center,
                          style: AppTextStyle.text12Regular.copyWith(
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.filteredRides.length,
                        separatorBuilder: (context, index) =>
                            12.verticalSpace,
                        itemBuilder: (context, index) {
                          final ride = controller.filteredRides[index];
                          return _RideResultCard(
                            ride: ride,
                            onTap: () => RideDetailsSheet.show(context, ride),
                          );
                        },
                      ),
                  ],
                );
              }),

              24.verticalSpace,
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildShimmerSearchResults() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, _) => 12.verticalSpace,
      itemBuilder: (_, _) => shimmerWrapper(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  shimmerContainer(
                    width: 38.r,
                    height: 38.r,
                    borderRadius: BorderRadius.circular(19.r),
                  ),
                  10.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        shimmerContainer(width: 130.w, height: 14.h),
                        6.verticalSpace,
                        shimmerContainer(width: 85.w, height: 10.h),
                      ],
                    ),
                  ),
                  shimmerContainer(
                    width: 60.w,
                    height: 22.h,
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                ],
              ),
              14.verticalSpace,
              shimmerContainer(
                width: double.infinity,
                height: 42.h,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          top: 12.h,
          left: 20.w,
          right: 20.w,
          bottom: MediaQuery.of(ctx).padding.bottom + 20.h,
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
            16.verticalSpace,
            Text(
              'Select Preferred Time',
              style: AppTextStyle.text18Semibold.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            4.verticalSpace,
            Text(
              'Choose an exact time on the clock or pick a quick commute hour',
              style: AppTextStyle.text12Regular.copyWith(
                color: AppColors.secondaryTextColor,
              ),
            ),
            16.verticalSpace,

            // Clock dial button
            InkWell(
              onTap: () {
                Get.back();
                controller.pickSearchTime(context);
              },
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.clock_fill,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Open Clock Time Picker',
                            style: AppTextStyle.text14Semibold.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          2.verticalSpace,
                          Text(
                            'Rotate the clock dial to pick any exact hour and minute',
                            style: AppTextStyle.text12Regular.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: AppColors.primaryColor,
                      size: 16.sp,
                    ),
                  ],
                ),
              ),
            ),

            18.verticalSpace,
            Text(
              'QUICK COMMUTE PRESETS',
              style: AppTextStyle.text10Medium.copyWith(
                color: AppColors.secondaryTextColor,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            10.verticalSpace,
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                '07:00 AM',
                '07:30 AM',
                '08:00 AM',
                '08:30 AM',
                '09:00 AM',
                '05:00 PM',
                '05:30 PM',
                '06:00 PM',
              ].map((time) {
                return Obx(() {
                  final isSelected = controller.preferredTime.value == time;
                  return ChoiceChip(
                    label: Text(time),
                    selected: isSelected,
                    selectedColor: AppColors.primaryColor,
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: AppTextStyle.text12Medium.copyWith(
                      color: isSelected ? Colors.white : AppColors.primaryTextColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) {
                        final now = DateTime.now();
                        final isToday = controller.selectedSearchDate.value.year == now.year &&
                            controller.selectedSearchDate.value.month == now.month &&
                            controller.selectedSearchDate.value.day == now.day;
                        if (isToday) {
                          // Parse e.g. "07:30 AM" or "05:00 PM"
                          final parts = time.split(' ');
                          if (parts.length == 2) {
                            final hm = parts[0].split(':');
                            if (hm.length == 2) {
                              int h = int.tryParse(hm[0]) ?? 0;
                              final int m = int.tryParse(hm[1]) ?? 0;
                              final isPm = parts[1].toUpperCase() == 'PM';
                              if (isPm && h < 12) h += 12;
                              if (!isPm && h == 12) h = 0;
                              final totalMins = h * 60 + m;
                              final nowMins = now.hour * 60 + now.minute;
                              if (totalMins < nowMins) {
                                AppSnackBar.error(
                                  message:
                                      'Cannot select a time in the past. Please choose an upcoming time.',
                                );
                                return;
                              }
                            }
                          }
                        }
                        controller.preferredTime.value = time;
                        Get.back();
                      }
                    },
                  );
                });
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showFlexibilityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          top: 12.h,
          left: 20.w,
          right: 20.w,
          bottom: MediaQuery.of(ctx).padding.bottom + 20.h,
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
            16.verticalSpace,
            Text(
              'Select Time Flexibility',
              style: AppTextStyle.text18Semibold.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            4.verticalSpace,
            Text(
              'Rides departing within this window from your preferred time will be matched',
              style: AppTextStyle.text12Regular.copyWith(
                color: AppColors.secondaryTextColor,
              ),
            ),
            16.verticalSpace,
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                'Exact Time',
                '±15 minutes',
                '±30 minutes',
                '±45 minutes',
                '±1 hour',
                'Anytime',
              ].map((flex) {
                return Obx(() {
                  final isSelected = controller.timeFlexibility.value == flex;
                  return ChoiceChip(
                    label: Text(flex),
                    selected: isSelected,
                    selectedColor: AppColors.primaryColor,
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: AppTextStyle.text12Medium.copyWith(
                      color: isSelected ? Colors.white : AppColors.primaryTextColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) {
                        controller.timeFlexibility.value = flex;
                        Get.back();
                      }
                    },
                  );
                });
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showSeatsPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          top: 12.h,
          left: 20.w,
          right: 20.w,
          bottom: MediaQuery.of(ctx).padding.bottom + 20.h,
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
            16.verticalSpace,
            Text(
              'Select Seats Needed',
              style: AppTextStyle.text18Semibold.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            4.verticalSpace,
            Text(
              'Filter rides that have enough empty seats available',
              style: AppTextStyle.text12Regular.copyWith(
                color: AppColors.secondaryTextColor,
              ),
            ),
            16.verticalSpace,
            ListTile(
              leading: Icon(
                CupertinoIcons.person,
                color: controller.requestedSeats.value == 1
                    ? AppColors.primaryColor
                    : AppColors.secondaryTextColor,
              ),
              title: Text(
                '1 seat - just me',
                style: AppTextStyle.text14Medium.copyWith(
                  fontWeight: controller.requestedSeats.value == 1
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: controller.requestedSeats.value == 1
                      ? AppColors.primaryColor
                      : AppColors.primaryTextColor,
                ),
              ),
              trailing: controller.requestedSeats.value == 1
                  ? const Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: AppColors.primaryColor,
                    )
                  : null,
              onTap: () {
                controller.requestedSeats.value = 1;
                controller.seatsNote.value = '1 seat - just me';
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(
                CupertinoIcons.person_2,
                color: controller.requestedSeats.value == 2
                    ? AppColors.primaryColor
                    : AppColors.secondaryTextColor,
              ),
              title: Text(
                '2 seats - me + friend / family',
                style: AppTextStyle.text14Medium.copyWith(
                  fontWeight: controller.requestedSeats.value == 2
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: controller.requestedSeats.value == 2
                      ? AppColors.primaryColor
                      : AppColors.primaryTextColor,
                ),
              ),
              trailing: controller.requestedSeats.value == 2
                  ? const Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: AppColors.primaryColor,
                    )
                  : null,
              onTap: () {
                controller.requestedSeats.value = 2;
                controller.seatsNote.value = '2 seats - me + friend';
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(
                CupertinoIcons.person_3,
                color: controller.requestedSeats.value == 3
                    ? AppColors.primaryColor
                    : AppColors.secondaryTextColor,
              ),
              title: Text(
                '3 seats - small group',
                style: AppTextStyle.text14Medium.copyWith(
                  fontWeight: controller.requestedSeats.value == 3
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: controller.requestedSeats.value == 3
                      ? AppColors.primaryColor
                      : AppColors.primaryTextColor,
                ),
              ),
              trailing: controller.requestedSeats.value == 3
                  ? const Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: AppColors.primaryColor,
                    )
                  : null,
              onTap: () {
                controller.requestedSeats.value = 3;
                controller.seatsNote.value = '3 seats - small group';
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(
                CupertinoIcons.person_3_fill,
                color: controller.requestedSeats.value == 4
                    ? AppColors.primaryColor
                    : AppColors.secondaryTextColor,
              ),
              title: Text(
                '4 seats - full vehicle (rideshare max)',
                style: AppTextStyle.text14Medium.copyWith(
                  fontWeight: controller.requestedSeats.value == 4
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: controller.requestedSeats.value == 4
                      ? AppColors.primaryColor
                      : AppColors.primaryTextColor,
                ),
              ),
              trailing: controller.requestedSeats.value == 4
                  ? const Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: AppColors.primaryColor,
                    )
                  : null,
              onTap: () {
                controller.requestedSeats.value = 4;
                controller.seatsNote.value = '4 seats - full vehicle';
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DateFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : const Color(0xFFCBD5E1),
            width: 1.1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyle.text11Medium.copyWith(
            color: isSelected ? Colors.white : AppColors.primaryTextColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _FormFieldLabel extends StatelessWidget {
  final String label;

  const _FormFieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyle.text12Semibold.copyWith(
        color: const Color(0xFF64748B),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _InputFieldContainer extends StatelessWidget {
  final IconData icon;
  final Widget child;

  const _InputFieldContainer({
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          width: 1.1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18.sp,
            color: const Color(0xFF64748B),
          ),
          12.horizontalSpace,
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _RideResultCard extends StatelessWidget {
  final RideModel ride;
  final VoidCallback onTap;

  const _RideResultCard({required this.ride, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currentUid = AuthService.instance.currentUser?.uid ?? '';
    final bool isMyOwnRide = currentUid.isNotEmpty && ride.driverId == currentUid;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: ride.isEnRouteMatch
              ? const Color(0xFF86EFAC)
              : const Color(0xFFE2E8F0),
          width: ride.isEnRouteMatch ? 1.4 : 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ride.isEnRouteMatch) ...[
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.alt_route_rounded,
                              size: 13,
                              color: Color(0xFF16A34A),
                            ),
                            4.horizontalSpace,
                            Text(
                              'En-Route Match • ~${ride.detourMinutes} min detour',
                              style: AppTextStyle.text10Medium.copyWith(
                                color: const Color(0xFF15803D),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${ride.seatsAvailable} seat${ride.seatsAvailable > 1 ? 's' : ''} left',
                        style: AppTextStyle.text10Medium.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  8.verticalSpace,
                ],
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: Text(
                        ride.driverName.isNotEmpty ? ride.driverName.substring(0, 1) : 'D',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: AppColors.primaryColor,
                        ),
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
                                ride.driverName,
                                style: AppTextStyle.text14Semibold,
                              ),
                              4.horizontalSpace,
                              if (ride.isVerified)
                                const Icon(
                                  Icons.verified,
                                  size: 15,
                                  color: AppColors.primaryColor,
                                ),
                              if (isMyOwnRide) ...[
                                6.horizontalSpace,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6.r),
                                    border: Border.all(
                                      color: const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Text(
                                    'Your Ride',
                                    style: AppTextStyle.text10Medium.copyWith(
                                      color: const Color(0xFF475569),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            ride.carModel,
                            style: AppTextStyle.text12Regular.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (ride.isEnRouteMatch && ride.enRouteSubFare != null) ...[
                          Text(
                            Utils.formatPrice(ride.enRouteSubFare!),
                            style: AppTextStyle.text18Semibold.copyWith(
                              color: const Color(0xFF16A34A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'sub-route / seat',
                            style: AppTextStyle.text10Medium.copyWith(
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ] else ...[
                          Text(
                            Utils.formatPrice(ride.pricePerSeat),
                            style: AppTextStyle.text18Semibold.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          Text(
                            'cash / seat',
                            style: AppTextStyle.text10Medium.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                10.verticalSpace,
                const Divider(color: AppColors.borderColor, height: 1),
                10.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${ride.origin} → ${ride.destination}',
                        style: AppTextStyle.text12Semibold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    10.horizontalSpace,
                    Text(
                      ride.departureTime,
                      style: AppTextStyle.text12Semibold.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
