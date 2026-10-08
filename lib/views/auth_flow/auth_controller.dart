import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/enums/user_type.dart';
import 'package:ridelink/core/services/notification_service.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/australian_phone_helper.dart';
import 'package:ridelink/core/utils/disposable_email_checker.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/core/utils/validation_mixin.dart';
import 'package:ridelink/data/repositories/auth_repository.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/driver_verification_service.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_profile_controller.dart';
import 'package:ridelink/widgets/app_button.dart';
import 'package:ridelink/widgets/app_text_field.dart';
import 'package:ridelink/widgets/document_upload_picker_sheet.dart';

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
  final RxString selectedVehicleType = 'Sedan'.obs;
  final RxInt vehicleSeats = 4.obs;

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> createAccountFormKey = GlobalKey<FormState>();

  final Rx<UserType> selectedUserType = Rx(UserType.passenger);

  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxBool isForgotPasswordLoading = false.obs;
  final RxBool isLoginPasswordVisible = false.obs;
  final RxBool isSignupPasswordVisible = false.obs;

  // Driver verification documents (file name & file path/URL & status)
  final RxString drivingLicencePath = ''.obs;
  final RxString drivingLicenceFilePath = ''.obs;
  final Rx<DocumentVerificationStatus> drivingLicenceStatus =
      DocumentVerificationStatus.notUploaded.obs;
  final RxString drivingLicenceRejectionReason = ''.obs;

  final RxString vehicleRegistrationPath = ''.obs;
  final RxString vehicleRegistrationFilePath = ''.obs;
  final Rx<DocumentVerificationStatus> vehicleRegistrationStatus =
      DocumentVerificationStatus.notUploaded.obs;
  final RxString vehicleRegistrationRejectionReason = ''.obs;

  final RxString vehicleInsurancePath = ''.obs;
  final RxString vehicleInsuranceFilePath = ''.obs;
  final Rx<DocumentVerificationStatus> vehicleInsuranceStatus =
      DocumentVerificationStatus.notUploaded.obs;
  final RxString vehicleInsuranceRejectionReason = ''.obs;

  final RxString policeCheckPath = ''.obs;
  final RxString policeCheckFilePath = ''.obs;
  final Rx<DocumentVerificationStatus> policeCheckStatus =
      DocumentVerificationStatus.optional.obs;
  final RxString policeCheckRejectionReason = ''.obs;

  // Track documents currently uploading to prevent duplicate uploads and show loaders
  final RxSet<String> uploadingDocIds = <String>{}.obs;
  bool isDocUploading(String docId) => uploadingDocIds.contains(docId);

  final AuthRepository authRepository = AuthRepository();
  final AuthService _authService = AuthService.instance;

  User? get currentUser => _authService.currentUser;

  Future<void> signOut() async {
    Preferences.logout();
    await _authService.signOut();
  }

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
    drivingLicenceFilePath.value = '';
    drivingLicenceStatus.value = DocumentVerificationStatus.notUploaded;
    drivingLicenceRejectionReason.value = '';
    vehicleRegistrationPath.value = '';
    vehicleRegistrationFilePath.value = '';
    vehicleRegistrationStatus.value = DocumentVerificationStatus.notUploaded;
    vehicleRegistrationRejectionReason.value = '';
    vehicleInsurancePath.value = '';
    vehicleInsuranceFilePath.value = '';
    vehicleInsuranceStatus.value = DocumentVerificationStatus.notUploaded;
    vehicleInsuranceRejectionReason.value = '';
    policeCheckPath.value = '';
    policeCheckFilePath.value = '';
    policeCheckStatus.value = DocumentVerificationStatus.optional;
    policeCheckRejectionReason.value = '';
    selectedUserType.value = UserType.passenger;
    isLoading.value = false;
    isGoogleLoading.value = false;
    isForgotPasswordLoading.value = false;
    isLoginPasswordVisible.value = false;
    isSignupPasswordVisible.value = false;
  }

  bool _isSplashNavigating = false;

  void onNavigateToScreens() {
    if (_isSplashNavigating) return;
    _isSplashNavigating = true;
    Future.delayed(const Duration(seconds: 2), () async {
      final user = _authService.currentUser;

      // 1. If an authenticated Firebase user is present
      if (user != null) {
        try {
          await user.reload();
        } catch (_) {}

        final refreshedUser = _authService.currentUser;
        final isVerified = refreshedUser?.emailVerified ?? false;

        // If email is NOT verified, strictly block access to home screens
        if (!isVerified) {
          Preferences.isLogged = false;
          Get.offAllNamed(AppRoutes.emailVerificationView);
          AppSnackBar.warning(
            message: 'Please verify your email address to continue to RideLink.',
          );
          return;
        }

        // If email is verified and marked as logged in
        if (Preferences.isLogged) {
          NotificationService.instance.syncTokenToFirestore();
          if (Preferences.userRole == 'driver') {
            Get.offAllNamed(AppRoutes.driverDashboard);
          } else {
            Get.offAllNamed(AppRoutes.passengerDashboard);
          }
          return;
        }
      }

      // 2. Guard against invalid cache: if marked logged in but no verified user session
      if (Preferences.isLogged && (user == null || !user.emailVerified)) {
        Preferences.isLogged = false;
        Get.offAllNamed(AppRoutes.getStartedView);
        return;
      }

      // 3. Unauthenticated user: navigate to Get Started screen
      Get.offNamed(AppRoutes.getStartedView);
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
        Preferences.userPhone = AustralianPhoneHelper.formatToAustralian(
          phoneNumberController.text.trim(),
        );
      }

      // Sync FCM token to Firestore
      NotificationService.instance.syncTokenToFirestore();

      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      if (selectedUserType.value == UserType.driver) {
        Preferences.userRole = 'driver';
        Get.offNamed(AppRoutes.driverVerificaitonUploadView);
      } else {
        Preferences.userRole = 'passenger';
        Get.offAllNamed(AppRoutes.passengerDashboard);
      }

      Future.delayed(const Duration(milliseconds: 350), () {
        AppSnackBar.success(message: 'Email verified successfully!');
      });
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

    if (DisposableEmailChecker.isDisposable(email)) {
      AppSnackBar.error(
        message: 'Temporary or disposable email addresses are not allowed.',
      );
      return;
    }

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

      // Sync FCM token to Firestore
      NotificationService.instance.syncTokenToFirestore();

      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      if (role == 'driver') {
        selectedUserType.value = UserType.driver;
        Get.offAllNamed(AppRoutes.driverDashboard);
      } else {
        selectedUserType.value = UserType.passenger;
        Get.offAllNamed(AppRoutes.passengerDashboard);
      }

      Future.delayed(const Duration(milliseconds: 350), () {
        AppSnackBar.success(message: 'Welcome back!');
      });
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

    if (DisposableEmailChecker.isDisposable(email)) {
      AppSnackBar.error(
        message: 'Temporary or disposable email addresses are not allowed.',
      );
      return;
    }
    final fullName = fullNameController.text.trim();
    final phone = AustralianPhoneHelper.formatToAustralian(
      phoneNumberController.text.trim(),
    );

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

      // Sync FCM token
      NotificationService.instance.syncTokenToFirestore();

      startResendTimer(30);

      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      Get.toNamed(AppRoutes.emailVerificationView);

      Future.delayed(const Duration(milliseconds: 300), () {
        AppSnackBar.success(
          message:
              'Account created! A verification link was sent to $email. Please verify your email.',
        );
      });
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

    if (DisposableEmailChecker.isDisposable(email)) {
      AppSnackBar.error(
        message: 'Temporary or disposable email addresses are not allowed.',
      );
      return;
    }
    final fullName = fullNameController.text.trim();
    final phone = AustralianPhoneHelper.formatToAustralian(
      phoneNumberController.text.trim(),
    );

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

      // Sync FCM token
      NotificationService.instance.syncTokenToFirestore();

      startResendTimer(30);

      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      Get.toNamed(AppRoutes.emailVerificationView);

      Future.delayed(const Duration(milliseconds: 300), () {
        AppSnackBar.success(
          message:
              'Account created! A verification link was sent to $email. Please verify your email.',
        );
      });
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
    if (DisposableEmailChecker.isDisposable(email)) {
      AppSnackBar.error(
        message: 'Temporary or disposable email addresses are not allowed.',
      );
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
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 22.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 22.h,
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

        // Sync FCM token to Firestore
        NotificationService.instance.syncTokenToFirestore();

        if (Get.isSnackbarOpen) {
          Get.closeCurrentSnackbar();
        }

        final welcomeName = user.displayName ?? "RideLink user";
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

        Future.delayed(const Duration(milliseconds: 350), () {
          AppSnackBar.success(
            message: 'Welcome, $welcomeName!',
          );
        });
      }
    } catch (e) {
      AppSnackBar.error(message: _authService.getFriendlyErrorMessage(e));
    } finally {
      isGoogleLoading.value = false;
    }
  }

  Future<void> _pickAndUploadDocument({
    required String title,
    required String docId,
    required RxString pathObs,
    required RxString filePathObs,
    required Rx<DocumentVerificationStatus> statusObs,
  }) async {
    if (statusObs.value.isVerified) {
      AppSnackBar.info(
        message: '$title has already been verified and cannot be changed.',
      );
      return;
    }
    if (isDocUploading(docId)) {
      AppSnackBar.info(message: 'Document is already uploading. Please wait.');
      return;
    }

    await DocumentUploadPickerSheet.show(
      title: title,
      onSelected: (fileName, filePath) async {
        pathObs.value = fileName;
        filePathObs.value = filePath;

        final user = _authService.currentUser;
        if (user != null) {
          try {
            uploadingDocIds.add(docId);
            AppSnackBar.info(message: 'Document is uploading...');

            final downloadUrl = await DriverVerificationService.instance
                .uploadDriverDocument(
                  userId: user.uid,
                  docType: docId,
                  title: title,
                  fileName: fileName,
                  file: File(filePath),
                  status: DocumentVerificationStatus.pending.value,
                );

            if (downloadUrl.isNotEmpty) {
              statusObs.value = DocumentVerificationStatus.pending;
              AppSnackBar.success(message: '$title uploaded successfully.');

              if (Get.isRegistered<DriverProfileController>()) {
                Get.find<DriverProfileController>().reloadProfile();
              }
            }
          } catch (e) {
            AppSnackBar.error(message: 'Failed to upload $title: $e');
          } finally {
            uploadingDocIds.remove(docId);
          }
        } else {
          statusObs.value = DocumentVerificationStatus.pending;
          AppSnackBar.success(message: '$title photo attached.');
        }
      },
    );
  }

  Future<void> onSelectDrivingLicence() async {
    await _pickAndUploadDocument(
      title: 'Driving Licence',
      docId: DriverDocumentId.drivingLicence,
      pathObs: drivingLicencePath,
      filePathObs: drivingLicenceFilePath,
      statusObs: drivingLicenceStatus,
    );
  }

  Future<void> onSelectVehicleRegistration() async {
    await _pickAndUploadDocument(
      title: 'Vehicle Registration',
      docId: DriverDocumentId.vehicleRegistration,
      pathObs: vehicleRegistrationPath,
      filePathObs: vehicleRegistrationFilePath,
      statusObs: vehicleRegistrationStatus,
    );
  }

  Future<void> onSelectVehicleInsurance() async {
    await _pickAndUploadDocument(
      title: 'Vehicle Insurance',
      docId: DriverDocumentId.vehicleInsurance,
      pathObs: vehicleInsurancePath,
      filePathObs: vehicleInsuranceFilePath,
      statusObs: vehicleInsuranceStatus,
    );
  }

  Future<void> onSelectPoliceCheck() async {
    await _pickAndUploadDocument(
      title: 'Police Check',
      docId: DriverDocumentId.policeCheck,
      pathObs: policeCheckPath,
      filePathObs: policeCheckFilePath,
      statusObs: policeCheckStatus,
    );
  }

  Future<void> onSubmitForVerification() async {
    if (uploadingDocIds.isNotEmpty) {
      AppSnackBar.warning(
        message: 'Please wait until document upload finishes.',
      );
      return;
    }

    final plate = vehiclePlateController.text.trim();
    if (plate.isEmpty && Preferences.vehicleNumber.isEmpty) {
      AppSnackBar.warning(
        message: 'Please enter your vehicle plate number before submitting.',
      );
      return;
    }

    if (drivingLicenceFilePath.value.isEmpty ||
        vehicleRegistrationFilePath.value.isEmpty ||
        vehicleInsuranceFilePath.value.isEmpty) {
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
        DriverDocumentId.drivingLicence: {
          'title': 'Driving Licence',
          'fileName': drivingLicencePath.value,
          'filePath': drivingLicenceFilePath.value,
        },
        DriverDocumentId.vehicleRegistration: {
          'title': 'Vehicle Registration',
          'fileName': vehicleRegistrationPath.value,
          'filePath': vehicleRegistrationFilePath.value,
        },
        DriverDocumentId.vehicleInsurance: {
          'title': 'Vehicle Insurance',
          'fileName': vehicleInsurancePath.value,
          'filePath': vehicleInsuranceFilePath.value,
        },
      };

      if (policeCheckFilePath.value.isNotEmpty) {
        docs[DriverDocumentId.policeCheck] = {
          'title': 'Police Check',
          'fileName': policeCheckPath.value,
          'filePath': policeCheckFilePath.value,
        };
      }

      final plate = vehiclePlateController.text.trim();
      final makeModel = vehicleMakeModelController.text.trim();
      final color = vehicleColorController.text.trim();
      final type = selectedVehicleType.value;

      final Map<String, dynamic> vehicleInfo = {};
      if (plate.isNotEmpty) {
        vehicleInfo['licensePlate'] = plate;
        Preferences.vehicleNumber = plate;
      }
      if (makeModel.isNotEmpty) {
        vehicleInfo['make'] = makeModel;
        vehicleInfo['model'] = makeModel;
        Preferences.vehicleModel = makeModel;
      }
      if (color.isNotEmpty) {
        vehicleInfo['color'] = color;
        Preferences.vehicleColor = color;
      }
      if (vehicleInfo.isNotEmpty) {
        vehicleInfo['type'] = type;
        Preferences.vehicleType = type;
      }

      await DriverVerificationService.instance.submitAllDriverDocuments(
        userId: uid,
        documents: docs,
        vehicleInfo: vehicleInfo.isNotEmpty ? vehicleInfo : null,
      );

      // Update in-memory driver profile if already registered
      if (Get.isRegistered<DriverProfileController>()) {
        final driverProfileCtrl = Get.find<DriverProfileController>();
        if (plate.isNotEmpty) {
          driverProfileCtrl.updateVehicleInfo(
            number: plate,
            type: type,
            model: makeModel,
            color: color,
          );
        }
        driverProfileCtrl.reloadProfile();
      }

      drivingLicenceStatus.value = DocumentVerificationStatus.pending;
      vehicleRegistrationStatus.value = DocumentVerificationStatus.pending;
      vehicleInsuranceStatus.value = DocumentVerificationStatus.pending;
      if (policeCheckFilePath.value.isNotEmpty) {
        policeCheckStatus.value = DocumentVerificationStatus.pending;
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

  Future<void> loadExistingDriverDocuments() async {
    if (vehiclePlateController.text.isEmpty && Preferences.vehicleNumber.isNotEmpty) {
      vehiclePlateController.text = Preferences.vehicleNumber;
    }
    if (vehicleMakeModelController.text.isEmpty && Preferences.vehicleModel.isNotEmpty) {
      vehicleMakeModelController.text = Preferences.vehicleModel;
    }
    if (vehicleColorController.text.isEmpty && Preferences.vehicleColor.isNotEmpty) {
      vehicleColorController.text = Preferences.vehicleColor;
    }
    if (Preferences.vehicleType.isNotEmpty) {
      selectedVehicleType.value = Preferences.vehicleType;
    }

    final user = _authService.currentUser;
    if (user == null) return;
    try {
      final docs =
          await DriverVerificationService.instance.getDriverDocs(user.uid);
      if (docs.isEmpty) return;

      for (final entry in docs.entries) {
        final key = entry.key;
        final val = entry.value;
        String fileName = '';
        String url = '';
        String rawStatus = 'pending';
        String rejectionReason = '';
        if (val is Map) {
          fileName = val['file_name']?.toString() ??
              val['fileName']?.toString() ??
              '';
          url = val['file_url']?.toString() ??
              val['downloadUrl']?.toString() ??
              '';
          rawStatus = val['status']?.toString() ?? 'pending';
          rejectionReason = val['rejection_reason']?.toString() ?? '';
        } else if (val is String) {
          url = val;
        }

        final status = DocumentVerificationStatus.fromString(rawStatus);

        if (key == DriverDocumentId.drivingLicence) {
          if (drivingLicencePath.value.isEmpty && fileName.isNotEmpty) {
            drivingLicencePath.value = fileName;
          }
          if (drivingLicenceFilePath.value.isEmpty && url.isNotEmpty) {
            drivingLicenceFilePath.value = url;
          }
          if (url.isNotEmpty) {
            drivingLicenceStatus.value = status;
            drivingLicenceRejectionReason.value = rejectionReason;
          }
        } else if (key == DriverDocumentId.vehicleRegistration) {
          if (vehicleRegistrationPath.value.isEmpty && fileName.isNotEmpty) {
            vehicleRegistrationPath.value = fileName;
          }
          if (vehicleRegistrationFilePath.value.isEmpty && url.isNotEmpty) {
            vehicleRegistrationFilePath.value = url;
          }
          if (url.isNotEmpty) {
            vehicleRegistrationStatus.value = status;
            vehicleRegistrationRejectionReason.value = rejectionReason;
          }
        } else if (key == DriverDocumentId.vehicleInsurance) {
          if (vehicleInsurancePath.value.isEmpty && fileName.isNotEmpty) {
            vehicleInsurancePath.value = fileName;
          }
          if (vehicleInsuranceFilePath.value.isEmpty && url.isNotEmpty) {
            vehicleInsuranceFilePath.value = url;
          }
          if (url.isNotEmpty) {
            vehicleInsuranceStatus.value = status;
            vehicleInsuranceRejectionReason.value = rejectionReason;
          }
        } else if (key == DriverDocumentId.policeCheck) {
          if (policeCheckPath.value.isEmpty && fileName.isNotEmpty) {
            policeCheckPath.value = fileName;
          }
          if (policeCheckFilePath.value.isEmpty && url.isNotEmpty) {
            policeCheckFilePath.value = url;
          }
          if (url.isNotEmpty) {
            policeCheckStatus.value = status;
            policeCheckRejectionReason.value = rejectionReason;
          }
        }
      }
    } catch (_) {}
  }

  Future<void> onSkipDriverVerification() async {
    Preferences.isLogged = true;
    Preferences.userRole = 'driver';
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.offAllNamed(AppRoutes.driverDashboard);
    Future.delayed(const Duration(milliseconds: 350), () {
      AppSnackBar.info(
        message:
            'Document upload skipped. You can upload your verification documents anytime from your profile.',
      );
    });
  }

  Future<void> onVerificationSubmited() async {
    Preferences.isLogged = true;
    Preferences.userRole = 'driver';
    Get.offAllNamed(AppRoutes.driverDashboard);
  }
}
