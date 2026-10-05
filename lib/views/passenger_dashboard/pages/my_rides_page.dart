import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/simmer_utils.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class MyRidesPage extends GetView<PassengerDashboardController> {
  const MyRidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header matching user reference (Centered "My Trips")
              Center(
                child: Text(
                  'My Trips',
                  style: AppTextStyle.text24Semibold.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryTextColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // 3-Tab Segmented Selector: Pending Requests | Confirmed | Completed
              Obx(
                () => Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildTabItem(
                        index: 0,
                        title: 'Pending',
                        count: controller.pendingRequests.length,
                        isActive: controller.selectedTripsTab.value == 0,
                        onTap: () => controller.switchTripsTab(0),
                      ),
                      _buildTabItem(
                        index: 1,
                        title: 'Confirmed',
                        count: controller.myBookings.length,
                        isActive: controller.selectedTripsTab.value == 1,
                        onTap: () => controller.switchTripsTab(1),
                      ),
                      _buildTabItem(
                        index: 2,
                        title: 'Completed',
                        count: controller.completedTrips.length,
                        isActive: controller.selectedTripsTab.value == 2,
                        onTap: () => controller.switchTripsTab(2),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Active Tab Content View
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingBookings.value) {
                    return _buildShimmerTripList();
                  }
                  switch (controller.selectedTripsTab.value) {
                    case 0:
                      return _buildPendingRequestsTab(context);
                    case 1:
                      return _buildConfirmedTripsTab(context);
                    case 2:
                      return _buildCompletedTripsTab(context);
                    default:
                      return _buildConfirmedTripsTab(context);
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Segment Tab Button Builder
  Widget _buildTabItem({
    required int index,
    required String title,
    required int count,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 9.h),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTextStyle.text12Semibold.copyWith(
                  color: isActive ? Colors.white : AppColors.secondaryTextColor,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (count > 0) ...[
                SizedBox(width: 4.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.25)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? Colors.white
                          : AppColors.secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // TAB 0: Pending Requests View
  Widget _buildPendingRequestsTab(BuildContext context) {
    if (controller.pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(18.r),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBEB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time_rounded,
                size: 40.sp,
                color: const Color(0xFFF59E0B),
              ),
            ),
            14.verticalSpace,
            Text(
              'No Pending Requests',
              style: AppTextStyle.text16Semibold.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            6.verticalSpace,
            Text(
              'When you request a ride, it will appear here\nawaiting driver confirmation.',
              style: AppTextStyle.text12Regular.copyWith(
                color: AppColors.secondaryTextColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            18.verticalSpace,
            ElevatedButton(
              onPressed: () => controller.switchTab(1), // Switch to Search tab
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text('Search Rides', style: AppTextStyle.buttonText),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: controller.pendingRequests.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final pending = controller.pendingRequests[index];
        return _PendingRequestCard(
          pending: pending,
          onCancel: () => _confirmCancelPendingRequest(context, pending),
          onViewDetails: () => controller.selectRideForDetails(pending.ride),
        );
      },
    );
  }

  // TAB 1: Confirmed Trips View
  Widget _buildConfirmedTripsTab(BuildContext context) {
    if (controller.myBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(18.r),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.car_detailed,
                size: 40.sp,
                color: AppColors.primaryColor,
              ),
            ),
            14.verticalSpace,
            Text(
              'No Confirmed Trips',
              style: AppTextStyle.text16Semibold.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            6.verticalSpace,
            Text(
              'You have no active confirmed rides right now.',
              style: AppTextStyle.text12Regular.copyWith(
                color: AppColors.secondaryTextColor,
              ),
            ),
            18.verticalSpace,
            ElevatedButton(
              onPressed: () => controller.switchTab(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text('Book a Ride', style: AppTextStyle.buttonText),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: controller.myBookings.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final booking = controller.myBookings[index];
        return _ConfirmedTripCard(
          booking: booking,
          onTrack: () {
            controller.currentSelectedRide.value = booking.ride;
            Get.toNamed(AppRoutes.liveTripTracking);
          },
          onChat: () {
            Get.toNamed(
              AppRoutes.rideChat,
              arguments: {
                'tripId': booking.ride.id,
                'driverName': booking.ride.driverName,
                'carModel': booking.ride.carModel,
                'route':
                    '${booking.ride.origin} → ${booking.ride.destination}',
              },
            );
          },
          onCancel: () => _confirmCancelBooking(context, booking),
        );
      },
    );
  }

  // TAB 2: Completed / Past Trips View
  Widget _buildCompletedTripsTab(BuildContext context) {
    if (controller.completedTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(18.r),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBEB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_border_rounded,
                size: 40.sp,
                color: const Color(0xFFF59E0B),
              ),
            ),
            14.verticalSpace,
            Text(
              'No Past Trips',
              style: AppTextStyle.text16Semibold.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            6.verticalSpace,
            Text(
              'Your completed carpools will be archived here.',
              style: AppTextStyle.text12Regular.copyWith(
                color: AppColors.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: controller.completedTrips.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final trip = controller.completedTrips[index];
        return _CompletedTripCard(
          trip: trip,
          onRateDriver: () => _showRateDriverBottomSheet(context, trip),
        );
      },
    );
  }

  // Shimmer List Placeholder while bookings are syncing from Firestore
  Widget _buildShimmerTripList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (_, _) => const _ShimmerTripCard(),
    );
  }

  // Modal Sheet to Cancel Pending Request
  void _confirmCancelPendingRequest(BuildContext context, dynamic request) {
    final String driverName = request is PassengerPendingRequestModel
        ? request.ride.driverName
        : 'the driver';

    String selectedReason = 'Change of plans';
    final List<String> reasons = [
      'Change of plans',
      'Booked another ride',
      'Driver taking too long',
      'Other reason',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, MediaQuery.of(context).padding.bottom + 20.h),
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
                      color: Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.exclamationmark_triangle_fill,
                      color: AppColors.red,
                      size: 22.sp,
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cancel Ride Request?',
                          style: AppTextStyle.text18Semibold.copyWith(
                            color: AppColors.primaryTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        2.verticalSpace,
                        Text(
                          'With $driverName',
                          style: AppTextStyle.text12Regular.copyWith(
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              14.verticalSpace,
              Text(
                'Are you sure you want to withdraw this ride request? The driver will be instantly notified of your cancellation.',
                style: AppTextStyle.text12Regular.copyWith(
                  color: AppColors.secondaryTextColor,
                  height: 1.4,
                ),
              ),
              16.verticalSpace,
              Text(
                'Reason for cancellation (optional):',
                style: AppTextStyle.text12Semibold.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              8.verticalSpace,
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: reasons.map((r) {
                  final isSelected = selectedReason == r;
                  return ChoiceChip(
                    label: Text(r),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        setSheetState(() => selectedReason = r);
                      }
                    },
                    selectedColor: const Color(0xFFFEE2E2),
                    backgroundColor: AppColors.containerFillColor,
                    labelStyle: AppTextStyle.text10Medium.copyWith(
                      color: isSelected ? AppColors.red : AppColors.primaryTextColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: BorderSide(
                        color: isSelected ? AppColors.red : AppColors.borderColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
              20.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        side: const BorderSide(color: AppColors.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Keep Request',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        controller.cancelPendingRequest(
                          request,
                          reason: selectedReason,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Confirm Cancel',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: Colors.white,
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

  // Modal Sheet to Cancel Confirmed Booking
  void _confirmCancelBooking(BuildContext context, dynamic booking) {
    final String driverName = booking is BookingModel
        ? booking.ride.driverName
        : 'the driver';

    String selectedReason = 'Change of plans';
    final List<String> reasons = [
      'Change of plans',
      'Found another ride',
      'Emergency came up',
      'Driver requested cancel',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, MediaQuery.of(context).padding.bottom + 20.h),
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
                      color: Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: AppColors.red,
                      size: 24.sp,
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cancel Confirmed Ride?',
                          style: AppTextStyle.text18Semibold.copyWith(
                            color: AppColors.primaryTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        2.verticalSpace,
                        Text(
                          'Ride with $driverName',
                          style: AppTextStyle.text12Regular.copyWith(
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              14.verticalSpace,
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_rounded,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                    10.horizontalSpace,
                    Expanded(
                      child: Text(
                        'Your reserved seat will be restored and an instant push notification will alert $driverName.',
                        style: AppTextStyle.text12Regular.copyWith(
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              16.verticalSpace,
              Text(
                'Reason for cancellation (optional):',
                style: AppTextStyle.text12Semibold.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              8.verticalSpace,
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: reasons.map((r) {
                  final isSelected = selectedReason == r;
                  return ChoiceChip(
                    label: Text(r),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        setSheetState(() => selectedReason = r);
                      }
                    },
                    selectedColor: const Color(0xFFFEE2E2),
                    backgroundColor: AppColors.containerFillColor,
                    labelStyle: AppTextStyle.text10Medium.copyWith(
                      color: isSelected ? AppColors.red : AppColors.primaryTextColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: BorderSide(
                        color: isSelected ? AppColors.red : AppColors.borderColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
              20.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        side: const BorderSide(color: AppColors.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Keep Ride',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        controller.cancelBooking(
                          booking,
                          reason: selectedReason,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Cancel Ride',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: Colors.white,
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

  // Interactive Bottom Sheet to Rate Driver
  void _showRateDriverBottomSheet(
    BuildContext context,
    CompletedTripModel trip,
  ) {
    final RxDouble ratingValue = 5.0.obs;
    final TextEditingController reviewController = TextEditingController();
    final RxList<String> selectedTags = <String>[].obs;

    final List<String> availableTags = [
      'Punctual',
      'Smooth Ride',
      'Clean Car',
      'Friendly Chat',
      'Safe Driver',
      'Great Music',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.only(
            top: 14.h,
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
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              16.verticalSpace,

              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFFBEB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF59E0B),
                      size: 26,
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rate Your Driver',
                          style: AppTextStyle.text18Semibold.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        2.verticalSpace,
                        Text(
                          'Trip with ${trip.driverName}',
                          style: AppTextStyle.text12Regular.copyWith(
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              18.verticalSpace,

              // Star Selector
              Center(
                child: Obx(
                  () => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final star = index + 1;
                          final isSelected = star <= ratingValue.value;
                          return GestureDetector(
                            onTap: () => ratingValue.value = star.toDouble(),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Icon(
                                isSelected
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: isSelected
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFCBD5E1),
                                size: 38.sp,
                              ),
                            ),
                          );
                        }),
                      ),
                      6.verticalSpace,
                      Text(
                        _getRatingLabel(ratingValue.value),
                        style: AppTextStyle.text14Medium.copyWith(
                          color: const Color(0xFFB45309),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              18.verticalSpace,
              Text(
                'What went well?',
                style: AppTextStyle.text12Semibold.copyWith(
                  color: AppColors.primaryTextColor,
                ),
              ),
              8.verticalSpace,

              // Compliment Tags
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: availableTags.map((tag) {
                  return Obx(() {
                    final isTagSelected = selectedTags.contains(tag);
                    return GestureDetector(
                      onTap: () {
                        if (isTagSelected) {
                          selectedTags.remove(tag);
                        } else {
                          selectedTags.add(tag);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isTagSelected
                              ? AppColors.primaryColor
                              : AppColors.containerFillColor,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isTagSelected
                                ? AppColors.primaryColor
                                : AppColors.borderColor,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyle.text10Medium.copyWith(
                            color: isTagSelected
                                ? Colors.white
                                : AppColors.primaryTextColor,
                            fontWeight: isTagSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),

              14.verticalSpace,

              // Optional Comment Text Field
              TextField(
                controller: reviewController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Share a note about this trip (optional)...',
                  hintStyle: AppTextStyle.text12Regular.copyWith(
                    color: AppColors.hintTextColor,
                  ),
                  filled: true,
                  fillColor: AppColors.secondaryBgColor,
                  contentPadding: EdgeInsets.all(12.w),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.primaryColor),
                  ),
                ),
              ),

              20.verticalSpace,

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  onPressed: () {
                    final combinedComment = [
                      if (selectedTags.isNotEmpty) selectedTags.join(', '),
                      if (reviewController.text.trim().isNotEmpty)
                        reviewController.text.trim(),
                    ].join(' • ');

                    controller.rateDriver(
                      tripId: trip.id,
                      rating: ratingValue.value,
                      comment: combinedComment,
                    );

                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Submit Rating',
                    style: AppTextStyle.text14Semibold.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingLabel(double rating) {
    if (rating >= 5.0) return '5.0 ★ Exceptional Ride!';
    if (rating >= 4.0) return '4.0 ★ Great Driver';
    if (rating >= 3.0) return '3.0 ★ Good Experience';
    if (rating >= 2.0) return '2.0 ★ Fair';
    return '1.0 ★ Needs Improvement';
  }
}

// ---------------------------------------------------------------------------
// CARD 1: PENDING REQUEST CARD
// ---------------------------------------------------------------------------
class _PendingRequestCard extends StatelessWidget {
  final PassengerPendingRequestModel pending;
  final VoidCallback onCancel;
  final VoidCallback onViewDetails;

  const _PendingRequestCard({
    required this.pending,
    required this.onCancel,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Clock Icon matching reference
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Orange Clock Icon Container
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Center(
                  child: Icon(
                    Icons.access_time_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 22.sp,
                  ),
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${pending.ride.origin} → ${pending.ride.destination}',
                      style: AppTextStyle.text14Semibold.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    3.verticalSpace,
                    Text(
                      '${pending.passengerLabel} • Waiting for driver approval',
                      style: AppTextStyle.text12Regular.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${pending.totalPrice.toStringAsFixed(2)}',
                style: AppTextStyle.text16Semibold.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          12.verticalSpace,
          const Divider(color: AppColors.borderColor, height: 1),
          10.verticalSpace,

          // Driver & Pickup Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12.r,
                    backgroundColor: const Color(0xFFEFF6FF),
                    child: Text(
                      pending.ride.driverName[0],
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  6.horizontalSpace,
                  Text(
                    'Driver: ${pending.ride.driverName}',
                    style: AppTextStyle.text12Medium,
                  ),
                  4.horizontalSpace,
                  Text(
                    '★ ${pending.ride.rating}',
                    style: AppTextStyle.text10Medium.copyWith(
                      color: const Color(0xFFD97706),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                pending.requestTime,
                style: AppTextStyle.text10Medium.copyWith(
                  fontWeight: FontWeight.normal,
                  color: AppColors.hintTextColor,
                ),
              ),
            ],
          ),

          12.verticalSpace,

          // Respective Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    backgroundColor: const Color(0xFFFEF2F2),
                    foregroundColor: AppColors.red,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Cancel Request',
                    style: AppTextStyle.text12Semibold.copyWith(
                      color: AppColors.red,
                    ),
                  ),
                ),
              ),
              8.horizontalSpace,
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewDetails,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryColor),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Ride Details',
                    style: AppTextStyle.text12Semibold.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CARD 2: CONFIRMED TRIP CARD
// ---------------------------------------------------------------------------
class _ConfirmedTripCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTrack;
  final VoidCallback onChat;
  final VoidCallback onCancel;

  const _ConfirmedTripCard({
    required this.booking,
    required this.onTrack,
    required this.onChat,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Green Checkmark Icon matching reference
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: const Color(0xFF16A34A),
                    size: 24.sp,
                  ),
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${booking.ride.origin} → ${booking.ride.destination}',
                      style: AppTextStyle.text14Semibold.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    3.verticalSpace,
                    Text(
                      '${booking.bookingDate} • ${booking.bookedSeats} seats approved',
                      style: AppTextStyle.text12Regular.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${booking.totalPrice.toStringAsFixed(2)}',
                style: AppTextStyle.text16Semibold.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          12.verticalSpace,
          const Divider(color: AppColors.borderColor, height: 1),
          10.verticalSpace,

          // Driver details & car
          Row(
            children: [
              CircleAvatar(
                radius: 14.r,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  booking.ride.driverName[0],
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              8.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.ride.driverName,
                      style: AppTextStyle.text12Semibold,
                    ),
                    Text(
                      '${booking.ride.carModel} • ${booking.ride.carPlate}',
                      style: AppTextStyle.text10Medium.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          14.verticalSpace,

          // Action Buttons: Track Ride, Chat, Cancel
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onTrack,
                  icon: const Icon(
                    CupertinoIcons.location_fill,
                    size: 15,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Track Ride',
                    style: AppTextStyle.buttonText.copyWith(fontSize: 12.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 9.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
              8.horizontalSpace,
              IconButton(
                onPressed: onChat,
                tooltip: 'Chat with driver',
                icon: Container(
                  padding: EdgeInsets.all(7.w),
                  decoration: BoxDecoration(
                    color: AppColors.containerFillColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Icon(
                    CupertinoIcons.chat_bubble_2_fill,
                    size: 16.sp,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              IconButton(
                onPressed: onCancel,
                tooltip: 'Cancel trip',
                icon: Container(
                  padding: EdgeInsets.all(7.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.xmark,
                    size: 15.sp,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CARD 3: COMPLETED TRIP CARD (WITH RATE DRIVER BUTTON REMOVAL FLOW)
// ---------------------------------------------------------------------------
class _CompletedTripCard extends StatelessWidget {
  final CompletedTripModel trip;
  final VoidCallback onRateDriver;

  const _CompletedTripCard({required this.trip, required this.onRateDriver});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Amber Star Icon matching reference
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Center(
                  child: Icon(
                    Icons.star_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 24.sp,
                  ),
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.route,
                      style: AppTextStyle.text14Semibold.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    3.verticalSpace,
                    Text(
                      '${trip.date} • ${trip.driverName}',
                      style: AppTextStyle.text12Regular.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                trip.fare,
                style: AppTextStyle.text16Semibold.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          10.verticalSpace,
          const Divider(color: AppColors.borderColor, height: 1),
          10.verticalSpace,

          // Car info & review comment if rated
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${trip.carModel} • ${trip.carPlate}',
                style: AppTextStyle.text10Medium.copyWith(
                  color: AppColors.secondaryTextColor,
                ),
              ),
              Text(
                'Payment: Cash',
                style: AppTextStyle.text10Medium.copyWith(
                  color: AppColors.hintTextColor,
                ),
              ),
            ],
          ),

          12.verticalSpace,

          // REACTIVE RATING SECTION:
          // If NOT rated: Shows "Rate Driver" button.
          // Once rated: The button is REMOVED and "Rated X ★" badge is shown!
          Obx(() {
            if (!trip.isRated.value) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Completed • Not rated yet',
                    style: AppTextStyle.text12Medium.copyWith(
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onRateDriver,
                    icon: const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFD97706),
                    ),
                    label: Text(
                      'Rate Driver',
                      style: AppTextStyle.text12Semibold.copyWith(
                        color: const Color(0xFF92400E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEF3C7),
                      foregroundColor: const Color(0xFF92400E),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        side: const BorderSide(color: Color(0xFFFCD34D)),
                      ),
                    ),
                  ),
                ],
              );
            }

            // Once rated: Rate Driver button is REMOVED! Shows Rated ★ badge!
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Completed',
                      style: AppTextStyle.text12Medium.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: Color(0xFFF59E0B),
                          ),
                          4.horizontalSpace,
                          Text(
                            'Rated ${trip.rating.value.toStringAsFixed(1)} ★',
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: const Color(0xFFB45309),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (trip.reviewComment.value.isNotEmpty) ...[
                  6.verticalSpace,
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBgColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '"${trip.reviewComment.value}"',
                      style: AppTextStyle.text10Medium.copyWith(
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.italic,
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ShimmerTripCard extends StatelessWidget {
  const _ShimmerTripCard();

  @override
  Widget build(BuildContext context) {
    return shimmerWrapper(
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                shimmerContainer(
                  width: 40.r,
                  height: 40.r,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                12.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      shimmerContainer(width: 140.w, height: 14.h),
                      6.verticalSpace,
                      shimmerContainer(width: 90.w, height: 10.h),
                    ],
                  ),
                ),
                shimmerContainer(
                  width: 65.w,
                  height: 24.h,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ],
            ),
            14.verticalSpace,
            shimmerContainer(
              width: double.infinity,
              height: 48.h,
              borderRadius: BorderRadius.circular(12.r),
            ),
            14.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: shimmerContainer(
                    height: 38.h,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                10.horizontalSpace,
                Expanded(
                  child: shimmerContainer(
                    height: 38.h,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
