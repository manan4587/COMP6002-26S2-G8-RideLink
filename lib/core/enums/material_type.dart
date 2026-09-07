import 'package:flutter/material.dart';
import 'package:ridelink/core/constants/app_assets.dart';
import 'package:ridelink/core/constants/app_colors.dart';

enum AppMaterialType { newMaterial, assign, received }

extension MaterialTypeExtension on AppMaterialType {
  String get title {
    switch (this) {
      case AppMaterialType.newMaterial:
        return 'New';
      case AppMaterialType.assign:
        return 'Assign';
      case AppMaterialType.received:
        return 'Received';
    }
  }

  Color get color {
    switch (this) {
      case AppMaterialType.newMaterial:
        return AppColors.primaryColor;
      case AppMaterialType.assign:
        return AppColors.trailReady;
      case AppMaterialType.received:
        return AppColors.paid;
    }
  }

  String get icon {
    switch (this) {
      case AppMaterialType.newMaterial:
        return AppAssets.clock;
      case AppMaterialType.assign:
        return AppAssets.assign;
      case AppMaterialType.received:
        return AppAssets.received;
    }
  }
}

enum AppMaterialHistoryType { all, newMaterial, assign, received }

extension MaterialHistoryTypeExtension on AppMaterialHistoryType {
  String get title {
    switch (this) {
      case AppMaterialHistoryType.all:
        return 'All';
      case AppMaterialHistoryType.newMaterial:
        return 'New';
      case AppMaterialHistoryType.assign:
        return 'Assign';
      case AppMaterialHistoryType.received:
        return 'Received';
    }
  }
}
