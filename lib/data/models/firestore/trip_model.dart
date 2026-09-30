import 'package:cloud_firestore/cloud_firestore.dart';

class TripChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole; // 'driver' | 'passenger'
  final String message;
  final DateTime timestamp;

  TripChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.timestamp,
  });

  factory TripChatMessageModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedTime = DateTime.now();
    if (map['timestamp'] is Timestamp) {
      parsedTime = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is String) {
      parsedTime = DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now();
    }

    return TripChatMessageModel(
      id: id,
      senderId: map['senderId']?.toString() ?? '',
      senderName: map['senderName']?.toString() ?? '',
      senderRole: map['senderRole']?.toString() ?? 'passenger',
      message: map['message']?.toString() ?? '',
      timestamp: parsedTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

class TripBookingModel {
  final String id;
  final String tripId;
  final String passengerId;
  final String passengerName;
  final String passengerPhone;
  final double passengerRating;
  final int requestedSeats;
  final double fare;
  final String status; // 'pending' | 'accepted' | 'declined' | 'cancelled'
  final String pickupAddress;
  final String dropAddress;
  final DateTime createdAt;

  TripBookingModel({
    required this.id,
    required this.tripId,
    required this.passengerId,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerRating,
    required this.requestedSeats,
    required this.fare,
    required this.status,
    required this.pickupAddress,
    required this.dropAddress,
    required this.createdAt,
  });

  factory TripBookingModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime created = DateTime.now();
    if (map['createdAt'] is Timestamp) {
      created = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      created = DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now();
    }

    return TripBookingModel(
      id: id,
      tripId: map['tripId']?.toString() ?? '',
      passengerId: map['passengerId']?.toString() ?? '',
      passengerName: map['passengerName']?.toString() ?? '',
      passengerPhone: map['passengerPhone']?.toString() ?? '',
      passengerRating: (map['passengerRating'] as num?)?.toDouble() ?? 0.0,
      requestedSeats: (map['requestedSeats'] as num?)?.toInt() ?? 1,
      fare: (map['fare'] as num?)?.toDouble() ?? 0.0,
      status: map['status']?.toString() ?? 'pending',
      pickupAddress: map['pickupAddress']?.toString() ?? '',
      dropAddress: map['dropAddress']?.toString() ?? '',
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'passengerId': passengerId,
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'passengerRating': passengerRating,
      'requestedSeats': requestedSeats,
      'fare': fare,
      'status': status,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class TripModel {
  final String id;
  final String driverId;
  final String driverName;
  final String driverPhone;
  final double driverRating;
  final int driverTotalRides;
  final String carModel;
  final String carPlate;
  final String carColor;
  final String originName;
  final String originAddress;
  final double originLat;
  final double originLng;
  final String destinationName;
  final String destinationAddress;
  final double destinationLat;
  final double destinationLng;
  final DateTime departureTime;
  final String departureTimeString;
  final int totalSeats;
  final int availableSeats;
  final int bookedSeats;
  final double pricePerSeat;
  final String communityName;
  final String status; // 'scheduled' | 'active' | 'completed' | 'cancelled'
  final bool allowLuggage;
  final bool allowPets;
  final bool allowSmoking;
  final DateTime createdAt;

  TripModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.driverRating,
    required this.driverTotalRides,
    required this.carModel,
    required this.carPlate,
    this.carColor = '',
    required this.originName,
    required this.originAddress,
    required this.originLat,
    required this.originLng,
    required this.destinationName,
    required this.destinationAddress,
    required this.destinationLat,
    required this.destinationLng,
    required this.departureTime,
    required this.departureTimeString,
    required this.totalSeats,
    required this.availableSeats,
    required this.bookedSeats,
    required this.pricePerSeat,
    this.communityName = '',
    required this.status,
    this.allowLuggage = true,
    this.allowPets = false,
    this.allowSmoking = false,
    required this.createdAt,
  });

  factory TripModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime depTime = DateTime.now();
    if (map['departureTime'] is Timestamp) {
      depTime = (map['departureTime'] as Timestamp).toDate();
    } else if (map['departureTime'] is String) {
      depTime = DateTime.tryParse(map['departureTime'] as String) ?? DateTime.now();
    }

    DateTime created = DateTime.now();
    if (map['createdAt'] is Timestamp) {
      created = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      created = DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now();
    }

    return TripModel(
      id: id,
      driverId: map['driverId']?.toString() ?? '',
      driverName: map['driverName']?.toString() ?? '',
      driverPhone: map['driverPhone']?.toString() ?? '',
      driverRating: (map['driverRating'] as num?)?.toDouble() ?? 0.0,
      driverTotalRides: (map['driverTotalRides'] as num?)?.toInt() ?? 0,
      carModel: map['carModel']?.toString() ?? '',
      carPlate: map['carPlate']?.toString() ?? '',
      carColor: map['carColor']?.toString() ?? '',
      originName: map['originName']?.toString() ?? '',
      originAddress: map['originAddress']?.toString() ?? '',
      originLat: (map['originLat'] as num?)?.toDouble() ?? 0.0,
      originLng: (map['originLng'] as num?)?.toDouble() ?? 0.0,
      destinationName: map['destinationName']?.toString() ?? '',
      destinationAddress: map['destinationAddress']?.toString() ?? '',
      destinationLat: (map['destinationLat'] as num?)?.toDouble() ?? 0.0,
      destinationLng: (map['destinationLng'] as num?)?.toDouble() ?? 0.0,
      departureTime: depTime,
      departureTimeString: map['departureTimeString']?.toString() ?? '',
      totalSeats: (map['totalSeats'] as num?)?.toInt() ?? 3,
      availableSeats: (map['availableSeats'] as num?)?.toInt() ?? 3,
      bookedSeats: (map['bookedSeats'] as num?)?.toInt() ?? 0,
      pricePerSeat: (map['pricePerSeat'] as num?)?.toDouble() ?? 0.0,
      communityName: map['communityName']?.toString() ?? '',
      status: map['status']?.toString() ?? 'scheduled',
      allowLuggage: map['allowLuggage'] as bool? ?? true,
      allowPets: map['allowPets'] as bool? ?? false,
      allowSmoking: map['allowSmoking'] as bool? ?? false,
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'driverRating': driverRating,
      'driverTotalRides': driverTotalRides,
      'carModel': carModel,
      'carPlate': carPlate,
      'carColor': carColor,
      'originName': originName,
      'originAddress': originAddress,
      'originLat': originLat,
      'originLng': originLng,
      'destinationName': destinationName,
      'destinationAddress': destinationAddress,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'departureTime': Timestamp.fromDate(departureTime),
      'departureTimeString': departureTimeString,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'bookedSeats': bookedSeats,
      'pricePerSeat': pricePerSeat,
      'communityName': communityName,
      'status': status,
      'allowLuggage': allowLuggage,
      'allowPets': allowPets,
      'allowSmoking': allowSmoking,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

