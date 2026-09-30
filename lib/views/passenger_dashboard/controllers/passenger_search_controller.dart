import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/data/models/passenger/passenger_models.dart';
import 'package:ridelink/data/services/auth_service.dart';

class PassengerSearchController extends GetxController {
  StreamSubscription? _authSubscription;

  // Search Inputs
  final TextEditingController fromLocationController = TextEditingController(
    text: '',
  );
  final TextEditingController toLocationController = TextEditingController(
    text: '',
  );

  final RxDouble fromLat = (-31.8156).obs;
  final RxDouble fromLng = (115.8452).obs;
  final RxDouble toLat = (-32.0044).obs;
  final RxDouble toLng = (115.8947).obs;

  final RxString selectedDate = 'Today, Oct 5'.obs;
  final RxString preferredTime = '8:00 AM'.obs;
  final RxString timeFlexibility = '±15 minutes'.obs;
  final RxInt requestedSeats = 1.obs;
  final RxString seatsNote = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxBool hasSearched = false.obs;

  // Available Rides List
  final RxList<RideModel> availableRides = <RideModel>[].obs;

  void swapLocations() {
    final temp = fromLocationController.text;
    fromLocationController.text = toLocationController.text;
    toLocationController.text = temp;

    final tempLat = fromLat.value;
    final tempLng = fromLng.value;
    fromLat.value = toLat.value;
    fromLng.value = toLng.value;
    toLat.value = tempLat;
    toLng.value = tempLng;
  }

  void performSearch() {
    hasSearched.value = true;
    AppSnackBar.success(message: 'Found ${availableRides.length} matching rides along your route');
  }

  List<RideModel> get filteredRides {
    if (selectedFilter.value == 'Verified') {
      return availableRides.where((r) => r.isVerified).toList();
    } else if (selectedFilter.value == 'Top Rated') {
      return availableRides.where((r) => r.rating >= 4.9).toList();
    } else if (selectedFilter.value == 'Price') {
      final list = List<RideModel>.from(availableRides);
      list.sort((a, b) => a.pricePerSeat.compareTo(b.pricePerSeat));
      return list;
    }
    return availableRides;
  }

  @override
  void onInit() {
    super.onInit();
    _authSubscription = AuthService.instance.authStateChanges.listen((u) {
      if (u == null) {
        clearState();
      }
    });
  }

  void clearState() {
    fromLocationController.clear();
    toLocationController.clear();
    hasSearched.value = false;
    selectedFilter.value = 'All';
    requestedSeats.value = 1;
    seatsNote.value = '';
    availableRides.clear();
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    fromLocationController.dispose();
    toLocationController.dispose();
    super.onClose();
  }
}

