import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_controller.dart';

class DriverTripsPage extends GetView<DriverTripsController> {
  const DriverTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> statusFilters = [
      'All',
      'Active',
      'Scheduled',
      'Completed',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),

              // Title Row with "Requests" action on top right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Driver Trips',
                    style: AppTextStyle.text20Semibold.copyWith(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  Obx(() {
                    final int totalReqs = controller.totalTripRequestsCount;
                    return InkWell(
                      onTap: controller.openAllTripRequests,
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: const Color(0xFF93C5FD),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.person_2_fill,
                              color: Color(0xFF2563EB),
                              size: 16,
                            ),
                            6.horizontalSpace,
                            Text(
                              'Requests',
                              style: AppTextStyle.text12Semibold.copyWith(
                                color: const Color(0xFF2563EB),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (totalReqs > 0) ...[
                              6.horizontalSpace,
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 1.h,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2563EB),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$totalReqs',
                                  style: AppTextStyle.text10Bold.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),

              14.verticalSpace,

              // Status Filter Tabs
              Obx(() {
                final currentFilter = controller.selectedTripFilter.value;
                return SizedBox(
                  height: 38.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: statusFilters.length,
                    separatorBuilder: (_, _) => 8.horizontalSpace,
                    itemBuilder: (context, index) {
                      final filter = statusFilters[index];
                      final isSelected =
                          currentFilter.toLowerCase() == filter.toLowerCase();
                      return GestureDetector(
                        onTap: () {
                          controller.selectedTripFilter.value = filter;
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryColor.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              filter,
                              style: AppTextStyle.text14Semibold.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),

              14.verticalSpace,

              // Trips List
              Expanded(
                child: Obx(() {
                  final trips = controller.filteredTrips;

                  if (trips.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(20.r),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.car_detailed,
                              size: 44.sp,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          16.verticalSpace,
                          Text(
                            controller.selectedTripFilter.value == 'All'
                                ? 'No Trips Published Yet'
                                : 'No ${controller.selectedTripFilter.value} Trips',
                            style: AppTextStyle.text18Semibold,
                          ),
                          8.verticalSpace,
                          Text(
                            'Publish your commute to start receiving passenger ride requests.',
                            textAlign: TextAlign.center,
                            style: AppTextStyle.text14Regular.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                          20.verticalSpace,
                          ElevatedButton.icon(
                            onPressed: () =>
                                Get.toNamed(AppRoutes.driverPublishRide),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 22.w,
                                vertical: 12.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            icon: const Icon(
                              CupertinoIcons.plus_circle,
                              size: 18,
                            ),
                            label: const Text('Publish a Ride'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: trips.length,
                    separatorBuilder: (_, _) => SizedBox(height: 14.h),
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      return Obx(() {
                        final status = trip.status.value;
                        final bool isActive =
                            status.toLowerCase() == 'active' ||
                            status.toLowerCase() == 'in progress';
                        final bool isCompleted =
                            status.toLowerCase() == 'completed';

                        return Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(22.r),
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFF86EFAC)
                                  : const Color(0xFFE2E8F0),
                              width: isActive ? 1.5 : 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isActive
                                    ? const Color(
                                        0xFF16A34A,
                                      ).withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Badges & Seats Header Row (Responsive to avoid overflow with recurring tag)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      spacing: 6.w,
                                      runSpacing: 4.h,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        // Status Badge
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 3.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? const Color(0xFFDCFCE7)
                                                : isCompleted
                                                ? const Color(0xFFF1F5F9)
                                                : const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 6.r,
                                                height: 6.r,
                                                decoration: BoxDecoration(
                                                  color: isActive
                                                      ? const Color(0xFF16A34A)
                                                      : isCompleted
                                                      ? const Color(0xFF64748B)
                                                      : const Color(0xFF2563EB),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              5.horizontalSpace,
                                              Text(
                                                status,
                                                style: AppTextStyle
                                                    .text12Semibold
                                                    .copyWith(
                                                      color: isActive
                                                          ? const Color(
                                                              0xFF15803D,
                                                            )
                                                          : isCompleted
                                                          ? const Color(
                                                              0xFF475569,
                                                            )
                                                          : const Color(
                                                              0xFF1D4ED8,
                                                            ),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Distinct Recurring Trip Badge
                                        if (trip.isRecurring)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 3.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEEF2FF),
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              border: Border.all(
                                                color: const Color(0xFFC7D2FE),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  CupertinoIcons
                                                      .arrow_2_circlepath,
                                                  size: 11.sp,
                                                  color: const Color(
                                                    0xFF4F46E5,
                                                  ),
                                                ),
                                                4.horizontalSpace,
                                                Text(
                                                  'Recurring',
                                                  style: AppTextStyle
                                                      .text12Semibold
                                                      .copyWith(
                                                        color: const Color(
                                                          0xFF4F46E5,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        // Community or Standard Trip Badge
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 3.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: trip.communityName.isNotEmpty
                                                ? const Color(0xFFEFF6FF)
                                                : const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                            border: Border.all(
                                              color:
                                                  trip.communityName.isNotEmpty
                                                  ? const Color(0xFFBFDBFE)
                                                  : const Color(0xFFE2E8F0),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                trip.communityName.isNotEmpty
                                                    ? CupertinoIcons
                                                          .person_2_fill
                                                    : CupertinoIcons.globe,
                                                size: 11.sp,
                                                color:
                                                    trip
                                                        .communityName
                                                        .isNotEmpty
                                                    ? const Color(0xFF2563EB)
                                                    : const Color(0xFF64748B),
                                              ),
                                              4.horizontalSpace,
                                              Text(
                                                trip.communityName.isNotEmpty
                                                    ? trip.communityName
                                                    : 'Standard Ride',
                                                style: AppTextStyle
                                                    .text12Semibold
                                                    .copyWith(
                                                      color:
                                                          trip
                                                              .communityName
                                                              .isNotEmpty
                                                          ? const Color(
                                                              0xFF1D4ED8,
                                                            )
                                                          : const Color(
                                                              0xFF475569,
                                                            ),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  8.horizontalSpace,

                                  // Seat Booking Counter
                                  Text(
                                    '${trip.bookedSeats.value}/${trip.totalSeats.value} Seats',
                                    style: AppTextStyle.text12Semibold.copyWith(
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),

                              12.verticalSpace,

                              // Route Info Row with Car Icon
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.r),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? const Color(0xFFDCFCE7)
                                          : const Color(0xFFEFF6FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      CupertinoIcons.car_detailed,
                                      color: isActive
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFF2563EB),
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
                                          '${trip.from} → ${trip.to}',
                                          style: AppTextStyle.text16Semibold
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF0F172A),
                                              ),
                                        ),
                                        4.verticalSpace,
                                        Text(
                                          '${trip.time.value} • \$${trip.pricePerSeat.value.toStringAsFixed(0)}/seat',
                                          style: AppTextStyle.text12Regular
                                              .copyWith(
                                                color: const Color(0xFF64748B),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              14.verticalSpace,

                              // Action Buttons based on Status
                              if (isActive) ...[
                                Row(
                                  children: [
                                    // Live Track Button (Primary Action)
                                    Expanded(
                                      flex: 3,
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            controller.openLiveTrip(trip),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF16A34A,
                                          ),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 9.h,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20.r,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(
                                          CupertinoIcons.location_fill,
                                          size: 16,
                                        ),
                                        label: Text(
                                          'Live Trip Tracking',
                                          style: AppTextStyle.text14Semibold
                                              .copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                    8.horizontalSpace,
                                    // Requests Button
                                    Expanded(
                                      flex: 2,
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            controller.openTripRequests(trip),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: Color(0xFF93C5FD),
                                            width: 1.2,
                                          ),
                                          backgroundColor: const Color(
                                            0xFFEFF6FF,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20.r,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 9.h,
                                          ),
                                        ),
                                        child: Text(
                                          trip.requests.isEmpty
                                              ? 'Requests'
                                              : 'Requests (${trip.requests.length})',
                                          style: AppTextStyle.text12Semibold
                                              .copyWith(
                                                color: const Color(0xFF2563EB),
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else if (isCompleted) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 9.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                CupertinoIcons
                                                    .checkmark_seal_fill,
                                                color: Color(0xFF16A34A),
                                                size: 16,
                                              ),
                                              6.horizontalSpace,
                                              Text(
                                                'Trip Completed & Settled',
                                                style: AppTextStyle
                                                    .text12Semibold
                                                    .copyWith(
                                                      color: const Color(
                                                        0xFF475569,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                // Scheduled Trip Actions
                                Row(
                                  children: [
                                    // Requests Pill Button (Blue Outline)
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            controller.openTripRequests(trip),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: Color(0xFF93C5FD),
                                            width: 1.2,
                                          ),
                                          backgroundColor: const Color(
                                            0xFFEFF6FF,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20.r,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8.h,
                                          ),
                                        ),
                                        child: Text(
                                          trip.requests.isEmpty
                                              ? 'Requests'
                                              : 'Requests (${trip.requests.length})',
                                          style: AppTextStyle.text12Semibold
                                              .copyWith(
                                                color: const Color(0xFF2563EB),
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                    8.horizontalSpace,
                                    // Edit Pill Button
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => controller
                                            .showEditTripSheet(context, trip),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                            width: 1.2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20.r,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8.h,
                                          ),
                                        ),
                                        child: Text(
                                          'Edit',
                                          style: AppTextStyle.text12Semibold
                                              .copyWith(
                                                color: const Color(0xFF475569),
                                              ),
                                        ),
                                      ),
                                    ),
                                    8.horizontalSpace,
                                    // Cancel Pill Button
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => controller
                                            .confirmCancelTrip(context, trip),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                            width: 1.2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20.r,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8.h,
                                          ),
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: AppTextStyle.text12Semibold
                                              .copyWith(
                                                color: const Color(0xFF64748B),
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      });
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Obx(() {
        if (controller.filteredTrips.isEmpty) {
          return SizedBox();
        }

        return FloatingActionButton.extended(
          onPressed: () => Get.toNamed(AppRoutes.driverPublishRide),
          backgroundColor: AppColors.primaryColor,
          elevation: 4,
          highlightElevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
          ),
          icon: const Icon(CupertinoIcons.plus, color: Colors.white, size: 18),
          label: Text(
            'Publish',
            style: AppTextStyle.text14Semibold.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }),
    );
  }
}
