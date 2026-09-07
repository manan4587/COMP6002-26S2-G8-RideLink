import 'package:get/get.dart';
import 'package:ridelink/views/auth_flow/login/login_bindings.dart';
import 'package:ridelink/views/auth_flow/login/login_view.dart';
import 'package:ridelink/views/auth_flow/splash/splash_bindings.dart';
import 'package:ridelink/views/auth_flow/splash/splash_view.dart';

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
  getPage(
    name: RoutesName.splashView,
    page: () => const SplashView(),
    binding: SplashBindings(),
  ),
  getPage(
    name: RoutesName.loginView,
    page: () => const LoginView(),
    binding: LoginBindings(),
  ),
];
