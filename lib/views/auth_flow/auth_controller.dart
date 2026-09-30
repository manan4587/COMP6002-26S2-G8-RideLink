import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/enums/user_type.dart';
import 'package:ridelink/core/services/notification_service.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/core/utils/validation_mixin.dart';
import 'package:ridelink/data/repositories/auth_repository.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/driver_verification_service.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_profile_controller.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';
import 'package:ridelink/widgets/app_button.dart';
import 'package:ridelink/widgets/app_text_field.dart';

class AuthController extends GetxController with ValidationMixin {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController forgotPasswordEmailController =
      TextEditingController();

  // Vehicle info controllers for driver registration
  final TextEditingController vehicleMakeModelController =
      TextEditingController();
  final TextEditingController vehiclePlateController = TextEditingController();
  final TextEditingController vehicleColorController = TextEditingController();
  final RxInt vehicleSeats = 4.obs;

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> createAccountFormKey = GlobalKey<FormState>();

  final Rx<UserType> selectedUserType = Rx(UserType.passenger);

  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxBool isForgotPasswordLoading = false.obs;
  final RxBool isLoginPasswordVisible = false.obs;
  final RxBool isSignupPasswordVisible = false.obs;

  // Driver verification documents (file name, base64 string & local file path)
  final RxString drivingLicencePath = ''.obs;
  final RxString drivingLicenceBase64 = ''.obs;
  final RxString drivingLicenceFilePath = ''.obs;

  final RxString vehicleRegistrationPath = ''.obs;
  final RxString vehicleRegistrationBase64 = ''.obs;
  final RxString vehicleRegistrationFilePath = ''.obs;

  final RxString vehicleInsurancePath = ''.obs;
  final RxString vehicleInsuranceBase64 = ''.obs;
  final RxString vehicleInsuranceFilePath = ''.obs;

  final RxString policeCheckPath = ''.obs;
  final RxString policeCheckBase64 = ''.obs;
  final RxString policeCheckFilePath = ''.obs;

  final AuthRepository authRepository = AuthRepository();
  final AuthService _authService = AuthService.instance;

  // Email verification state
  final RxInt resendEmailCountdown = 30.obs;
  final RxBool isResendingEmail = false.obs;
  final RxBool isCheckingVerification = false.obs;
  Timer? _resendTimer;
  StreamSubscription? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _authSubscription = _authService.authStateChanges.listen((user) {
      if (user == null) {
        clearAllFields();
      }
    });
  }

  void clearAllFields() {
    fullNameController.clear();
    emailController.clear();
    passwordController.clear();
    phoneNumberController.clear();
    forgotPasswordEmailController.clear();
    vehicleMakeModelController.clear();
    vehiclePlateController.clear();
    vehicleColorController.clear();
    vehicleSeats.value = 4;
    drivingLicencePath.value = '';
    drivingLicenceBase64.value = '';
    drivingLicenceFilePath.value = '';
    vehicleRegistrationPath.value = '';
    vehicleRegistrationBase64.value = '';
    vehicleRegistrationFilePath.value = '';
    vehicleInsurancePath.value = '';
    vehicleInsuranceBase64.value = '';
    vehicleInsuranceFilePath.value = '';
    policeCheckPath.value = '';
    policeCheckBase64.value = '';
    policeCheckFilePath.value = '';
    selectedUserType.value = UserType.passenger;
    isLoading.value = false;
    isGoogleLoading.value = false;
    isForgotPasswordLoading.value = false;
    isLoginPasswordVisible.value = false;
    isSignupPasswordVisible.value = false;
  }

  void onNavigateToScreens() {
    Future.delayed(const Duration(seconds: 2), () {
      if (Preferences.isLogged) {
        if (Preferences.userRole == 'driver') {
          Get.offAllNamed(AppRoutes.driverDashboard);
        } else {
          Get.offAllNamed(AppRoutes.passengerDashboard);
        }
      } else {
        Get.offNamed(AppRoutes.getStartedView);
      }
    });
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    _authSubscription?.cancel();
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneNumberController.dispose();
    forgotPasswordEmailController.dispose();
    vehicleMakeModelController.dispose();
    vehiclePlateController.dispose();
    vehicleColorController.dispose();
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

  /// Resend Firebase verification email
  Future<void> onResendEmail() async {
    if (resendEmailCountdown.value > 0 || isResendingEmail.value) return;

    try {
      isResendingEmail.value = true;
      await _authService.sendVerificationEmail();
      startResendTimer(30);
      AppSnackBar.success(
        message:
            'Verification email sent successfully! Please check your inbox or spam.',
      );
    } catch (e) {
      AppSnackBar.error(message: _authService.getFriendlyErrorMessage(e));
    } finally {
      isResendingEmail.value = false;
    }
  }

  /// Check if the user has verified their email via Firebase
  Future<void> onEmailVerified() async {
    isCheckingVerification.value = true;
    try {
      final isVerified = await _authService.checkEmailVerified();
      if (!isVerified) {
        AppSnackBar.warning(
          message:
              'Email is not verified yet. Please check your inbox, click the link, and try again.',
        );
        return;
      }

      Preferences.isLogged = true;

      final current = _authService.currentUser;
      if (current != null) {
        if (current.displayName != null && current.displayName!.isNotEmpty) {
          Preferences.userName = current.displayName!;
        }
        if (current.email != null) {
          Preferences.userEmail = current.email!;
        }
      }

      if (fullNameController.text.trim().isNotEmpty) {
        Preferences.userName = fullNameController.text.trim();
      }
      if (emailController.text.trim().isNotEmpty) {
        Preferences.userEmail = emailController.text.trim();
      }
      if (phoneNumberController.text.trim().isNotEmpty) {
        Preferences.userPhone = phoneNumberController.text.trim();
      }

      if (Get.isRegistered<PassengerDashboardController>()) {
        Get.find<PassengerDashboardController>().reloadProfile();
      }
      if (Get.isRegistered<DriverProfileController>()) {
        Get.find<DriverProfileController>().reloadProfile();
      }

      // Sync FCM token to Firestore
      NotificationService.instance.syncTokenToFirestore();

      AppSnackBar.success(message: 'Email verified successfully!');

      if (selectedUserType.value == UserType.driver) {
        Preferences.userRole = 'driver';
        Get.offNamed(AppRoutes.driverVerificaitonUploadView);
      } else {
        Preferences.userRole = 'passenger';
        Get.offAllNamed(AppRoutes.passengerDashboard);
      }
    } catch (e) {
      AppSnackBar.error(message: _authService.getFriendlyErrorMessage(e));
    } finally {
      isCheckingVerification.value = false;
    }
  }

  /// Sign In with Email & Password
  /// Enforces email verification after clicking Sign In
  Future<void> onLogin([GlobalKey<FormState>? formKey]) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final isValid =
        formKey?.currentState?.validate() ??
        loginFormKey.currentState?.validate() ??
        true;
    if (!isValid) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      isLoading.value = true;
      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        AppSnackBar.error(message: 'Sign in failed. Please try again.');
        return;
      }

      // Check if email is verified
      if (!user.emailVerified) {
        // Send a fresh verification email so user can verify immediately
        await _authService.sendVerificationEmail(user);
        startResendTimer(30);

        AppSnackBar.warning(
          message:
              'Please verify your email address to continue. A fresh verification email has been sent.',
        );
        Get.toNamed(AppRoutes.emailVerificationView);
        return;
      }

      // Fetch Firestore profile to resolve user role and stored details
      final profile = await _authService.getUserProfile(user.uid);
      final role =
          profile?.activeRole ??
          (selectedUserType.value == UserType.driver ? 'driver' : 'passenger');

      Preferences.isLogged = true;
      Preferences.userEmail = user.email ?? email;
      Preferences.userName = profile?.fullName ?? user.displayName ?? '';
      if (profile?.phoneNumber != null && profile!.phoneNumber.isNotEmpty) {
        Preferences.userPhone = profile.phoneNumber;
      }
      Preferences.userRole = role;

      if (Get.isRegistered<PassengerDashboardController>()) {
        Get.find<PassengerDashboardController>().reloadProfile();
      }
      if (Get.isRegistered<DriverProfileController>()) {
        Get.find<DriverProfileController>().reloadProfile();
      }

      // Sync FCM token to Firestore
      NotificationService.instance.syncTokenToFirestore();

      AppSnackBar.success(message: 'Welcome back!');

      if (role == 'driver') {
        selectedUserType.value = UserType.driver;
        Get.offAllNamed(AppRoutes.driverDashboard);
      } else {
        selectedUserType.value = UserType.passenger;
        Get.offAllNamed(AppRoutes.passengerDashboard);
      }
    } catch (e) {
      AppSnackBar.error(message: _authService.getFriendlyErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  /// Create Passenger Account using Firebase Auth + Firestore
  Future<void> onPassegerAccountCreate([GlobalKey<FormState>? formKey]) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final isValid =
        formKey?.currentState?.validate() ??
        createAccountFormKey.currentState?.validate() ??
        true;
    if (!isValid) return;

    final email = emailController.text.trim();
    final password = passwordController.text;
    final fullName = fullNameController.text.trim();
    final phone = phoneNumberController.text.trim();

    try {
      isLoading.value = true;
      await _authService.registerWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phone,
        role: 'passenger',
      );

      Preferences.userName = fullName;
      Preferences.userEmail = email;
      Preferences.userPhone = phone;
      Preferences.userRole = 'passenger';
      selectedUserType.value = UserType.passenger;

      if (Get.isRegistered<PassengerDashboardController>()) {
        Get.find<PassengerDashboardController>().reloadProfile();
      }

      startResendTimer(30);
      AppSnackBar.success(
        message:
            'Account created! A verification link was sent to $email. Please verify your email.',
      );
      Get.toNamed(AppRoutes.emailVerificationView);
    } catch (e) {
      AppSnackBar.error(message: _authService.getFriendlyErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  /// Create Driver Account using Firebase Auth + Firestore
  Future<void> onDriverAccountCreate([GlobalKey<FormState>? formKey]) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final isValid =
        formKey?.currentState?.validate() ??
        createAccountFormKey.currentState?.validate() ??
        true;
    if (!isValid) return;

    final email = emailController.text.trim();
    final password = passwordController.text;
    final fullName = fullNameController.text.trim();
    final phone = phoneNumberController.text.trim();

    try {
      isLoading.value = true;
      await _authService.registerWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phone,
        role: 'driver',
      );

      Preferences.userName = fullName;
      Preferences.userEmail = email;
      Preferences.userPhone = phone;
      Preferences.userRole = 'driver';
      selectedUserType.value = UserType.driver;

      if (Get.isRegistered<DriverProfileController>()) {
        Get.find<DriverProfileController>().reloadProfile();
      }

      startResendTimer(30);
      AppSnackBar.success(
        message:
            'Account created! A verification link was sent to $email. Please verify your email.',
      );
      Get.toNamed(AppRoutes.emailVerificationView);
    } catch (e) {
      AppSnackBar.error(message: _authService.getFriendlyErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  /// Forgot Password - Send Reset Email via Firebase
  Future<void> onSendForgotPasswordEmail() async {
    final email = forgotPasswordEmailController.text.trim();
    if (email.isEmpty) {
      AppSnackBar.warning(
        message: 'Please enter your registered email address.',
      );
      return;
    }
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      AppSnackBar.warning(message: 'Please enter a valid email address.');
      return;
    }

    try {
      isForgotPasswordLoading.value = true;
      await _authService.sendPasswordResetEmail(email);
      Get.back(); // Close bottom sheet
      forgotPasswordEmailController.clear();
      AppSnackBar.success(
        message:
            'Password reset link sent to $email. Please check your inbox or spam.',
      );
    } catch (e) {
      AppSnackBar.error(message: _authService.getFriendlyErrorMessage(e));
    } finally {
      isForgotPasswordLoading.value = false;
    }
  }

  /// Show clean Forgot Password Bottom Sheet
  void showForgotPasswordDialog(BuildContext context) {
    if (emailController.text.trim().isNotEmpty) {
      forgotPasswordEmailController.text = emailController.text.trim();
    }
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
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
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            16.verticalSpace,
            Text('Reset Password', style: AppTextStyle.text20Semibold),
            6.verticalSpace,
            Text(
              'Enter the email associated with your RideLink account and we will send you a password reset link.',
              style: AppTextStyle.text14Regular.copyWith(
                color: AppColors.secondaryTextColor,
              ),
            ),
            18.verticalSpace,
            AppTextFormField(
              controller: forgotPasswordEmailController,
              label: 'Email Address',
              hintText: 'Enter your registered email',
              keyboardType: TextInputType.emailAddress,
              prefix: const Icon(
                Icons.email_outlined,
                color: AppColors.secondaryTextColor,
              ),
            ),
            20.verticalSpace,
            Obx(
              () => AppButton(
                onPressed: onSendForgotPasswordEmail,
                label: 'Send Reset Link',
                isLoading: isForgotPasswordLoading.value,
              ),
            ),
            12.verticalSpace,
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// Sign In with Google (default role: passenger)
  Future<void> onContinueWithGoogle() async {
    try {
      isGoogleLoading.value = true;
      final credential = await _authService.signInWithGoogle(
        defaultRole: 'passenger',
      );

      if (credential == null) {
        // User cancelled flow
        return;
      }

      final user = credential.user;
      if (user != null) {
        final profile = await _authService.getUserProfile(user.uid);
        // Default to 'passenger' unless an existing account already had a specific role
        final activeRole = profile?.activeRole ?? 'passenger';

        Preferences.isLogged = true;
        Preferences.userEmail = user.email ?? '';
        Preferences.userName = profile?.fullName ?? user.displayName ?? '';
        if (profile?.phoneNumber != null && profile!.phoneNumber.isNotEmpty) {
          Preferences.userPhone = profile.phoneNumber;
        }
        Preferences.userRole = activeRole;

        if (Get.isRegistered<PassengerDashboardController>()) {
          Get.find<PassengerDashboardController>().reloadProfile();
        }
        if (Get.isRegistered<DriverProfileController>()) {
          Get.find<DriverProfileController>().reloadProfile();
        }

        // Sync FCM token to Firestore
        NotificationService.instance.syncTokenToFirestore();

        AppSnackBar.success(
          message: 'Welcome, ${user.displayName ?? "RideLink user"}!',
        );

        if (activeRole == 'driver') {
          selectedUserType.value = UserType.driver;
          if (profile?.isVerifiedDriver == true) {
            Get.offAllNamed(AppRoutes.driverDashboard);
          } else {
            Get.offNamed(AppRoutes.driverVerificaitonUploadView);
          }
        } else {
          selectedUserType.value = UserType.passenger;
          Get.offAllNamed(AppRoutes.passengerDashboard);
        }
      }
    } catch (e) {
      AppSnackBar.error(message: _authService.getFriendlyErrorMessage(e));
    } finally {
      isGoogleLoading.value = false;
    }
  }

  Future<void> _pickDocumentImage({
    required String title,
    required void Function(String fileName, String base64, String filePath)
        onSelected,
  }) async {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.hintTextColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Text(
                'Upload $title',
                style: AppTextStyle.text18Semibold.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              8.verticalSpace,
              Text(
                'Please provide a clear and legible photo or scan of your $title.',
                style: AppTextStyle.text12Regular.copyWith(
                  color: AppColors.secondaryTextColor,
                ),
              ),
              16.verticalSpace,
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.camera_fill,
                    color: AppColors.primaryColor,
                  ),
                ),
                title: Text(
                  'Take Photo',
                  style: AppTextStyle.text14Medium,
                ),
                subtitle: Text(
                  'Use your camera to take a photo',
                  style: AppTextStyle.text10Regular.copyWith(
                    color: AppColors.secondaryTextColor,
                  ),
                ),
                onTap: () async {
                  Get.back();
                  final image = await Utils.pickImage(ImageSource.camera);
                  if (image != null && image.path.isNotEmpty) {
                    final base64 = await Utils.xFileToBase64(image);
                    final name = image.name.isNotEmpty
                        ? image.name
                        : '${title.toLowerCase().replaceAll(' ', '_')}.jpg';
                    onSelected(name, base64 ?? '', image.path);
                    AppSnackBar.success(message: '$title photo attached.');
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.photo_fill,
                    color: AppColors.primaryColor,
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: AppTextStyle.text14Medium,
                ),
                subtitle: Text(
                  'Upload an image from your photo library',
                  style: AppTextStyle.text10Regular.copyWith(
                    color: AppColors.secondaryTextColor,
                  ),
                ),
                onTap: () async {
                  Get.back();
                  final image = await Utils.pickImage(ImageSource.gallery);
                  if (image != null && image.path.isNotEmpty) {
                    final base64 = await Utils.xFileToBase64(image);
                    final name = image.name.isNotEmpty
                        ? image.name
                        : '${title.toLowerCase().replaceAll(' ', '_')}.jpg';
                    onSelected(name, base64 ?? '', image.path);
                    AppSnackBar.success(message: '$title photo attached.');
                  }
                },
              ),
              12.verticalSpace,
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> onSelectDrivingLicence() async {
    await _pickDocumentImage(
      title: 'Driving Licence',
      onSelected: (fileName, base64, filePath) {
        drivingLicencePath.value = fileName;
        drivingLicenceBase64.value = base64;
        drivingLicenceFilePath.value = filePath;
      },
    );
  }

  Future<void> onSelectVehicleRegistration() async {
    await _pickDocumentImage(
      title: 'Vehicle Registration',
      onSelected: (fileName, base64, filePath) {
        vehicleRegistrationPath.value = fileName;
        vehicleRegistrationBase64.value = base64;
        vehicleRegistrationFilePath.value = filePath;
      },
    );
  }

  Future<void> onSelectVehicleInsurance() async {
    await _pickDocumentImage(
      title: 'Vehicle Insurance',
      onSelected: (fileName, base64, filePath) {
        vehicleInsurancePath.value = fileName;
        vehicleInsuranceBase64.value = base64;
        vehicleInsuranceFilePath.value = filePath;
      },
    );
  }

  Future<void> onSelectPoliceCheck() async {
    await _pickDocumentImage(
      title: 'Police Check',
      onSelected: (fileName, base64, filePath) {
        policeCheckPath.value = fileName;
        policeCheckBase64.value = base64;
        policeCheckFilePath.value = filePath;
      },
    );
  }

  Future<void> onSubmitForVerification() async {
    if ((drivingLicenceBase64.value.isEmpty &&
            drivingLicenceFilePath.value.isEmpty) ||
        (vehicleRegistrationBase64.value.isEmpty &&
            vehicleRegistrationFilePath.value.isEmpty) ||
        (vehicleInsuranceBase64.value.isEmpty &&
            vehicleInsuranceFilePath.value.isEmpty)) {
      AppSnackBar.warning(
        message:
            'Please attach Driving Licence, Vehicle Registration, and Vehicle Insurance before submitting.',
      );
      return;
    }

    final user = _authService.currentUser;
    final uid =
        user?.uid ??
        (Preferences.userEmail.isNotEmpty
            ? Preferences.userEmail
            : 'driver_user');

    try {
      isLoading.value = true;

      final Map<String, Map<String, dynamic>> docs = {
        'driving_licence': {
          'title': 'Driving Licence (DL)',
          'fileName': drivingLicencePath.value,
          'base64': drivingLicenceBase64.value,
          'filePath': drivingLicenceFilePath.value,
        },
        'vehicle_registration': {
          'title': 'Vehicle Registration (VR)',
          'fileName': vehicleRegistrationPath.value,
          'base64': vehicleRegistrationBase64.value,
          'filePath': vehicleRegistrationFilePath.value,
        },
        'vehicle_insurance': {
          'title': 'Vehicle Insurance (VI)',
          'fileName': vehicleInsurancePath.value,
          'base64': vehicleInsuranceBase64.value,
          'filePath': vehicleInsuranceFilePath.value,
        },
      };

      if (policeCheckBase64.value.isNotEmpty ||
          policeCheckFilePath.value.isNotEmpty) {
        docs['police_check'] = {
          'title': 'Police Check (PC)',
          'fileName': policeCheckPath.value,
          'base64': policeCheckBase64.value,
          'filePath': policeCheckFilePath.value,
        };
      }

      final vehicleInfo = {
        'make': vehicleMakeModelController.text.trim(),
        'model': vehicleMakeModelController.text.trim(),
        'licensePlate': vehiclePlateController.text.trim(),
        'color': vehicleColorController.text.trim(),
        'totalSeats': vehicleSeats.value,
        'year': 2022,
      };

      await DriverVerificationService.instance.submitAllDriverDocuments(
        userId: uid,
        documents: docs,
        vehicleInfo: vehicleInfo,
      );

      // Update in-memory driver profile if already registered
      if (Get.isRegistered<DriverProfileController>()) {
        final driverProfileCtrl = Get.find<DriverProfileController>();
        driverProfileCtrl.updateVehicleInfo(
          number: vehiclePlateController.text.trim(),
          type: 'Sedan (${vehicleSeats.value} seats)',
          model: vehicleMakeModelController.text.trim(),
        );
      }

      AppSnackBar.success(
        message: 'Verification documents submitted to our admin team!',
      );
      Get.toNamed(AppRoutes.verificationSubmittedView);
    } catch (e) {
      AppSnackBar.error(
        message:
            'Failed to submit documents: ${_authService.getFriendlyErrorMessage(e)}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onSkipDriverVerification() async {
    Preferences.isLogged = true;
    Preferences.userRole = 'driver';
    AppSnackBar.info(
      message:
          'Document upload skipped. You can upload your verification documents anytime from your profile.',
    );
    Get.offAllNamed(AppRoutes.driverDashboard);
  }

  Future<void> onVerificationSubmited() async {
    Preferences.isLogged = true;
    Preferences.userRole = 'driver';
    Get.offAllNamed(AppRoutes.driverDashboard);
  }
}
