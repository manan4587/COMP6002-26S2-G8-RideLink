import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/route_matching_helper.dart';
import 'package:ridelink/data/models/passenger/passenger_models.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/google_places_service.dart';

class PassengerSearchController extends GetxController {
  StreamSubscription? _authSubscription;

  // Search Inputs
  final TextEditingController fromLocationController = TextEditingController(
    text: '',
  );
  final TextEditingController toLocationController = TextEditingController(
    text: '',
  );

  final RxDouble fromLat = (0.0).obs;
  final RxDouble fromLng = (0.0).obs;
  final RxDouble toLat = (0.0).obs;
  final RxDouble toLng = (0.0).obs;

  final RxString selectedDate = 'Today, Oct 5'.obs;
  final RxString preferredTime = '8:00 AM'.obs;
  final RxString timeFlexibility = '±15 minutes'.obs;
  final RxInt requestedSeats = 1.obs;
  final RxString seatsNote = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxBool hasSearched = false.obs;
  final RxBool isSearching = false.obs;

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

  Future<void> performSearch() async {
    isSearching.value = true;
    hasSearched.value = true;

    // Geocode pickup if address was typed without place selection
    if (fromLocationController.text.trim().isNotEmpty &&
        fromLat.value == 0.0 &&
        fromLng.value == 0.0) {
      final geo = await GooglePlacesService.instance.getCoordinatesForAddress(
        fromLocationController.text.trim(),
      );
      if (geo != null) {
        fromLat.value = geo.latitude;
        fromLng.value = geo.longitude;
      }
    }

    // Geocode destination if address was typed without place selection
    if (toLocationController.text.trim().isNotEmpty &&
        toLat.value == 0.0 &&
        toLng.value == 0.0) {
      final geo = await GooglePlacesService.instance.getCoordinatesForAddress(
        toLocationController.text.trim(),
      );
      if (geo != null) {
        toLat.value = geo.latitude;
        toLng.value = geo.longitude;
      }
    }

    await Future.delayed(const Duration(milliseconds: 250));
    isSearching.value = false;
    final count = filteredRides.length;
    if (count > 0) {
      AppSnackBar.success(
        message: 'Found $count matching ride${count == 1 ? '' : 's'} along your route',
      );
    } else {
      AppSnackBar.info(
        message: 'No rides found along this corridor. Showing all available trips.',
      );
    }
  }

  List<RideModel> get filteredRides {
    final fromQuery = fromLocationController.text.trim().toLowerCase();
    final toQuery = toLocationController.text.trim().toLowerCase();
    final seats = requestedSeats.value;

    final bool hasSearchCoords = (fromLat.value != 0.0 || fromLng.value != 0.0) &&
        (toLat.value != 0.0 || toLng.value != 0.0);

    List<RideModel> list = [];

    if (hasSearchCoords) {
      // 1. En-route corridor & detour matching
      final pPickup = LatLng(fromLat.value, fromLng.value);
      final pDrop = LatLng(toLat.value, toLng.value);

      for (final r in availableRides) {
        if (r.seatsAvailable < seats) continue;

        // Skip if driver route coordinates are uninitialized
        if (r.originLat == 0.0 && r.originLng == 0.0 && r.destinationLat == 0.0 && r.destinationLng == 0.0) {
          continue;
        }

        final dOrigin = LatLng(r.originLat, r.originLng);
        final dDest = LatLng(r.destinationLat, r.destinationLng);

        final matchResult = RouteMatchingHelper.evaluateEnRouteMatch(
          driverOrigin: dOrigin,
          driverDestination: dDest,
          passengerPickup: pPickup,
          passengerDropoff: pDrop,
          driverFullSeatPrice: r.pricePerSeat,
          maxDetourKm: 5.0, // 5km detour corridor
        );

        if (matchResult.isMatch) {
          list.add(
            r.copyWith(
              isEnRouteMatch: true,
              enRouteDetourKm: matchResult.detourKm,
              detourMinutes: matchResult.detourMinutes,
              enRouteSubFare: matchResult.recommendedFare,
              searchedPickupLat: fromLat.value,
              searchedPickupLng: fromLng.value,
              searchedDropLat: toLat.value,
              searchedDropLng: toLng.value,
              searchedPickupAddress: fromLocationController.text.trim(),
              searchedDropAddress: toLocationController.text.trim(),
            ),
          );
        }
      }

      // Sort en-route matches: lowest detour minutes first
      list.sort((a, b) => a.detourMinutes.compareTo(b.detourMinutes));
    }

    // 2. If no coordinate matches, or text search was used, fallback to keyword matching
    if (list.isEmpty) {
      list = availableRides.where((r) {
        if (r.seatsAvailable < seats) return false;

        if (fromQuery.isNotEmpty) {
          final origin = r.origin.toLowerCase();
          final matchOrigin =
              origin.contains(fromQuery) || fromQuery.contains(origin);
          if (!matchOrigin) {
            final words = fromQuery
                .split(RegExp(r'[\s,]+'))
                .where((w) => w.length > 2);
            if (words.isNotEmpty && !words.any((w) => origin.contains(w))) {
              return false;
            }
          }
        }

        if (toQuery.isNotEmpty) {
          final dest = r.destination.toLowerCase();
          final matchDest =
              dest.contains(toQuery) || toQuery.contains(dest);
          if (!matchDest) {
            final words = toQuery
                .split(RegExp(r'[\s,]+'))
                .where((w) => w.length > 2);
            if (words.isNotEmpty && !words.any((w) => dest.contains(w))) {
              return false;
            }
          }
        }

        return true;
      }).toList();
    }

    // 3. Fallback to all available rides if no match found
    if (list.isEmpty && (fromQuery.isNotEmpty || toQuery.isNotEmpty)) {
      list = availableRides.where((r) => r.seatsAvailable >= seats).toList();
    }

    // 4. Apply Tab Filter
    if (selectedFilter.value == 'Verified') {
      list = list.where((r) => r.isVerified).toList();
    } else if (selectedFilter.value == 'Top Rated') {
      list = list.where((r) => r.rating >= 4.5).toList();
    } else if (selectedFilter.value == 'Price') {
      final sorted = List<RideModel>.from(list);
      sorted.sort((a, b) {
        final priceA = a.enRouteSubFare ?? a.pricePerSeat;
        final priceB = b.enRouteSubFare ?? b.pricePerSeat;
        return priceA.compareTo(priceB);
      });
      return sorted;
    }

    return list;
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

