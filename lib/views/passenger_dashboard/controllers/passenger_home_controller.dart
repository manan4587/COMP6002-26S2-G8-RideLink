import 'dart:async';

import 'package:get/get.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class PassengerHomeController extends GetxController {
  // Passenger Trust Rating
  final RxDouble trustRating = 0.0.obs;

  // Recent Routes
  final RxList<RecentRouteModel> recentRoutes = <RecentRouteModel>[].obs;

  StreamSubscription? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _authSubscription = AuthService.instance.authStateChanges.listen((u) {
      if (u == null) {
        clearState();
      } else {
        loadUserStats(u.uid);
      }
    });
    final currentUser = AuthService.instance.currentUser;
    if (currentUser != null) {
      loadUserStats(currentUser.uid);
    }
  }

  Future<void> loadUserStats(String uid) async {
    try {
      final profile = await AuthService.instance.getUserProfile(uid);
      if (profile != null) {
        trustRating.value = profile.rating;
      }
    } catch (_) {}
  }

  void reloadHome() {
    final currentUser = AuthService.instance.currentUser;
    if (currentUser != null) {
      loadUserStats(currentUser.uid);
    }
  }

  void clearState() {
    trustRating.value = 0.0;
    recentRoutes.clear();
  }

  void selectRecentRoute(RecentRouteModel route) {
    if (Get.isRegistered<PassengerDashboardController>()) {
      final dash = Get.find<PassengerDashboardController>();
      dash.fromLocationController.text = route.from;
      dash.toLocationController.text = route.to;
      dash.switchTab(1); // Jump to Search Page
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}

