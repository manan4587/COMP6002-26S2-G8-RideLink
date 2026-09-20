import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';
import 'package:ridelink/widgets/app_button.dart';
import 'package:ridelink/widgets/app_main_container.dart';

class PassengerSavedLocationsPage
    extends GetView<PassengerDashboardController> {
  const PassengerSavedLocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBgColor,
      body: AppMainContainer(
        alignment: AlignmentGeometry.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Navigation Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(
                            CupertinoIcons.back,
                            size: 22.sp,
                            color: AppColors.primaryTextColor,
                          ),
                          splashRadius: 22.r,
                        ),
                        Text(
                          'Saved Locations',
                          style: AppTextStyle.text18Semibold.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _showAddLocationDialog(context),
                      icon: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      splashRadius: 22.r,
                    ),
                  ],
                ),

                12.verticalSpace,

                // Quick Hint Banner
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.containerFillColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.placemark,
                          color: AppColors.primaryColor,
                          size: 18.sp,
                        ),
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instant Pickup & Drop-off',
                              style: AppTextStyle.text14Semibold.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            2.verticalSpace,
                            Text(
                              'Tap any saved location when searching for rides to autocomplete your origin or destination.',
                              style: AppTextStyle.text12Regular.copyWith(
                                color: AppColors.secondaryTextColor,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                18.verticalSpace,

                Text(
                  'Your Frequent Places',
                  style: AppTextStyle.text16Semibold.copyWith(
                    color: AppColors.primaryTextColor,
                  ),
                ),
                10.verticalSpace,

                // Reactive List of Saved Locations
                Obx(() {
                  if (controller.savedLocations.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(28.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            CupertinoIcons.location_slash,
                            size: 40.sp,
                            color: AppColors.secondaryTextColor,
                          ),
                          10.verticalSpace,
                          Text(
                            'No Saved Locations Yet',
                            style: AppTextStyle.text14Semibold,
                          ),
                          4.verticalSpace,
                          Text(
                            'Add your home, office, or university for quick 1-tap booking.',
                            style: AppTextStyle.text12Regular.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: controller.savedLocations.map((loc) {
                      return _LocationItemTile(
                        location: loc,
                        onDelete: () => controller.removeSavedLocation(loc.id),
                        onSelect: () {
                          controller.toLocationController.text = loc.address;
                          Get.back();
                          controller.switchTab(0);
                        },
                      );
                    }).toList(),
                  );
                }),

                20.verticalSpace,

                AppButton(
                  onPressed: () => _showAddLocationDialog(context),
                  label: '+ Add New Location',
                ),

                24.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddLocationDialog(BuildContext context) {
    final titleController = TextEditingController();
    final addressController = TextEditingController();
    String selectedCategory = 'home';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Container(
          padding: EdgeInsets.only(
            top: 12.h,
            left: 20.w,
            right: 20.w,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              16.verticalSpace,
              Text(
                'Add Saved Location',
                style: AppTextStyle.text18Semibold.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              4.verticalSpace,
              Text(
                'Bookmark a frequent pickup or drop-off spot',
                style: AppTextStyle.text12Regular.copyWith(
                  color: AppColors.secondaryTextColor,
                ),
              ),
              16.verticalSpace,

              // Category Selector Chips
              Row(
                children: [
                  _CategoryChip(
                    label: 'Home',
                    icon: CupertinoIcons.home,
                    isSelected: selectedCategory == 'home',
                    onTap: () => setState(() => selectedCategory = 'home'),
                  ),
                  8.horizontalSpace,
                  _CategoryChip(
                    label: 'Work',
                    icon: CupertinoIcons.briefcase,
                    isSelected: selectedCategory == 'work',
                    onTap: () => setState(() => selectedCategory = 'work'),
                  ),
                  8.horizontalSpace,
                  _CategoryChip(
                    label: 'Uni',
                    icon: CupertinoIcons.book,
                    isSelected: selectedCategory == 'university',
                    onTap: () =>
                        setState(() => selectedCategory = 'university'),
                  ),
                  8.horizontalSpace,
                  _CategoryChip(
                    label: 'Other',
                    icon: CupertinoIcons.placemark,
                    isSelected: selectedCategory == 'custom',
                    onTap: () => setState(() => selectedCategory = 'custom'),
                  ),
                ],
              ),
              14.verticalSpace,

              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Place Name (e.g. My Apartment, Monash Uni)',
                  labelStyle: AppTextStyle.text12Regular.copyWith(
                    color: AppColors.secondaryTextColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                ),
                style: AppTextStyle.text14Medium,
              ),
              12.verticalSpace,

              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Full Address or Landmark',
                  labelStyle: AppTextStyle.text12Regular.copyWith(
                    color: AppColors.secondaryTextColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                ),
                style: AppTextStyle.text14Medium,
              ),
              20.verticalSpace,

              AppButton(
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty &&
                      addressController.text.trim().isNotEmpty) {
                    controller.addSavedLocation(
                      title: titleController.text.trim(),
                      address: addressController.text.trim(),
                      category: selectedCategory,
                    );
                    Navigator.of(ctx).pop();
                  }
                },
                label: 'Save Place',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.containerFillColor,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.borderColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14.sp,
                color: isSelected ? Colors.white : AppColors.primaryTextColor,
              ),
              4.horizontalSpace,
              Text(
                label,
                style: AppTextStyle.text12Semibold.copyWith(
                  color: isSelected ? Colors.white : AppColors.primaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationItemTile extends StatelessWidget {
  final SavedLocationModel location;
  final VoidCallback onDelete;
  final VoidCallback onSelect;

  const _LocationItemTile({
    required this.location,
    required this.onDelete,
    required this.onSelect,
  });

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'home':
        return CupertinoIcons.home;
      case 'work':
        return CupertinoIcons.briefcase;
      case 'university':
        return CupertinoIcons.book;
      case 'gym':
        return CupertinoIcons.heart_fill;
      default:
        return CupertinoIcons.placemark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.containerFillColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForCategory(location.category),
              color: AppColors.primaryColor,
              size: 20.sp,
            ),
          ),
          12.horizontalSpace,
          Expanded(
            child: GestureDetector(
              onTap: onSelect,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.title,
                    style: AppTextStyle.text14Semibold.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  2.verticalSpace,
                  Text(
                    location.address,
                    style: AppTextStyle.text12Regular.copyWith(
                      color: AppColors.secondaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.secondaryTextColor,
              size: 18.sp,
            ),
            splashRadius: 18.r,
          ),
        ],
      ),
    );
  }
}
