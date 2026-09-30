import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                    ),

                    12.verticalSpace,

                    // Destination with Google Places Autocomplete
                    GooglePlacesSearchField(
                      controller: controller.toLocationController,
                      label: 'DESTINATION',
                      labelColor: AppColors.primaryColor,
                      hintText: 'Search drop-off destination or university',
                    ),

                    14.verticalSpace,

                    // Preferred Time
                    _FormFieldLabel(label: 'Preferred Time'),
                    6.verticalSpace,
                    GestureDetector(
                      onTap: () => _showTimePicker(context),
                      child: _InputFieldContainer(
                        icon: CupertinoIcons.clock,
                        child: Obx(
                          () => Text(
                            controller.preferredTime.value,
                            style: AppTextStyle.text14Medium.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),

                    14.verticalSpace,

                    // Time Flexibility
                    _FormFieldLabel(label: 'Time Flexibility'),
                    6.verticalSpace,
                    GestureDetector(
                      onTap: () => _showFlexibilityPicker(context),
                      child: _InputFieldContainer(
                        icon: CupertinoIcons.clock,
                        child: Obx(
                          () => Text(
                            controller.timeFlexibility.value,
                            style: AppTextStyle.text14Medium.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),

                    14.verticalSpace,

                    // Seats Needed
                    _FormFieldLabel(label: 'Seats Needed'),
                    6.verticalSpace,
                    GestureDetector(
                      onTap: () => _showSeatsPicker(context),
                      child: _InputFieldContainer(
                        icon: CupertinoIcons.car_detailed,
                        child: Obx(
                          () => Text(
                            controller.seatsNote.value,
                            style: AppTextStyle.text14Medium.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),

                    20.verticalSpace,

                    // Find Rides Gradient Button
                    GestureDetector(
                      onTap: () {
                        controller.hasSearched.value = true;
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
                          'Matching Rides (${controller.availableRides.length})',
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

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.availableRides.length,
                      separatorBuilder: (context, index) =>
                          12.verticalSpace,
                      itemBuilder: (context, index) {
                        final ride = controller.availableRides[index];
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
    );
  }

  void _showTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Preferred Time',
              style: AppTextStyle.text16Semibold.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            14.verticalSpace,
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                '07:30 AM',
                '08:00 AM',
                '08:30 AM',
                '09:00 AM',
                '05:00 PM',
                '05:30 PM',
              ].map((time) {
                return ActionChip(
                  label: Text(time),
                  onPressed: () {
                    controller.preferredTime.value = time;
                    Navigator.of(ctx).pop();
                  },
                );
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
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Time Flexibility',
              style: AppTextStyle.text16Semibold.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            14.verticalSpace,
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                'Exact Time',
                '±15 minutes',
                '±30 minutes',
                '±45 minutes',
                '±1 hour',
              ].map((flex) {
                return ActionChip(
                  label: Text(flex),
                  onPressed: () {
                    controller.timeFlexibility.value = flex;
                    Navigator.of(ctx).pop();
                  },
                );
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
      builder: (ctx) => Material(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Seats Needed',
                style: AppTextStyle.text16Semibold.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              14.verticalSpace,
              ListTile(
                leading: const Icon(CupertinoIcons.person),
                title: const Text('1 seat - just me'),
                onTap: () {
                  controller.requestedSeats.value = 1;
                  controller.seatsNote.value = '1 seat - just me';
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.person_2),
                title: const Text('2 seats - me + friend / family'),
                onTap: () {
                  controller.requestedSeats.value = 2;
                  controller.seatsNote.value = '2 seats - me + my brother';
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.person_3),
                title: const Text('3 seats - small group'),
                onTap: () {
                  controller.requestedSeats.value = 3;
                  controller.seatsNote.value = '3 seats - small group';
                  Navigator.of(ctx).pop();
                },
              ),
            ],
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
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
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: Text(
                        ride.driverName.substring(0, 1),
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
                        Text(
                          '\$${ride.pricePerSeat.toStringAsFixed(0)}',
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
                    ),
                  ],
                ),
                10.verticalSpace,
                const Divider(color: AppColors.borderColor, height: 1),
                10.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${ride.origin} → ${ride.destination}',
                      style: AppTextStyle.text12Semibold,
                    ),
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
