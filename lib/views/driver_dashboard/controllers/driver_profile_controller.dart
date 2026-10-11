import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/driver_verification_service.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_controller.dart';
import 'package:ridelink/widgets/document_upload_picker_sheet.dart';

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
  final RxDouble driverRating = 5.0.obs;
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

  // Verification Status & Document Uploads (Direct map: url & status)
  final RxBool isVerifiedByAdmin = false.obs;
  final Rx<DocumentVerificationStatus> dlStatus =
      DocumentVerificationStatus.notUploaded.obs;
  final Rx<DocumentVerificationStatus> vrStatus =
      DocumentVerificationStatus.notUploaded.obs;
  final Rx<DocumentVerificationStatus> viStatus =
      DocumentVerificationStatus.notUploaded.obs;
  final Rx<DocumentVerificationStatus> pcStatus =
      DocumentVerificationStatus.optional.obs;

  // Track documents currently uploading to prevent duplicate uploads and show loaders
  final RxSet<String> uploadingDocIds = <String>{}.obs;
  bool isDocUploading(String docId) => uploadingDocIds.contains(docId);

  final RxString dlRejectionReason = ''.obs;
  final RxString vrRejectionReason = ''.obs;
  final RxString viRejectionReason = ''.obs;
  final RxString pcRejectionReason = ''.obs;

  final RxString drivingLicenceDoc = ''.obs;
  final RxString vehicleRegistrationDoc = ''.obs;
  final RxString vehicleInsuranceDoc = ''.obs;
  final RxString policeCheckDoc = ''.obs;

  final RxString drivingLicenceUrl =
      ''.obs; // Holds document URL/path for image preview
  final RxString vehicleRegistrationUrl =
      ''.obs; // Holds document URL/path for image preview
  final RxString vehicleInsuranceUrl =
      ''.obs; // Holds document URL/path for image preview
  final RxString policeCheckUrl =
      ''.obs; // Holds document URL/path for image preview

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
  StreamSubscription? _profileSubscription;

  DocumentVerificationStatus getDocStatus(String docId) {
    switch (docId) {
      case DriverDocumentId.drivingLicence:
        return dlStatus.value;
      case DriverDocumentId.vehicleRegistration:
        return vrStatus.value;
      case DriverDocumentId.vehicleInsurance:
        return viStatus.value;
      case DriverDocumentId.policeCheck:
        return pcStatus.value;
      default:
        return DocumentVerificationStatus.notUploaded;
    }
  }

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
    driverRating.value = 5.0;
    driverTripsCount.value = 0;
    vehicleModel.value = 'N/A';
    vehicleNumber.value = 'N/A';
    vehicleType.value = 'N/A';
    vehicleColor.value = 'N/A';
    dlStatus.value = DocumentVerificationStatus.notUploaded;
    drivingLicenceDoc.value = '';
    drivingLicenceUrl.value = '';
    dlRejectionReason.value = '';
    vrStatus.value = DocumentVerificationStatus.notUploaded;
    vehicleRegistrationDoc.value = '';
    vehicleRegistrationUrl.value = '';
    vrRejectionReason.value = '';
    viStatus.value = DocumentVerificationStatus.notUploaded;
    vehicleInsuranceDoc.value = '';
    vehicleInsuranceUrl.value = '';
    viRejectionReason.value = '';
    pcStatus.value = DocumentVerificationStatus.optional;
    policeCheckDoc.value = '';
    policeCheckUrl.value = '';
    pcRejectionReason.value = '';
    isVerifiedByAdmin.value = false;
    _docsSubscription?.cancel();
    _profileSubscription?.cancel();
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

    _profileSubscription?.cancel();
    _profileSubscription = AuthService.instance
        .streamUserProfile(user.uid)
        .listen(
          (profile) {
            if (profile != null) {
              if (profile.isVerifiedDriver) {
                isVerifiedByAdmin.value = true;
              }
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
              driverRating.value = profile.rating > 0 ? profile.rating : 5.0;
              driverTripsCount.value = profile.tripsCompleted;

              if (profile.vehicle != null) {
                final v = profile.vehicle!;
                final fullModel = '${v.make} ${v.model}'.trim();
                if (fullModel.isNotEmpty) {
                  vehicleModel.value = fullModel;
                  Preferences.vehicleModel = fullModel;
                }
                if (v.licensePlate.isNotEmpty) {
                  vehicleNumber.value = v.licensePlate;
                  Preferences.vehicleNumber = v.licensePlate;
                }
                if (v.color.isNotEmpty) {
                  vehicleColor.value = v.color;
                  Preferences.vehicleColor = v.color;
                }
                if (v.type.isNotEmpty) {
                  vehicleType.value = v.type;
                  Preferences.vehicleType = v.type;
                }
              }
            }
          },
          onError: (err) {
            debugPrint('[DriverProfileController] Profile stream error: $err');
          },
        );

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
        driverRating.value = profile.rating > 0 ? profile.rating : 5.0;
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
          if (vehicleModel.value != 'N/A') {
            Preferences.vehicleModel = vehicleModel.value;
          }
          if (vehicleNumber.value != 'N/A') {
            Preferences.vehicleNumber = vehicleNumber.value;
          }
          if (vehicleColor.value != 'N/A') {
            Preferences.vehicleColor = vehicleColor.value;
          }
          if (vehicleType.value != 'N/A') {
            Preferences.vehicleType = vehicleType.value;
          }
        } else {
          if (Preferences.vehicleModel.isNotEmpty && Preferences.vehicleModel != 'N/A') {
            vehicleModel.value = Preferences.vehicleModel;
          }
          if (Preferences.vehicleNumber.isNotEmpty && Preferences.vehicleNumber != 'N/A') {
            vehicleNumber.value = Preferences.vehicleNumber;
          }
          if (Preferences.vehicleColor.isNotEmpty && Preferences.vehicleColor != 'N/A') {
            vehicleColor.value = Preferences.vehicleColor;
          }
          if (Preferences.vehicleType.isNotEmpty && Preferences.vehicleType != 'N/A') {
            vehicleType.value = Preferences.vehicleType;
          }
        }
      }
    } catch (_) {}
  }

  void _listenToDriverDocuments(String userId) {
    _docsSubscription?.cancel();
    _docsSubscription = DriverVerificationService.instance
        .streamDriverDocsMap(userId)
        .listen((driverDocs) {
          // Reset states first so any document not uploaded stays Not Uploaded
          dlStatus.value = DocumentVerificationStatus.notUploaded;
          drivingLicenceDoc.value = '';
          drivingLicenceUrl.value = '';
          dlRejectionReason.value = '';

          vrStatus.value = DocumentVerificationStatus.notUploaded;
          vehicleRegistrationDoc.value = '';
          vehicleRegistrationUrl.value = '';
          vrRejectionReason.value = '';

          viStatus.value = DocumentVerificationStatus.notUploaded;
          vehicleInsuranceDoc.value = '';
          vehicleInsuranceUrl.value = '';
          viRejectionReason.value = '';

          pcStatus.value = DocumentVerificationStatus.optional;
          policeCheckDoc.value = '';
          policeCheckUrl.value = '';
          pcRejectionReason.value = '';

          for (final entry in driverDocs.entries) {
            final docId = entry.key;
            final dynamic val = entry.value;

            String fileUrl = '';
            DocumentVerificationStatus docStatus =
                DocumentVerificationStatus.pending;
            String fileName = '';
            String rejectionReason = '';

            if (val is Map) {
              fileUrl = val['file_url']?.toString() ??
                  val['downloadUrl']?.toString() ??
                  '';
              docStatus = DocumentVerificationStatus.fromString(
                val['status']?.toString(),
              );
              fileName = val['file_name']?.toString() ??
                  val['fileName']?.toString() ??
                  '';
              rejectionReason = val['rejection_reason']?.toString() ?? '';
            }

            final preview = fileUrl.trim();

            if (docId == DriverDocumentId.drivingLicence) {
              dlStatus.value = docStatus;
              drivingLicenceDoc.value = fileName.isNotEmpty
                  ? fileName
                  : 'Driving Licence Document';
              drivingLicenceUrl.value = preview;
              dlRejectionReason.value = rejectionReason;
            } else if (docId == DriverDocumentId.vehicleRegistration) {
              vrStatus.value = docStatus;
              vehicleRegistrationDoc.value = fileName.isNotEmpty
                  ? fileName
                  : 'Vehicle Registration Document';
              vehicleRegistrationUrl.value = preview;
              vrRejectionReason.value = rejectionReason;
            } else if (docId == DriverDocumentId.vehicleInsurance) {
              viStatus.value = docStatus;
              vehicleInsuranceDoc.value = fileName.isNotEmpty
                  ? fileName
                  : 'Vehicle Insurance Document';
              vehicleInsuranceUrl.value = preview;
              viRejectionReason.value = rejectionReason;
            } else if (docId == DriverDocumentId.policeCheck) {
              pcStatus.value = docStatus;
              policeCheckDoc.value = fileName.isNotEmpty
                  ? fileName
                  : 'Police Check Document';
              policeCheckUrl.value = preview;
              pcRejectionReason.value = rejectionReason;
            }
          }

          final bool allRequiredVerified =
              dlStatus.value.isVerified &&
              vrStatus.value.isVerified &&
              viStatus.value.isVerified;

          isVerifiedByAdmin.value = allRequiredVerified;
        },
        onError: (err) {
          debugPrint('[DriverProfileController] Docs stream error: $err');
        },
      );
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
    String? color,
  }) async {
    if (isVerifiedByAdmin.value) {
      AppSnackBar.warning(
        message:
            'Vehicle details are verified by admin and locked. Please contact support.',
      );
      return;
    }

    final cleanNumber = number.trim();
    final cleanType = type.trim();
    final cleanModel = model?.trim() ?? '';
    final cleanColor = color?.trim() ?? '';

    // 1. Update in-memory reactive observables immediately
    vehicleNumber.value = cleanNumber.isNotEmpty ? cleanNumber : 'N/A';
    vehicleType.value = cleanType.isNotEmpty ? cleanType : 'Sedan';
    if (cleanModel.isNotEmpty) {
      vehicleModel.value = cleanModel;
    }
    if (cleanColor.isNotEmpty) {
      vehicleColor.value = cleanColor;
    }

    // 2. Persist to local Preferences
    Preferences.vehicleNumber = vehicleNumber.value;
    Preferences.vehicleType = vehicleType.value;
    Preferences.vehicleModel = vehicleModel.value;
    if (cleanColor.isNotEmpty) {
      Preferences.vehicleColor = vehicleColor.value;
    }

    // 3. Save to Firestore database
    final user = AuthService.instance.currentUser;
    if (user != null) {
      try {
        await DriverVerificationService.instance.saveVehicleDetails(
          userId: user.uid,
          licensePlate: cleanNumber,
          vehicleType: cleanType,
          vehicleModel: cleanModel,
          vehicleColor: cleanColor.isNotEmpty ? cleanColor : vehicleColor.value,
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

  Future<void> uploadDocument(String docId) async {
    if (isVerifiedByAdmin.value || getDocStatus(docId).isVerified) {
      AppSnackBar.info(
        message:
            'This document has been verified by admin and cannot be changed.',
      );
      return;
    }
    if (isDocUploading(docId)) {
      AppSnackBar.info(message: 'Document is already uploading. Please wait.');
      return;
    }
    final user = AuthService.instance.currentUser;
    if (user == null) {
      AppSnackBar.error(message: 'Please log in to upload documents.');
      return;
    }

    String title = 'Document';
    if (docId == DriverDocumentId.drivingLicence) {
      title = 'Driving Licence';
    } else if (docId == DriverDocumentId.vehicleRegistration) {
      title = 'Vehicle Registration';
    } else if (docId == DriverDocumentId.vehicleInsurance) {
      title = 'Vehicle Insurance';
    } else if (docId == DriverDocumentId.policeCheck) {
      title = 'Police Check';
    }

    await DocumentUploadPickerSheet.show(
      title: title,
      onSelected: (fileName, filePath) async {
        await _saveDocFile(
          userId: user.uid,
          docKey: docId,
          title: title,
          fileName: fileName,
          filePath: filePath,
        );
      },
    );
  }

  Future<void> _saveDocFile({
    required String userId,
    required String docKey,
    required String title,
    required String fileName,
    required String filePath,
  }) async {
    if (isVerifiedByAdmin.value || getDocStatus(docKey).isVerified) {
      AppSnackBar.info(
        message:
            'This document has been verified by admin and cannot be changed.',
      );
      return;
    }
    if (uploadingDocIds.contains(docKey)) return;
    try {
      uploadingDocIds.add(docKey);
      AppSnackBar.info(message: 'Document is uploading...');

      final downloadUrl = await DriverVerificationService.instance
          .uploadDriverDocument(
            userId: userId,
            docType: docKey,
            title: title,
            fileName: fileName,
            file: File(filePath),
            status: DocumentVerificationStatus.pending.value,
          );

      // Immediately update local reactive state for instant UI reflection
      switch (docKey) {
        case DriverDocumentId.drivingLicence:
          dlStatus.value = DocumentVerificationStatus.pending;
          drivingLicenceDoc.value = fileName;
          drivingLicenceUrl.value = downloadUrl;
          dlRejectionReason.value = '';
          break;
        case DriverDocumentId.vehicleRegistration:
          vrStatus.value = DocumentVerificationStatus.pending;
          vehicleRegistrationDoc.value = fileName;
          vehicleRegistrationUrl.value = downloadUrl;
          vrRejectionReason.value = '';
          break;
        case DriverDocumentId.vehicleInsurance:
          viStatus.value = DocumentVerificationStatus.pending;
          vehicleInsuranceDoc.value = fileName;
          vehicleInsuranceUrl.value = downloadUrl;
          viRejectionReason.value = '';
          break;
        case DriverDocumentId.policeCheck:
          pcStatus.value = DocumentVerificationStatus.pending;
          policeCheckDoc.value = fileName;
          policeCheckUrl.value = downloadUrl;
          pcRejectionReason.value = '';
          break;
      }
      isVerifiedByAdmin.value = false;

      AppSnackBar.success(
        message:
            '$title uploaded successfully! Our team will review within 24 hours.',
      );
    } catch (e) {
      AppSnackBar.error(message: 'Failed to upload document: $e');
    } finally {
      uploadingDocIds.remove(docKey);
    }
  }

  // Safety & SOS actions
  Future<void> callEmergencyServices() async {
    try {
      await Utils.launchURL('tel:000');
    } catch (_) {
      AppSnackBar.warning(
        message: 'Could not open phone dialer. Please dial 000 immediately.',
      );
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
                    onPressed: () => Get.back(),
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
                      Get.back();
                      Preferences.logout();
                      if (Get.isRegistered<DriverDashboardController>()) {
                        Get.find<DriverDashboardController>().cleanupAll();
                      }
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
    final newStatus = isVerifiedByAdmin.value
        ? DocumentVerificationStatus.verified
        : DocumentVerificationStatus.pending;
    dlStatus.value = newStatus;
    vrStatus.value = newStatus;
    viStatus.value = newStatus;
    pcStatus.value = isVerifiedByAdmin.value
        ? DocumentVerificationStatus.verified
        : DocumentVerificationStatus.optional;

    final user = AuthService.instance.currentUser;
    if (user != null) {
      DriverVerificationService.instance.updateDocumentStatus(
        userId: user.uid,
        docType: DriverDocumentId.drivingLicence,
        status: newStatus.value,
      );
      DriverVerificationService.instance.updateDocumentStatus(
        userId: user.uid,
        docType: DriverDocumentId.vehicleRegistration,
        status: newStatus.value,
      );
      DriverVerificationService.instance.updateDocumentStatus(
        userId: user.uid,
        docType: DriverDocumentId.vehicleInsurance,
        status: newStatus.value,
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
      if (Get.isRegistered<DriverDashboardController>()) {
        Get.find<DriverDashboardController>().cleanupAll();
      }
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
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            18.verticalSpace,
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
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
                        'Delete Driver Account',
                        style: AppTextStyle.text18Semibold.copyWith(
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      Text(
                        'This action is irreversible',
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
              'Are you sure you want to permanently delete your driver account? All published trips, earnings history, vehicle documents, and ratings will be erased immediately.',
              style: AppTextStyle.text14Regular.copyWith(
                color: AppColors.secondaryTextColor,
                height: 1.45,
              ),
            ),
            22.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: const BorderSide(color: AppColors.borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.text14Semibold.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      deleteAccount();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Delete Account',
                      style: AppTextStyle.text14Semibold.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

  @override
  void onClose() {
    _authSubscription?.cancel();
    _docsSubscription?.cancel();
    _profileSubscription?.cancel();
    super.onClose();
  }
}
