import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/data/services/google_places_service.dart';
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
                          controller.toLat.value = loc.latitude;
                          controller.toLng.value = loc.longitude;
                          Get.back();
                          controller.switchTab(1); // Jump to Search tab
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _AddSavedLocationSheet(controller: controller),
    );
  }
}

class _AddSavedLocationSheet extends StatefulWidget {
  final PassengerDashboardController controller;

  const _AddSavedLocationSheet({required this.controller});

  @override
  State<_AddSavedLocationSheet> createState() => _AddSavedLocationSheetState();
}

class _AddSavedLocationSheetState extends State<_AddSavedLocationSheet> {
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _addressFocusNode = FocusNode();

  String _selectedCategory = 'home';
  double? _selectedLat;
  double? _selectedLng;
  List<PlacePrediction> _predictions = [];
  bool _isSearching = false;
  bool _isSaving = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _addressController.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  void _onAddressChanged(String query) {
    _debounceTimer?.cancel();
    _selectedLat = null;
    _selectedLng = null;

    final trimmed = query.trim();
    if (trimmed.length < 2) {
      if (mounted) {
        setState(() {
          _predictions = [];
          _isSearching = false;
        });
      }
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      setState(() => _isSearching = true);
      try {
        final results = await GooglePlacesService.instance.searchPlaces(trimmed);
        if (mounted) {
          setState(() {
            _predictions = results;
            _isSearching = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _predictions = [];
            _isSearching = false;
          });
        }
      }
    });
  }

  Future<void> _selectPrediction(PlacePrediction prediction) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _predictions = [];
      _isSearching = true;
    });

    try {
      final details = await GooglePlacesService.instance.getPlaceDetails(prediction.placeId);
      if (mounted) {
        setState(() {
          _isSearching = false;
          if (details != null) {
            _addressController.text = details.formattedAddress.isNotEmpty
                ? details.formattedAddress
                : prediction.fullText;
            _selectedLat = details.latitude;
            _selectedLng = details.longitude;
            if (_titleController.text.trim().isEmpty) {
              _titleController.text = details.displayName.isNotEmpty
                  ? details.displayName
                  : prediction.primaryText;
            }
          } else {
            _addressController.text = prediction.fullText;
            if (_titleController.text.trim().isEmpty) {
              _titleController.text = prediction.primaryText;
            }
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _addressController.text = prediction.fullText;
        });
      }
    }
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final address = _addressController.text.trim();

    if (title.isEmpty) {
      AppSnackBar.error(message: 'Please enter a name for this place');
      return;
    }
    if (address.isEmpty) {
      AppSnackBar.error(message: 'Please search and select an address');
      return;
    }

    setState(() => _isSaving = true);

    double lat = _selectedLat ?? 0.0;
    double lng = _selectedLng ?? 0.0;

    if (lat == 0.0 && lng == 0.0) {
      final geocoded = await GooglePlacesService.instance.getCoordinatesForAddress(address);
      if (geocoded != null) {
        lat = geocoded.latitude;
        lng = geocoded.longitude;
      }
    }

    if (!mounted) return;
    Get.back();
    Future.delayed(const Duration(milliseconds: 250), () {
      widget.controller.addSavedLocation(
        title: title,
        address: address,
        category: _selectedCategory,
        latitude: lat,
        longitude: lng,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.w,
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
                  isSelected: _selectedCategory == 'home',
                  onTap: () => setState(() => _selectedCategory = 'home'),
                ),
                8.horizontalSpace,
                _CategoryChip(
                  label: 'Work',
                  icon: CupertinoIcons.briefcase,
                  isSelected: _selectedCategory == 'work',
                  onTap: () => setState(() => _selectedCategory = 'work'),
                ),
                8.horizontalSpace,
                _CategoryChip(
                  label: 'Uni',
                  icon: CupertinoIcons.book,
                  isSelected: _selectedCategory == 'university',
                  onTap: () => setState(() => _selectedCategory = 'university'),
                ),
                8.horizontalSpace,
                _CategoryChip(
                  label: 'Other',
                  icon: CupertinoIcons.placemark,
                  isSelected: _selectedCategory == 'custom',
                  onTap: () => setState(() => _selectedCategory = 'custom'),
                ),
              ],
            ),
            14.verticalSpace,

            // Address Search Field with Autocomplete
            TextField(
              controller: _addressController,
              focusNode: _addressFocusNode,
              onChanged: _onAddressChanged,
              decoration: InputDecoration(
                labelText: 'Search Address or Landmark',
                hintText: 'e.g. Flinders Street Station, Melbourne',
                prefixIcon: const Icon(
                  CupertinoIcons.search,
                  color: AppColors.secondaryTextColor,
                  size: 20,
                ),
                suffixIcon: _isSearching
                    ? Transform.scale(
                        scale: 0.6,
                        child: const CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : _addressController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              CupertinoIcons.clear_circled_solid,
                              color: AppColors.secondaryTextColor,
                              size: 18,
                            ),
                            onPressed: () {
                              _addressController.clear();
                              _onAddressChanged('');
                            },
                          )
                        : null,
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

            // Autocomplete Predictions Dropdown
            if (_predictions.isNotEmpty) ...[
              Container(
                constraints: BoxConstraints(maxHeight: 190.h),
                margin: EdgeInsets.only(top: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _predictions.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: AppColors.borderColor.withValues(alpha: 0.5),
                  ),
                  itemBuilder: (ctx, index) {
                    final item = _predictions[index];
                    return InkWell(
                      onTap: () => _selectPrediction(item),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.location_solid,
                              size: 16.sp,
                              color: AppColors.primaryColor,
                            ),
                            10.horizontalSpace,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.primaryText,
                                    style: AppTextStyle.text14Medium.copyWith(
                                      color: AppColors.primaryTextColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item.secondaryText.isNotEmpty) ...[
                                    2.verticalSpace,
                                    Text(
                                      item.secondaryText,
                                      style: AppTextStyle.text12Regular.copyWith(
                                        color: AppColors.secondaryTextColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            if (_selectedLat != null && _selectedLat != 0.0) ...[
              6.verticalSpace,
              Row(
                children: [
                  Icon(
                    CupertinoIcons.check_mark_circled_solid,
                    color: const Color(0xFF16A34A),
                    size: 14.sp,
                  ),
                  6.horizontalSpace,
                  Text(
                    'Place verified with map coordinates',
                    style: AppTextStyle.text12Regular.copyWith(
                      color: const Color(0xFF16A34A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

            12.verticalSpace,

            // Place Label / Name Field
            TextField(
              controller: _titleController,
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
            20.verticalSpace,

            AppButton(
              onPressed: _isSaving ? null : _handleSave,
              isLoading: _isSaving,
              label: 'Save Place',
            ),
          ],
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
