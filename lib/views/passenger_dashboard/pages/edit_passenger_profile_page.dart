import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_assets.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/core/utils/validation_mixin.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';
import 'package:ridelink/widgets/app_border_container.dart';
import 'package:ridelink/widgets/app_button.dart';
import 'package:ridelink/widgets/app_main_container.dart';
import 'package:ridelink/widgets/app_text_field.dart';

class EditPassengerProfilePage extends StatefulWidget {
  const EditPassengerProfilePage({super.key});

  @override
  State<EditPassengerProfilePage> createState() =>
      _EditPassengerProfilePageState();
}

class _EditPassengerProfilePageState extends State<EditPassengerProfilePage>
    with ValidationMixin {
  final PassengerDashboardController controller =
      Get.find<PassengerDashboardController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  Worker? _nameWorker;
  Worker? _emailWorker;
  Worker? _phoneWorker;

  @override
  void initState() {
    super.initState();
    controller.reloadProfile();

    final initialName = controller.passengerName.value.isNotEmpty
        ? controller.passengerName.value
        : Preferences.userName;
    final initialEmail = controller.passengerEmail.value.isNotEmpty
        ? controller.passengerEmail.value
        : (Preferences.userEmail.isNotEmpty
            ? Preferences.userEmail
            : (AuthService.instance.currentUser?.email ?? ''));
    final initialPhone = controller.passengerPhone.value.isNotEmpty
        ? controller.passengerPhone.value
        : Preferences.userPhone;

    _nameController = TextEditingController(text: initialName);
    _emailController = TextEditingController(text: initialEmail);
    _phoneController = TextEditingController(text: initialPhone);

    _nameWorker = ever(controller.passengerName, (val) {
      if (_nameController.text.isEmpty && val.isNotEmpty) {
        _nameController.text = val;
      }
    });
    _emailWorker = ever(controller.passengerEmail, (val) {
      if (_emailController.text.isEmpty && val.isNotEmpty) {
        _emailController.text = val;
      }
    });
    _phoneWorker = ever(controller.passengerPhone, (val) {
      if (_phoneController.text.isEmpty && val.isNotEmpty) {
        _phoneController.text = val;
      }
    });
  }

  @override
  void dispose() {
    _nameWorker?.dispose();
    _emailWorker?.dispose();
    _phoneWorker?.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onSaveProfile() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      controller.updatePassengerProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      Get.back();
    }
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
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Form(
              key: _formKey,
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
                          4.horizontalSpace,
                          Text(
                            'Edit Profile',
                            style: AppTextStyle.text20Semibold.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.25,
                            ),
                          ),
                        ),
                        child: Text(
                          'Passenger',
                          style: AppTextStyle.text12Semibold.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  16.verticalSpace,

                  // Profile Photo Header Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 20.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColors.borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Obx(
                          () => CircleAvatar(
                            radius: 42.r,
                            backgroundColor: const Color(0xFFDBEAFE),
                            child: Text(
                              controller.passengerInitials,
                              style: AppTextStyle.text24Semibold.copyWith(
                                color: AppColors.primaryColor,
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        10.verticalSpace,
                        Obx(
                          () => Text(
                            controller.passengerName.value,
                            style: AppTextStyle.text18Semibold.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        3.verticalSpace,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 14.sp,
                              color: AppColors.primaryColor,
                            ),
                            4.horizontalSpace,
                            Text(
                              'Verified Passenger Account',
                              style: AppTextStyle.text12Medium.copyWith(
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  20.verticalSpace,

                  // Main Edit Form Section
                  AppBorderContainer(
                    margin: EdgeInsets.all(0),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.person_crop_circle,
                            size: 18.sp,
                            color: AppColors.primaryColor,
                          ),
                          8.horizontalSpace,
                          Text(
                            'Personal Information',
                            style: AppTextStyle.text16Semibold.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      6.verticalSpace,
                      Text(
                        'Keep your contact information accurate for smooth trip coordination.',
                        style: AppTextStyle.text12Regular.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      18.verticalSpace,

                      // Full Name
                      AppTextFormField(
                        controller: _nameController,
                        label: 'Full Name',
                        hintText: 'Enter your full name',
                        keyboardType: TextInputType.name,
                        prefix: Icon(
                          CupertinoIcons.person,
                          size: 18.sp,
                          color: AppColors.secondaryTextColor,
                        ),
                        validator: (value) => nameValidator(value),
                      ),

                      16.verticalSpace,

                      // Email Address
                      AppTextFormField(
                        controller: _emailController,
                        label: 'Email Address',
                        hintText: 'name@example.com',
                        keyboardType: TextInputType.emailAddress,
                        prefix: Icon(
                          CupertinoIcons.mail,
                          size: 18.sp,
                          color: AppColors.secondaryTextColor,
                        ),
                        validator: (value) => emailValidator(value),
                        readOnly: true,
                      ),

                      16.verticalSpace,

                      // Phone Number
                      AppTextFormField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hintText: '04xx xxx xxx',
                        keyboardType: TextInputType.phone,
                        prefix: Icon(
                          CupertinoIcons.phone,
                          size: 18.sp,
                          color: AppColors.secondaryTextColor,
                        ),
                        validator: (value) => phoneValidator(value, 10),
                      ),
                    ],
                  ),

                  24.verticalSpace,

                  // Save Changes CTA Button
                  AppButton(
                    onPressed: _onSaveProfile,
                    label: 'Save Changes',
                    icon: AppAssets.checkIcon,
                  ),

                  12.verticalSpace,

                  // Cancel Button
                  Center(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Cancel',
                        style: AppTextStyle.text14Medium.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ),
                  ),

                  16.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
