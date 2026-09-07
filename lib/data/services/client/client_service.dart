// ignore_for_file: avoid_annotating_with_dynamic, avoid_dynamic_calls

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, Response;

import '../../../core/errors/error_message.dart';
import '../../../core/utils/preferences.dart';
import '../../../routes/routes_name.dart';
import '../../handler/api_endpoints_url.dart';
import '../connectivity_service.dart';
import 'base_response.dart';
import 'interceptor.dart';
import 'result.dart';

export 'base_response.dart';

// 200 = success
// 500 = Internal Server Error
// 401 = Unauthorized
// 403 = Forbidden
// 404 = Not Found

enum RequestType { get, post, delete, put, patch }

abstract class ClientService {
  final Dio _dio = Dio();

  Future<Result<BaseResponse<dynamic>, String>> request({
    required RequestType requestType,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    _dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      receiveDataWhenStatusError: true,
      sendTimeout: const Duration(minutes: 1),
      connectTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(minutes: 2),
    );

    if (data is FormData) {
      _dio.options.headers['Content-Type'] = 'multipart/form-data';
    }

    _dio.interceptors.clear();
    _dio.interceptors.addAll([
      AuthInterceptor(),
      if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
    ]);

    Response? response;

    try {
      if (await ConnectivityService.isConnected) {
        switch (requestType) {
          // GET
          case RequestType.get:
            response = await _dio.get(path, queryParameters: queryParameters);

          // POST
          case RequestType.post:
            response = await _dio.post(path, data: data);

          // PUT
          case RequestType.put:
            response = await _dio.put(path, data: data);

          // PATCH
          case RequestType.patch:
            response = await _dio.patch(path, data: data);

          // DELETE
          case RequestType.delete:
            response = await _dio.delete(path);
        }

        final result = BaseResponse.fromResponse(response.data);

        if (result.status == 200 || result.status == 201) {
          return Success(result);
        } else {
          return Failure(result.message);
        }
      } else {
        return Failure(ErrorMessage.noInternet);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        return Failure(ErrorMessage.tryAgain);
      }
      if (e.response?.statusCode == 422) {
        return Success(BaseResponse.fromResponse(e.response?.data));
      } else if (e.response?.statusCode == 401) {
        Preferences.logout();
        await Get.offAllNamed(RoutesName.loginView);
        return Failure(
          e.response?.data['message'] as String? ?? ErrorMessage.tryAgain,
        );
      } else if (e.response?.statusCode == 400 ||
          e.response?.statusCode == 404) {
        return Failure(
          e.response?.data['message'] as String? ?? ErrorMessage.tryAgain,
        );
      } else {
        if (e.response != null && e.response?.data != null) {
          final result = BaseResponse.fromResponse(e.response?.data);
          return Failure(result.message);
        } else {
          return Failure(ErrorMessage.tryAgain);
        }
      }
    } on Exception catch (_) {
      return Failure(ErrorMessage.tryAgain);
    }
  }
}

// Request type not found exception
class RequestTypeNotFoundException implements Exception {
  RequestTypeNotFoundException(this.cause);
  String cause;
}
