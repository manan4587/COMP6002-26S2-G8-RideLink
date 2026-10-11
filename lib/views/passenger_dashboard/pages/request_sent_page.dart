import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class RequestSentPage extends GetView<PassengerDashboardController> {
  const RequestSentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ride = controller.currentSelectedRide.value ??
        (controller.availableRides.isNotEmpty
            ? controller.availableRides.first
            : null);

    if (ride == null) {
      return Scaffold(
        backgroundColor: AppColors.secondaryBgColor,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.checkmark_circle, size: 48, color: AppColors.primaryColor),
                12.verticalSpace,
                Text('Request Submitted', style: AppTextStyle.text18Semibold),
                16.verticalSpace,
                ElevatedButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.passengerDashboard),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final int seatsNeeded = controller.requestedSeats.value;

    final String passengerPickup = ride.searchedPickupAddress.isNotEmpty
        ? ride.searchedPickupAddress
        : (controller.fromLocationController.text.trim().isNotEmpty
            ? controller.fromLocationController.text.trim()
            : (ride.pickupSuggestion.isNotEmpty ? ride.pickupSuggestion : ride.origin));

    final String passengerDrop = ride.searchedDropAddress.isNotEmpty
        ? ride.searchedDropAddress
        : (controller.toLocationController.text.trim().isNotEmpty
            ? controller.toLocationController.text.trim()
            : (ride.dropOffPlan.isNotEmpty ? ride.dropOffPlan : ride.destination));

    return Scaffold(
      backgroundColor: AppColors.secondaryBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              // Top Back button row
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    controller.switchTab(2); // Jump to Trips tab
                    controller.selectedTripsTab.value = 0; // Show Pending Requests tab
                    Get.offAllNamed(AppRoutes.passengerDashboard);
                  },
                  icon: Icon(
                    CupertinoIcons.back,
                    size: 22.sp,
                    color: AppColors.primaryTextColor,
                  ),
                  splashRadius: 22.r,
                ),
              ),

              20.verticalSpace,

              // Circular Clock Icon matching reference
              Container(
                width: 72.w,
                height: 72.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFBEB),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.access_time_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 38.sp,
                  ),
                ),
              ),

              18.verticalSpace,

              Text(
                'Request Sent',
                style: AppTextStyle.text24Semibold.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryTextColor,
                ),
              ),
              6.verticalSpace,
              Text(
                'Waiting for driver approval.',
                style: AppTextStyle.text14Regular.copyWith(
                  color: AppColors.secondaryTextColor,
                ),
              ),

              26.verticalSpace,

              // Your Request Card
              Obx(() {
                final pName = controller.passengerName.value.isNotEmpty
                    ? controller.passengerName.value
                    : (Preferences.userName.isNotEmpty
                          ? Preferences.userName
                          : 'You');
                final subtitle = seatsNeeded > 1
                    ? '$pName + ${seatsNeeded - 1} passenger${seatsNeeded > 2 ? 's' : ''} • $seatsNeeded seats'
                    : '$pName • $seatsNeeded seat';
                return _SummaryTile(
                  icon: CupertinoIcons.car_detailed,
                  title: 'Your Request',
                  subtitle: subtitle,
                );
              }),

              12.verticalSpace,

              // Stream driver's real-time online status from database
              StreamBuilder<bool>(
                stream: AuthService.instance.streamUserOnlineStatus(
                  ride.driverId,
                ),
                initialData: ride.isDriverOnline,
                builder: (context, snapshot) {
                  final bool isDriverOnline = snapshot.data ?? true;

                  return Column(
                    children: [
                      // Status Card
                      _SummaryTile(
                        icon: isDriverOnline
                            ? CupertinoIcons.bell
                            : CupertinoIcons.exclamationmark_triangle,
                        iconColor: isDriverOnline
                            ? AppColors.primaryColor
                            : const Color(0xFFD97706),
                        iconBg: isDriverOnline
                            ? const Color(0xFFEFF6FF)
                            : const Color(0xFFFEF3C7),
                        title: isDriverOnline
                            ? 'Status'
                            : 'Driver is Currently Offline',
                        subtitle: isDriverOnline
                            ? 'Awaiting driver approval • ${ride.driverName} is online'
                            : 'Awaiting approval • ${ride.driverName} is offline right now',
                        trailingBadge: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDriverOnline
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: isDriverOnline
                                  ? const Color(0xFF86EFAC)
                                  : const Color(0xFFFECACA),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDriverOnline
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                              5.horizontalSpace,
                              Text(
                                isDriverOnline ? 'Online' : 'Offline',
                                style: AppTextStyle.text10Medium.copyWith(
                                  color: isDriverOnline
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFFB91C1C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Offline Warning / Notice Alert Box
                      if (!isDriverOnline) ...[
                        12.verticalSpace,
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: const Color(0xFFFDE68A),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(6.r),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFEF3C7),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  CupertinoIcons.clock_fill,
                                  color: const Color(0xFFD97706),
                                  size: 16.sp,
                                ),
                              ),
                              12.horizontalSpace,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Approval Might Take Longer',
                                      style: AppTextStyle.text12Semibold
                                          .copyWith(
                                            color: const Color(0xFF92400E),
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    3.verticalSpace,
                                    Text(
                                      'The driver is currently offline and not checking requests actively. They will receive a push notification, but it may take some extra time for them to respond.',
                                      style: AppTextStyle.text12Regular
                                          .copyWith(
                                            color: const Color(0xFFB45309),
                                            height: 1.35,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),

              12.verticalSpace,

              // Pickup Card
              _SummaryTile(
                icon: CupertinoIcons.location,
                title: 'Pickup Location',
                subtitle: passengerPickup,
              ),

              12.verticalSpace,

              // Drop-off Card
              _SummaryTile(
                icon: CupertinoIcons.arrow_branch,
                title: 'Drop-off Destination',
                subtitle: passengerDrop,
              ),

              24.verticalSpace,

              // Reactive Approved Banner if the driver accepts while user is on this page
              Obx(() {
                final approvedBooking = controller.myBookings.firstWhereOrNull(
                  (b) =>
                      b.ride.id == ride.id &&
                      (b.status.toLowerCase() == 'accepted' ||
                          b.status.toLowerCase() == 'confirmed'),
                );
                if (approvedBooking == null) return const SizedBox.shrink();

                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 20.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFF86EFAC),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.checkmark_seal_fill,
                            color: const Color(0xFF16A34A),
                            size: 26.sp,
                          ),
                          10.horizontalSpace,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Request Approved!',
                                  style: AppTextStyle.text14Semibold.copyWith(
                                    color: const Color(0xFF15803D),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                2.verticalSpace,
                                Text(
                                  '${ride.driverName} accepted your ride request.',
                                  style: AppTextStyle.text12Regular.copyWith(
                                    color: const Color(0xFF166534),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      12.verticalSpace,
                      GestureDetector(
                        onTap: () {
                          controller.currentSelectedRide.value =
                              approvedBooking.ride;
                          Get.toNamed(AppRoutes.requestApproved);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'View Confirmed Ride',
                            style: AppTextStyle.text14Semibold.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // View My Trips CTA Button
              GestureDetector(
                onTap: () {
                  controller.switchTab(2); // Jump to Trips tab
                  controller.selectedTripsTab.value = 0; // Show Pending Requests tab
                  Get.offAllNamed(AppRoutes.passengerDashboard);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
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
                      const Icon(
                        CupertinoIcons.car_detailed,
                        color: Colors.white,
                        size: 20,
                      ),
                      10.horizontalSpace,
                      Text(
                        'View My Trips',
                        style: AppTextStyle.text16Semibold.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              20.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Color? iconBg;
  final Widget? trailingBadge;

  const _SummaryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.iconBg,
    this.trailingBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: iconBg ?? const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.primaryColor,
              size: 18.sp,
            ),
          ),
          14.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyle.text14Semibold.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ?trailingBadge,
                  ],
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
        ],
      ),
    );
  }
}
