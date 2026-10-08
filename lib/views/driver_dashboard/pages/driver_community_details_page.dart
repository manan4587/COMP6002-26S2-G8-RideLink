import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/data/models/firestore/trip_model.dart';
import 'package:ridelink/data/services/community_service.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_community_controller.dart';

class DriverCommunityDetailsPage extends StatelessWidget {
  const DriverCommunityDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<DriverCommunityController>()
        ? Get.find<DriverCommunityController>()
        : Get.put(DriverCommunityController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Obx(() {
          final community =
              controller.selectedCommunity.value ??
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
                    onPressed: () => Get.back(),
                    child: const Text('Back'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header with Back Button and Title
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
                      community.name,
                      style: AppTextStyle.text18Semibold.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Scrollable Details
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Corridor Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(22.r),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 14,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
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
                                size: 28.sp,
                              ),
                            ),
                            12.verticalSpace,
                            Text(
                              community.name,
                              style: AppTextStyle.text20Semibold.copyWith(
                                fontSize: 21.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                              textAlign: TextAlign.center,
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
                            8.verticalSpace,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.map_pin_ellipse,
                                    size: 14.sp,
                                    color: const Color(0xFF2563EB),
                                  ),
                                  6.horizontalSpace,
                                  Flexible(
                                    child: Text(
                                      community.routeSummary,
                                      style: AppTextStyle.text12Semibold
                                          .copyWith(
                                            color: const Color(0xFF2563EB),
                                            fontWeight: FontWeight.w600,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
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

                      14.verticalSpace,

                      // Stats Row: Drivers & Passengers
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: CupertinoIcons.person_badge_plus,
                              label: 'Verified Drivers',
                              countObs: community.driversCount,
                              iconColor: const Color(0xFF2563EB),
                              bgColor: const Color(0xFFEFF6FF),
                            ),
                          ),
                          12.horizontalSpace,
                          Expanded(
                            child: _StatCard(
                              icon: CupertinoIcons.person_2_fill,
                              label: 'Commuters',
                              countObs: community.passengersCount,
                              iconColor: const Color(0xFF0284C7),
                              bgColor: const Color(0xFFF0F9FF),
                            ),
                          ),
                        ],
                      ),

                      18.verticalSpace,

                      // CREATE RIDE FOR COMMUNITY CALL-TO-ACTION (Prominent Gradient Card)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(18.w),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1E40AF),
                              Color(0xFF2563EB),
                              Color(0xFF38BDF8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF2563EB,
                              ).withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 5),
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
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    CupertinoIcons.arrow_up_right_circle_fill,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                ),
                                10.horizontalSpace,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Offer Ride in ${community.name}',
                                        style: AppTextStyle.text14Semibold
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                      ),
                                      2.verticalSpace,
                                      Text(
                                        'Verified community members get priority.',
                                        style: AppTextStyle.text10Medium
                                            .copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.85,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            14.verticalSpace,
                            SizedBox(
                              width: double.infinity,
                              height: 46.h,
                              child: ElevatedButton.icon(
                                onPressed: () => controller
                                    .createRideForCommunity(community),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF1D4ED8),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                                icon: const Icon(
                                  CupertinoIcons.plus_circle_fill,
                                  size: 18,
                                  color: Color(0xFF1D4ED8),
                                ),
                                label: Text(
                                  'Create Ride for this Community',
                                  style: AppTextStyle.text14Semibold.copyWith(
                                    color: const Color(0xFF1D4ED8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      18.verticalSpace,

                      // Community Corridor Benefits
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Corridor Guidelines & Perks',
                              style: AppTextStyle.text14Semibold.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            10.verticalSpace,
                            _BenefitRow(
                              icon: CupertinoIcons.checkmark_shield_fill,
                              color: const Color(0xFF10B981),
                              text:
                                  'Verified university students & institutional commuters only',
                            ),
                            8.verticalSpace,
                            _BenefitRow(
                              icon: CupertinoIcons.arrow_merge,
                              color: const Color(0xFF2563EB),
                              text:
                                  'Direct corridor routing along ${community.routeSummary}',
                            ),
                            8.verticalSpace,
                            _BenefitRow(
                              icon: CupertinoIcons.sparkles,
                              color: const Color(0xFFF59E0B),
                              text:
                                  'Priority carpool lane transit & subsidized commuter fuel sharing',
                            ),
                          ],
                        ),
                      ),

                      18.verticalSpace,

                      // Active Rides in this Community (Real-Time Stream)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active Community Rides',
                            style: AppTextStyle.text14Semibold.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            community.name,
                            style: AppTextStyle.text12Medium.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      8.verticalSpace,

                      StreamBuilder<List<TripModel>>(
                        stream: CommunityService.instance.streamCommunityTrips(
                          community.name,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            );
                          }

                          final trips = snapshot.data ?? [];

                          if (trips.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(18.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    community.icon,
                                    size: 32.sp,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  8.verticalSpace,
                                  Text(
                                    'No upcoming rides yet in ${community.name}',
                                    style: AppTextStyle.text12Semibold.copyWith(
                                      color: const Color(0xFF475569),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  4.verticalSpace,
                                  Text(
                                    'Be the first to publish a ride along this corridor!',
                                    style: AppTextStyle.text10Medium.copyWith(
                                      color: const Color(0xFF64748B),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: trips.length,
                            separatorBuilder: (_, _) => SizedBox(height: 10.h),
                            itemBuilder: (context, idx) {
                              final trip = trips[idx];
                              return Container(
                                padding: EdgeInsets.all(14.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8.r),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEFF6FF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        community.icon,
                                        size: 16.sp,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    10.horizontalSpace,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${trip.originName} → ${trip.destinationName}',
                                            style: AppTextStyle.text12Semibold
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(
                                                    0xFF0F172A,
                                                  ),
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          2.verticalSpace,
                                          Text(
                                            '${trip.departureTimeString} • Driver: ${trip.driverName}',
                                            style: AppTextStyle.text10Medium
                                                .copyWith(
                                                  color: const Color(
                                                    0xFF64748B,
                                                  ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    10.horizontalSpace,
                                    Text(
                                      '\$${trip.pricePerSeat.toStringAsFixed(2)}',
                                      style: AppTextStyle.text14Semibold
                                          .copyWith(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),

                      20.verticalSpace,

                      // Network Membership Button & State
                      Obx(() {
                        final isJoined = community.isJoined.value;
                        if (isJoined) {
                          return Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: const Color(0xFFA7F3D0),
                                  ),
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
                                      'You are a member of this driver corridor',
                                      style: AppTextStyle.text14Medium.copyWith(
                                        color: const Color(0xFF047857),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              12.verticalSpace,
                              OutlinedButton.icon(
                                onPressed: () => controller
                                    .confirmLeaveCommunity(context, community),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFFFECACA),
                                  ),
                                  minimumSize: Size(double.infinity, 48.h),
                                  backgroundColor: const Color(0xFFFEF2F2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.exit_to_app_rounded,
                                  size: 18,
                                  color: Color(0xFFDC2626),
                                ),
                                label: Text(
                                  'Leave Driver Network',
                                  style: AppTextStyle.text14Semibold.copyWith(
                                    color: const Color(0xFFDC2626),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return ElevatedButton.icon(
                          onPressed: () => controller.joinCommunity(community),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: Size(double.infinity, 50.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          icon: Icon(
                            CupertinoIcons.person_badge_plus,
                            size: 18.sp,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Join Driver Network',
                            style: AppTextStyle.text14Semibold.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),

                      24.verticalSpace,
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final RxInt countObs;
  final Color iconColor;
  final Color bgColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.countObs,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
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
                padding: EdgeInsets.all(7.r),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 15.sp, color: iconColor),
              ),
              8.horizontalSpace,
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyle.text12Medium.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          10.verticalSpace,
          Obx(
            () => Text(
              '${countObs.value}',
              style: AppTextStyle.text20Semibold.copyWith(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _BenefitRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15.sp, color: color),
        8.horizontalSpace,
        Expanded(
          child: Text(
            text,
            style: AppTextStyle.text12Regular.copyWith(
              color: const Color(0xFF475569),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
