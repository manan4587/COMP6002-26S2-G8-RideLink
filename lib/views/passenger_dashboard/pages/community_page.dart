import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PassengerDashboardController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Commuter Communities',
                style: AppTextStyle.text20Semibold.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryTextColor,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Connect with verified passengers & drivers along your regular route.',
                style: AppTextStyle.text14Regular.copyWith(
                  color: AppColors.secondaryTextColor,
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
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    icon: Icon(
                      CupertinoIcons.search,
                      size: 18.sp,
                      color: AppColors.secondaryTextColor,
                    ),
                    hintText:
                        'Search communities (e.g. Curtin, Monash, CBD)...',
                    hintStyle: AppTextStyle.text14Regular.copyWith(
                      color: AppColors.hintTextColor,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 18.h),

              // Communities List
              Obx(() {
                if (controller.isCommunitiesLoading.value &&
                    controller.communities.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 48.h),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  );
                }

                final filtered = controller.communities.where((c) {
                  if (_searchQuery.isEmpty) return true;
                  return c.name.toLowerCase().contains(_searchQuery) ||
                      c.routeSummary.toLowerCase().contains(_searchQuery) ||
                      c.description.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: Column(
                        children: [
                          Icon(
                            CupertinoIcons.search,
                            size: 40.sp,
                            color: AppColors.secondaryTextColor,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'No communities found',
                            style: AppTextStyle.text16Semibold,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => SizedBox(height: 14.h),
                  itemBuilder: (context, index) {
                    final community = filtered[index];
                    return _CommunityCard(
                      community: community,
                      onTap: () => controller.openCommunityDetails(community),
                      onToggleJoin: () {
                        if (community.isJoined.value) {
                          controller.confirmLeaveCommunity(community);
                        } else {
                          controller.toggleCommunityJoin(community);
                        }
                      },
                    );
                  },
                );
              }),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final CommunityModel community;
  final VoidCallback onTap;
  final VoidCallback onToggleJoin;

  const _CommunityCard({
    required this.community,
    required this.onTap,
    required this.onToggleJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
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
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  community.name,
                                  style: AppTextStyle.text16Semibold.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: const Color(0xFF94A3B8),
                                size: 20.sp,
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            community.routeSummary,
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                Text(
                  community.description,
                  style: AppTextStyle.text12Regular.copyWith(
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),

                SizedBox(height: 14.h),

                // Metrics Row: Passengers, Drivers, Next Ride
                Row(
                  children: [
                    // Passenger badge
                    Obx(
                      () => _MetricPill(
                        icon: CupertinoIcons.person_fill,
                        label: '${community.passengersCount.value} Passengers',
                        color: const Color(0xFF2563EB),
                        bgColor: const Color(0xFFEFF6FF),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Drivers badge
                    Obx(
                      () => _MetricPill(
                        icon: CupertinoIcons.car_detailed,
                        label: '${community.driversCount.value} Drivers',
                        color: const Color(0xFF0284C7),
                        bgColor: const Color(0xFFF0F9FF),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                // Action Buttons Row: View Community Details & Quick Join Toggle
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                        ),
                        child: Text(
                          'View Details',
                          style: AppTextStyle.text12Semibold.copyWith(
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: onToggleJoin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: community.isJoined.value
                                ? const Color(0xFFFEF2F2)
                                : const Color(0xFF2563EB),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(
                                color: community.isJoined.value
                                    ? const Color(0xFFFECACA)
                                    : const Color(0xFF2563EB),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                          ),
                          child: Text(
                            community.isJoined.value
                                ? 'Leave'
                                : 'Join Group',
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: community.isJoined.value
                                  ? const Color(0xFFDC2626)
                                  : Colors.white,
                            ),
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
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _MetricPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTextStyle.text10Medium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
