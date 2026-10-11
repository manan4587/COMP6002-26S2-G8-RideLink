import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class HomePage extends GetView<PassengerDashboardController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBgColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () async {
            await Future.wait([
              controller.tripsController.reloadTrips(),
              controller.profileController.reloadProfile(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => controller.switchTab(4),
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
                                  color: AppColors.primaryColor
                                      .withValues(alpha: 0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                controller.passengerInitials,
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
                                    controller.passengerName.value.isNotEmpty
                                        ? controller.passengerName.value
                                        : (Preferences.userName.isNotEmpty
                                            ? Preferences.userName
                                            : 'Passenger'),
                                    style: AppTextStyle.text18Semibold,
                                  ),
                                ),
                              ],
                            ),
                            Obx(() {
                              final rating = controller.trustRating.value;
                              final ratingStr =
                                  rating > 0 ? rating.toStringAsFixed(1) : '5.0';
                              return Text(
                                'Passenger • $ratingStr ★',
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
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        CupertinoIcons.bell,
                        size: 20.sp,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Hero Card: Where are you going today?
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(22.w),
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
                    Text(
                      'Where are you going\ntoday?',
                      style: AppTextStyle.text24Semibold.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    12.verticalSpace,
                    Text(
                      'Search rides, check saved routes, or\njoin a community.',
                      style: AppTextStyle.text14Regular.copyWith(
                        color: AppColors.secondaryTextColor,
                        height: 1.35,
                      ),
                    ),
                    18.verticalSpace,
                    GestureDetector(
                      onTap: () =>
                          controller.switchTab(1), // Switch to Search tab
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF2563EB,
                              ).withValues(alpha: 0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.search,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                            8.horizontalSpace,
                            Text(
                              'Search Ride',
                              style: AppTextStyle.text14Semibold.copyWith(
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

              16.verticalSpace,

              // Top Stats Cards Row: Trust Rating & Recent routes
              Row(
                children: [
                  // Trust Rating Card
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.r),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFFBEB),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.star_outline_rounded,
                              color: const Color(0xFFF59E0B),
                              size: 20.sp,
                            ),
                          ),
                          10.horizontalSpace,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Trust Rating',
                                  style: AppTextStyle.text12Medium.copyWith(
                                    color: AppColors.secondaryTextColor,
                                  ),
                                ),
                                4.verticalSpace,
                                Obx(
                                  () => Row(
                                    children: [
                                      Text(
                                        (controller.trustRating.value > 0
                                                ? controller.trustRating.value
                                                : 5.0)
                                            .toStringAsFixed(1),
                                        style: AppTextStyle.text18Semibold
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      4.horizontalSpace,
                                      Icon(
                                        Icons.star,
                                        size: 15.sp,
                                        color: AppColors.primaryTextColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  12.horizontalSpace,

                  // Recent Routes Count Card
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.r),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.arrow_branch,
                              color: AppColors.primaryColor,
                              size: 18.sp,
                            ),
                          ),
                          10.horizontalSpace,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recent routes',
                                  style: AppTextStyle.text12Medium.copyWith(
                                    color: AppColors.secondaryTextColor,
                                  ),
                                ),
                                4.verticalSpace,
                                Obx(
                                  () => Text(
                                    '${controller.recentRoutes.length}',
                                    style: AppTextStyle.text18Semibold.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              20.verticalSpace,

              // Recent Routes Section
              Text(
                'Recent Routes',
                style: AppTextStyle.text16Semibold.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTextColor,
                ),
              ),
              12.verticalSpace,

              Obx(() {
                if (controller.recentRoutes.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'No recent routes yet',
                        style: AppTextStyle.text14Regular.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ),
                  );
                }
                return Column(
                  children: controller.recentRoutes.map((route) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _RecentRouteCard(
                        from: route.from,
                        to: route.to,
                        subtitle: route.subtitle,
                        onTap: () => controller.selectRecentRoute(route),
                      ),
                    );
                  }).toList(),
                );
              }),

              20.verticalSpace,

              // Nearby Communities Section
              Obx(() {
                if (controller.communities.isEmpty) {
                  return const SizedBox.shrink();
                }

                final curtin = controller.communities.first;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nearby Communities',
                      style: AppTextStyle.text16Semibold.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    12.verticalSpace,
                    Container(
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
                          onTap: () => controller.openCommunityDetails(curtin),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: curtin.iconBgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    curtin.icon,
                                    color: curtin.iconColor,
                                    size: 20.sp,
                                  ),
                                ),
                                14.horizontalSpace,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        curtin.name,
                                        style:
                                            AppTextStyle.text16Semibold.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      4.verticalSpace,
                                      Text(
                                        '${curtin.commonTime} • ${curtin.passengersCount.value} passengers • ${curtin.driversCount.value} drivers',
                                        style:
                                            AppTextStyle.text12Regular.copyWith(
                                          color: AppColors.secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.secondaryTextColor,
                                  size: 20.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
}

class _RecentRouteCard extends StatelessWidget {
  final String from;
  final String to;
  final String subtitle;
  final VoidCallback onTap;

  const _RecentRouteCard({
    required this.from,
    required this.to,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.arrow_branch,
                    color: AppColors.primaryColor,
                    size: 18.sp,
                  ),
                ),
                14.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            from,
                            style: AppTextStyle.text16Semibold.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.w),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                          Text(
                            to,
                            style: AppTextStyle.text16Semibold.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      4.verticalSpace,
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
          ),
        ),
      ),
    );
  }
}
