import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RideModel {
  final String id;
  final String driverId;
  final String driverName;
  final String driverAvatar;
  final String driverPhone;
  final double rating;
  final int totalRides;
  final String carModel;
  final String carPlate;
  final String origin;
  final String destination;
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final double currentDriverLat;
  final double currentDriverLng;
  final String departureTime;
  final String estimatedDuration;
  final double pricePerSeat;
  final int seatsAvailable;
  final bool isVerified;
  final bool isDriverOnline;
  final List<String> stops;
  final int matchPercentage;
  final int detourMinutes;
  final String pickupSuggestion;
  final String dropOffPlan;
  final bool isEnRouteMatch;
  final double enRouteDetourKm;
  final double? enRouteSubFare;
  final double searchedPickupLat;
  final double searchedPickupLng;
  final double searchedDropLat;
  final double searchedDropLng;
  final String searchedPickupAddress;
  final String searchedDropAddress;
  final String status;

  RideModel({
    required this.id,
    this.driverId = '',
    required this.driverName,
    required this.driverAvatar,
    this.driverPhone = '+61 412 345 678',
    required this.rating,
    required this.totalRides,
    required this.carModel,
    required this.carPlate,
    required this.origin,
    required this.destination,
    this.originLat = 0.0,
    this.originLng = 0.0,
    this.destinationLat = 0.0,
    this.destinationLng = 0.0,
    this.currentDriverLat = 0.0,
    this.currentDriverLng = 0.0,
    required this.departureTime,
    required this.estimatedDuration,
    required this.pricePerSeat,
    required this.seatsAvailable,
    this.isVerified = true,
    this.isDriverOnline = true,
    this.stops = const [],
    this.matchPercentage = 95,
    this.detourMinutes = 4,
    this.pickupSuggestion = 'Shell Station, Landsdale',
    this.dropOffPlan = 'Landsdale → Curtin University',
    this.isEnRouteMatch = false,
    this.enRouteDetourKm = 0.0,
    this.enRouteSubFare,
    this.searchedPickupLat = 0.0,
    this.searchedPickupLng = 0.0,
    this.searchedDropLat = 0.0,
    this.searchedDropLng = 0.0,
    this.searchedPickupAddress = '',
    this.searchedDropAddress = '',
    this.status = 'scheduled',
  });

  RideModel copyWith({
    String? id,
    String? driverId,
    String? driverName,
    String? driverAvatar,
    String? driverPhone,
    double? rating,
    int? totalRides,
    String? carModel,
    String? carPlate,
    String? origin,
    String? destination,
    double? originLat,
    double? originLng,
    double? destinationLat,
    double? destinationLng,
    double? currentDriverLat,
    double? currentDriverLng,
    String? departureTime,
    String? estimatedDuration,
    double? pricePerSeat,
    int? seatsAvailable,
    bool? isVerified,
    bool? isDriverOnline,
    List<String>? stops,
    int? matchPercentage,
    int? detourMinutes,
    String? pickupSuggestion,
    String? dropOffPlan,
    bool? isEnRouteMatch,
    double? enRouteDetourKm,
    double? enRouteSubFare,
    double? searchedPickupLat,
    double? searchedPickupLng,
    double? searchedDropLat,
    double? searchedDropLng,
    String? searchedPickupAddress,
    String? searchedDropAddress,
    String? status,
  }) {
    return RideModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverAvatar: driverAvatar ?? this.driverAvatar,
      driverPhone: driverPhone ?? this.driverPhone,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      carModel: carModel ?? this.carModel,
      carPlate: carPlate ?? this.carPlate,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      currentDriverLat: currentDriverLat ?? this.currentDriverLat,
      currentDriverLng: currentDriverLng ?? this.currentDriverLng,
      departureTime: departureTime ?? this.departureTime,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      seatsAvailable: seatsAvailable ?? this.seatsAvailable,
      isVerified: isVerified ?? this.isVerified,
      isDriverOnline: isDriverOnline ?? this.isDriverOnline,
      stops: stops ?? this.stops,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      detourMinutes: detourMinutes ?? this.detourMinutes,
      pickupSuggestion: pickupSuggestion ?? this.pickupSuggestion,
      dropOffPlan: dropOffPlan ?? this.dropOffPlan,
      isEnRouteMatch: isEnRouteMatch ?? this.isEnRouteMatch,
      enRouteDetourKm: enRouteDetourKm ?? this.enRouteDetourKm,
      enRouteSubFare: enRouteSubFare ?? this.enRouteSubFare,
      searchedPickupLat: searchedPickupLat ?? this.searchedPickupLat,
      searchedPickupLng: searchedPickupLng ?? this.searchedPickupLng,
      searchedDropLat: searchedDropLat ?? this.searchedDropLat,
      searchedDropLng: searchedDropLng ?? this.searchedDropLng,
      searchedPickupAddress: searchedPickupAddress ?? this.searchedPickupAddress,
      searchedDropAddress: searchedDropAddress ?? this.searchedDropAddress,
      status: status ?? this.status,
    );
  }
}

class PassengerPendingRequestModel {
  final String id;
  final String bookingId;
  final RideModel ride;
  final int requestedSeats;
  final String passengerLabel;
  final double totalPrice;
  final String requestTime;
  final RxString status;

  PassengerPendingRequestModel({
    required this.id,
    this.bookingId = '',
    required this.ride,
    required this.requestedSeats,
    required this.passengerLabel,
    required this.totalPrice,
    required this.requestTime,
    String status = 'Waiting for driver approval',
  }) : status = status.obs;
}

class BookingModel {
  final String id;
  final String bookingId;
  final RideModel ride;
  final int bookedSeats;
  final double totalPrice;
  final String status; // 'Confirmed', 'Upcoming', 'Completed', 'Cancelled'
  final String bookingDate;

  BookingModel({
    required this.id,
    this.bookingId = '',
    required this.ride,
    required this.bookedSeats,
    required this.totalPrice,
    required this.status,
    required this.bookingDate,
  });
}

class CompletedTripModel {
  final String id;
  final String driverName;
  final String carModel;
  final String carPlate;
  final String route;
  final String date;
  final String fare;
  final RxBool isRated;
  final RxDouble rating;
  final RxString reviewComment;

  CompletedTripModel({
    required this.id,
    required this.driverName,
    required this.carModel,
    required this.carPlate,
    required this.route,
    required this.date,
    required this.fare,
    bool isRated = false,
    double rating = 5.0,
    String reviewComment = '',
  })  : isRated = isRated.obs,
        rating = rating.obs,
        reviewComment = reviewComment.obs;
}

class SavedLocationModel {
  final String id;
  final String title;
  final String address;
  final String category; // 'home', 'work', 'university', 'gym', 'custom'

  SavedLocationModel({
    required this.id,
    required this.title,
    required this.address,
    required this.category,
  });
}

class PassengerEmergencyContactModel {
  final String id;
  final String name;
  final String relation; // e.g. 'Mother', 'Father', 'Spouse', 'Sibling', 'Friend', 'Guardian'
  final String phone;
  final RxBool isPrimary;

  PassengerEmergencyContactModel({
    required this.id,
    required this.name,
    required this.relation,
    required this.phone,
    bool isPrimary = false,
  }) : isPrimary = isPrimary.obs;
}

class RecentRouteModel {
  final String id;
  final String from;
  final String to;
  final String subtitle;

  RecentRouteModel({
    required this.id,
    required this.from,
    required this.to,
    required this.subtitle,
  });
}

class PassengerSupportChatMessageModel {
  final String id;
  final String senderRole; // 'passenger' | 'admin'
  final String senderName;
  final String message;
  final DateTime timestamp;

  PassengerSupportChatMessageModel({
    required this.id,
    required this.senderRole,
    required this.senderName,
    required this.message,
    required this.timestamp,
  });

  bool get isAdmin => senderRole == 'admin';
}

class PassengerSupportTicketModel {
  final String id;
  final String subject;
  final String category;
  final String message;
  final DateTime createdAt;
  final RxString status;
  final RxList<PassengerSupportChatMessageModel> messages;

  PassengerSupportTicketModel({
    required this.id,
    required this.subject,
    required this.category,
    required this.message,
    required this.createdAt,
    String status = 'Open',
    List<PassengerSupportChatMessageModel>? initialMessages,
  })  : status = normalizeStatus(status).obs,
        messages = (initialMessages ??
                [
                  PassengerSupportChatMessageModel(
                    id: 'msg_init',
                    senderRole: 'passenger',
                    senderName: 'Passenger',
                    message: message,
                    timestamp: createdAt,
                  ),
                ])
            .obs;

  static String normalizeStatus(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Open';
    final clean =
        raw.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    if (clean == 'in_progress' || clean == 'inprogress') return 'In Progress';
    if (clean == 'resolved' || clean == 'closed') return 'Resolved';
    if (clean == 'open') return 'Open';
    return raw.trim();
  }

  String get displayStatus => normalizeStatus(status.value);

  bool get isLocked => normalizeStatus(status.value) == 'Resolved';
}

class CommunityModel {
  final String id;
  final String name;
  final String routeSummary; // e.g. 'Landsdale → Curtin University'
  final String commonTime; // e.g. '7:30 AM - 9:00 AM'
  final String description;
  final RxInt passengersCount;
  final RxInt driversCount;
  final String nextRideTime; // e.g. 'Tomorrow 8:00 AM'
  final int nextRideSeatsOpen; // e.g. 3
  final RxBool isJoined;
  final IconData icon;

  CommunityModel({
    required this.id,
    required this.name,
    required this.routeSummary,
    required this.commonTime,
    required this.description,
    required int passengersCount,
    required int driversCount,
    required this.nextRideTime,
    required this.nextRideSeatsOpen,
    bool isJoined = false,
    this.icon = Icons.school_outlined,
  })  : passengersCount = passengersCount.obs,
        driversCount = driversCount.obs,
        isJoined = isJoined.obs;

  static IconData parseIcon(dynamic iconData) {
    if (iconData is IconData) return iconData;
    if (iconData is String) {
      switch (iconData.toLowerCase().trim()) {
        case 'school':
        case 'university':
        case 'campus':
        case 'education':
          return Icons.school_outlined;
        case 'business':
        case 'work':
        case 'office':
        case 'cbd':
          return Icons.business_center_outlined;
        case 'hospital':
        case 'medical':
        case 'health':
          return Icons.local_hospital_outlined;
        case 'car':
        case 'commute':
        case 'drive':
        case 'route':
          return Icons.directions_car_outlined;
        default:
          return Icons.groups_outlined;
      }
    }
    return Icons.groups_outlined;
  }

  factory CommunityModel.fromMap(
    Map<String, dynamic> data,
    String id, {
    String? currentUserId,
  }) {
    final memberIds = (data['memberIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final passengerMemberIds = (data['passengerMemberIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final driverMemberIds = (data['driverMemberIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final bool isUserJoined = currentUserId != null &&
        (memberIds.contains(currentUserId) ||
            passengerMemberIds.contains(currentUserId) ||
            driverMemberIds.contains(currentUserId));

    final rawPassengers = (data['passengersCount'] as num?)?.toInt() ??
        passengerMemberIds.length;
    final rawDrivers = (data['driversCount'] as num?)?.toInt() ??
        driverMemberIds.length;

    return CommunityModel(
      id: id,
      name: data['name']?.toString() ?? '',
      routeSummary: data['routeSummary']?.toString() ?? '',
      commonTime: data['commonTime']?.toString() ?? '8:00 AM - 9:30 AM',
      description: data['description']?.toString() ?? '',
      passengersCount: rawPassengers < 0 ? 0 : rawPassengers,
      driversCount: rawDrivers < 0 ? 0 : rawDrivers,
      nextRideTime: data['nextRideTime']?.toString() ?? 'Tomorrow 8:00 AM',
      nextRideSeatsOpen: (data['nextRideSeatsOpen'] as num?)?.toInt() ?? 3,
      isJoined: isUserJoined,
      icon: parseIcon(data['icon']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'routeSummary': routeSummary,
      'commonTime': commonTime,
      'description': description,
      'passengersCount': passengersCount.value,
      'driversCount': driversCount.value,
      'nextRideTime': nextRideTime,
      'nextRideSeatsOpen': nextRideSeatsOpen,
      'icon': 'school',
    };
  }
}

