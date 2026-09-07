import 'package:flutter/material.dart';
import 'package:ridelink/core/constants/app_colors.dart';

enum TaskType { priority, assign, myTask, completed }

extension TaskTypeExtension on TaskType {
  String get title {
    switch (this) {
      case TaskType.priority:
        return 'Priority Cases';
      case TaskType.assign:
        return 'Assign Task';
      case TaskType.myTask:
        return 'My Task';
      case TaskType.completed:
        return 'Completed Task';
    }
  }

  String get description {
    switch (this) {
      case TaskType.priority:
        return '2 out of 3';
      case TaskType.assign:
        return '10 Tasks';
      case TaskType.myTask:
        return '05 Tasks';
      case TaskType.completed:
        return '4 Tasks';
    }
  }

  Color get color {
    switch (this) {
      case TaskType.priority:
        return AppColors.pending;
      case TaskType.assign:
        return AppColors.paid;
      case TaskType.myTask:
        return AppColors.inProgress;
      case TaskType.completed:
        return AppColors.high;
    }
  }
}
