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
    final controller = Get.isRegistered<DriverCommunityController>()
        ? Get.find<DriverCommunityController>()
        : Get.put<DriverCommunityController>(DriverCommunityController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h),
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
              SizedBox(height: 14.h),

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
                        'Search corridors (e.g. Curtin, Stadium, CBD)...',
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

              SizedBox(height: 14.h),

              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: () async {
                    await controller.reloadCommunities();
                  },
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.communities.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }

                    final list = controller.filteredCommunities.where((c) {
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

                    if (list.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        children: [
                          Padding(
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
                                if (_selectedCategory != 'All' ||
                                    controller.searchQuery.value.isNotEmpty) ...[
                                  SizedBox(height: 8.h),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedCategory = 'All';
                                        controller.searchQuery.value = '';
                                        _searchController.clear();
                                      });
                                    },
                                    child: const Text('Reset Filters'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => SizedBox(height: 14.h),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return _DriverCommunityCard(
                        community: item,
                        onTap: () => controller.openCommunityDetails(item),
                        onJoin: () => controller.joinCommunity(item),
                        onCreateRide: () =>
                            controller.createRideForCommunity(item),
                        onLeave: () =>
                            controller.confirmLeaveCommunity(context, item),
                      );
                    },
                  );
                }),
              ),
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
  final VoidCallback onTap;
  final VoidCallback onJoin;
  final VoidCallback onCreateRide;
  final VoidCallback onLeave;

  const _DriverCommunityCard({
    required this.community,
    required this.onTap,
    required this.onJoin,
    required this.onCreateRide,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isJoined = community.isJoined.value;
      return Container(
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
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22.r),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      12.horizontalSpace,
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
                            4.verticalSpace,
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
                                    style: AppTextStyle.text12Regular.copyWith(
                                      color: const Color(0xFF64748B),
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

                  12.verticalSpace,

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
                                'Next Trip: ',
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

                  12.verticalSpace,

                  // Metrics Row (NO car icon, using driver badge icon)
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.person_badge_plus,
                              size: 12.sp,
                              color: const Color(0xFF0284C7),
                            ),
                            4.horizontalSpace,
                            Text(
                              '${community.driversCount.value} Verified Drivers',
                              style: AppTextStyle.text10Medium.copyWith(
                                color: const Color(0xFF0284C7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      8.horizontalSpace,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.person_fill,
                              size: 12.sp,
                              color: const Color(0xFF2563EB),
                            ),
                            4.horizontalSpace,
                            Text(
                              '${community.passengersCount.value} Commuters',
                              style: AppTextStyle.text10Medium.copyWith(
                                color: const Color(0xFF2563EB),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  14.verticalSpace,

                  // Action Buttons Row: View Details & Quick Join / Offer Ride
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onTap,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
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
                      10.horizontalSpace,
                      Expanded(
                        child: isJoined
                            ? Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: onCreateRide,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF16A34A),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14.r),
                                        ),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8.h),
                                      ),
                                      icon: const Icon(
                                        CupertinoIcons.plus_circle,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        'Offer Ride',
                                        style:
                                            AppTextStyle.text12Semibold.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  6.horizontalSpace,
                                  IconButton(
                                    tooltip: 'Leave Community',
                                    onPressed: onLeave,
                                    icon: const Icon(
                                      Icons.exit_to_app_rounded,
                                      size: 18,
                                      color: Color(0xFFDC2626),
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFFFEF2F2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        side: const BorderSide(
                                          color: Color(0xFFFECACA),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ElevatedButton.icon(
                                onPressed: onJoin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
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
    });
  }
}
