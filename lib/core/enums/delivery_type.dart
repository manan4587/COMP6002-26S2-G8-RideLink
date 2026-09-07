enum DeliveryType {
  upcomingCourier,
  availableTask,
  acceptedTask,
  deliveredTask,
}

extension DeliveryTypeExtension on DeliveryType {
  String get title {
    switch (this) {
      case DeliveryType.upcomingCourier:
        return 'Upcoming Courier';
      case DeliveryType.availableTask:
        return 'Available Task';
      case DeliveryType.acceptedTask:
        return 'Accepted Task';
      case DeliveryType.deliveredTask:
        return 'Delivered Task';
    }
  }

  String get appBarTitle {
    switch (this) {
      case DeliveryType.upcomingCourier:
        return 'Upcoming Task';
      case DeliveryType.availableTask:
        return 'Available Task';
      case DeliveryType.acceptedTask:
        return 'Accepted Task';
      case DeliveryType.deliveredTask:
        return 'Delivered Task';
    }
  }
}
