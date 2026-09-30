import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/data/models/passenger/passenger_models.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';

class PassengerProfileController extends GetxController {
  // Passenger Profile Info
  final RxString passengerName = Preferences.userName.obs;
  final RxString passengerEmail = Preferences.userEmail.obs;
  final RxString passengerPhone = Preferences.userPhone.obs;
  final RxDouble passengerRating = 0.0.obs;
  final RxInt tripsCount = 0.obs;

  // Saved Locations
  final RxList<SavedLocationModel> savedLocations = <SavedLocationModel>[].obs;

  // Emergency Contacts
  final RxList<PassengerEmergencyContactModel> emergencyContacts =
      <PassengerEmergencyContactModel>[].obs;

  // Push Notifications Preferences
  final RxBool pushBookingConfirmations = Preferences.pushBookingConfirmations.obs;
  final RxBool pushDriverArrivalAlerts = Preferences.pushDriverArrivalAlerts.obs;
  final RxBool pushTripStatusUpdates = Preferences.pushTripStatusUpdates.obs;
  final RxBool pushDriverChatMessages = Preferences.pushDriverChatMessages.obs;
  final RxBool pushSafetyAlerts = Preferences.pushSafetyAlerts.obs;

  StreamSubscription? _authSubscription;

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

    // Persist push notification preference changes
    ever(pushBookingConfirmations, (val) => Preferences.pushBookingConfirmations = val);
    ever(pushDriverArrivalAlerts, (val) => Preferences.pushDriverArrivalAlerts = val);
    ever(pushTripStatusUpdates, (val) => Preferences.pushTripStatusUpdates = val);
    ever(pushDriverChatMessages, (val) => Preferences.pushDriverChatMessages = val);
    ever(pushSafetyAlerts, (val) => Preferences.pushSafetyAlerts = val);
  }

  void clearState() {
    passengerName.value = 'N/A';
    passengerEmail.value = 'N/A';
    passengerPhone.value = 'N/A';
    passengerRating.value = 0.0;
    tripsCount.value = 0;
    savedLocations.clear();
    emergencyContacts.clear();
  }

  Future<void> reloadProfile() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      clearState();
      return;
    }

    if (Preferences.userName.isNotEmpty) {
      passengerName.value = Preferences.userName;
    }
    if (Preferences.userEmail.isNotEmpty) {
      passengerEmail.value = Preferences.userEmail;
    }
    if (Preferences.userPhone.isNotEmpty) {
      passengerPhone.value = Preferences.userPhone;
    }

    savedLocations.clear();
    emergencyContacts.clear();
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      passengerName.value = user.displayName!;
      Preferences.userName = user.displayName!;
    }
      if (user.email != null && user.email!.isNotEmpty) {
        passengerEmail.value = user.email!;
        Preferences.userEmail = user.email!;
      }
      try {
        final profile = await AuthService.instance.getUserProfile(user.uid);
        if (profile != null) {
          passengerRating.value = profile.rating;
          tripsCount.value = profile.tripsCompleted;
          if (profile.fullName.isNotEmpty) {
            passengerName.value = profile.fullName;
            Preferences.userName = profile.fullName;
          }
          if (profile.email.isNotEmpty) {
            passengerEmail.value = profile.email;
            Preferences.userEmail = profile.email;
          }
          if (profile.phoneNumber.isNotEmpty) {
            passengerPhone.value = profile.phoneNumber;
            Preferences.userPhone = profile.phoneNumber;
          }

          if (profile.savedLocations.isNotEmpty) {
            savedLocations.assignAll(
              profile.savedLocations.map(
                (loc) => SavedLocationModel(
                  id: loc.id,
                  title: loc.label,
                  address: loc.address,
                  category: loc.label.toLowerCase().contains('home')
                      ? 'home'
                      : loc.label.toLowerCase().contains('work')
                          ? 'work'
                          : loc.label.toLowerCase().contains('uni')
                              ? 'university'
                              : 'custom',
                ),
              ),
            );
          }

          if (profile.emergencyContacts.isNotEmpty) {
            emergencyContacts.assignAll(
              profile.emergencyContacts.asMap().entries.map(
                (entry) => PassengerEmergencyContactModel(
                  id: 'emg_${entry.key}',
                  name: entry.value.name,
                  relation: entry.value.relationship,
                  phone: entry.value.phone,
                  isPrimary: entry.key == 0,
                ),
              ),
            );
          }
        }
      } catch (_) {}
  }

  String get passengerInitials {
    final parts = passengerName.value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Future<void> updatePassengerProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    if (name.trim().isNotEmpty) {
      passengerName.value = name.trim();
      Preferences.userName = name.trim();
    }
    if (email.trim().isNotEmpty) {
      passengerEmail.value = email.trim();
      Preferences.userEmail = email.trim();
    }
    if (phone.trim().isNotEmpty) {
      passengerPhone.value = phone.trim();
      Preferences.userPhone = phone.trim();
    }

    try {
      await AuthService.instance.updateProfile(
        fullName: name.trim(),
        email: email.trim(),
        phoneNumber: phone.trim(),
      );
    } catch (_) {}

    AppSnackBar.success(message: 'Profile updated successfully!');
  }

  // Saved Locations Management
  Future<void> addSavedLocation({
    required String title,
    required String address,
    required String category,
  }) async {
    final newLoc = SavedLocationModel(
      id: 'loc_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      address: address.trim(),
      category: category,
    );
    savedLocations.add(newLoc);
    _syncSavedLocationsToFirestore();
    AppSnackBar.success(message: 'Saved "$title" to your favourite locations.');
  }

  Future<void> deleteSavedLocation(String id) async {
    savedLocations.removeWhere((loc) => loc.id == id);
    _syncSavedLocationsToFirestore();
    AppSnackBar.info(message: 'Location removed.');
  }

  Future<void> removeSavedLocation(String id) => deleteSavedLocation(id);

  void _syncSavedLocationsToFirestore() {
    try {
      final list = savedLocations
          .map(
            (l) => {
              'id': l.id,
              'label': l.title,
              'address': l.address,
              'latitude': 0.0,
              'longitude': 0.0,
            },
          )
          .toList();
      AuthService.instance.updateSavedLocations(list);
    } catch (_) {}
  }

  // Emergency Contacts Management
  Future<void> addEmergencyContact({
    required String name,
    required String relation,
    required String phone,
    bool isPrimary = false,
  }) async {
    if (isPrimary) {
      for (final c in emergencyContacts) {
        c.isPrimary.value = false;
      }
    }
    final newContact = PassengerEmergencyContactModel(
      id: 'emg_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      relation: relation.trim(),
      phone: phone.trim(),
      isPrimary: isPrimary,
    );
    emergencyContacts.add(newContact);
    _syncEmergencyContactsToFirestore();
    AppSnackBar.success(message: 'Added $name as emergency contact.');
  }

  Future<void> deleteEmergencyContact(String id) async {
    emergencyContacts.removeWhere((c) => c.id == id);
    _syncEmergencyContactsToFirestore();
    AppSnackBar.info(message: 'Emergency contact removed.');
  }

  Future<void> removeEmergencyContact(String id) => deleteEmergencyContact(id);

  Future<void> updateEmergencyContact({
    required String id,
    required String name,
    required String relation,
    required String phone,
    bool isPrimary = false,
  }) async {
    final idx = emergencyContacts.indexWhere((c) => c.id == id);
    if (idx != -1) {
      if (isPrimary) {
        for (final c in emergencyContacts) {
          c.isPrimary.value = false;
        }
      }
      emergencyContacts[idx] = PassengerEmergencyContactModel(
        id: id,
        name: name.trim(),
        relation: relation.trim(),
        phone: phone.trim(),
        isPrimary: isPrimary,
      );
      _syncEmergencyContactsToFirestore();
      AppSnackBar.success(message: 'Emergency contact updated.');
    }
  }

  Future<void> setPrimaryEmergencyContact(String id) async {
    for (final c in emergencyContacts) {
      c.isPrimary.value = (c.id == id);
    }
    _syncEmergencyContactsToFirestore();
    AppSnackBar.success(message: 'Primary emergency contact updated.');
  }

  void switchToDriverMode() {
    Preferences.userRole = 'driver';
    unawaited(AuthService.instance.updateActiveRole('driver'));
    Get.offAllNamed(AppRoutes.driverDashboard);
    AppSnackBar.success(message: 'Switched to Driver Mode.');
  }

  void _syncEmergencyContactsToFirestore() {
    try {
      final data = emergencyContacts
          .map(
            (c) => {
              'name': c.name,
              'relationship': c.relation,
              'phone': c.phone,
            },
          )
          .toList();
      AuthService.instance.updateEmergencyContacts(data);
    } catch (_) {}
  }

  // Safety & SOS Actions
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
      AppSnackBar.info(
        message: 'Calling RideLink 24/7 Passenger Safety Hotline...',
      );
    }
  }

  Future<void> sendSafetyEmail() async {
    try {
      await Utils.launchURL(
        'mailto:safety@ridelink.com?subject=Urgent%20Passenger%20Safety%20Inquiry',
      );
    } catch (_) {
      AppSnackBar.info(message: 'Opening mail to safety@ridelink.com...');
    }
  }

  // Logout Bottom Sheet
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
                        'Confirm passenger session end',
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
              'Are you sure you want to log out of your RideLink passenger account? You will need to log back in to book rides or view your scheduled carpools.',
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

  // Delete Account Bottom Sheet
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
                        'Delete Account',
                        style: AppTextStyle.text18Semibold.copyWith(
                          color: AppColors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      2.verticalSpace,
                      Text(
                        'Permanent action • Cannot be undone',
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
              'Are you sure you want to delete your passenger account? This action is permanent and will permanently erase your passenger profile, saved favourite locations, and booking history.',
              style: AppTextStyle.text14Medium.copyWith(
                color: AppColors.primaryTextColor,
                height: 1.4,
              ),
            ),
            12.verticalSpace,
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.red,
                    size: 18,
                  ),
                  8.horizontalSpace,
                  Expanded(
                    child: Text(
                      'Any upcoming or active ride bookings will be automatically cancelled with the drivers.',
                      style: AppTextStyle.text12Regular.copyWith(
                        color: const Color(0xFF991B1B),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
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
                      'Keep Account',
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
                      try {
                        await AuthService.instance.deleteAccount();
                      } catch (_) {}
                      Preferences.logout();
                      Get.offAllNamed(AppRoutes.getStartedView);
                      AppSnackBar.success(
                        message: 'Your account has been deleted permanently.',
                      );
                    },
                    child: Text(
                      'Delete Forever',
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

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}

