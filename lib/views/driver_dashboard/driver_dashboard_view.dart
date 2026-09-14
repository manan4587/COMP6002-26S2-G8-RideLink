import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_controller.dart';
import 'package:ridelink/views/driver_dashboard/pages/create_ride_page.dart';
import 'package:ridelink/views/driver_dashboard/pages/driver_home_page.dart';
import 'package:ridelink/views/driver_dashboard/pages/driver_profile_page.dart';
import 'package:ridelink/views/driver_dashboard/pages/driver_requests_page.dart';

class DriverDashboardView extends GetView<DriverDashboardController> {
  const DriverDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = const [
      DriverHomePage(),
      CreateRidePage(),
      DriverRequestsPage(),
      DriverProfilePage(),
    ];

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentTabIndex.value,
          children: pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(
              top: BorderSide(color: AppColors.borderColor, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _DriverNavBarItem(
                    icon: CupertinoIcons.car_detailed,
                    activeIcon: CupertinoIcons.car_detailed,
                    label: 'Trips',
                    isSelected: controller.currentTabIndex.value == 0,
                    onTap: () => controller.switchTab(0),
                  ),
                  _DriverNavBarItem(
                    icon: CupertinoIcons.plus_circle,
                    activeIcon: CupertinoIcons.plus_circle_fill,
                    label: 'Publish',
                    isSelected: controller.currentTabIndex.value == 1,
                    onTap: () => controller.switchTab(1),
                  ),
                  _DriverNavBarItem(
                    icon: CupertinoIcons.person_2,
                    activeIcon: CupertinoIcons.person_2_fill,
                    label: 'Requests',
                    isSelected: controller.currentTabIndex.value == 2,
                    badgeCount: controller.pendingRequests.length,
                    onTap: () => controller.switchTab(2),
                  ),
                  _DriverNavBarItem(
                    icon: CupertinoIcons.person,
                    activeIcon: CupertinoIcons.person_fill,
                    label: 'Profile',
                    isSelected: controller.currentTabIndex.value == 3,
                    onTap: () => controller.switchTab(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DriverNavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final int? badgeCount;
  final VoidCallback onTap;

  const _DriverNavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 22.sp,
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.secondaryTextColor,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: AppTextStyle.text10Medium.copyWith(
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.secondaryTextColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              right: -6.w,
              top: -4.h,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
