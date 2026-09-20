import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_assets.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/validation_mixin.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/auth_flow/auth_controller.dart';
import 'package:ridelink/widgets/app_border_container.dart';
import 'package:ridelink/widgets/app_button.dart';
import 'package:ridelink/widgets/app_cutom_login_button.dart';
import 'package:ridelink/widgets/app_main_container.dart';
import 'package:ridelink/widgets/app_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with ValidationMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController controller = Get.find<AuthController>();

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
                  Container(
                    height: 60.h,
                    width: 60.h,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: AppColors.containerFillColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Image.asset(AppAssets.appLogo, fit: BoxFit.contain),
                  ),
                  14.verticalSpace,
                  Text(
                    'Welcome Back',
                    style: AppTextStyle.text24Semibold.copyWith(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  6.verticalSpace,
                  Text(
                    'Sign in to access your rides and routes',
                    style: AppTextStyle.text14Regular.copyWith(
                      color: AppColors.secondaryTextColor,
                    ),
                  ),

                  24.verticalSpace,

                  // Main Form Card
                  AppBorderContainer(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextFormField(
                        controller: controller.emailController,
                        label: 'Email Address',
                        hintText: 'Enter your email address',
                        keyboardType: TextInputType.emailAddress,
                        prefix: SvgPicture.asset(
                          AppAssets.user,
                          width: 18.w,
                          height: 18.h,
                          colorFilter: const ColorFilter.mode(
                            AppColors.secondaryTextColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        validator: (value) => emailValidator(value),
                      ),
                      14.verticalSpace,
                      Obx(() {
                        final isVisible =
                            controller.isLoginPasswordVisible.value;
                        return AppTextFormField(
                          controller: controller.passwordController,
                          label: 'Password',
                          hintText: 'Enter your password',
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
                            onTap: controller.toggleLoginPasswordVisibility,
                            child: Icon(
                              isVisible
                                  ? CupertinoIcons.eye_slash
                                  : CupertinoIcons.eye,
                              size: 20.sp,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        );
                      }),
                      8.verticalSpace,

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            AppSnackBar.info(
                              message:
                                  'Password reset instruction will be sent to your registered email.',
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),

                      18.verticalSpace,

                      // Login Button
                      Obx(
                        () => AppButton(
                          onPressed: () => controller.onLogin(_formKey),
                          label: 'Sign In',
                          isLoading: controller.isLoading.value,
                        ),
                      ),
                    ],
                  ),

                  20.verticalSpace,

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

                  // Google Login Button
                  AppCutomLoginButton(
                    lable: 'Continue with Google',
                    icon: AppAssets.googleIcon,
                    onTap: () {
                      AppSnackBar.info(
                        message: 'Google Sign-In integration ready.',
                      );
                    },
                  ),

                  26.verticalSpace,

                  // Create Account Link
                  GestureDetector(
                    onTap: () {
                      if (Get.previousRoute == AppRoutes.createAccountView) {
                        Get.back();
                      } else {
                        Get.toNamed(AppRoutes.createAccountView);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyle.text14Medium.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                          Text(
                            'Create Account',
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
