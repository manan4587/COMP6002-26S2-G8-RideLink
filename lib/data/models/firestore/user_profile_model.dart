class UserProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? photoUrl;
  final String activeRole; // 'passenger' | 'driver'
  final List<String> roles;
  final bool isEmailVerified;
  final double rating;
  final int ratingCount;
  final int tripsCompleted;
  final bool isVerifiedDriver;
  final bool isOnline;
  final VehicleInfo? vehicle;
  final List<SavedLocationItem> savedLocations;
  final List<EmergencyContactItem> emergencyContacts;
  final Map<String, dynamic>? driverDocs;
  final String? fcmToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.photoUrl,
    this.activeRole = 'passenger',
    this.roles = const ['passenger'],
    this.isEmailVerified = false,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.tripsCompleted = 0,
    this.isVerifiedDriver = false,
    this.isOnline = true,
    this.vehicle,
    this.savedLocations = const [],
    this.emergencyContacts = const [],
    this.driverDocs,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map, String id) {
    return UserProfileModel(
      id: id,
      fullName: (map['fullName'] ?? map['name'] ?? map['displayName'])
              ?.toString() ??
          '',
      email: (map['email'])?.toString() ?? '',
      phoneNumber: (map['phoneNumber'] ??
              map['phone'] ??
              map['mobile'] ??
              map['contact'])
          ?.toString() ??
          '',
      photoUrl: map['photoUrl'] as String?,
      activeRole: map['activeRole'] as String? ?? 'passenger',
      roles: (map['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['passenger'],
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      rating: (map['passengerStats']?['rating'] as num?)?.toDouble() ??
          (map['driverStats']?['rating'] as num?)?.toDouble() ??
          (map['rating'] as num?)?.toDouble() ??
          0.0,
      ratingCount: (map['passengerStats']?['ratingCount'] as num?)?.toInt() ??
          (map['driverStats']?['ratingCount'] as num?)?.toInt() ??
          0,
      tripsCompleted:
          (map['passengerStats']?['tripsCompleted'] as num?)?.toInt() ??
              (map['driverStats']?['tripsCompleted'] as num?)?.toInt() ??
              (map['tripsCompleted'] as num?)?.toInt() ??
              0,
      isVerifiedDriver: map['is_verified_driver'] as bool? ?? false,
      isOnline: map['isOnline'] as bool? ?? true,
      vehicle: map['vehicle'] != null
          ? VehicleInfo.fromMap(map['vehicle'] as Map<String, dynamic>)
          : null,
      savedLocations: (map['savedLocations'] as List<dynamic>?)
              ?.map((e) => SavedLocationItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      emergencyContacts: (map['emergencyContacts'] as List<dynamic>?)
              ?.map((e) =>
                  EmergencyContactItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      driverDocs: null,
      fcmToken: map['fcmToken'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      if (photoUrl != null && photoUrl!.isNotEmpty) 'photoUrl': photoUrl,
      'activeRole': activeRole,
      'roles': roles,
      'isEmailVerified': isEmailVerified,
      'isOnline': isOnline,
      'is_verified_driver': isVerifiedDriver,
      'passengerStats': {
        'rating': rating,
        'ratingCount': ratingCount,
        'tripsCompleted': tripsCompleted,
      },
      'driverStats': {
        'rating': rating,
        'ratingCount': ratingCount,
        'tripsCompleted': tripsCompleted,
      },
      if (vehicle != null) 'vehicle': vehicle!.toMap(),
      'savedLocations': savedLocations.map((e) => e.toMap()).toList(),
      'emergencyContacts': emergencyContacts.map((e) => e.toMap()).toList(),
      if (fcmToken != null && fcmToken!.isNotEmpty) 'fcmToken': fcmToken,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class VehicleInfo {
  final String make;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final int totalSeats;
  final String type;

  VehicleInfo({
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    this.totalSeats = 4,
    this.type = 'Sedan',
  });

  factory VehicleInfo.fromMap(Map<String, dynamic> map) {
    return VehicleInfo(
      make: map['make'] as String? ?? '',
      model: map['model'] as String? ?? '',
      year: (map['year'] as num?)?.toInt() ?? 2022,
      color: map['color'] as String? ?? '',
      licensePlate: map['licensePlate'] as String? ?? '',
      totalSeats: (map['totalSeats'] as num?)?.toInt() ?? 4,
      type: map['type'] as String? ?? 'Sedan',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'make': make,
      'model': model,
      'color': color,
      'licensePlate': licensePlate,
      'type': type,
    };
  }
}

class SavedLocationItem {
  final String id;
  final String label;
  final String address;
  final double lat;
  final double lng;

  SavedLocationItem({
    required this.id,
    required this.label,
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory SavedLocationItem.fromMap(Map<String, dynamic> map) {
    return SavedLocationItem(
      id: map['id'] as String? ?? '',
      label: map['label'] as String? ?? '',
      address: map['address'] as String? ?? '',
      lat: (map['location']?['_lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['location']?['_long'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'address': address,
      'location': {
        '_lat': lat,
        '_long': lng,
      },
    };
  }
}

class EmergencyContactItem {
  final String name;
  final String relationship;
  final String phone;

  EmergencyContactItem({
    required this.name,
    required this.relationship,
    required this.phone,
  });

  factory EmergencyContactItem.fromMap(Map<String, dynamic> map) {
    return EmergencyContactItem(
      name: map['name'] as String? ?? '',
      relationship: map['relationship'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relationship': relationship,
      'phone': phone,
    };
  }
}

