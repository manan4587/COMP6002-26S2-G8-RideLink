import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData;

import '../../../core/utils/preferences.dart';
import '../../../routes/routes_name.dart';
import 'header_builder.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    super.onRequest(options, handler);

    String? token = Preferences.token;

    if (token != null) {
      if (options.data is FormData) {
        options.headers = HeaderBuilder()
            .setContentType('multipart/form-data')
            .setBearerToken(token)
            .build();
      } else {
        options.headers = HeaderBuilder().setBearerToken(token).build();
      }
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);
    if (err.response?.statusCode == 401) {
      Preferences.logout();
      Get.offAllNamed(RoutesName.loginView);
    }
  }
}
