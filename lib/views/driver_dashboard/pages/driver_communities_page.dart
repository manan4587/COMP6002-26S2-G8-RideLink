import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/data/models/passenger/passenger_models.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_community_controller.dart';

class DriverCommunitiesPage extends StatefulWidget {
  const DriverCommunitiesPage({super.key});

  @override
  State<DriverCommunitiesPage> createState() => _DriverCommunitiesPageState();
}

class _DriverCommunitiesPageState extends State<DriverCommunitiesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<DriverCommunityController>()
        ? Get.find<DriverCommunityController>()
        : Get.put<DriverCommunityController>(DriverCommunityController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              Center(
                child: Text(
                  'Driver Communities',
                  style: AppTextStyle.text20Semibold.copyWith(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryTextColor,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Center(
                child: Text(
                  'Connect with verified drivers sharing regular commuter corridors.',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.text12Regular.copyWith(
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Search Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    controller.searchQuery.value = val;
                  },
                  decoration: InputDecoration(
                    icon: Icon(
                      CupertinoIcons.search,
                      size: 18.sp,
                      color: AppColors.secondaryTextColor,
                    ),
                    hintText:
                        'Search corridors (e.g. Curtin, Joondalup, CBD)...',
                    hintStyle: AppTextStyle.text14Regular.copyWith(
                      color: AppColors.hintTextColor,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.communities.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
                  }

                  final list = controller.filteredCommunities;

                  if (list.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.search,
                              size: 40.sp,
                              color: AppColors.secondaryTextColor,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'No driver communities found',
                              style: AppTextStyle.text16Semibold,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => SizedBox(height: 14.h),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return _DriverCommunityCard(
                        community: item,
                        onToggleJoin: () => controller.toggleCommunityJoin(item),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverCommunityCard extends StatelessWidget {
  final CommunityModel community;
  final VoidCallback onToggleJoin;

  const _DriverCommunityCard({
    required this.community,
    required this.onToggleJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isJoined = community.isJoined.value;
      return Container(
        padding: EdgeInsets.all(16.w),
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
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    community.icon,
                    color: const Color(0xFF2563EB),
                    size: 20.sp,
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        community.name,
                        style: AppTextStyle.text16Semibold.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      4.verticalSpace,
                      Text(
                        community.routeSummary,
                        style: AppTextStyle.text12Regular.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      4.verticalSpace,
                      Text(
                        'Peak Hours: ${community.commonTime}',
                        style: AppTextStyle.text12Regular.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (community.description.isNotEmpty) ...[
              10.verticalSpace,
              Text(
                community.description,
                style: AppTextStyle.text12Regular.copyWith(
                  color: const Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
            ],

            14.verticalSpace,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${community.driversCount.value} Drivers • ${community.passengersCount.value} Passengers',
                  style: AppTextStyle.text12Semibold.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                OutlinedButton(
                  onPressed: onToggleJoin,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isJoined
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF2563EB),
                      width: 1.2,
                    ),
                    backgroundColor: isJoined
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFFEFF6FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                  ),
                  child: Text(
                    isJoined ? 'Joined ✓' : 'Join Network',
                    style: AppTextStyle.text12Semibold.copyWith(
                      color: isJoined
                          ? const Color(0xFF475569)
                          : const Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
