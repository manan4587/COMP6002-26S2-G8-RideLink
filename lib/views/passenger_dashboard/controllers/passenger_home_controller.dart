import 'dart:async';

import 'package:get/get.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class PassengerHomeController extends GetxController {
  // Passenger Trust Rating
  final RxDouble trustRating = 5.0.obs;

  // Recent Routes
  final RxList<RecentRouteModel> recentRoutes = <RecentRouteModel>[].obs;

  StreamSubscription? _authSubscription;
  StreamSubscription? _profileSubscription;

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

  void loadUserStats(String uid) {
    _profileSubscription?.cancel();
    AuthService.instance.getUserProfile(uid).then((profile) {
      if (profile != null) {
        trustRating.value = profile.rating > 0 ? profile.rating : 5.0;
      }
    }).catchError((_) {});

    _profileSubscription =
        AuthService.instance.streamUserProfile(uid).listen((profile) {
      if (profile != null) {
        trustRating.value = profile.rating > 0 ? profile.rating : 5.0;
      }
    });
  }

  void reloadHome() {
    final currentUser = AuthService.instance.currentUser;
    if (currentUser != null) {
      loadUserStats(currentUser.uid);
    }
  }

  void clearState() {
    _profileSubscription?.cancel();
    _profileSubscription = null;
    trustRating.value = 5.0;
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
    _profileSubscription?.cancel();
    super.onClose();
  }
}

