import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';

class NetworkController extends GetxController {
  static NetworkController get instance => Get.find<NetworkController>();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Reactive boolean representing online status
  final RxBool isConnected = true.obs;

  /// Reactive boolean for active manual check loading state
  final RxBool isChecking = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChanged,
    );
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      await _evaluateConnection(results);
    } catch (e) {
      debugPrint('[NetworkController] Init connectivity check error: $e');
    }
  }

  Future<void> _handleConnectivityChanged(
    List<ConnectivityResult> results,
  ) async {
    await _evaluateConnection(results);
  }

  Future<bool> _evaluateConnection(List<ConnectivityResult> results) async {
    final hasNetworkInterface =
        results.isNotEmpty &&
        !results.every((r) => r == ConnectivityResult.none);

    if (!hasNetworkInterface) {
      isConnected.value = false;
      return false;
    }

    // Verify actual internet reachability via lightweight DNS probe
    final hasInternet = await _pingInternet();
    isConnected.value = hasInternet;
    return hasInternet;
  }

  Future<bool> _pingInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      // Fallback secondary probe if google.com query times out or fails
      try {
        final fallback = await InternetAddress.lookup(
          'one.one.one.one',
        ).timeout(const Duration(seconds: 4));
        return fallback.isNotEmpty && fallback[0].rawAddress.isNotEmpty;
      } catch (_) {
        return false;
      }
    }
  }

  /// Manual refresh triggered by user tapping the Refresh button on NoInternetPage
  Future<void> checkConnectionManually() async {
    if (isChecking.value) return;
    isChecking.value = true;
    try {
      final results = await _connectivity.checkConnectivity();
      final hasInternet = await _evaluateConnection(results);
      if (hasInternet) {
        AppSnackBar.success(message: 'Internet connection restored!');
      } else {
        AppSnackBar.info(
          message: 'Still offline. Please check your network and try again.',
        );
      }
    } finally {
      isChecking.value = false;
    }
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}

