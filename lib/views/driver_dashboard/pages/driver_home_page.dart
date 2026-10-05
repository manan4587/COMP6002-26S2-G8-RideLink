import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/data/services/device_location_service.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_controller.dart';

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final DriverHomeController homeController =
        Get.find<DriverHomeController>();
    final DriverTripsController tripsController =
        Get.find<DriverTripsController>();
    final DriverProfileController profileController =
        Get.find<DriverProfileController>();
    final DriverDashboardController dashboardController =
        Get.find<DriverDashboardController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!dashboardController.hasLocationPermission.value) {
        dashboardController.requestLocationPermissionPrompt(context: context);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.secondaryBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => dashboardController.switchTab(3),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Obx(
                          () => Container(
                            width: 46.w,
                            height: 46.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFEFF6FF),
                              border: Border.all(
                                color: AppColors.primaryColor,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                profileController.driverInitials,
                                style: AppTextStyle.text16Semibold.copyWith(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Obx(
                                  () => Text(
                                    profileController.driverName.value,
                                    style: AppTextStyle.text18Semibold,
                                  ),
                                ),
                                Obx(
                                  () => profileController.isVerifiedByAdmin.value
                                      ? Padding(
                                          padding: EdgeInsets.only(left: 4.w),
                                          child: Icon(
                                            Icons.verified,
                                            size: 16.sp,
                                            color: AppColors.primaryColor,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                            Obx(() {
                              final isVerified =
                                  profileController.isVerifiedByAdmin.value;
                              final rating = profileController.driverRating.value;
                              final ratingStr =
                                  rating > 0 ? rating.toStringAsFixed(1) : '0.0';
                              final title =
                                  isVerified ? 'Verified Driver' : 'Driver';
                              return Text(
                                '$title • $ratingStr ★',
                                style: AppTextStyle.text12Regular.copyWith(
                                  color: AppColors.secondaryTextColor,
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Online / Offline Toggle
                  Obx(
                    () => GestureDetector(
                      onTap: homeController.toggleOnlineStatus,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: homeController.isOnline.value
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: homeController.isOnline.value
                                ? const Color(0xFF16A34A)
                                : AppColors.borderColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: homeController.isOnline.value
                                    ? const Color(0xFF16A34A)
                                    : AppColors.secondaryTextColor,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              homeController.isOnline.value ? 'Online' : 'Offline',
                              style: AppTextStyle.text12Semibold.copyWith(
                                color: homeController.isOnline.value
                                    ? const Color(0xFF16A34A)
                                    : AppColors.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Location Permission Needed Banner (shown if location is not granted or blocked)
              Obx(() {
                final status = dashboardController.locationPermissionStatus.value;
                if (status == null || status == LocationCheckResult.granted) {
                  return const SizedBox.shrink();
                }

                final bool isBlocked = status == LocationCheckResult.deniedForever;
                final bool isGpsOff = status == LocationCheckResult.serviceDisabled;

                return Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isBlocked ? const Color(0xFFFEF2F2) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isBlocked ? const Color(0xFFFECACA) : const Color(0xFFFDE68A),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: isBlocked ? const Color(0xFFFEE2E2) : const Color(0xFFFDE68A),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isBlocked
                              ? CupertinoIcons.location_slash_fill
                              : CupertinoIcons.location_fill,
                          color: isBlocked ? const Color(0xFFDC2626) : const Color(0xFFD97706),
                          size: 18.sp,
                        ),
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBlocked
                                  ? 'Location Access Blocked'
                                  : (isGpsOff ? 'Device GPS is Off' : 'Location Access Needed'),
                              style: AppTextStyle.text14Semibold.copyWith(
                                color: isBlocked ? const Color(0xFF991B1B) : const Color(0xFF92400E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            2.verticalSpace,
                            Text(
                              isBlocked
                                  ? 'Allow location in Settings for live trips.'
                                  : (isGpsOff
                                      ? 'Turn on GPS for live route navigation.'
                                      : 'Allow location to navigate and track rides.'),
                              style: AppTextStyle.text12Regular.copyWith(
                                color: isBlocked ? const Color(0xFFB91C1C) : const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                      8.horizontalSpace,
                      ElevatedButton(
                        onPressed: () => dashboardController.requestLocationPermissionPrompt(
                          context: context,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isBlocked ? const Color(0xFFDC2626) : const Color(0xFFD97706),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          isBlocked ? 'Settings' : 'Allow',
                          style: AppTextStyle.buttonText.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Earnings Banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Earnings",
                      style: AppTextStyle.text14Medium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Obx(
                      () => Text(
                        '\$${homeController.todayEarnings.value.toStringAsFixed(2)}',
                        style: AppTextStyle.text30Semibold.copyWith(
                          color: Colors.white,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => _StatItem(
                            label: 'Completed Trips',
                            value: '${homeController.completedTripsCount.value}',
                          ),
                        ),
                        Obx(
                          () => _StatItem(
                            label: 'Weekly Total',
                            value:
                                '\$${homeController.weeklyEarnings.value.toStringAsFixed(0)}',
                          ),
                        ),
                        _StatItem(label: 'Acceptance', value: '98%'),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 22.h),

              // Publish New Ride Quick Action
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.driverPublishRide),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.primaryColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.plus_circle_fill,
                        color: AppColors.primaryColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Publish a New Trip',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Scheduled Trips List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Published Trips',
                    style: AppTextStyle.text18Semibold,
                  ),
                  Obx(() {
                    final activeCount = tripsController.myTrips.where((t) {
                      final s = t.status.value.toLowerCase().trim();
                      return s != 'completed' && s != 'cancelled';
                    }).length;
                    return Text(
                      '$activeCount Active',
                      style: AppTextStyle.text12Semibold.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    );
                  }),
                ],
              ),

              SizedBox(height: 12.h),

              Obx(() {
                final activeOrScheduledTrips = tripsController.myTrips.where((t) {
                  final s = t.status.value.toLowerCase().trim();
                  return s != 'completed' && s != 'cancelled';
                }).toList();

                if (activeOrScheduledTrips.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
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
                          'No Active Trips',
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
                          label: const Text('Publish a Trip'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeOrScheduledTrips.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final trip = activeOrScheduledTrips[index];
                    return Obx(() {
                      final bool isActive =
                          trip.status.value.toLowerCase() == 'active' ||
                          trip.status.value.toLowerCase() == 'in progress';
                      return Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFF86EFAC)
                                : AppColors.borderColor,
                            width: isActive ? 1.5 : 1.0,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF22C55E,
                                    ).withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFFDCFCE7)
                                        : const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isActive) ...[
                                        Container(
                                          width: 6.r,
                                          height: 6.r,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF16A34A),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        4.horizontalSpace,
                                      ],
                                      Text(
                                        isActive
                                            ? 'Active (In Progress)'
                                            : trip.status.value,
                                        style: AppTextStyle.text10Medium
                                            .copyWith(
                                              color: isActive
                                                  ? const Color(0xFF16A34A)
                                                  : AppColors.primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${trip.pricePerSeat.value.toStringAsFixed(0)} / seat',
                                  style: AppTextStyle.text14Semibold.copyWith(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              '${trip.from} → ${trip.to}',
                              style: AppTextStyle.text14Semibold.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              trip.time.value,
                              style: AppTextStyle.text12Regular.copyWith(
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: [
                                Text(
                                  'Booked: ${trip.bookedSeats.value}/${trip.totalSeats.value} seats',
                                  style: AppTextStyle.text12Semibold,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isActive) ...[
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            tripsController.openLiveTrip(trip),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF2563EB,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 6.h,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10.r,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(
                                          CupertinoIcons.location_fill,
                                          size: 13,
                                        ),
                                        label: Text(
                                          'Live Track',
                                          style: AppTextStyle.buttonText
                                              .copyWith(fontSize: 11.sp),
                                        ),
                                      ),
                                      6.horizontalSpace,
                                    ],
                                    if (trip.status.value.toLowerCase() == 'completed') ...[
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              CupertinoIcons.checkmark_seal_fill,
                                              color: Color(0xFF16A34A),
                                              size: 14,
                                            ),
                                            4.horizontalSpace,
                                            Text(
                                              'Completed',
                                              style: AppTextStyle.text12Semibold.copyWith(
                                                color: const Color(0xFF475569),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ] else ...[
                                      ElevatedButton(
                                        onPressed: () =>
                                            tripsController.toggleTripStatus(trip),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isActive
                                              ? const Color(0xFF16A34A)
                                              : AppColors.primaryColor,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 14.w,
                                            vertical: 6.h,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10.r,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          isActive ? 'End Ride' : 'Start Ride',
                                          style: AppTextStyle.buttonText.copyWith(
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),

                            // Passenger & Emergency Contact Details
                            if (trip.acceptedPassengers.isNotEmpty) ...[
                              12.verticalSpace,
                              const Divider(
                                color: AppColors.borderColor,
                                height: 1,
                              ),
                              10.verticalSpace,
                              ...trip.acceptedPassengers.map((p) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 12.r,
                                          backgroundColor: const Color(
                                            0xFFEFF6FF,
                                          ),
                                          child: Text(
                                            p.passengerName[0],
                                            style: AppTextStyle.text11Bold
                                                .copyWith(
                                                  color: AppColors.primaryColor,
                                                ),
                                          ),
                                        ),
                                        8.horizontalSpace,
                                        Expanded(
                                          child: Text(
                                            '${p.passengerName} (★ ${p.rating})',
                                            style: AppTextStyle.text12Semibold,
                                          ),
                                        ),
                                        Text(
                                          '${p.seats} seat',
                                          style: AppTextStyle.text12Medium
                                              .copyWith(
                                                color: AppColors
                                                    .secondaryTextColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                    8.verticalSpace,

                                    // EMERGENCY CONTACT: Visible only during active trips!
                                    if (isActive) ...[
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFFECACA),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              CupertinoIcons.shield_fill,
                                              color: Color(0xFFDC2626),
                                              size: 14,
                                            ),
                                            8.horizontalSpace,
                                            Expanded(
                                              child: Text(
                                                'Emergency: ${p.emergencyContactName}',
                                                style: AppTextStyle
                                                    .text12Semibold
                                                    .copyWith(
                                                      color: const Color(
                                                        0xFF991B1B,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            6.horizontalSpace,
                                            // Chat Passenger
                                            InkWell(
                                              onTap: () => tripsController
                                                  .openDriverChat(
                                                passenger: p,
                                                tripId: trip.id,
                                                route: '${trip.from} → ${trip.to}',
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              child: Container(
                                                padding: EdgeInsets.all(5.r),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFEFF6FF),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  CupertinoIcons
                                                      .chat_bubble_2_fill,
                                                  color: Color(0xFF2563EB),
                                                  size: 13,
                                                ),
                                              ),
                                            ),
                                            6.horizontalSpace,
                                            // Call Emergency Contact (Direct dialer)
                                            InkWell(
                                              onTap: () => Utils.launchCall(
                                                p.emergencyContactPhone,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w,
                                                  vertical: 4.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFDC2626,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        10.r,
                                                      ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      CupertinoIcons.phone_fill,
                                                      color: Colors.white,
                                                      size: 11,
                                                    ),
                                                    4.horizontalSpace,
                                                    Text(
                                                      'Call',
                                                      style: AppTextStyle
                                                          .text12Semibold
                                                          .copyWith(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ] else ...[
                                      // TRIP NOT ACTIVE: PRIVACY PROTECTED
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.lock_outline_rounded,
                                              color:
                                                  AppColors.secondaryTextColor,
                                              size: 13,
                                            ),
                                            6.horizontalSpace,
                                            Expanded(
                                              child: Text(
                                                'Emergency contact protected (Unlocks when ride starts)',
                                                style: AppTextStyle
                                                    .text10Regular
                                                    .copyWith(
                                                      color: AppColors
                                                          .secondaryTextColor,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              }),
                            ],
                          ],
                        ),
                      );
                    });
                  },
                );
              }),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyle.text16Semibold.copyWith(color: Colors.white),
        ),
        Text(
          label,
          style: AppTextStyle.text10Medium.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}
