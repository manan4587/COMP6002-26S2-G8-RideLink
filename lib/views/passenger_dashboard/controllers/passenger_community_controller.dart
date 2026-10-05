import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/data/models/passenger/passenger_models.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/community_service.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';

class PassengerCommunityController extends GetxController {
  // Selected Community for Details Page
  final Rx<CommunityModel?> selectedCommunity = Rx<CommunityModel?>(null);

  // Communities List from Firestore
  final RxList<CommunityModel> communities = <CommunityModel>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription? _communitiesSubscription;
  StreamSubscription? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    final user = AuthService.instance.currentUser;
    if (user != null) {
      _listenToCommunities();
    } else {
      isLoading.value = false;
    }

    _authSubscription = AuthService.instance.authStateChanges.listen((u) {
      if (u != null) {
        _listenToCommunities();
      } else {
        clearState();
      }
    });
  }

  void clearState() {
    _communitiesSubscription?.cancel();
    _communitiesSubscription = null;
    communities.clear();
    selectedCommunity.value = null;
    isLoading.value = false;
  }

  void _listenToCommunities() {
    isLoading.value = true;
    _communitiesSubscription?.cancel();
    _communitiesSubscription = CommunityService.instance
        .streamCommunities()
        .listen(
          (items) {
            communities.assignAll(items);
            isLoading.value = false;

            // Sync selectedCommunity if currently open
            if (selectedCommunity.value != null) {
              final updated = items.firstWhereOrNull(
                (c) => c.id == selectedCommunity.value!.id,
              );
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

  Future<void> joinCommunity(CommunityModel comm) async {
    if (comm.isJoined.value) return;

    comm.isJoined.value = true;
    comm.passengersCount.value++;
    AppSnackBar.success(
      message: 'Joined ${comm.name}! You will now see community rides.',
    );
    try {
      await CommunityService.instance.joinCommunity(comm.id, role: 'passenger');
    } catch (e) {
      comm.isJoined.value = false;
      comm.passengersCount.value = (comm.passengersCount.value - 1).clamp(
        0,
        9999,
      );
      AppSnackBar.error(message: 'Failed to join community: $e');
    }
  }

  Future<void> toggleCommunityJoin(CommunityModel comm) async {
    if (!comm.isJoined.value) {
      await joinCommunity(comm);
    }
  }

  void openCommunityDetails(CommunityModel comm) {
    selectedCommunity.value = comm;
    Get.toNamed(AppRoutes.passengerCommunityDetails);
  }

  Future<void> confirmLeaveCommunity(
    BuildContext? context,
    CommunityModel comm,
  ) async {
    final ctx = context ?? Get.context;
    bool shouldLeave = false;

    if (ctx != null) {
      final result = await showModalBottomSheet<bool>(
        context: ctx,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (sheetCtx) => Container(
          padding: EdgeInsets.only(
            top: 12.h,
            left: 20.w,
            right: 20.w,
            bottom: MediaQuery.of(sheetCtx).padding.bottom + 20.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              18.verticalSpace,
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF2F2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.exit_to_app_rounded,
                      color: const Color(0xFFDC2626),
                      size: 22.sp,
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Leave Community?',
                          style: AppTextStyle.text18Semibold.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        2.verticalSpace,
                        Text(
                          comm.name,
                          style: AppTextStyle.text12Medium.copyWith(
                            color: AppColors.secondaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              14.verticalSpace,
              Text(
                'Are you sure you want to leave ${comm.name}? You will no longer receive corridor ride updates, member chat privileges, or community commute benefits.',
                style: AppTextStyle.text14Regular.copyWith(
                  color: const Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
              22.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetCtx, false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: const BorderSide(color: AppColors.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Stay',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(sheetCtx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Leave Community',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      shouldLeave = result == true;
    } else {
      shouldLeave = true;
    }

    if (!shouldLeave) return;

    comm.isJoined.value = false;
    comm.passengersCount.value = (comm.passengersCount.value - 1).clamp(
      0,
      9999,
    );
    AppSnackBar.info(message: 'You have left ${comm.name}.');
    try {
      await CommunityService.instance.leaveCommunity(
        comm.id,
        role: 'passenger',
      );
    } catch (e) {
      comm.isJoined.value = true;
      comm.passengersCount.value++;
      AppSnackBar.error(message: 'Failed to leave community: $e');
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _communitiesSubscription?.cancel();
    super.onClose();
  }
}
