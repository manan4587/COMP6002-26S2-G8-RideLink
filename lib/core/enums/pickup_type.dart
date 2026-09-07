enum PickupType { availableTask, acceptedTask, pickedUpTask }

extension PickupTypeExtension on PickupType {
  String get title {
    switch (this) {
      case PickupType.availableTask:
        return 'Available Task';
      case PickupType.acceptedTask:
        return 'Accepted Task';
      case PickupType.pickedUpTask:
        return 'Picked Up Task';
    }
  }
}
