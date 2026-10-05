import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/data/services/auth_service.dart';

class DriverHomeController extends GetxController {
  // Real-time Driver Stats
  final RxDouble todayEarnings = 0.0.obs;
  final RxDouble weeklyEarnings = 0.00.obs;
  final RxInt completedTripsCount = 0.obs;
  final RxDouble weeklyHours = 0.0.obs;
  final RxBool isOnline = true.obs;

  StreamSubscription? _authSubscription;
  StreamSubscription? _onlineSubscription;
  StreamSubscription? _statsSubscription;
  StreamSubscription? _userDocSubscription;

  @override
  void onInit() {
    super.onInit();
    final user = AuthService.instance.currentUser;
    if (user != null) {
      _listenToOnlineStatus(user.uid);
      _listenToDriverStats(user.uid);
    }

    _authSubscription = AuthService.instance.authStateChanges.listen((u) {
      if (u != null) {
        _listenToOnlineStatus(u.uid);
        _listenToDriverStats(u.uid);
      } else {
        clearState();
      }
    });
  }

  void _listenToDriverStats(String uid) {
    _statsSubscription?.cancel();
    _statsSubscription = AuthService.instance
        .streamUserProfile(uid)
        .listen(
          (profile) {
            if (profile != null) {
              // Read stats if available or user profile completed trips
              completedTripsCount.value = profile.tripsCompleted;
            }
          },
          onError: (err) {
            debugPrint('[DriverHomeController] Profile stats stream error: $err');
          },
        );

    // Also stream user doc directly to get todayEarnings and totalEarnings
    _userDocSubscription?.cancel();
    _userDocSubscription = AuthService.instance.userDocumentStream(uid).listen(
      (data) {
        if (data != null && data['driverStats'] is Map) {
          final stats = data['driverStats'] as Map;
          final today = (stats['todayEarnings'] as num?)?.toDouble() ?? 0.0;
          final total = (stats['totalEarnings'] as num?)?.toDouble() ?? 0.0;
          final trips = (stats['tripsCompleted'] as num?)?.toInt();
          todayEarnings.value = today;
          weeklyEarnings.value = total;
          if (trips != null) {
            completedTripsCount.value = trips;
          }
        }
      },
      onError: (err) {
        debugPrint('[DriverHomeController] User doc stream error: $err');
      },
    );
  }

  void _listenToOnlineStatus(String uid) {
    _onlineSubscription?.cancel();
    _onlineSubscription = AuthService.instance
        .streamUserOnlineStatus(uid)
        .listen(
          (status) {
            isOnline.value = status;
          },
          onError: (err) {
            debugPrint('[DriverHomeController] Online status stream error: $err');
          },
        );
  }

  Future<void> toggleOnlineStatus() async {
    final nextStatus = !isOnline.value;
    isOnline.value = nextStatus;
    await AuthService.instance.updateOnlineStatus(nextStatus);
    if (nextStatus) {
      AppSnackBar.success(
        message: "You are now Online! Passengers can request your rides.",
      );
    } else {
      AppSnackBar.info(
        message:
            "You are now Offline. Passengers will be informed that you might take longer to accept.",
      );
    }
  }

  void clearState() {
    _onlineSubscription?.cancel();
    _onlineSubscription = null;
    _statsSubscription?.cancel();
    _statsSubscription = null;
    _userDocSubscription?.cancel();
    _userDocSubscription = null;
    todayEarnings.value = 0.0;
    weeklyEarnings.value = 0.00;
    completedTripsCount.value = 0;
    weeklyHours.value = 0.0;
    isOnline.value = true;
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _authSubscription = null;
    _onlineSubscription?.cancel();
    _onlineSubscription = null;
    _statsSubscription?.cancel();
    _statsSubscription = null;
    _userDocSubscription?.cancel();
    _userDocSubscription = null;
    super.onClose();
  }
}

