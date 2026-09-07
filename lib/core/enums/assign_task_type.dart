import 'package:flutter/material.dart';
import 'package:ridelink/core/constants/app_colors.dart';

enum AssignTaskType { high, standard }

extension AssignTaskTypeExtension on AssignTaskType {
  String get title {
    switch (this) {
      case AssignTaskType.high:
        return 'High';
      case AssignTaskType.standard:
        return 'Standard';
    }
  }

  Color get color {
    switch (this) {
      case AssignTaskType.high:
        return AppColors.pending;
      case AssignTaskType.standard:
        return AppColors.trailReady;
    }
  }
}
