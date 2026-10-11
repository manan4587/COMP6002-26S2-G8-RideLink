import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_profile_controller.dart';
import 'package:ridelink/widgets/app_border_container.dart';
import 'package:ridelink/widgets/app_button.dart';
import 'package:ridelink/widgets/app_main_container.dart';

class VehicleRegistrationPage extends StatefulWidget {
  const VehicleRegistrationPage({super.key});

  @override
  State<VehicleRegistrationPage> createState() =>
      _VehicleRegistrationPageState();
}

class _VehicleRegistrationPageState extends State<VehicleRegistrationPage> {
  final DriverProfileController controller =
      Get.find<DriverProfileController>();

  late final TextEditingController _numberController;
  late final TextEditingController _modelController;
  late final TextEditingController _colorController;
  late String _selectedType;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _vehicleTypes = [
    {'type': 'Sedan', 'icon': CupertinoIcons.car_detailed},
    {'type': 'SUV', 'icon': CupertinoIcons.car},
    {'type': 'Hatchback', 'icon': CupertinoIcons.car_detailed},
    {'type': 'Van / MPV', 'icon': CupertinoIcons.bus},
    {'type': 'Electric / EV', 'icon': CupertinoIcons.car},
  ];

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(
      text: controller.vehicleNumber.value != 'N/A'
          ? controller.vehicleNumber.value
          : '',
    );
    _modelController = TextEditingController(
      text: controller.vehicleModel.value != 'N/A'
          ? controller.vehicleModel.value
          : '',
    );
    _colorController = TextEditingController(
      text: controller.vehicleColor.value != 'N/A'
          ? controller.vehicleColor.value
          : '',
    );
    _selectedType =
        controller.vehicleType.value.isNotEmpty &&
            controller.vehicleType.value != 'N/A'
        ? controller.vehicleType.value
        : 'Sedan';
  }

  @override
  void dispose() {
    _numberController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _showLockedNotice() {
    AppSnackBar.info(
      message:
          'Vehicle details are verified by admin and locked. Please open a support ticket to request changes.',
    );
  }

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
                      'Vehicle & Registration',
                      style: AppTextStyle.text18Semibold.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                12.verticalSpace,

                // Vehicle Registration Card
                Obx(() {
                  final bool isVerified = controller.isVerifiedByAdmin.value;

                  // Keep controllers populated with verified values if they become available
                  if (isVerified) {
                    if (controller.vehicleNumber.value != 'N/A' &&
                        controller.vehicleNumber.value.isNotEmpty &&
                        _numberController.text.isEmpty) {
                      _numberController.text = controller.vehicleNumber.value;
                    }
                    if (controller.vehicleModel.value != 'N/A' &&
                        controller.vehicleModel.value.isNotEmpty &&
                        _modelController.text.isEmpty) {
                      _modelController.text = controller.vehicleModel.value;
                    }
                    if (controller.vehicleColor.value != 'N/A' &&
                        controller.vehicleColor.value.isNotEmpty &&
                        _colorController.text.isEmpty) {
                      _colorController.text = controller.vehicleColor.value;
                    }
                    if (controller.vehicleType.value != 'N/A' &&
                        controller.vehicleType.value.isNotEmpty) {
                      _selectedType = controller.vehicleType.value;
                    }
                  }

                  return AppBorderContainer(
                    margin: EdgeInsets.symmetric(horizontal: 0),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Banner
                      if (isVerified)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.verified_user_rounded,
                                color: Color(0xFF16A34A),
                                size: 20,
                              ),
                              10.horizontalSpace,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Vehicle Details Verified',
                                      style: AppTextStyle.text14Semibold.copyWith(
                                        color: const Color(0xFF15803D),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    4.verticalSpace,
                                    Text(
                                      'Your vehicle details have been verified by admin. All fields are read-only. To request updates, please open a support ticket below.',
                                      style: AppTextStyle.text12Regular.copyWith(
                                        color: const Color(0xFF166534),
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                              10.horizontalSpace,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Vehicle Registration Details',
                                      style: AppTextStyle.text14Semibold.copyWith(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    4.verticalSpace,
                                    Text(
                                      'Enter accurate vehicle details matching your official registration certificate.',
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

                      20.verticalSpace,

                      // Vehicle Number
                      Text(
                        'Vehicle Plate Number',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      8.verticalSpace,
                      GestureDetector(
                        onTap: isVerified ? _showLockedNotice : null,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: isVerified ? const Color(0xFFF8FAFC) : AppColors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: isVerified ? const Color(0xFFE2E8F0) : AppColors.borderColor,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isVerified ? CupertinoIcons.lock_fill : CupertinoIcons.number,
                                color: isVerified
                                    ? AppColors.secondaryTextColor
                                    : AppColors.primaryColor,
                                size: 18.sp,
                              ),
                              10.horizontalSpace,
                              Expanded(
                                child: TextField(
                                  controller: _numberController,
                                  readOnly: isVerified,
                                  onTap: isVerified ? _showLockedNotice : null,
                                  style: AppTextStyle.text16Semibold.copyWith(
                                    letterSpacing: 1.2,
                                    color: isVerified
                                        ? AppColors.secondaryTextColor
                                        : AppColors.primaryTextColor,
                                  ),
                                  textCapitalization: TextCapitalization.characters,
                                  decoration: const InputDecoration(
                                    hintText: '1ABC 123',
                                    border: InputBorder.none,
                                    isDense: true,
                                    suffixIcon: null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      20.verticalSpace,

                      // Type of Vehicle
                      Text(
                        'Type of Vehicle',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      4.verticalSpace,
                      Text(
                        'Select the category that best matches your registered vehicle',
                        style: AppTextStyle.text12Regular.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      12.verticalSpace,

                      // Vehicle Type Selector Grid / List
                      ..._vehicleTypes.map((item) {
                        final type = item['type'] as String;
                        final icon = item['icon'] as IconData;
                        final isSelected = _selectedType == type;

                        return GestureDetector(
                          onTap: isVerified
                              ? _showLockedNotice
                              : () {
                                  setState(() {
                                    _selectedType = type;
                                  });
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: EdgeInsets.only(bottom: 10.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isVerified
                                      ? const Color(0xFFF1F5F9)
                                      : const Color(0xFFEFF6FF))
                                  : (isVerified ? const Color(0xFFF8FAFC) : AppColors.white),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: isSelected
                                    ? (isVerified
                                        ? const Color(0xFFCBD5E1)
                                        : AppColors.primaryColor)
                                    : (isVerified ? const Color(0xFFE2E8F0) : AppColors.borderColor),
                                width: isSelected ? 1.8 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  icon,
                                  color: isSelected
                                      ? (isVerified
                                          ? AppColors.secondaryTextColor
                                          : AppColors.primaryColor)
                                      : AppColors.secondaryTextColor,
                                  size: 20.sp,
                                ),
                                12.horizontalSpace,
                                Expanded(
                                  child: Text(
                                    type,
                                    style: AppTextStyle.text14Semibold.copyWith(
                                      color: isSelected
                                          ? (isVerified
                                              ? AppColors.secondaryTextColor
                                              : AppColors.primaryColor)
                                          : AppColors.primaryTextColor,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: isVerified
                                        ? AppColors.secondaryTextColor
                                        : AppColors.primaryColor,
                                    size: 18.sp,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),

                      16.verticalSpace,

                      // Vehicle Model (Basic info)
                      Text(
                        'Vehicle Make & Model',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      8.verticalSpace,
                      GestureDetector(
                        onTap: isVerified ? _showLockedNotice : null,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: isVerified ? const Color(0xFFF8FAFC) : AppColors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: isVerified ? const Color(0xFFE2E8F0) : AppColors.borderColor,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isVerified ? CupertinoIcons.lock_fill : CupertinoIcons.car_detailed,
                                color: AppColors.secondaryTextColor,
                                size: 18.sp,
                              ),
                              10.horizontalSpace,
                              Expanded(
                                child: TextField(
                                  controller: _modelController,
                                  readOnly: isVerified,
                                  onTap: isVerified ? _showLockedNotice : null,
                                  style: AppTextStyle.text14Medium.copyWith(
                                    color: isVerified
                                        ? AppColors.secondaryTextColor
                                        : AppColors.primaryTextColor,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. Toyota Camry 2022',
                                    border: InputBorder.none,
                                    isDense: true,
                                    suffixIcon: null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      16.verticalSpace,

                      // Vehicle Color
                      Text(
                        'Vehicle Color',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      8.verticalSpace,
                      GestureDetector(
                        onTap: isVerified ? _showLockedNotice : null,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: isVerified ? const Color(0xFFF8FAFC) : AppColors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: isVerified ? const Color(0xFFE2E8F0) : AppColors.borderColor,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isVerified ? CupertinoIcons.lock_fill : CupertinoIcons.paintbrush,
                                color: AppColors.secondaryTextColor,
                                size: 18.sp,
                              ),
                              10.horizontalSpace,
                              Expanded(
                                child: TextField(
                                  controller: _colorController,
                                  readOnly: isVerified,
                                  onTap: isVerified ? _showLockedNotice : null,
                                  style: AppTextStyle.text14Medium.copyWith(
                                    color: isVerified
                                        ? AppColors.secondaryTextColor
                                        : AppColors.primaryTextColor,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. Silver, Pearl White, Black',
                                    border: InputBorder.none,
                                    isDense: true,
                                    suffixIcon: null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      24.verticalSpace,

                      // Save Button or Support Contact
                      if (isVerified)
                        OutlinedButton.icon(
                          onPressed: () {
                            Get.toNamed(
                              AppRoutes.driverSupport,
                              arguments: {
                                'category': 'Verification & Documents',
                                'subject': 'Update Verified Vehicle Details',
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.support_agent_rounded,
                            color: AppColors.primaryColor,
                          ),
                          label: Text(
                            'Open Support Ticket to Update Vehicle',
                            style: AppTextStyle.text14Semibold.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 48.h),
                            side: const BorderSide(
                              color: AppColors.primaryColor,
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            backgroundColor: AppColors.white,
                          ),
                        )
                      else
                        AppButton(
                          onPressed: () async {
                            final plate = _numberController.text.trim();
                            if (plate.isEmpty) {
                              AppSnackBar.warning(
                                message: 'Please enter your vehicle plate number.',
                              );
                              return;
                            }

                            setState(() => _isLoading = true);
                            Get.back();
                            await controller.updateVehicleInfo(
                              number: plate,
                              type: _selectedType,
                              model: _modelController.text.trim(),
                              color: _colorController.text.trim(),
                            );
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          },
                          isLoading: _isLoading,
                          label: 'Save Vehicle Details',
                        ),
                    ],
                  );
                }),

                20.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
