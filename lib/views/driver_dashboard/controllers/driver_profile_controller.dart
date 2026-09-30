import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/driver_verification_service.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';

class DriverProfileController extends GetxController {
  // Driver Profile Information
  final RxString driverName = Preferences.userName.isEmpty
      ? 'N/A'.obs
      : Preferences.userName.obs;
  final RxString driverEmail = Preferences.userEmail.isEmpty
      ? 'N/A'.obs
      : Preferences.userEmail.obs;
  final RxString driverPhone = Preferences.userPhone.isEmpty
      ? 'N/A'.obs
      : Preferences.userPhone.obs;
  final RxDouble driverRating = 0.0.obs;
  final RxInt driverTripsCount = 0.obs;

  // Vehicle Information
  final RxString vehicleNumber =
      (Preferences.vehicleNumber.isNotEmpty ? Preferences.vehicleNumber : 'N/A')
          .obs;
  final RxString vehicleType =
      (Preferences.vehicleType.isNotEmpty ? Preferences.vehicleType : 'N/A')
          .obs;
  final RxString vehicleModel =
      (Preferences.vehicleModel.isNotEmpty ? Preferences.vehicleModel : 'N/A')
          .obs;
  final RxString vehicleColor =
      (Preferences.vehicleColor.isNotEmpty ? Preferences.vehicleColor : 'N/A')
          .obs;

  // Verification Status & Document Uploads
  final RxBool isVerifiedByAdmin = false.obs;
  final RxString dlStatus = 'Not Uploaded'.obs;
  final RxString vrStatus = 'Not Uploaded'.obs;
  final RxString viStatus = 'Not Uploaded'.obs;
  final RxString pcStatus = 'Optional'.obs;

  final RxString drivingLicenceDoc = ''.obs;
  final RxString vehicleRegistrationDoc = ''.obs;
  final RxString vehicleInsuranceDoc = ''.obs;
  final RxString policeCheckDoc = ''.obs;

  final RxString drivingLicenceBase64 = ''.obs;
  final RxString vehicleRegistrationBase64 = ''.obs;
  final RxString vehicleInsuranceBase64 = ''.obs;
  final RxString policeCheckBase64 = ''.obs;

  // Notification Preferences
  final RxBool pushRideRequests = Preferences.pushRideRequests.obs;
  final RxBool pushPassengerMessages = Preferences.pushPassengerMessages.obs;
  final RxBool pushStatusUpdates = Preferences.pushStatusUpdates.obs;
  final RxBool pushTripStatusUpdates = Preferences.pushTripStatusUpdates.obs;
  final RxBool pushWeeklySummary = Preferences.pushWeeklySummary.obs;
  final RxBool pushSafetyAlerts = Preferences.pushSafetyAlerts.obs;
  final RxBool pushAdminAnnouncements = Preferences.pushAdminAnnouncements.obs;

  StreamSubscription? _authSubscription;
  StreamSubscription? _docsSubscription;

  @override
  void onInit() {
    super.onInit();
    reloadProfile();

    _authSubscription = AuthService.instance.authStateChanges.listen((user) {
      if (user != null) {
        reloadProfile();
      } else {
        clearState();
      }
    });

    // Persist push notification preferences
    ever(pushRideRequests, (val) => Preferences.pushRideRequests = val);
    ever(
      pushPassengerMessages,
      (val) => Preferences.pushPassengerMessages = val,
    );
    ever(pushStatusUpdates, (val) => Preferences.pushStatusUpdates = val);
    ever(
      pushTripStatusUpdates,
      (val) => Preferences.pushTripStatusUpdates = val,
    );
    ever(pushWeeklySummary, (val) => Preferences.pushWeeklySummary = val);
    ever(pushSafetyAlerts, (val) => Preferences.pushSafetyAlerts = val);
    ever(
      pushAdminAnnouncements,
      (val) => Preferences.pushAdminAnnouncements = val,
    );
  }

  void clearState() {
    driverName.value = 'N/A';
    driverEmail.value = 'N/A';
    driverPhone.value = 'N/A';
    driverRating.value = 0.0;
    driverTripsCount.value = 0;
    vehicleModel.value = 'N/A';
    vehicleNumber.value = 'N/A';
    vehicleType.value = 'N/A';
    vehicleColor.value = 'N/A';
    dlStatus.value = 'Not Uploaded';
    drivingLicenceDoc.value = '';
    drivingLicenceBase64.value = '';
    vrStatus.value = 'Not Uploaded';
    vehicleRegistrationDoc.value = '';
    vehicleRegistrationBase64.value = '';
    viStatus.value = 'Not Uploaded';
    vehicleInsuranceDoc.value = '';
    vehicleInsuranceBase64.value = '';
    pcStatus.value = 'Optional';
    policeCheckDoc.value = '';
    policeCheckBase64.value = '';
    isVerifiedByAdmin.value = false;
    _docsSubscription?.cancel();
  }

  Future<void> reloadProfile() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      clearState();
      return;
    }

    if (Preferences.userName.isNotEmpty) {
      driverName.value = Preferences.userName;
    }
    if (Preferences.userEmail.isNotEmpty) {
      driverEmail.value = Preferences.userEmail;
    }
    if (Preferences.userPhone.isNotEmpty) {
      driverPhone.value = Preferences.userPhone;
    }

    _listenToDriverDocuments(user.uid);

    if (user.displayName != null && user.displayName!.isNotEmpty) {
      driverName.value = user.displayName!;
      Preferences.userName = user.displayName!;
    }
    if (user.email != null && user.email!.isNotEmpty) {
      driverEmail.value = user.email!;
      Preferences.userEmail = user.email!;
    }
    try {
      final profile = await AuthService.instance.getUserProfile(user.uid);
      if (profile != null) {
        driverRating.value = profile.rating;
        driverTripsCount.value = profile.tripsCompleted;
        if (profile.fullName.isNotEmpty) {
          driverName.value = profile.fullName;
          Preferences.userName = profile.fullName;
        }
        if (profile.email.isNotEmpty) {
          driverEmail.value = profile.email;
          Preferences.userEmail = profile.email;
        }
        if (profile.phoneNumber.isNotEmpty) {
          driverPhone.value = profile.phoneNumber;
          Preferences.userPhone = profile.phoneNumber;
        }
        isVerifiedByAdmin.value = profile.isVerifiedDriver;

        if (profile.vehicle != null) {
          final v = profile.vehicle!;
          final fullModel = '${v.make} ${v.model}'.trim();
          vehicleModel.value = fullModel.isNotEmpty ? fullModel : 'N/A';
          vehicleNumber.value = v.licensePlate.isNotEmpty
              ? v.licensePlate
              : 'N/A';
          vehicleColor.value = v.color.isNotEmpty ? v.color : 'N/A';
          vehicleType.value = v.type.isNotEmpty ? v.type : 'N/A';
          Preferences.vehicleModel = vehicleModel.value;
          Preferences.vehicleNumber = vehicleNumber.value;
          Preferences.vehicleColor = vehicleColor.value;
          Preferences.vehicleType = vehicleType.value;
        } else {
          vehicleModel.value = Preferences.vehicleModel.isNotEmpty
              ? Preferences.vehicleModel
              : 'N/A';
          vehicleNumber.value = Preferences.vehicleNumber.isNotEmpty
              ? Preferences.vehicleNumber
              : 'N/A';
          vehicleColor.value = Preferences.vehicleColor.isNotEmpty
              ? Preferences.vehicleColor
              : 'N/A';
          vehicleType.value = Preferences.vehicleType.isNotEmpty
              ? Preferences.vehicleType
              : 'N/A';
        }
      }
    } catch (_) {}
  }

  void _listenToDriverDocuments(String userId) {
    _docsSubscription?.cancel();
    _docsSubscription = DriverVerificationService.instance
        .streamDriverDocuments(userId)
        .listen((docs) {
          // Reset states first so any document not uploaded or deleted stays Not Uploaded
          dlStatus.value = 'Not Uploaded';
          drivingLicenceDoc.value = '';
          drivingLicenceBase64.value = '';

          vrStatus.value = 'Not Uploaded';
          vehicleRegistrationDoc.value = '';
          vehicleRegistrationBase64.value = '';

          viStatus.value = 'Not Uploaded';
          vehicleInsuranceDoc.value = '';
          vehicleInsuranceBase64.value = '';

          pcStatus.value = 'Optional';
          policeCheckDoc.value = '';
          policeCheckBase64.value = '';

          for (final doc in docs) {
            final rawType =
                doc['type']?.toString() ?? doc['id']?.toString() ?? '';
            final docType = rawType.toLowerCase().replaceAll(' ', '_');
            final fileName = doc['fileName']?.toString() ?? '';
            final fileUrl = doc['fileUrl']?.toString() ??
                doc['url']?.toString() ??
                doc['downloadUrl']?.toString() ??
                '';
            final base64 = doc['base64']?.toString() ?? '';
            final preview = fileUrl.trim().isNotEmpty ? fileUrl.trim() : base64.trim();
            final rawStatus = doc['status']?.toString() ?? 'Pending';
            final bool hasContent =
                preview.isNotEmpty || fileName.trim().isNotEmpty;
            final status = hasContent ? rawStatus : 'Not Uploaded';

            if (docType == 'driving_licence' ||
                docType == 'driving_license' ||
                docType == 'dl') {
              if (hasContent) {
                dlStatus.value = status;
                drivingLicenceDoc.value = fileName;
                drivingLicenceBase64.value = preview;
              }
            } else if (docType == 'vehicle_registration' || docType == 'vr') {
              if (hasContent) {
                vrStatus.value = status;
                vehicleRegistrationDoc.value = fileName;
                vehicleRegistrationBase64.value = preview;
              }
            } else if (docType == 'vehicle_insurance' || docType == 'vi') {
              if (hasContent) {
                viStatus.value = status;
                vehicleInsuranceDoc.value = fileName;
                vehicleInsuranceBase64.value = preview;
              }
            } else if (docType == 'police_check' || docType == 'pc') {
              if (hasContent) {
                pcStatus.value = status;
                policeCheckDoc.value = fileName;
                policeCheckBase64.value = preview;
              }
            }
          }

          final bool allRequiredVerified =
              dlStatus.value.trim().toLowerCase() == 'verified' &&
              vrStatus.value.trim().toLowerCase() == 'verified' &&
              viStatus.value.trim().toLowerCase() == 'verified';

          isVerifiedByAdmin.value = allRequiredVerified;
        });
  }

  String get driverInitials {
    final parts = driverName.value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty || parts[0] == 'N/A') return 'D';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Future<void> updateVehicleInfo({
    required String number,
    required String type,
    String? model,
  }) async {
    final cleanNumber = number.trim();
    final cleanType = type.trim();
    final cleanModel = model?.trim() ?? '';

    // 1. Update in-memory reactive observables immediately
    vehicleNumber.value = cleanNumber.isNotEmpty ? cleanNumber : 'N/A';
    vehicleType.value = cleanType.isNotEmpty ? cleanType : 'Sedan';
    if (cleanModel.isNotEmpty) {
      vehicleModel.value = cleanModel;
    }

    // 2. Persist to local Preferences
    Preferences.vehicleNumber = vehicleNumber.value;
    Preferences.vehicleType = vehicleType.value;
    Preferences.vehicleModel = vehicleModel.value;

    // 3. Save to Firestore database
    final user = AuthService.instance.currentUser;
    if (user != null) {
      try {
        await DriverVerificationService.instance.saveVehicleDetails(
          userId: user.uid,
          licensePlate: cleanNumber,
          vehicleType: cleanType,
          vehicleModel: cleanModel,
        );
        AppSnackBar.success(
          message: 'Vehicle registration saved to database successfully!',
        );
      } catch (e) {
        debugPrint(
          '[DriverProfileController] Error saving vehicle details to database: $e',
        );
        AppSnackBar.error(
          message: 'Failed to sync vehicle details to database: $e',
        );
      }
    } else {
      AppSnackBar.success(message: 'Vehicle & registration updated locally!');
    }
  }

  Future<void> uploadDocument(String documentType) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      AppSnackBar.error(message: 'Please log in to upload documents.');
      return;
    }

    await Get.bottomSheet(
      Material(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Document',
                style: AppTextStyle.text18Semibold.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              4.verticalSpace,
              Text(
                'Select source for your document image',
                style: AppTextStyle.text12Regular.copyWith(
                  color: AppColors.secondaryTextColor,
                ),
              ),
              16.verticalSpace,
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.primaryColor,
                ),
                title: Text('Take Photo', style: AppTextStyle.text14Semibold),
                onTap: () async {
                  Get.back();
                  await _pickAndSaveDoc(
                    user.uid,
                    documentType,
                    ImageSource.camera,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.primaryColor,
                ),
                title: Text(
                  'Choose from Gallery',
                  style: AppTextStyle.text14Semibold,
                ),
                onTap: () async {
                  Get.back();
                  await _pickAndSaveDoc(
                    user.uid,
                    documentType,
                    ImageSource.gallery,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndSaveDoc(
    String userId,
    String documentType,
    ImageSource source,
  ) async {
    try {
      final file = await Utils.pickImage(source);
      if (file == null) return;

      AppSnackBar.info(message: 'Uploading document to Firebase Storage...');
      final base64String = await Utils.xFileToBase64(file);
      final fileName = file.name.isNotEmpty
          ? file.name
          : '${documentType}_doc.jpg';

      String title = 'Document';
      String docKey = documentType;
      if (documentType.contains('licence') || documentType.contains('DL')) {
        title = 'Driving Licence';
        docKey = 'driving_licence';
      } else if (documentType.contains('rego') ||
          documentType.contains('VR') ||
          documentType.contains('registration')) {
        title = 'Vehicle Registration';
        docKey = 'vehicle_registration';
      } else if (documentType.contains('insurance') ||
          documentType.contains('VI')) {
        title = 'Vehicle Insurance';
        docKey = 'vehicle_insurance';
      } else if (documentType.contains('police') ||
          documentType.contains('PC')) {
        title = 'Police Check';
        docKey = 'police_check';
      }

      final downloadUrl =
          await DriverVerificationService.instance.uploadDriverDocument(
        userId: userId,
        docType: docKey,
        title: title,
        fileName: fileName,
        file: File(file.path),
        base64Data: base64String,
        status: 'Pending',
      );

      final previewContent =
          downloadUrl.isNotEmpty ? downloadUrl : (base64String ?? '');

      // Immediately update local reactive state for instant UI reflection
      switch (docKey) {
        case 'driving_licence':
          dlStatus.value = 'Pending';
          drivingLicenceDoc.value = fileName;
          drivingLicenceBase64.value = previewContent;
          break;
        case 'vehicle_registration':
          vrStatus.value = 'Pending';
          vehicleRegistrationDoc.value = fileName;
          vehicleRegistrationBase64.value = previewContent;
          break;
        case 'vehicle_insurance':
          viStatus.value = 'Pending';
          vehicleInsuranceDoc.value = fileName;
          vehicleInsuranceBase64.value = previewContent;
          break;
        case 'police_check':
          pcStatus.value = 'Pending';
          policeCheckDoc.value = fileName;
          policeCheckBase64.value = previewContent;
          break;
      }
      isVerifiedByAdmin.value = false;

      AppSnackBar.success(
        message:
            '$title uploaded successfully! Our team will review within 24 hours.',
      );
    } catch (e) {
      AppSnackBar.error(message: 'Failed to upload document: $e');
    }
  }

  // Safety & SOS actions
  Future<void> callEmergencyServices() async {
    try {
      await Utils.launchURL('tel:000');
    } catch (_) {
      AppSnackBar.info(message: 'Calling Emergency Services (000)...');
    }
  }

  Future<void> callSafetyHotline() async {
    try {
      await Utils.launchURL('tel:1800743354');
    } catch (_) {
      AppSnackBar.info(message: 'Calling RideLink 24/7 Safety Hotline...');
    }
  }

  Future<void> sendSafetyEmail() async {
    try {
      await Utils.launchURL(
        'mailto:safety@ridelink.com?subject=Urgent%20Driver%20Safety%20Inquiry',
      );
    } catch (_) {
      AppSnackBar.info(message: 'Opening mail to safety@ridelink.com...');
    }
  }

  // Profile Mode Switcher: Driver -> Passenger
  void switchToPassengerMode() {
    Preferences.userRole = 'passenger';
    unawaited(AuthService.instance.updateActiveRole('passenger'));
    Get.offAllNamed(AppRoutes.passengerDashboard);
    AppSnackBar.success(
      message: 'Switched to Passenger Mode. Ready to search rides!',
    );
  }

  // Logout Confirmation Bottom Sheet
  void confirmLogout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          top: 12.h,
          left: 20.w,
          right: 20.w,
          bottom: MediaQuery.of(context).padding.bottom + 20.h,
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
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.red,
                    size: 24,
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log Out',
                        style: AppTextStyle.text18Semibold.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      2.verticalSpace,
                      Text(
                        'Confirm session termination',
                        style: AppTextStyle.text12Regular.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            16.verticalSpace,
            Text(
              'Are you sure you want to log out of your RideLink driver account? You will need to log back in to manage your rides and receive bookings.',
              style: AppTextStyle.text14Medium.copyWith(
                color: AppColors.primaryTextColor,
                height: 1.4,
              ),
            ),
            20.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderColor),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.text14Medium.copyWith(
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      Preferences.logout();
                      await AuthService.instance.signOut();
                      Get.offAllNamed(AppRoutes.getStartedView);
                      AppSnackBar.info(message: 'Logged out successfully.');
                    },
                    child: Text(
                      'Log Out',
                      style: AppTextStyle.text14Semibold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void toggleAdminVerification() {
    isVerifiedByAdmin.value = !isVerifiedByAdmin.value;
    final newStatus = isVerifiedByAdmin.value ? 'Verified' : 'Pending';
    dlStatus.value = newStatus;
    vrStatus.value = newStatus;
    viStatus.value = newStatus;
    pcStatus.value = isVerifiedByAdmin.value ? 'Verified' : 'Optional';

    final user = AuthService.instance.currentUser;
    if (user != null) {
      DriverVerificationService.instance.updateDocumentStatus(
        userId: user.uid,
        docType: 'driving_licence',
        status: newStatus,
      );
      DriverVerificationService.instance.updateDocumentStatus(
        userId: user.uid,
        docType: 'vehicle_registration',
        status: newStatus,
      );
      DriverVerificationService.instance.updateDocumentStatus(
        userId: user.uid,
        docType: 'vehicle_insurance',
        status: newStatus,
      );
    }

    if (isVerifiedByAdmin.value) {
      AppSnackBar.success(
        message: 'Admin simulation: Driver documents verified!',
      );
    } else {
      AppSnackBar.info(
        message: 'Admin simulation: Driver verification reset to pending.',
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user != null) {
        await AuthService.instance.deleteAccount();
      }
      Preferences.logout();
      Get.offAllNamed(AppRoutes.getStartedView);
      AppSnackBar.success(message: 'Account deleted successfully.');
    } catch (e) {
      AppSnackBar.error(message: 'Failed to delete account: $e');
    }
  }

  void confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your driver account? All trips, earnings history, and ratings will be erased. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              deleteAccount();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _docsSubscription?.cancel();
    super.onClose();
  }
}
