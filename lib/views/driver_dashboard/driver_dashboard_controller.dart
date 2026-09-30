import 'package:get/get.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_community_controller.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_home_controller.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_profile_controller.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_support_controller.dart';
import 'package:ridelink/views/driver_dashboard/controllers/driver_trips_controller.dart';

export 'package:ridelink/data/models/driver/driver_models.dart';
export 'package:ridelink/views/driver_dashboard/controllers/driver_community_controller.dart';
export 'package:ridelink/views/driver_dashboard/controllers/driver_home_controller.dart';
export 'package:ridelink/views/driver_dashboard/controllers/driver_profile_controller.dart';
export 'package:ridelink/views/driver_dashboard/controllers/driver_support_controller.dart';
export 'package:ridelink/views/driver_dashboard/controllers/driver_trips_controller.dart';

class DriverDashboardController extends GetxController {
  // Navigation
  final RxInt currentTabIndex = 0.obs;

  // Domain Sub-Controllers
  late final DriverHomeController homeController;
  late final DriverTripsController tripsController;
  late final DriverCommunityController communityController;
  late final DriverSupportController supportController;
  late final DriverProfileController profileController;

  @override
  void onInit() {
    super.onInit();
    homeController = Get.isRegistered<DriverHomeController>()
        ? Get.find<DriverHomeController>()
        : Get.put<DriverHomeController>(DriverHomeController());

    tripsController = Get.isRegistered<DriverTripsController>()
        ? Get.find<DriverTripsController>()
        : Get.put<DriverTripsController>(DriverTripsController());

    communityController = Get.isRegistered<DriverCommunityController>()
        ? Get.find<DriverCommunityController>()
        : Get.put<DriverCommunityController>(DriverCommunityController());

    supportController = Get.isRegistered<DriverSupportController>()
        ? Get.find<DriverSupportController>()
        : Get.put<DriverSupportController>(DriverSupportController());

    profileController = Get.isRegistered<DriverProfileController>()
        ? Get.find<DriverProfileController>()
        : Get.put<DriverProfileController>(DriverProfileController());
  }

  void switchTab(int index) {
    currentTabIndex.value = index;
  }
}
