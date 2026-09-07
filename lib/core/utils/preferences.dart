import 'dart:async';
import 'dart:convert';

import 'package:get_storage/get_storage.dart';

import '../../data/models/data/user_model.dart';

class Preferences {
  const Preferences._();

  static const String _user = 'user';
  static const String _deviceId = 'deviceId';
  static const String _isLogged = 'isLogged';
  static const String _token = 'token';

  static set deviceId(String? value) => GetStorage().write(_deviceId, value);
  static String? get deviceId => GetStorage().read(_deviceId);

  static set isLogged(bool value) => GetStorage().write(_isLogged, value);
  static bool get isLogged => GetStorage().read(_isLogged) ?? false;

  static set token(String? value) => GetStorage().write(_token, value);
  static String? get token => GetStorage().read(_token);

  static set user(User value) {
    final String encodedValue = jsonEncode(value.toJson());
    final GetStorage storage = GetStorage();
    unawaited(storage.write(_user, encodedValue));
  }

  /// Get user data (Put user model)
  static User get user {
    final storage = GetStorage();
    final String result = storage.read(_user) as String;
    return User.fromJson(json.decode(result) as Map<String, dynamic>);
  }

  /// Remove all user data and token
  static void logout() {
    final GetStorage storage = GetStorage();
    unawaited(storage.write(_isLogged, false));
    unawaited(storage.write(_token, null));
    unawaited(storage.write(_user, null));
    unawaited(storage.write(_deviceId, null));
  }
}
