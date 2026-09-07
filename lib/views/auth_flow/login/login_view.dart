import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/widgets/app_button.dart';
import 'package:ridelink/widgets/app_text_field.dart';

import '../../../core/utils/validation_mixin.dart';
import '../../../theme/app_style.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> with ValidationMixin {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(
          defaultPadding,
        ).copyWith(top: defaultPadding * 2),
        child: Form(
          key: controller.signInFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              100.verticalSpace,
              Text('Welcome Back', style: AppTextStyle.text24Semibold),
              4.verticalSpace,
              Text(
                'Please enter your details to login',
                style: AppTextStyle.text14Regular.copyWith(
                  color: AppColors.grey,
                ),
              ),
              24.verticalSpace,
              buildEmailTextFiled(),
              16.verticalSpace,
              buildPasswordTextFiled(),
              6.verticalSpace,
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Request for new password ?',
                  style: AppTextStyle.text14Medium.copyWith(
                    color: AppColors.inProgress,
                  ),
                ),
              ),
              16.verticalSpace,
              buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmailTextFiled() {
    return AppTextFormField(
      controller: controller.emailController,
      label: 'Email',
      hintText: 'Enter your email',
      keyboardType: TextInputType.emailAddress,
      validator: (value) => emailValidator(value),
    );
  }

  Widget buildPasswordTextFiled() {
    return AppTextFormField(
      controller: controller.passwordController,
      label: 'Password',
      hintText: 'Enter your password',
      keyboardType: TextInputType.visiblePassword,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) => passwordValidator(value),
    );
  }

  // Sign Up Button
  Widget buildLoginButton() {
    return Obx(
      () => AppButton(
        onPressed: controller.onLogin,
        label: 'Login',
        isLoading: controller.isLoading.value,
      ),
    );
  }
}
