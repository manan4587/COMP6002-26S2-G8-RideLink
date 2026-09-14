import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ridelink/core/enums/user_type.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/core/utils/validation_mixin.dart';
import 'package:ridelink/data/repositories/auth_repository.dart';
import 'package:ridelink/routes/routes_name.dart';

class AuthController extends GetxController with ValidationMixin {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> createAccountFormKey = GlobalKey<FormState>();

  final Rx<UserType> selectedUserType = Rx(UserType.passenger);

  final RxBool isLoading = false.obs;
  final RxBool isLoginPasswordVisible = false.obs;
  final RxBool isSignupPasswordVisible = false.obs;

  // Driver verification documents
  final RxString drivingLicencePath = ''.obs;
  final RxString vehicleRegistrationPath = ''.obs;
  final RxString vehicleInsurancePath = ''.obs;
  final RxString policeCheckPath = ''.obs;

  final AuthRepository authRepository = AuthRepository();

  // Email verification state
  final RxInt resendEmailCountdown = 30.obs;
  final RxBool isResendingEmail = false.obs;
  final RxBool isCheckingVerification = false.obs;
  Timer? _resendTimer;

  @override
  void onInit() {
    Future.delayed(
      const Duration(seconds: 2),
      () => Get.offNamed(AppRoutes.getStartedView),
    );
    super.onInit();
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }

  void toggleLoginPasswordVisibility() {
    isLoginPasswordVisible.value = !isLoginPasswordVisible.value;
  }

  void toggleSignupPasswordVisibility() {
    isSignupPasswordVisible.value = !isSignupPasswordVisible.value;
  }

  void startResendTimer([int seconds = 30]) {
    _resendTimer?.cancel();
    resendEmailCountdown.value = seconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendEmailCountdown.value > 0) {
        resendEmailCountdown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> onResendEmail() async {
    if (resendEmailCountdown.value > 0 || isResendingEmail.value) return;

    try {
      isResendingEmail.value = true;
      // Simulate API call to resend verification email
      await Future.delayed(const Duration(seconds: 1));
      startResendTimer(30);
      AppSnackBar.success(
        message:
            'Verification email resent successfully! Please check your inbox.',
      );
    } catch (e) {
      AppSnackBar.error(message: 'Failed to resend email: $e');
    } finally {
      isResendingEmail.value = false;
    }
  }

  Future<void> onEmailVerified() async {
    isCheckingVerification.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    isCheckingVerification.value = false;
    if (selectedUserType.value == UserType.driver) {
      Get.toNamed(AppRoutes.driverDashboard);
    } else {
      Get.toNamed(AppRoutes.passengerDashboard);
    }
  }

  Future<void> onLogin([GlobalKey<FormState>? formKey]) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final isValid = formKey?.currentState?.validate() ?? loginFormKey.currentState?.validate() ?? true;
    if (isValid) {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 600));
      isLoading.value = false;
      if (selectedUserType.value == UserType.driver) {
        Get.offAllNamed(AppRoutes.driverDashboard);
      } else {
        Get.offAllNamed(AppRoutes.passengerDashboard);
      }
    }
  }

  Future<void> onPassegerAccountCreate([GlobalKey<FormState>? formKey]) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final isValid = formKey?.currentState?.validate() ?? createAccountFormKey.currentState?.validate() ?? true;
    if (isValid) {
      startResendTimer(30);
      Get.toNamed(AppRoutes.emailVerificationView);
    }
  }

  Future<void> onDriverAccountCreate([GlobalKey<FormState>? formKey]) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final isValid = formKey?.currentState?.validate() ?? createAccountFormKey.currentState?.validate() ?? true;
    if (isValid) {
      Get.toNamed(AppRoutes.driverVerificaitonUploadView);
    }
  }

  Future<void> onSelectDrivingLicence() async {
    final image = await Utils.pickImage(ImageSource.gallery);
    if (image != null && image.path.isNotEmpty) {
      drivingLicencePath.value = image.name.isNotEmpty ? image.name : 'driving_licence.jpg';
      AppSnackBar.success(message: 'Driving Licence attached.');
    }
  }

  Future<void> onSelectVehicleRegistration() async {
    final image = await Utils.pickImage(ImageSource.gallery);
    if (image != null && image.path.isNotEmpty) {
      vehicleRegistrationPath.value = image.name.isNotEmpty ? image.name : 'vehicle_registration.jpg';
      AppSnackBar.success(message: 'Vehicle Registration attached.');
    }
  }

  Future<void> onSelectVehicleInsurance() async {
    final image = await Utils.pickImage(ImageSource.gallery);
    if (image != null && image.path.isNotEmpty) {
      vehicleInsurancePath.value = image.name.isNotEmpty ? image.name : 'vehicle_insurance.jpg';
      AppSnackBar.success(message: 'Vehicle Insurance attached.');
    }
  }

  Future<void> onSelectPoliceCheck() async {
    final image = await Utils.pickImage(ImageSource.gallery);
    if (image != null && image.path.isNotEmpty) {
      policeCheckPath.value = image.name.isNotEmpty ? image.name : 'police_check.jpg';
      AppSnackBar.success(message: 'Police Check document attached.');
    }
  }

  Future<void> onSubmitForVerification() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    isLoading.value = false;
    Get.toNamed(AppRoutes.verificationSubmittedView);
  }

  Future<void> onVerificationSubmited() async {
    Get.offAllNamed(AppRoutes.driverDashboard);
  }
}
