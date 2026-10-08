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
  static const String _userRole = 'userRole'; // 'passenger' or 'driver'
  static const String _userName = 'userName';
  static const String _userEmail = 'userEmail';
  static const String _userPhone = 'userPhone';
  static const String _rideOtp = 'rideOtp';
  static const String _pushBookingConfirmations = 'pushBookingConfirmations';
  static const String _pushDriverArrivalAlerts = 'pushDriverArrivalAlerts';
  static const String _pushTripStatusUpdates = 'pushTripStatusUpdates';
  static const String _pushDriverChatMessages = 'pushDriverChatMessages';
  static const String _pushSafetyAlerts = 'pushSafetyAlerts';

  static set deviceId(String? value) => GetStorage().write(_deviceId, value);
  static String? get deviceId => GetStorage().read(_deviceId);

  static set isLogged(bool value) => GetStorage().write(_isLogged, value);
  static bool get isLogged => GetStorage().read(_isLogged) ?? false;

  static set userRole(String? value) => GetStorage().write(_userRole, value);
  static String? get userRole => GetStorage().read(_userRole);

  static set token(String? value) => GetStorage().write(_token, value);
  static String? get token => GetStorage().read(_token);

  static set userName(String? value) => GetStorage().write(_userName, value);
  static String get userName => GetStorage().read(_userName) ?? '';

  static set userEmail(String? value) => GetStorage().write(_userEmail, value);
  static String get userEmail => GetStorage().read(_userEmail) ?? '';

  static set userPhone(String? value) => GetStorage().write(_userPhone, value);
  static String get userPhone => GetStorage().read(_userPhone) ?? '';

  static set rideOtp(String? value) => GetStorage().write(_rideOtp, value);
  static String get rideOtp => GetStorage().read(_rideOtp) ?? '';

  static set pushBookingConfirmations(bool value) =>
      GetStorage().write(_pushBookingConfirmations, value);
  static bool get pushBookingConfirmations =>
      GetStorage().read(_pushBookingConfirmations) ?? true;

  static set pushDriverArrivalAlerts(bool value) =>
      GetStorage().write(_pushDriverArrivalAlerts, value);
  static bool get pushDriverArrivalAlerts =>
      GetStorage().read(_pushDriverArrivalAlerts) ?? true;

  static set pushTripStatusUpdates(bool value) =>
      GetStorage().write(_pushTripStatusUpdates, value);
  static bool get pushTripStatusUpdates =>
      GetStorage().read(_pushTripStatusUpdates) ?? true;

  static set pushDriverChatMessages(bool value) =>
      GetStorage().write(_pushDriverChatMessages, value);
  static bool get pushDriverChatMessages =>
      GetStorage().read(_pushDriverChatMessages) ?? true;

  static set pushSafetyAlerts(bool value) =>
      GetStorage().write(_pushSafetyAlerts, value);
  static bool get pushSafetyAlerts =>
      GetStorage().read(_pushSafetyAlerts) ?? true;

  static const String _pushRideRequests = 'pushRideRequests';
  static const String _pushPassengerMessages = 'pushPassengerMessages';
  static const String _pushStatusUpdates = 'pushStatusUpdates';
  static const String _pushWeeklySummary = 'pushWeeklySummary';
  static const String _pushAdminAnnouncements = 'pushAdminAnnouncements';

  static set pushRideRequests(bool value) =>
      GetStorage().write(_pushRideRequests, value);
  static bool get pushRideRequests =>
      GetStorage().read(_pushRideRequests) ?? true;

  static set pushPassengerMessages(bool value) =>
      GetStorage().write(_pushPassengerMessages, value);
  static bool get pushPassengerMessages =>
      GetStorage().read(_pushPassengerMessages) ?? true;

  static set pushStatusUpdates(bool value) =>
      GetStorage().write(_pushStatusUpdates, value);
  static bool get pushStatusUpdates =>
      GetStorage().read(_pushStatusUpdates) ?? true;

  static set pushWeeklySummary(bool value) =>
      GetStorage().write(_pushWeeklySummary, value);
  static bool get pushWeeklySummary =>
      GetStorage().read(_pushWeeklySummary) ?? true;

  static set pushAdminAnnouncements(bool value) =>
      GetStorage().write(_pushAdminAnnouncements, value);
  static bool get pushAdminAnnouncements =>
      GetStorage().read(_pushAdminAnnouncements) ?? true;

  // Vehicle Information
  static const String _vehicleNumber = 'vehicleNumber';
  static const String _vehicleType = 'vehicleType';
  static const String _vehicleModel = 'vehicleModel';
  static const String _vehicleColor = 'vehicleColor';

  static set vehicleNumber(String? value) =>
      GetStorage().write(_vehicleNumber, value);
  static String get vehicleNumber =>
      GetStorage().read(_vehicleNumber) ?? '';

  static set vehicleType(String? value) =>
      GetStorage().write(_vehicleType, value);
  static String get vehicleType =>
      GetStorage().read(_vehicleType) ?? '';

  static set vehicleModel(String? value) =>
      GetStorage().write(_vehicleModel, value);
  static String get vehicleModel =>
      GetStorage().read(_vehicleModel) ?? '';

  static set vehicleColor(String? value) =>
      GetStorage().write(_vehicleColor, value);
  static String get vehicleColor =>
      GetStorage().read(_vehicleColor) ?? '';

  static set user(User value) {
    final String encodedValue = jsonEncode(value.toJson());
    final GetStorage storage = GetStorage();
    unawaited(storage.write(_user, encodedValue));
  }

  /// Get user data (Put user model)
  static User? get user {
    final storage = GetStorage();
    final dynamic result = storage.read(_user);
    if (result == null || result is! String) return null;
    return User.fromJson(json.decode(result) as Map<String, dynamic>);
  }

  /// Remove all user data and token
  static void logout() {
    final GetStorage storage = GetStorage();
    unawaited(storage.write(_isLogged, false));
    unawaited(storage.write(_token, null));
    unawaited(storage.write(_user, null));
    unawaited(storage.write(_deviceId, null));
    unawaited(storage.write(_userRole, null));
    unawaited(storage.write(_userName, null));
    unawaited(storage.write(_userEmail, null));
    unawaited(storage.write(_userPhone, null));
    unawaited(storage.write(_rideOtp, null));
    unawaited(storage.write(_vehicleNumber, null));
    unawaited(storage.write(_vehicleType, null));
    unawaited(storage.write(_vehicleModel, null));
    unawaited(storage.write(_vehicleColor, null));
  }
}
