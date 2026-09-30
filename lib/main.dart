import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ridelink/core/services/notification_service.dart';
import 'package:ridelink/routes/routes.dart';
import 'package:ridelink/views/auth_flow/auth_controller.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_controller.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

import 'core/utils/stretch_scroll_behavior.dart';
import 'core/utils/utils.dart';
import 'firebase_options.dart';
import 'routes/routes_name.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService.instance.init();
  Utils.darkStatusBar();
  await Utils.screenPortrait();
  Utils.hideKeyboard();
  await GetStorage.init();
  _appDepencyBiding();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,

      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'RideLink',
          themeMode: ThemeMode.light,
          getPages: pages,
          initialRoute: AppRoutes.splashView,
          scrollBehavior: ScrollBehaviorModified(),
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            final scale = mediaQueryData.textScaler.clamp(
              minScaleFactor: 1.0,
              maxScaleFactor: 1.14,
            );
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: scale),
              child: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}

void _appDepencyBiding() {
  Get.put<AuthController>(AuthController());
  Get.put<DriverHomeController>(DriverHomeController());
  Get.put<DriverTripsController>(DriverTripsController());
  Get.put<DriverSupportController>(DriverSupportController());
  Get.put<DriverProfileController>(DriverProfileController());
  Get.put<DriverDashboardController>(DriverDashboardController());
  Get.put<PassengerDashboardController>(PassengerDashboardController());
}
