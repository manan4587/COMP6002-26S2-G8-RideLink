import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/theme/app_text_style.dart';

class CommunityItem {
  final String name;
  final String description;
  final int memberCount;
  final int dailyRides;
  final IconData icon;
  bool isJoined;

  CommunityItem({
    required this.name,
    required this.description,
    required this.memberCount,
    required this.dailyRides,
    required this.icon,
    this.isJoined = false,
  });
}

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final List<CommunityItem> _communities = [
    CommunityItem(
      name: 'Monash University Clayton Carpool',
      description: 'Daily rides between Clayton campus and Eastern suburbs.',
      memberCount: 480,
      dailyRides: 24,
      icon: Icons.school_outlined,
      isJoined: true,
    ),
    CommunityItem(
      name: 'Melbourne CBD Corporate Commuters',
      description: 'City workers carpooling during peak morning & evening hours.',
      memberCount: 1250,
      dailyRides: 68,
      icon: Icons.business_outlined,
      isJoined: false,
    ),
    CommunityItem(
      name: 'Geelong ⇄ Melbourne Commuters',
      description: 'Long-distance highway shared rides along Princes Freeway.',
      memberCount: 390,
      dailyRides: 16,
      icon: Icons.alt_route_outlined,
      isJoined: false,
    ),
    CommunityItem(
      name: 'Deakin Uni Burwood Students',
      description: 'Cost-friendly rides for university students & staff.',
      memberCount: 310,
      dailyRides: 12,
      icon: Icons.menu_book_outlined,
      isJoined: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Commuter Communities', style: AppTextStyle.text20Semibold),
              SizedBox(height: 6.h),
              Text(
                'Join local groups to split costs and find regular rides.',
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
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(
                      CupertinoIcons.search,
                      size: 18.sp,
                      color: AppColors.secondaryTextColor,
                    ),
                    hintText: 'Search groups (e.g. Uni, Workplace)...',
                    hintStyle: AppTextStyle.text14Regular.copyWith(
                      color: AppColors.hintTextColor,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Communities List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _communities.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final group = _communities[index];
                  return Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEFF6FF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                group.icon,
                                color: AppColors.primaryColor,
                                size: 22.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group.name,
                                    style: AppTextStyle.text14Semibold,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    '${group.memberCount} members • ${group.dailyRides} daily rides',
                                    style: AppTextStyle.text10Medium.copyWith(
                                      color: AppColors.secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          group.description,
                          style: AppTextStyle.text12Regular.copyWith(
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  group.isJoined = !group.isJoined;
                                });
                                if (group.isJoined) {
                                  AppSnackBar.success(
                                    message: 'Joined ${group.name} successfully!',
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: group.isJoined
                                    ? AppColors.containerFillColor
                                    : AppColors.primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  side: BorderSide(
                                    color: group.isJoined
                                        ? AppColors.borderColor
                                        : AppColors.primaryColor,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                              ),
                              child: Text(
                                group.isJoined ? 'Joined ✓' : 'Join Group',
                                style: AppTextStyle.text12Semibold.copyWith(
                                  color: group.isJoined
                                      ? AppColors.primaryColor
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
