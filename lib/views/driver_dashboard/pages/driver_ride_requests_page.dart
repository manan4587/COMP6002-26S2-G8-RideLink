import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_controller.dart';

class DriverRideRequestsPage extends GetView<DriverTripsController> {
  const DriverRideRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Screen 24 Top Bar: Back button and Centered "Passenger Requests"
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        CupertinoIcons.back,
                        size: 22.sp,
                        color: AppColors.primaryTextColor,
                      ),
                      splashRadius: 22.r,
                    ),
                  ),
                  Text(
                    'Passenger Requests',
                    style: AppTextStyle.text20Semibold.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),

            // Trip Filter Chips (All Trips or Specific Trip)
            Obx(() {
              final selectedTrip = controller.selectedTripForRequests.value;
              final tripsWithRequests = controller.myTrips.where((t) {
                final s = t.status.value.toLowerCase().trim();
                if (s == 'completed' || s == 'cancelled') return false;
                return t.requests.any(
                      (r) => r.status.value.toLowerCase() == 'pending',
                    ) ||
                    controller.pendingRequests.any(
                      (r) =>
                          r.tripId == t.id &&
                          r.status.value.toLowerCase() == 'pending',
                    );
              }).toList();
              final totalAllRequests = controller.totalTripRequestsCount;

              return Container(
                height: 40.h,
                margin: EdgeInsets.only(bottom: 10.h),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    // "All Trips" Chip
                    GestureDetector(
                      onTap: () {
                        controller.selectedTripForRequests.value = null;
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 8.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: selectedTrip == null
                              ? AppColors.primaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: selectedTrip == null
                                ? AppColors.primaryColor
                                : const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                          boxShadow: selectedTrip == null
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
                            'All Requests ($totalAllRequests)',
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: selectedTrip == null
                                  ? Colors.white
                                  : const Color(0xFF475569),
                              fontWeight: selectedTrip == null
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Individual Trip Chips
                    ...tripsWithRequests.map((t) {
                      final isSelected = selectedTrip?.id == t.id;
                      return GestureDetector(
                        onTap: () {
                          controller.selectedTripForRequests.value = t;
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 8.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
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
                              '${t.from} → ${t.to} (${t.requests.where((r) => r.status.value.toLowerCase() == 'pending').length})',
                              style: AppTextStyle.text12Semibold.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF475569),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),

            // Requests Body List
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryColor,
                onRefresh: () async {
                  await controller.reloadDriverTrips();
                },
                child: Obx(() {
                  final currentTrip = controller.selectedTripForRequests.value;

                // Collect list of items (trip + request pairs)
                final List<MapEntry<DriverTripModel, PassengerRequestModel>>
                items = [];
                final Set<String> addedReqIds = {};

                if (currentTrip != null) {
                  final s = currentTrip.status.value.toLowerCase().trim();
                  if (s != 'completed' && s != 'cancelled') {
                    for (final req in currentTrip.requests) {
                      if (req.status.value.toLowerCase() == 'pending' &&
                          addedReqIds.add(req.id)) {
                        items.add(MapEntry(currentTrip, req));
                      }
                    }
                    for (final req in controller.pendingRequests) {
                      if (req.tripId == currentTrip.id &&
                          req.status.value.toLowerCase() == 'pending' &&
                          addedReqIds.add(req.id)) {
                        items.add(MapEntry(currentTrip, req));
                      }
                    }
                  }
                } else {
                  for (final trip in controller.myTrips) {
                    final s = trip.status.value.toLowerCase().trim();
                    if (s == 'completed' || s == 'cancelled') continue;
                    for (final req in trip.requests) {
                      if (req.status.value.toLowerCase() == 'pending' &&
                          addedReqIds.add(req.id)) {
                        items.add(MapEntry(trip, req));
                      }
                    }
                  }
                  for (final req in controller.pendingRequests) {
                    if (req.status.value.toLowerCase() == 'pending' &&
                        addedReqIds.add(req.id)) {
                      final trip = controller.myTrips.firstWhereOrNull(
                        (t) => t.id == req.tripId,
                      );
                      if (trip != null) {
                        final s = trip.status.value.toLowerCase().trim();
                        if (s != 'completed' && s != 'cancelled') {
                          items.add(MapEntry(trip, req));
                        }
                      } else {
                        // Fallback trip model if trip document is still streaming
                        final fallbackTrip = DriverTripModel(
                          id: req.tripId ?? '',
                          from: req.from,
                          to: req.to,
                          time: req.time,
                          pricePerSeat: req.fare,
                          totalSeats: 4,
                          bookedSeats: 0,
                          status: 'scheduled',
                        );
                        items.add(MapEntry(fallbackTrip, req));
                      }
                    }
                  }
                }

                if (items.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    children: [
                      SizedBox(height: 60.h),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
                                  CupertinoIcons.person_2,
                                  size: 40.sp,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                              16.verticalSpace,
                              Text(
                                'No Pending Requests',
                                style: AppTextStyle.text18Semibold.copyWith(
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              8.verticalSpace,
                              Text(
                                currentTrip != null
                                    ? 'No requests waiting for ${currentTrip.from} → ${currentTrip.to}.'
                                    : 'All passenger requests for your published trips have been reviewed.',
                                textAlign: TextAlign.center,
                                style: AppTextStyle.text14Regular.copyWith(
                                  color: AppColors.secondaryTextColor,
                                ),
                              ),
                              20.verticalSpace,
                              OutlinedButton(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  side:
                                      const BorderSide(color: Color(0xFFCBD5E1)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                ),
                                child: const Text('Back to Trips'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => SizedBox(height: 14.h),
                  itemBuilder: (context, index) {
                    final trip = items[index].key;
                    final req = items[index].value;

                    return Obx(() {
                      final bool isAccepted = req.status.value == 'Accepted';
                      final bool isDeclined = req.status.value == 'Declined';

                      return InkWell(
                        onTap: () => controller.openRequestDetails(trip, req),
                        borderRadius: BorderRadius.circular(22.r),
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(22.r),
                            border: Border.all(
                              color: isAccepted
                                  ? const Color(0xFF86EFAC)
                                  : isDeclined
                                  ? const Color(0xFFFECACA)
                                  : const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
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
                              // Route Badge & Seats Info Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFFBFDBFE),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            CupertinoIcons.car_detailed,
                                            size: 13.sp,
                                            color: const Color(0xFF2563EB),
                                          ),
                                          5.horizontalSpace,
                                          Expanded(
                                            child: Text(
                                              '${trip.from} → ${trip.to}',
                                              style: AppTextStyle.text12Semibold
                                                  .copyWith(
                                                    color: const Color(
                                                      0xFF1D4ED8,
                                                    ),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '${Utils.formatPrice(req.fare)} AUD',
                                    style: AppTextStyle.text16Semibold.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF16A34A),
                                    ),
                                  ),
                                ],
                              ),

                              12.verticalSpace,

                              // Passenger Details Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44.r,
                                    height: 44.r,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEFF6FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        req.passengerName.isNotEmpty
                                            ? req.passengerName[0]
                                            : 'P',
                                        style: AppTextStyle.text18Semibold
                                            .copyWith(
                                              color: const Color(0xFF2563EB),
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ),
                                  12.horizontalSpace,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              req.passengerName,
                                              style: AppTextStyle.text16Semibold
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(
                                                      0xFF0F172A,
                                                    ),
                                                  ),
                                            ),
                                            6.horizontalSpace,
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6.w,
                                                vertical: 2.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFEF3C7),
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.star_rounded,
                                                    color: const Color(
                                                      0xFFD97706,
                                                    ),
                                                    size: 13.sp,
                                                  ),
                                                  2.horizontalSpace,
                                                  Text(
                                                    (req.rating.value > 0
                                                            ? req.rating.value
                                                            : 5.0)
                                                        .toStringAsFixed(1),
                                                    style: AppTextStyle
                                                        .text12Semibold
                                                        .copyWith(
                                                          color: const Color(
                                                            0xFF92400E,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        4.verticalSpace,
                                        Text(
                                          '${req.seats} seat(s) • ${req.travellingWith} • Detour: ${req.detour}',
                                          style: AppTextStyle.text12Regular
                                              .copyWith(
                                                color: const Color(0xFF64748B),
                                              ),
                                        ),
                                        2.verticalSpace,
                                        Text(
                                          'Pickup: ${req.from} • ${req.time}',
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

                              // Status Pill or Accept & Decline Buttons
                              if (isAccepted)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: const Color(0xFF86EFAC),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Request Accepted ✓',
                                      style: AppTextStyle.text12Semibold
                                          .copyWith(
                                            color: const Color(0xFF15803D),
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                )
                              else if (isDeclined)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: const Color(0xFFFECACA),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Request Declined',
                                      style: AppTextStyle.text12Semibold
                                          .copyWith(
                                            color: const Color(0xFFDC2626),
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => controller
                                            .acceptRideRequest(trip, req),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFDCFCE7,
                                          ),
                                          foregroundColor: const Color(
                                            0xFF15803D,
                                          ),
                                          elevation: 0,
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
                                          'Accept',
                                          style: AppTextStyle.text12Semibold
                                              .copyWith(
                                                color: const Color(0xFF15803D),
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                    12.horizontalSpace,
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => controller
                                            .declineRideRequest(trip, req),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFFEE2E2,
                                          ),
                                          foregroundColor: const Color(
                                            0xFFDC2626,
                                          ),
                                          elevation: 0,
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
                                          'Decline',
                                          style: AppTextStyle.text14Semibold
                                              .copyWith(
                                                color: const Color(0xFFDC2626),
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
                      );
                    });
                  },
                );
              }),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
