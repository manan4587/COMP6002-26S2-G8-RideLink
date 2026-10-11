import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/utils/preferences.dart';

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
  final double currentDriverHeading;
  final double currentDriverSpeed;
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
  final DateTime? departureDateTime;

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
    this.currentDriverHeading = 0.0,
    this.currentDriverSpeed = 0.0,
    required this.departureTime,
    required this.estimatedDuration,
    required this.pricePerSeat,
    required this.seatsAvailable,
    this.isVerified = true,
    this.isDriverOnline = true,
    this.stops = const [],
    this.matchPercentage = 95,
    this.detourMinutes = 4,
    this.pickupSuggestion = '',
    this.dropOffPlan = '',
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
    this.departureDateTime,
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
    double? currentDriverHeading,
    double? currentDriverSpeed,
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
    DateTime? departureDateTime,
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
      currentDriverHeading: currentDriverHeading ?? this.currentDriverHeading,
      currentDriverSpeed: currentDriverSpeed ?? this.currentDriverSpeed,
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
      departureDateTime: departureDateTime ?? this.departureDateTime,
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
  final String pickupOtp;
  final String passengerStatus; // 'to_pickup' | 'arrived' | 'onboard' | 'dropped_off'

  BookingModel({
    required this.id,
    this.bookingId = '',
    required this.ride,
    required this.bookedSeats,
    required this.totalPrice,
    required this.status,
    required this.bookingDate,
    this.pickupOtp = '1234',
    this.passengerStatus = 'to_pickup',
  });

  bool get isOnboard =>
      passengerStatus.toLowerCase().trim() == 'onboard' ||
      status.toLowerCase().trim() == 'onboard' ||
      passengerStatus.toLowerCase().trim() == 'dropped_off' ||
      status.toLowerCase().trim() == 'completed';
}

class CompletedTripModel {
  final String id;
  final String bookingId;
  final String driverId;
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
    this.bookingId = '',
    this.driverId = '',
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
  final double latitude;
  final double longitude;

  SavedLocationModel({
    required this.id,
    required this.title,
    required this.address,
    required this.category,
    this.latitude = 0.0,
    this.longitude = 0.0,
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
  final String pickupLocation;
  final String dropOffLocation;
  final double dropOffLat;
  final double dropOffLng;
  final String fixedLocationType; // 'dropoff' | 'pickup' | 'both' | 'none'
  final bool isFixedPickup;
  final bool isFixedDropOff;
  final String fixedLocation;
  final String commonTime; // e.g. '7:30 AM - 9:00 AM'
  final String nextRideTime; // e.g. '22/10/2026 08:00 AM'
  final String recurringOption; // e.g. 'Weekdays (Mon-Fri)'
  final List<String> recurringDays; // e.g. ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']
  final String description;
  final RxInt passengersCount;
  final RxInt driversCount;
  final int nextRideSeatsOpen; // e.g. 3
  final RxBool isJoined;
  final IconData icon;
  final String iconType;
  final String category;
  final String coverImageUrl;
  final bool isActive;
  final List<String> memberIds;
  final List<String> passengerMemberIds;
  final List<String> driverMemberIds;

  CommunityModel({
    required this.id,
    required this.name,
    required this.routeSummary,
    this.pickupLocation = '',
    this.dropOffLocation = '',
    this.dropOffLat = 0.0,
    this.dropOffLng = 0.0,
    this.fixedLocationType = 'none',
    this.isFixedPickup = false,
    this.isFixedDropOff = false,
    this.fixedLocation = '',
    required this.commonTime,
    required this.description,
    required int passengersCount,
    required int driversCount,
    required this.nextRideTime,
    required this.nextRideSeatsOpen,
    this.recurringOption = 'Weekdays (Mon-Fri)',
    this.recurringDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    bool isJoined = false,
    this.icon = Icons.home_outlined,
    this.iconType = 'home',
    this.category = 'corridor',
    this.coverImageUrl = '',
    this.isActive = true,
    this.memberIds = const [],
    this.passengerMemberIds = const [],
    this.driverMemberIds = const [],
  })  : passengersCount = passengersCount.obs,
        driversCount = driversCount.obs,
        isJoined = isJoined.obs;

  bool get hasFixedTerminal =>
      isFixedDropOff || isFixedPickup || fixedLocationType != 'none';

  String get fixedTerminalLabel {
    if (fixedLocation.isNotEmpty) return fixedLocation;
    if (isFixedDropOff || fixedLocationType == 'dropoff') {
      return dropOffLocation.isNotEmpty ? dropOffLocation : routeSummary;
    }
    if (isFixedPickup || fixedLocationType == 'pickup') {
      return pickupLocation.isNotEmpty ? pickupLocation : routeSummary;
    }
    return '';
  }

  static IconData parseIcon(dynamic iconData) {
    if (iconData is IconData) return iconData;
    if (iconData is String) {
      switch (iconData.toLowerCase().trim()) {
        case 'home':
        case 'residential':
        case 'suburb':
        case 'neighbourhood':
        case 'house':
        case 'residence':
          return Icons.home_outlined;
        case 'stadium':
        case 'arena':
        case 'sports':
        case 'events':
        case 'optus':
        case 'match':
          return Icons.stadium_outlined;
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
          // Replaced car icon with home per requirement
          return Icons.home_outlined;
        default:
          return Icons.home_outlined;
      }
    }
    return Icons.home_outlined;
  }

  static String parseIconType(dynamic iconData) {
    if (iconData is String) {
      final val = iconData.toLowerCase().trim();
      if (val == 'home' || val == 'residential' || val == 'suburb' || val == 'house' || val == 'residence') return 'home';
      if (val == 'stadium' || val == 'arena' || val == 'sports' || val == 'events' || val == 'optus' || val == 'match') return 'stadium';
      if (val == 'school' || val == 'university' || val == 'campus' || val == 'education') return 'school';
      if (val == 'business' || val == 'work' || val == 'office' || val == 'cbd') return 'business';
      if (val == 'hospital' || val == 'medical' || val == 'health') return 'hospital';
      if (val == 'car') return 'home'; // car replaced by home
    }
    return 'home';
  }

  Color get iconColor {
    switch (iconType) {
      case 'home':
        return const Color(0xFFD97706); // Amber
      case 'stadium':
        return const Color(0xFF059669); // Emerald
      case 'school':
        return const Color(0xFF4F46E5); // Indigo
      case 'business':
        return const Color(0xFF2563EB); // Blue
      case 'hospital':
        return const Color(0xFFDC2626); // Red
      default:
        return const Color(0xFFD97706);
    }
  }

  Color get iconBgColor {
    switch (iconType) {
      case 'home':
        return const Color(0xFFFEF3C7); // Amber 100
      case 'stadium':
        return const Color(0xFFD1FAE5); // Emerald 100
      case 'school':
        return const Color(0xFFEEF2FF); // Indigo 50
      case 'business':
        return const Color(0xFFEFF6FF); // Blue 50
      case 'hospital':
        return const Color(0xFFFEE2E2); // Red 100
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  String get categoryLabel {
    switch (iconType) {
      case 'home':
        return 'Residential';
      case 'stadium':
        return 'Stadium & Events';
      case 'school':
        return 'Campus & Uni';
      case 'business':
        return 'CBD & Work';
      case 'hospital':
        return 'Healthcare';
      default:
        return 'Community';
    }
  }

  factory CommunityModel.fromMap(
    Map<String, dynamic> data,
    String id, {
    String? currentUserId,
    String? userRole,
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

    final effectiveRole = userRole ?? Preferences.userRole;
    final bool isUserJoined;
    if (currentUserId == null) {
      isUserJoined = false;
    } else if (effectiveRole == 'driver') {
      isUserJoined = driverMemberIds.contains(currentUserId);
    } else {
      isUserJoined = passengerMemberIds.contains(currentUserId) ||
          (memberIds.contains(currentUserId) &&
              !driverMemberIds.contains(currentUserId));
    }

    final rawPassengers = (data['passengersCount'] as num?)?.toInt() ??
        passengerMemberIds.length;
    final rawDrivers = (data['driversCount'] as num?)?.toInt() ??
        driverMemberIds.length;

    final rawIcon = data['icon'];
    final rawFixedType = data['fixedLocationType']?.toString().toLowerCase().trim() ?? 'none';
    final parsedDropLocation = data['dropOffLocation']?.toString() ??
        data['dropoffLocation']?.toString() ??
        data['destination']?.toString() ??
        data['to']?.toString() ??
        '';
    final isFixedDrop = data['isFixedDropOff'] == true ||
        data['isFixedDropoff'] == true ||
        data['fixedDropOff'] == true ||
        data['fixedDrop'] == true ||
        rawFixedType == 'dropoff' ||
        rawFixedType == 'both' ||
        parsedDropLocation.trim().isNotEmpty;
    final isFixedPick = data['isFixedPickup'] == true ||
        data['isFixedPickup'] == true ||
        rawFixedType == 'pickup' ||
        rawFixedType == 'both';

    final rawDropLat = (data['dropOffLat'] ??
            data['dropoffLat'] ??
            data['toLat'] ??
            data['destinationLat'] ??
            data['fixedLat'] as num?)
        ?.toDouble() ??
        0.0;
    final rawDropLng = (data['dropOffLng'] ??
            data['dropoffLng'] ??
            data['toLng'] ??
            data['destinationLng'] ??
            data['fixedLng'] as num?)
        ?.toDouble() ??
        0.0;

    final recurringDaysList = (data['recurringDays'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

    return CommunityModel(
      id: id,
      name: data['name']?.toString() ?? '',
      routeSummary: data['routeSummary']?.toString() ?? '',
      pickupLocation: data['pickupLocation']?.toString() ??
          data['pickUpLocation']?.toString() ??
          data['from']?.toString() ??
          '',
      dropOffLocation: parsedDropLocation,
      dropOffLat: rawDropLat,
      dropOffLng: rawDropLng,
      fixedLocationType: rawFixedType,
      isFixedPickup: isFixedPick,
      isFixedDropOff: isFixedDrop,
      fixedLocation: data['fixedLocation']?.toString() ?? '',
      commonTime: data['commonTime']?.toString() ?? '7:30 AM - 9:00 AM',
      nextRideTime: data['nextRideTime']?.toString() ?? 'Tomorrow 8:00 AM',
      recurringOption: data['recurringOption']?.toString() ?? 'Weekdays (Mon-Fri)',
      recurringDays: recurringDaysList,
      description: data['description']?.toString() ?? '',
      passengersCount: rawPassengers < 0 ? 0 : rawPassengers,
      driversCount: rawDrivers < 0 ? 0 : rawDrivers,
      nextRideSeatsOpen: (data['nextRideSeatsOpen'] as num?)?.toInt() ?? 3,
      isJoined: isUserJoined,
      icon: parseIcon(rawIcon),
      iconType: parseIconType(rawIcon),
      category: data['category']?.toString() ?? 'corridor',
      coverImageUrl: data['coverImageUrl']?.toString() ?? '',
      isActive: data['isActive'] != false,
      memberIds: memberIds,
      passengerMemberIds: passengerMemberIds,
      driverMemberIds: driverMemberIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'routeSummary': routeSummary,
      'pickupLocation': pickupLocation,
      'dropOffLocation': dropOffLocation,
      'dropOffLat': dropOffLat,
      'dropOffLng': dropOffLng,
      'fixedLocationType': fixedLocationType,
      'isFixedPickup': isFixedPickup,
      'isFixedDropOff': isFixedDropOff,
      'fixedLocation': fixedLocation,
      'commonTime': commonTime,
      'nextRideTime': nextRideTime,
      'recurringOption': recurringOption,
      'recurringDays': recurringDays,
      'description': description,
      'passengersCount': passengersCount.value,
      'driversCount': driversCount.value,
      'nextRideSeatsOpen': nextRideSeatsOpen,
      'icon': iconType,
      'category': category,
      'coverImageUrl': coverImageUrl,
      'isActive': isActive,
      'memberIds': memberIds,
      'passengerMemberIds': passengerMemberIds,
      'driverMemberIds': driverMemberIds,
    };
  }
}

