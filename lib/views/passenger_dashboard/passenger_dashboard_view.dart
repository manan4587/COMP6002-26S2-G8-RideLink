import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/pages/community_page.dart';
import 'package:ridelink/views/passenger_dashboard/pages/home_page.dart';
import 'package:ridelink/views/passenger_dashboard/pages/my_rides_page.dart';
import 'package:ridelink/views/passenger_dashboard/pages/profile_page.dart';
import 'package:ridelink/views/passenger_dashboard/pages/search_page.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class PassengerDashboardView extends GetView<PassengerDashboardController> {
  const PassengerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.reloadProfile();
    });

    final List<Widget> pages = const [
      HomePage(),
      SearchPage(),
      MyRidesPage(),
      CommunityPage(),
      ProfilePage(),
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
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavBarItem(
                    icon: CupertinoIcons.home,
                    activeIcon: CupertinoIcons.home,
                    label: 'Home',
                    isSelected: controller.currentTabIndex.value == 0,
                    onTap: () => controller.switchTab(0),
                  ),
                  _NavBarItem(
                    icon: CupertinoIcons.search,
                    activeIcon: CupertinoIcons.search,
                    label: 'Search',
                    isSelected: controller.currentTabIndex.value == 1,
                    onTap: () => controller.switchTab(1),
                  ),
                  _NavBarItem(
                    icon: CupertinoIcons.car,
                    activeIcon: CupertinoIcons.car,
                    label: 'Trips',
                    isSelected: controller.currentTabIndex.value == 2,
                    onTap: () => controller.switchTab(2),
                  ),
                  _NavBarItem(
                    icon: CupertinoIcons.person_2,
                    activeIcon: CupertinoIcons.person_2,
                    label: 'Community',
                    isSelected: controller.currentTabIndex.value == 3,
                    onTap: () => controller.switchTab(3),
                  ),
                  _NavBarItem(
                    icon: CupertinoIcons.person,
                    activeIcon: CupertinoIcons.person,
                    label: 'Profile',
                    isSelected: controller.currentTabIndex.value == 4,
                    onTap: () => controller.switchTab(4),
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

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12.w : 8.w,
          vertical: 4.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20.sp,
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.secondaryTextColor,
            ),
            SizedBox(height: 3.h),
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
      ),
    );
  }
}
