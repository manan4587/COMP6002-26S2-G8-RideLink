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
  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    'Joined',
    'Residential',
    'Stadium & Events',
    'Campus & Uni',
    'CBD & Work',
    'Healthcare',
  ];

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
        child: RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () async {
            await controller.communityController.reloadCommunities();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
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
                        'Search communities (e.g. Curtin, Stadium, CBD)...',
                    hintStyle: AppTextStyle.text14Regular.copyWith(
                      color: AppColors.hintTextColor,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 7.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : const Color(0xFFCBD5E1),
                              width: 1.1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryColor
                                          .withValues(alpha: 0.25),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            cat,
                            style: AppTextStyle.text11Medium.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primaryTextColor,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
                  final matchesQuery = _searchQuery.isEmpty ||
                      c.name.toLowerCase().contains(_searchQuery) ||
                      c.routeSummary.toLowerCase().contains(_searchQuery) ||
                      c.description.toLowerCase().contains(_searchQuery);
                  if (!matchesQuery) return false;

                  if (_selectedCategory == 'Joined') return c.isJoined.value;
                  if (_selectedCategory == 'Residential') {
                    return c.iconType == 'home';
                  }
                  if (_selectedCategory == 'Stadium & Events') {
                    return c.iconType == 'stadium';
                  }
                  if (_selectedCategory == 'Campus & Uni') {
                    return c.iconType == 'school';
                  }
                  if (_selectedCategory == 'CBD & Work') {
                    return c.iconType == 'business';
                  }
                  if (_selectedCategory == 'Healthcare') {
                    return c.iconType == 'hospital';
                  }
                  return true;
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
                          if (_selectedCategory != 'All' ||
                              _searchQuery.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                  _selectedCategory = 'All';
                                });
                              },
                              child: const Text('Reset Filters'),
                            ),
                          ],
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
                      onJoin: () => controller.joinCommunity(community),
                      onLeave: () => controller.confirmLeaveCommunity(context, community),
                    );
                  },
                );
              }),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final CommunityModel community;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const _CommunityCard({
    required this.community,
    required this.onTap,
    required this.onJoin,
    required this.onLeave,
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
                // Top Header Row with Icon and Category Tag
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: community.iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        community.icon,
                        color: community.iconColor,
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
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: community.iconBgColor,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  community.categoryLabel,
                                  style: AppTextStyle.text10Medium.copyWith(
                                    color: community.iconColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.map_pin_ellipse,
                                size: 13.sp,
                                color: const Color(0xFF2563EB),
                              ),
                              4.horizontalSpace,
                              Expanded(
                                child: Text(
                                  community.routeSummary,
                                  style: AppTextStyle.text12Semibold.copyWith(
                                    color: const Color(0xFF2563EB),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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

                SizedBox(height: 12.h),

                // Dedicated Commute Timing Container
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.clock,
                            size: 14.sp,
                            color: const Color(0xFF2563EB),
                          ),
                          6.horizontalSpace,
                          Text(
                            'Peak Commute: ',
                            style: AppTextStyle.text11Medium.copyWith(
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              community.commonTime,
                              style: AppTextStyle.text11Medium.copyWith(
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (community.recurringOption.isNotEmpty) ...[
                        6.verticalSpace,
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.repeat,
                              size: 14.sp,
                              color: const Color(0xFF7C3AED),
                            ),
                            6.horizontalSpace,
                            Text(
                              'Cadence: ',
                              style: AppTextStyle.text11Medium.copyWith(
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                community.recurringOption,
                                style: AppTextStyle.text11Medium.copyWith(
                                  color: const Color(0xFF6D28D9),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (community.nextRideTime.isNotEmpty) ...[
                        6.verticalSpace,
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.calendar,
                              size: 14.sp,
                              color: const Color(0xFF059669),
                            ),
                            6.horizontalSpace,
                            Text(
                              'Next Ride: ',
                              style: AppTextStyle.text11Medium.copyWith(
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${community.nextRideTime} (${community.nextRideSeatsOpen} seats open)',
                                style: AppTextStyle.text11Medium.copyWith(
                                  color: const Color(0xFF059669),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (community.hasFixedTerminal) ...[
                        6.verticalSpace,
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.placemark,
                              size: 14.sp,
                              color: const Color(0xFFD97706),
                            ),
                            6.horizontalSpace,
                            Text(
                              community.isFixedDropOff
                                  ? 'Fixed Drop-off: '
                                  : 'Fixed Terminal: ',
                              style: AppTextStyle.text11Medium.copyWith(
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                community.fixedTerminalLabel,
                                style: AppTextStyle.text11Medium.copyWith(
                                  color: const Color(0xFF92400E),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // Metrics Row: Passengers & Verified Drivers (Removed Car icon)
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
                    // Drivers badge (using badge icon instead of car)
                    Obx(
                      () => _MetricPill(
                        icon: CupertinoIcons.person_badge_plus,
                        label: '${community.driversCount.value} Verified Drivers',
                        color: const Color(0xFF0284C7),
                        bgColor: const Color(0xFFF0F9FF),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                // Action Buttons Row: View Community Details & Quick Join
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
                      child: Obx(() {
                        final isJoined = community.isJoined.value;
                        if (isJoined) {
                          return OutlinedButton.icon(
                            onPressed: onLeave,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFA7F3D0),
                                width: 1.2,
                              ),
                              backgroundColor: const Color(0xFFECFDF5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                            ),
                            icon: const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: Color(0xFF059669),
                            ),
                            label: Text(
                              'Joined',
                              style: AppTextStyle.text12Semibold.copyWith(
                                color: const Color(0xFF059669),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }

                        return ElevatedButton.icon(
                          onPressed: onJoin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                          ),
                          icon: const Icon(
                            CupertinoIcons.person_badge_plus,
                            size: 15,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Join Group',
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
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
