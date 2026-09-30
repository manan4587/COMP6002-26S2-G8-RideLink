import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/data/models/passenger/passenger_models.dart';
import 'package:ridelink/data/services/community_service.dart';
import 'package:ridelink/routes/routes_name.dart';

class PassengerCommunityController extends GetxController {
  // Selected Community for Details Page
  final Rx<CommunityModel?> selectedCommunity = Rx<CommunityModel?>(null);

  // Communities List from Firestore
  final RxList<CommunityModel> communities = <CommunityModel>[].obs;
  final RxBool isLoading = true.obs;

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

        // Sync selectedCommunity if currently open
        if (selectedCommunity.value != null) {
          final updated =
              items.firstWhereOrNull((c) => c.id == selectedCommunity.value!.id);
          if (updated != null) {
            selectedCommunity.value = updated;
          }
        }
      },
      onError: (err) {
        debugPrint('[PassengerCommunityController] Stream error: $err');
        isLoading.value = false;
      },
    );
  }

  Future<void> toggleCommunityJoin(CommunityModel comm) async {
    final willJoin = !comm.isJoined.value;
    comm.isJoined.value = willJoin;
    if (willJoin) {
      comm.passengersCount.value++;
      AppSnackBar.success(
        message: 'Joined ${comm.name}! You will now see community rides.',
      );
      try {
        await CommunityService.instance
            .joinCommunity(comm.id, role: 'passenger');
      } catch (e) {
        comm.isJoined.value = false;
        comm.passengersCount.value =
            (comm.passengersCount.value - 1).clamp(0, 9999);
        AppSnackBar.error(message: 'Failed to join community: $e');
      }
    } else {
      comm.passengersCount.value =
          (comm.passengersCount.value - 1).clamp(0, 9999);
      AppSnackBar.info(message: 'Left ${comm.name}.');
      try {
        await CommunityService.instance
            .leaveCommunity(comm.id, role: 'passenger');
      } catch (e) {
        comm.isJoined.value = true;
        comm.passengersCount.value++;
        AppSnackBar.error(message: 'Failed to leave community: $e');
      }
    }
  }

  void openCommunityDetails(CommunityModel comm) {
    selectedCommunity.value = comm;
    Get.toNamed(AppRoutes.passengerCommunityDetails);
  }

  Future<void> confirmLeaveCommunity(CommunityModel comm) async {
    comm.isJoined.value = false;
    comm.passengersCount.value =
        (comm.passengersCount.value - 1).clamp(0, 9999);
    AppSnackBar.info(message: 'You have left ${comm.name}.');
    try {
      await CommunityService.instance
          .leaveCommunity(comm.id, role: 'passenger');
    } catch (e) {
      comm.isJoined.value = true;
      comm.passengersCount.value++;
      AppSnackBar.error(message: 'Failed to leave community: $e');
    }
  }

  @override
  void onClose() {
    _communitiesSubscription?.cancel();
    super.onClose();
  }
}

