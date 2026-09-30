import 'package:get/get.dart';

class DriverHomeController extends GetxController {
  // Real-time Driver Stats
  final RxDouble todayEarnings = 0.0.obs;
  final RxDouble weeklyEarnings = 0.00.obs;
  final RxInt completedTripsCount = 0.obs;
  final RxDouble weeklyHours = 0.0.obs;
  final RxBool isOnline = true.obs;

  void toggleOnlineStatus() {
    isOnline.value = !isOnline.value;
  }

  void clearState() {
    todayEarnings.value = 0.0;
    weeklyEarnings.value = 0.00;
    completedTripsCount.value = 0;
    weeklyHours.value = 0.0;
    isOnline.value = true;
  }
}
