import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/data/models/passenger/passenger_models.dart';
import 'package:ridelink/data/services/community_service.dart';

class DriverCommunityController extends GetxController {
  final RxList<CommunityModel> communities = <CommunityModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  StreamSubscription? _communitiesSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToCommunities();
  }

  void _listenToCommunities() {
    isLoading.value = true;
    _communitiesSubscription?.cancel();
    _communitiesSubscription =
        CommunityService.instance.streamCommunities().listen(
      (items) {
        communities.assignAll(items);
        isLoading.value = false;
      },
      onError: (err) {
        debugPrint('[DriverCommunityController] Stream error: $err');
        isLoading.value = false;
      },
    );
  }

  List<CommunityModel> get filteredCommunities {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return communities;
    return communities.where((c) {
      return c.name.toLowerCase().contains(query) ||
          c.routeSummary.toLowerCase().contains(query) ||
          c.description.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> toggleCommunityJoin(CommunityModel comm) async {
    final willJoin = !comm.isJoined.value;
    comm.isJoined.value = willJoin;

    if (willJoin) {
      comm.driversCount.value++;
      AppSnackBar.success(
        message: 'Joined ${comm.name}! Drivers in this network get route priority.',
      );
      try {
        await CommunityService.instance.joinCommunity(comm.id, role: 'driver');
      } catch (e) {
        comm.isJoined.value = false;
        comm.driversCount.value = (comm.driversCount.value - 1).clamp(0, 9999);
        AppSnackBar.error(message: 'Failed to join community: $e');
      }
    } else {
      comm.driversCount.value = (comm.driversCount.value - 1).clamp(0, 9999);
      AppSnackBar.info(message: 'Left ${comm.name}.');
      try {
        await CommunityService.instance.leaveCommunity(comm.id, role: 'driver');
      } catch (e) {
        comm.isJoined.value = true;
        comm.driversCount.value++;
        AppSnackBar.error(message: 'Failed to leave community: $e');
      }
    }
  }

  @override
  void onClose() {
    _communitiesSubscription?.cancel();
    super.onClose();
  }
}

