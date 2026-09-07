import 'package:get/get.dart';
import 'package:ridelink/routes/routes_name.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    Future.delayed(
      Duration(seconds: 2),
      () => Get.toNamed(RoutesName.loginView),
    );
    super.onInit();
  }
}
