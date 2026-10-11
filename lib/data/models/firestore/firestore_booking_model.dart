class FirestoreBookingModel {
  final String id;
  final String rideId;
  final String passengerId;
  final String driverId;
  final String passengerName;
  final String? passengerPhoto;
  final double passengerRating;
  final String originName;
  final String destinationName;
  final DateTime departureTime;
  final String driverName;
  final String carModel;
  final String carPlate;
  final int seatsBooked;
  final double pricePerSeat;
  final double totalAmount;
  final String paymentStatus; // 'pending' | 'held_in_escrow' | 'paid' | 'refunded'
  final String status; // 'pending' | 'confirmed' | 'declined' | 'completed' | 'cancelled'
  final DateTime? createdAt;

  FirestoreBookingModel({
    required this.id,
    required this.rideId,
    required this.passengerId,
    required this.driverId,
    required this.passengerName,
    this.passengerPhoto,
    required this.passengerRating,
    required this.originName,
    required this.destinationName,
    required this.departureTime,
    required this.driverName,
    required this.carModel,
    required this.carPlate,
    required this.seatsBooked,
    required this.pricePerSeat,
    required this.totalAmount,
    this.paymentStatus = 'held_in_escrow',
    this.status = 'confirmed',
    this.createdAt,
  });

  factory FirestoreBookingModel.fromMap(Map<String, dynamic> map, String id) {
    return FirestoreBookingModel(
      id: id,
      rideId: map['rideId'] as String? ?? '',
      passengerId: map['passengerId'] as String? ?? '',
      driverId: map['driverId'] as String? ?? '',
      passengerName: map['passenger']?['name'] as String? ?? '',
      passengerPhoto: map['passenger']?['photoUrl'] as String?,
      passengerRating:
          (map['passengerRating'] as num?)?.toDouble() ??
          (map['passenger']?['rating'] as num?)?.toDouble() ??
          (map['rating'] as num?)?.toDouble() ??
          5.0,
      originName: map['rideSnapshot']?['originName'] as String? ?? '',
      destinationName: map['rideSnapshot']?['destinationName'] as String? ?? '',
      departureTime: map['rideSnapshot']?['departureTime'] != null
          ? DateTime.tryParse(map['rideSnapshot']['departureTime'].toString()) ??
              DateTime.now()
          : DateTime.now(),
      driverName: map['rideSnapshot']?['driverName'] as String? ?? '',
      carModel: map['rideSnapshot']?['carModel'] as String? ?? '',
      carPlate: map['rideSnapshot']?['carPlate'] as String? ?? '',
      seatsBooked: (map['seatsBooked'] as num?)?.toInt() ?? 1,
      pricePerSeat: (map['pricePerSeat'] as num?)?.toDouble() ?? 12.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 12.0,
      paymentStatus: map['paymentStatus'] as String? ?? 'held_in_escrow',
      status: map['status'] as String? ?? 'confirmed',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rideId': rideId,
      'passengerId': passengerId,
      'driverId': driverId,
      'passenger': {
        'name': passengerName,
        'photoUrl': passengerPhoto,
        'rating': passengerRating,
      },
      'rideSnapshot': {
        'originName': originName,
        'destinationName': destinationName,
        'departureTime': departureTime.toIso8601String(),
        'driverName': driverName,
        'carModel': carModel,
        'carPlate': carPlate,
      },
      'seatsBooked': seatsBooked,
      'pricePerSeat': pricePerSeat,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

