import 'package:get/get.dart';
import 'package:ridelink/views/auth_flow/view/create_account_view.dart';
import 'package:ridelink/views/auth_flow/view/driver_verification_upload_view.dart';
import 'package:ridelink/views/auth_flow/view/email_verification_view.dart';
import 'package:ridelink/views/auth_flow/view/get_started_view.dart';
import 'package:ridelink/views/auth_flow/view/login_view.dart';
import 'package:ridelink/views/auth_flow/view/splash_view.dart';
import 'package:ridelink/views/auth_flow/view/verification_submitted_view.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_view.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_view.dart';

import 'routes_name.dart';

GetPage getPage({
  String? name,
  GetPageBuilder? page,
  Bindings? binding,
  List<GetPage<dynamic>>? children,
}) {
  return GetPage(
    name: name!,
    page: page!,
    binding: binding,
    children: children ?? [],
    participatesInRootNavigator: true,
    popGesture: true,
  );
}

List<GetPage> pages = [
  getPage(name: AppRoutes.splashView, page: () => const SplashView()),
  getPage(name: AppRoutes.getStartedView, page: () => const GetStartedView()),
  getPage(name: AppRoutes.loginView, page: () => const LoginView()),
  getPage(
    name: AppRoutes.createAccountView,
    page: () => const CreateAccountView(),
  ),
  getPage(
    name: AppRoutes.driverVerificaitonUploadView,
    page: () => const DriverVerificationUploadView(),
  ),
  getPage(
    name: AppRoutes.verificationSubmittedView,
    page: () => const VerificationSubmittedView(),
  ),
  getPage(
    name: AppRoutes.emailVerificationView,
    page: () => const EmailVerificationView(),
  ),
  getPage(
    name: AppRoutes.passengerDashboard,
    page: () => const PassengerDashboardView(),
  ),
  getPage(
    name: AppRoutes.driverDashboard,
    page: () => const DriverDashboardView(),
  ),
];
