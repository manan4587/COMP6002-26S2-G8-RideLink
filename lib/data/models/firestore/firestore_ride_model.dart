class FirestoreRideModel {
  final String id;
  final String driverId;
  final String driverName;
  final String? driverPhotoUrl;
  final double driverRating;
  final int driverTotalRides;
  final String carModel;
  final String carPlate;
  final LocationPoint origin;
  final LocationPoint destination;
  final List<String> stops;
  final DateTime departureTime;
  final int estimatedDurationMinutes;
  final int totalSeats;
  final int availableSeats;
  final double pricePerSeat;
  final String currency;
  final bool allowLuggage;
  final bool allowPets;
  final bool allowSmoking;
  final String status; // 'scheduled' | 'active' | 'completed' | 'cancelled'
  final DateTime? createdAt;

  FirestoreRideModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    this.driverPhotoUrl,
    required this.driverRating,
    required this.driverTotalRides,
    required this.carModel,
    required this.carPlate,
    required this.origin,
    required this.destination,
    this.stops = const [],
    required this.departureTime,
    required this.estimatedDurationMinutes,
    required this.totalSeats,
    required this.availableSeats,
    required this.pricePerSeat,
    this.currency = 'AUD',
    this.allowLuggage = true,
    this.allowPets = false,
    this.allowSmoking = false,
    this.status = 'scheduled',
    this.createdAt,
  });

  factory FirestoreRideModel.fromMap(Map<String, dynamic> map, String id) {
    return FirestoreRideModel(
      id: id,
      driverId: map['driverId'] as String? ?? '',
      driverName: map['driver']?['name'] as String? ?? '',
      driverPhotoUrl: map['driver']?['photoUrl'] as String?,
      driverRating: (map['driver']?['rating'] as num?)?.toDouble() ?? 0.0,
      driverTotalRides: (map['driver']?['totalRides'] as num?)?.toInt() ?? 0,
      carModel: map['vehicle']?['model'] as String? ?? '',
      carPlate: map['vehicle']?['plate'] as String? ?? '',
      origin: LocationPoint.fromMap(map['origin'] as Map<String, dynamic>? ?? {}),
      destination:
          LocationPoint.fromMap(map['destination'] as Map<String, dynamic>? ?? {}),
      stops: (map['stops'] as List<dynamic>?)
              ?.map((e) => (e['name'] ?? '').toString())
              .toList() ??
          [],
      departureTime: map['departureTime'] != null
          ? DateTime.tryParse(map['departureTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      estimatedDurationMinutes:
          (map['estimatedDurationMinutes'] as num?)?.toInt() ?? 30,
      totalSeats: (map['totalSeats'] as num?)?.toInt() ?? 3,
      availableSeats: (map['availableSeats'] as num?)?.toInt() ?? 3,
      pricePerSeat: (map['pricePerSeat'] as num?)?.toDouble() ?? 12.0,
      currency: map['currency'] as String? ?? 'AUD',
      allowLuggage: map['preferences']?['allowLuggage'] as bool? ?? true,
      allowPets: map['preferences']?['allowPets'] as bool? ?? false,
      allowSmoking: map['preferences']?['allowSmoking'] as bool? ?? false,
      status: map['status'] as String? ?? 'scheduled',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driverId': driverId,
      'driver': {
        'name': driverName,
        'photoUrl': driverPhotoUrl,
        'rating': driverRating,
        'totalRides': driverTotalRides,
        'isVerified': true,
      },
      'vehicle': {
        'model': carModel,
        'plate': carPlate,
      },
      'origin': origin.toMap(),
      'destination': destination.toMap(),
      'stops': stops.map((s) => {'name': s}).toList(),
      'departureTime': departureTime.toIso8601String(),
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'pricePerSeat': pricePerSeat,
      'currency': currency,
      'preferences': {
        'allowLuggage': allowLuggage,
        'allowPets': allowPets,
        'allowSmoking': allowSmoking,
      },
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class LocationPoint {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String? geohash;

  LocationPoint({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.geohash,
  });

  factory LocationPoint.fromMap(Map<String, dynamic> map) {
    return LocationPoint(
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      lat: (map['geopoint']?['_lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['geopoint']?['_long'] as num?)?.toDouble() ?? 0.0,
      geohash: map['geohash'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'geopoint': {
        '_lat': lat,
        '_long': lng,
      },
      if (geohash != null) 'geohash': geohash,
    };
  }
}

