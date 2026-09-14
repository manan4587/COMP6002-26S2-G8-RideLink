enum UserType { passenger, driver }

extension UserTypeExtension on UserType {
  String get title {
    switch (this) {
      case UserType.passenger:
        return 'Passenger';
      case UserType.driver:
        return 'Driver';
    }
  }

  
}
