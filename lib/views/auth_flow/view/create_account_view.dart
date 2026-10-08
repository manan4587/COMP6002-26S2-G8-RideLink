import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_assets.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/enums/user_type.dart';
import 'package:ridelink/core/utils/australian_phone_helper.dart';
import 'package:ridelink/core/utils/validation_mixin.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/auth_flow/auth_controller.dart';
import 'package:ridelink/widgets/app_border_container.dart';
import 'package:ridelink/widgets/app_button.dart';
import 'package:ridelink/widgets/app_cutom_login_button.dart';
import 'package:ridelink/widgets/app_main_container.dart';
import 'package:ridelink/widgets/app_text_field.dart';

class CreateAccountView extends StatefulWidget {
  const CreateAccountView({super.key});

  @override
  State<CreateAccountView> createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<CreateAccountView>
    with ValidationMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController controller = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    controller.clearAllFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBgColor,
      body: AppMainContainer(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Navigation Bar
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        CupertinoIcons.back,
                        size: 22.sp,
                        color: AppColors.primaryTextColor,
                      ),
                      splashRadius: 22.r,
                    ),
                  ),

                  // Header Section
                  8.verticalSpace,
                  Text(
                    'Create Account',
                    style: AppTextStyle.text24Semibold.copyWith(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  6.verticalSpace,
                  Text(
                    'Join RideLink to share rides and commute smarter',
                    style: AppTextStyle.text14Regular.copyWith(
                      color: AppColors.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  20.verticalSpace,

                  // Main Card
                  AppBorderContainer(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      AppTextFormField(
                        controller: controller.fullNameController,
                        label: 'Full Name',
                        hintText: 'e.g. Alex Johnson',
                        keyboardType: TextInputType.name,
                        prefix: SvgPicture.asset(
                          AppAssets.user,
                          width: 18.w,
                          height: 18.h,
                          colorFilter: const ColorFilter.mode(
                            AppColors.secondaryTextColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        validator: (value) => nameValidator(value),
                      ),
                      12.verticalSpace,

                      // Email Address
                      AppTextFormField(
                        controller: controller.emailController,
                        label: 'Email Address',
                        hintText: 'name@example.com',
                        keyboardType: TextInputType.emailAddress,
                        prefix: Icon(
                          Icons.email_outlined,
                          size: 18.sp,
                          color: AppColors.secondaryTextColor,
                        ),
                        validator: (value) => emailValidator(value),
                      ),
                      12.verticalSpace,

                      // Phone Number
                      AppTextFormField(
                        controller: controller.phoneNumberController,
                        label: 'Phone Number',
                        hintText: '469 712 617',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\+')),
                          AustralianPhoneInputFormatter(),
                        ],
                        prefix: AustralianPhonePrefix(
                          icon: SvgPicture.asset(
                            AppAssets.phone,
                            width: 18.w,
                            height: 18.h,
                            colorFilter: const ColorFilter.mode(
                              AppColors.secondaryTextColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        validator: (value) => phoneValidator(value),
                      ),
                      12.verticalSpace,

                      // Password with visibility toggle
                      Obx(() {
                        final isVisible =
                            controller.isSignupPasswordVisible.value;
                        return AppTextFormField(
                          controller: controller.passwordController,
                          label: 'Password',
                          hintText: 'At least 8 chars, 1 uppercase, 1 symbol',
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: !isVisible,
                          prefix: SvgPicture.asset(
                            AppAssets.password,
                            width: 18.w,
                            height: 18.h,
                            colorFilter: const ColorFilter.mode(
                              AppColors.secondaryTextColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: controller.toggleSignupPasswordVisibility,
                            child: Icon(
                              isVisible
                                  ? CupertinoIcons.eye_slash
                                  : CupertinoIcons.eye,
                              size: 20.sp,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                          validator: (value) => passwordValidator(value),
                        );
                      }),

                      20.verticalSpace,

                      // Join As Label
                      Row(
                        children: [
                          Text(
                            'Join as',
                            style: AppTextStyle.text14Medium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                          4.horizontalSpace,
                          Text(
                            '*',
                            style: AppTextStyle.text14Medium.copyWith(
                              color: AppColors.red,
                            ),
                          ),
                        ],
                      ),
                      10.verticalSpace,

                      // Interactive Role Selector Cards
                      Obx(() {
                        final selected = controller.selectedUserType.value;
                        return Row(
                          children: [
                            // Passenger Role Card
                            Expanded(
                              child: _RoleCard(
                                title: 'Passenger',
                                subtitle: 'Book & share rides',
                                icon: AppAssets.passagerMode,
                                isSelected: selected == UserType.passenger,
                                onTap: () => controller.selectedUserType(
                                  UserType.passenger,
                                ),
                              ),
                            ),
                            12.horizontalSpace,
                            // Driver Role Card
                            Expanded(
                              child: _RoleCard(
                                title: 'Driver',
                                subtitle: 'Offer rides & earn',
                                icon: AppAssets.driverMode,
                                isSelected: selected == UserType.driver,
                                onTap: () => controller.selectedUserType(
                                  UserType.driver,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),

                      // Driver Documents Preview Banner
                      Obx(() {
                        if (controller.selectedUserType.value ==
                            UserType.passenger) {
                          return const SizedBox.shrink();
                        }

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: EdgeInsets.only(top: 18.h),
                          decoration: BoxDecoration(
                            color: AppColors.containerFillColor,
                            border: Border.all(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.2,
                              ),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 14.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.shield_outlined,
                                    size: 18.sp,
                                    color: AppColors.primaryColor,
                                  ),
                                  8.horizontalSpace,
                                  Expanded(
                                    child: Text(
                                      'Driver Verification Required',
                                      style: AppTextStyle.text14Semibold
                                          .copyWith(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              6.verticalSpace,
                              Text(
                                "You'll upload these documents in the next step to get verified, or you can skip and upload them later in your profile:",
                                style: AppTextStyle.text12Regular.copyWith(
                                  color: AppColors.secondaryTextColor,
                                ),
                              ),
                              12.verticalSpace,
                              _DriverDocsTile(
                                icon: AppAssets.drivingLicense,
                                label: 'Driving Licence',
                                tag: 'Required',
                                isRequired: true,
                              ),
                              8.verticalSpace,
                              _DriverDocsTile(
                                icon: AppAssets.vehicleRegistration,
                                label: 'Vehicle Registration',
                                tag: 'Required',
                                isRequired: true,
                              ),
                              8.verticalSpace,
                              _DriverDocsTile(
                                icon: AppAssets.vehicleInsurance,
                                label: 'Vehicle Insurance',
                                tag: 'Required',
                                isRequired: true,
                              ),
                              8.verticalSpace,
                              _DriverDocsTile(
                                icon: AppAssets.policCheck,
                                label: 'Police Check',
                                tag: 'Optional',
                                isRequired: false,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),

                  16.verticalSpace,

                  // Email Verification Notice
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.mail_outline_rounded,
                            size: 16.sp,
                            color: AppColors.primaryColor,
                          ),
                          8.horizontalSpace,
                          Expanded(
                            child: Text(
                              'An email verification link will be sent to confirm your identity upon account creation.',
                              style: AppTextStyle.text12Medium.copyWith(
                                color: AppColors.primaryColor,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  14.verticalSpace,

                  // Submit Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Obx(() {
                      final isPassenger =
                          controller.selectedUserType.value ==
                          UserType.passenger;
                      return AppButton(
                        onPressed: isPassenger
                            ? () => controller.onPassegerAccountCreate(_formKey)
                            : () => controller.onDriverAccountCreate(_formKey),
                        label: isPassenger
                            ? 'Create Passenger Account'
                            : 'Create Driver Account',
                        isLoading: controller.isLoading.value,
                        icon: AppAssets.checkIcon,
                      );
                    }),
                  ),

                  18.verticalSpace,

                  // Or Continue With Divider
                  Row(
                    children: [
                      16.horizontalSpace,
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.borderColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        child: Text(
                          'or continue with',
                          style: AppTextStyle.text12Medium.copyWith(
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.borderColor,
                        ),
                      ),
                      16.horizontalSpace,
                    ],
                  ),

                  16.verticalSpace,

                  // Google Sign-Up Button
                  Obx(
                    () => AppCutomLoginButton(
                      lable: 'Continue with Google',
                      icon: AppAssets.googleIcon,
                      isLoading: controller.isGoogleLoading.value,
                      onTap: controller.isGoogleLoading.value
                          ? null
                          : controller.onContinueWithGoogle,
                    ),
                  ),

                  20.verticalSpace,

                  // Already Have an Account Link
                  GestureDetector(
                    onTap: () {
                      if (Get.previousRoute == AppRoutes.loginView) {
                        Get.back();
                      } else {
                        Get.offNamed(AppRoutes.loginView);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTextStyle.text14Medium.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                          Text(
                            'Sign In',
                            style: AppTextStyle.text14Semibold.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
            width: isSelected ? 2 : 1.2,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryColor.withValues(alpha: 0.08)
                  : AppColors.primaryTextColor.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyle.text14Semibold.copyWith(
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.primaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: 18.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.borderColor,
                      width: 1.5,
                    ),
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 12.sp, color: AppColors.white)
                      : null,
                ),
              ],
            ),

            3.verticalSpace,
            Text(
              subtitle,
              style: AppTextStyle.text10Medium.copyWith(
                color: AppColors.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverDocsTile extends StatelessWidget {
  const _DriverDocsTile({
    required this.label,
    required this.icon,
    required this.tag,
    required this.isRequired,
  });

  final String label;
  final String icon;
  final String tag;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            height: 28.h,
            width: 28.w,
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(8.r),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              icon,
              colorFilter: const ColorFilter.mode(
                AppColors.primaryColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          10.horizontalSpace,
          Expanded(
            child: Text(
              label,
              style: AppTextStyle.text12Semibold.copyWith(
                color: AppColors.primaryTextColor,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: isRequired
                  ? const Color(0xFFEFF6FF)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              tag,
              style: AppTextStyle.text10Medium.copyWith(
                color: isRequired
                    ? AppColors.primaryColor
                    : AppColors.secondaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
