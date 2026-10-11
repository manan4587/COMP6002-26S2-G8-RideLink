import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/route_matching_helper.dart';
import 'package:ridelink/data/models/passenger/passenger_models.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/google_places_service.dart';
import 'package:ridelink/theme/app_text_style.dart';

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

  final Rx<DateTime> selectedSearchDate = DateTime.now().obs;
  final Rx<TimeOfDay> selectedSearchTime = const TimeOfDay(
    hour: 8,
    minute: 0,
  ).obs;

  final RxString activeDatePreset = 'Today'.obs; // 'Today', 'Tomorrow', 'Weekend', 'Custom'
  final RxString activeTimePreset = 'Morning'.obs; // 'Morning', 'Noon', 'Evening', 'Custom'

  final RxString selectedDate = 'Today'.obs;
  final RxString preferredTime = '08:00 AM'.obs;
  final RxString timeFlexibility = '±30 minutes'.obs;
  final RxInt requestedSeats = 1.obs;
  final RxString seatsNote = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxBool hasSearched = false.obs;
  final RxBool isSearching = false.obs;

  // Available Rides List
  final RxList<RideModel> availableRides = <RideModel>[].obs;

  String get formattedSearchDate {
    final date = selectedSearchDate.value;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) {
      return 'Today (${DateFormat('d MMM').format(date)})';
    } else if (diff == 1) {
      return 'Tomorrow (${DateFormat('d MMM').format(date)})';
    }
    return DateFormat('EEE, d MMM').format(date);
  }

  String get formattedSearchTime {
    final time = selectedSearchTime.value;
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  void selectToday() {
    activeDatePreset.value = 'Today';
    selectedSearchDate.value = DateTime.now();
    selectedDate.value = formattedSearchDate;
    if (hasSearched.value) {
      performSearch();
    }
  }

  void selectTomorrow() {
    activeDatePreset.value = 'Tomorrow';
    selectedSearchDate.value = DateTime.now().add(const Duration(days: 1));
    selectedDate.value = formattedSearchDate;
    if (hasSearched.value) {
      performSearch();
    }
  }

  void selectWeekend() {
    activeDatePreset.value = 'Weekend';
    final now = DateTime.now();
    final daysUntilSaturday = (DateTime.saturday - now.weekday + 7) % 7;
    final target = daysUntilSaturday == 0 ? now : now.add(Duration(days: daysUntilSaturday));
    selectedSearchDate.value = target;
    selectedDate.value = formattedSearchDate;
    if (hasSearched.value) {
      performSearch();
    }
  }

  void selectMorning() {
    final now = DateTime.now();
    final isToday = selectedSearchDate.value.year == now.year &&
        selectedSearchDate.value.month == now.month &&
        selectedSearchDate.value.day == now.day;
    if (isToday && (now.hour * 60 + now.minute > 8 * 60)) {
      AppSnackBar.warning(
        message:
            'Morning (8:00 AM) has already passed for today. Please pick an upcoming time.',
      );
      return;
    }
    activeTimePreset.value = 'Morning';
    selectedSearchTime.value = const TimeOfDay(hour: 8, minute: 0);
    preferredTime.value = formattedSearchTime;
    if (hasSearched.value) {
      performSearch();
    }
  }

  void selectNoon() {
    final now = DateTime.now();
    final isToday = selectedSearchDate.value.year == now.year &&
        selectedSearchDate.value.month == now.month &&
        selectedSearchDate.value.day == now.day;
    if (isToday && (now.hour * 60 + now.minute > 12 * 60 + 30)) {
      AppSnackBar.warning(
        message:
            'Noon (12:30 PM) has already passed for today. Please pick an upcoming time.',
      );
      return;
    }
    activeTimePreset.value = 'Noon';
    selectedSearchTime.value = const TimeOfDay(hour: 12, minute: 30);
    preferredTime.value = formattedSearchTime;
    if (hasSearched.value) {
      performSearch();
    }
  }

  void selectEvening() {
    final now = DateTime.now();
    final isToday = selectedSearchDate.value.year == now.year &&
        selectedSearchDate.value.month == now.month &&
        selectedSearchDate.value.day == now.day;
    if (isToday && (now.hour * 60 + now.minute > 17 * 60 + 30)) {
      AppSnackBar.warning(
        message:
            'Evening (5:30 PM) has already passed for today. Please pick an upcoming time.',
      );
      return;
    }
    activeTimePreset.value = 'Evening';
    selectedSearchTime.value = const TimeOfDay(hour: 17, minute: 30);
    preferredTime.value = formattedSearchTime;
    if (hasSearched.value) {
      performSearch();
    }
  }

  Future<void> pickSearchDate(BuildContext context) async {
    final now = DateTime.now();
    DateTime tempDate = selectedSearchDate.value.isBefore(now)
        ? now
        : selectedSearchDate.value;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.only(
            top: 12.h,
            left: 20.w,
            right: 20.w,
            bottom: MediaQuery.of(ctx).padding.bottom + 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag handle
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              14.verticalSpace,
              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Ride Date',
                    style: AppTextStyle.text18Semibold.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      selectedSearchDate.value = tempDate;
                      final today = DateTime(now.year, now.month, now.day);
                      final picked = DateTime(tempDate.year, tempDate.month, tempDate.day);
                      final diff = picked.difference(today).inDays;
                      if (diff == 0) {
                        activeDatePreset.value = 'Today';
                      } else if (diff == 1) {
                        activeDatePreset.value = 'Tomorrow';
                      } else {
                        activeDatePreset.value = 'Custom';
                      }
                      selectedDate.value = formattedSearchDate;
                      if (hasSearched.value) {
                        performSearch();
                      }
                      Get.back();
                    },
                    child: Text(
                      'Done',
                      style: AppTextStyle.text14Semibold.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              10.verticalSpace,
              // Calendar View
              Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF2563EB),
                    onPrimary: Colors.white,
                    onSurface: Color(0xFF1E293B),
                  ),
                ),
                child: SizedBox(
                  height: 320.h,
                  child: CalendarDatePicker(
                    initialDate: tempDate,
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 365)),
                    onDateChanged: (val) {
                      tempDate = val;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickSearchTime(BuildContext context) async {
    final now = DateTime.now();
    TimeOfDay tempTime = selectedSearchTime.value;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.only(
            top: 12.h,
            left: 20.w,
            right: 20.w,
            bottom: MediaQuery.of(ctx).padding.bottom + 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag handle
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              14.verticalSpace,
              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Preferred Time',
                    style: AppTextStyle.text18Semibold.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final isToday = selectedSearchDate.value.year == now.year &&
                          selectedSearchDate.value.month == now.month &&
                          selectedSearchDate.value.day == now.day;
                      if (isToday) {
                        final pickedMinutes = tempTime.hour * 60 + tempTime.minute;
                        final currentMinutes = now.hour * 60 + now.minute;
                        if (pickedMinutes < currentMinutes) {
                          AppSnackBar.error(
                            message:
                                'Cannot select a time in the past. Please choose an upcoming time.',
                          );
                          return;
                        }
                      }
                      selectedSearchTime.value = tempTime;
                      activeTimePreset.value = 'Custom';
                      preferredTime.value = formattedSearchTime;
                      if (hasSearched.value) {
                        performSearch();
                      }
                      Get.back();
                    },
                    child: Text(
                      'Done',
                      style: AppTextStyle.text14Semibold.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              14.verticalSpace,
              // Cupertino Time Wheel Picker
              SizedBox(
                height: 200.h,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime(
                    now.year,
                    now.month,
                    now.day,
                    selectedSearchTime.value.hour,
                    selectedSearchTime.value.minute,
                  ),
                  use24hFormat: false,
                  onDateTimeChanged: (DateTime newDateTime) {
                    tempTime = TimeOfDay(
                      hour: newDateTime.hour,
                      minute: newDateTime.minute,
                    );
                  },
                ),
              ),
              12.verticalSpace,
            ],
          ),
        );
      },
    );
  }

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

  bool _matchesDate(RideModel r, DateTime targetDate, String preset, DateTime now) {
    if (r.departureDateTime == null) return true;

    if (preset == 'Weekend') {
      final isSatOrSun = r.departureDateTime!.weekday == DateTime.saturday ||
          r.departureDateTime!.weekday == DateTime.sunday;
      final diffDays = r.departureDateTime!
          .difference(DateTime(now.year, now.month, now.day))
          .inDays;
      return isSatOrSun && diffDays >= 0 && diffDays <= 7;
    }

    return r.departureDateTime!.year == targetDate.year &&
        r.departureDateTime!.month == targetDate.month &&
        r.departureDateTime!.day == targetDate.day;
  }

  List<RideModel> get filteredRides {
    final fromQuery = fromLocationController.text.trim().toLowerCase();
    final toQuery = toLocationController.text.trim().toLowerCase();
    final seats = requestedSeats.value;
    final now = DateTime.now();
    final targetDate = selectedSearchDate.value;
    final activePreset = activeDatePreset.value;

    // Exclude rides that have already completed, cancelled, or departed in the past
    final validRides = availableRides.where((r) {
      final s = r.status.toLowerCase().trim();
      if (s == 'completed' ||
          s == 'cancelled' ||
          s == 'active' ||
          s == 'started' ||
          s == 'in_progress') {
        return false;
      }
      if (r.departureDateTime != null) {
        if (r.departureDateTime!.isBefore(now.subtract(const Duration(minutes: 5)))) {
          return false;
        }
      }
      return true;
    }).toList();

    // 0. Filter strictly by selected date / date preset
    final dateFilteredRides = validRides.where((r) {
      return _matchesDate(r, targetDate, activePreset, now);
    }).toList();

    final bool hasSearchCoords = (fromLat.value != 0.0 || fromLng.value != 0.0) &&
        (toLat.value != 0.0 || toLng.value != 0.0);

    List<RideModel> list = [];

    if (hasSearchCoords) {
      // 1. En-route corridor & detour matching
      final pPickup = LatLng(fromLat.value, fromLng.value);
      final pDrop = LatLng(toLat.value, toLng.value);

      for (final r in dateFilteredRides) {
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
      list = dateFilteredRides.where((r) {
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

    // 3. If still empty and no specific query text entered, show all rides for that date
    if (list.isEmpty && fromQuery.isEmpty && toQuery.isEmpty) {
      list = dateFilteredRides.where((r) => r.seatsAvailable >= seats).toList();
    }

    // Attach searched pickup and dropoff locations to all matching rides
    final pPickupText = fromLocationController.text.trim();
    final pDropText = toLocationController.text.trim();
    list = list.map((r) {
      return r.copyWith(
        searchedPickupAddress: r.searchedPickupAddress.isNotEmpty
            ? r.searchedPickupAddress
            : (pPickupText.isNotEmpty ? pPickupText : r.origin),
        searchedDropAddress: r.searchedDropAddress.isNotEmpty
            ? r.searchedDropAddress
            : (pDropText.isNotEmpty ? pDropText : r.destination),
        pickupSuggestion: pPickupText.isNotEmpty ? pPickupText : r.origin,
        dropOffPlan: pDropText.isNotEmpty ? pDropText : r.destination,
      );
    }).toList();

    // 4. Date & Time Ranking / Sorting
    final targetMinutes = _timeToMinutes(preferredTime.value);

    list.sort((a, b) {
      // Prioritize en-route corridor matches
      if (a.isEnRouteMatch && !b.isEnRouteMatch) return -1;
      if (!a.isEnRouteMatch && b.isEnRouteMatch) return 1;

      // Prioritize matching search date if departure date is recorded
      final aDateMatch = a.departureDateTime != null &&
          a.departureDateTime!.year == targetDate.year &&
          a.departureDateTime!.month == targetDate.month &&
          a.departureDateTime!.day == targetDate.day;
      final bDateMatch = b.departureDateTime != null &&
          b.departureDateTime!.year == targetDate.year &&
          b.departureDateTime!.month == targetDate.month &&
          b.departureDateTime!.day == targetDate.day;

      if (aDateMatch && !bDateMatch) return -1;
      if (!aDateMatch && bDateMatch) return 1;

      // Prioritize time closeness to preferred commute time
      final aTimeDelta = (_timeToMinutes(a.departureTime) - targetMinutes).abs();
      final bTimeDelta = (_timeToMinutes(b.departureTime) - targetMinutes).abs();
      if (aTimeDelta != bTimeDelta) {
        return aTimeDelta.compareTo(bTimeDelta);
      }

      // Prioritize lower detour
      return a.detourMinutes.compareTo(b.detourMinutes);
    });

    // 5. Apply Tab Filter
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

  int _timeToMinutes(String timeStr) {
    try {
      final clean = timeStr.trim().toUpperCase();
      final isPM = clean.contains('PM');
      final isAM = clean.contains('AM');
      final parts = clean
          .replaceAll('AM', '')
          .replaceAll('PM', '')
          .trim()
          .split(':');
      if (parts.length >= 2) {
        var hour = int.tryParse(parts[0].trim()) ?? 8;
        final minute = int.tryParse(parts[1].trim()) ?? 0;
        if (isPM && hour < 12) hour += 12;
        if (isAM && hour == 12) hour = 0;
        return hour * 60 + minute;
      }
    } catch (_) {}
    return 8 * 60;
  }

  int get flexibilityWindowMinutes {
    final flex = timeFlexibility.value.toLowerCase();
    if (flex.contains('15')) return 15;
    if (flex.contains('30')) return 30;
    if (flex.contains('1 hour') || flex.contains('60')) return 60;
    if (flex.contains('anytime')) return 99999;
    return 30;
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
    fromLat.value = 0.0;
    fromLng.value = 0.0;
    toLat.value = 0.0;
    toLng.value = 0.0;
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

