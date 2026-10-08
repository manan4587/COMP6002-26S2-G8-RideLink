import 'package:get/get.dart';

class DriverTripModel {
  final String id;
  final String from;
  final String to;
  final double fromLat;
  final double fromLng;
  final double toLat;
  final double toLng;
  final RxDouble currentDriverLat;
  final RxDouble currentDriverLng;
  final RxString time;
  final RxDouble pricePerSeat;
  final RxInt totalSeats;
  final RxInt bookedSeats;
  final RxString status; // 'Active', 'Scheduled', 'Completed', 'Cancelled'
  final bool isRecurring;
  final List<String> recurringDays;
  final String communityName;
  final DateTime? departureDateTime;
  final RxList<PassengerRequestModel> requests;
  final RxList<PassengerRequestModel> acceptedPassengers;

  DriverTripModel({
    required this.id,
    required this.from,
    required this.to,
    this.fromLat = 0.0,
    this.fromLng = 0.0,
    this.toLat = 0.0,
    this.toLng = 0.0,
    double currentDriverLat = 0.0,
    double currentDriverLng = 0.0,
    required String time,
    required double pricePerSeat,
    required int totalSeats,
    required int bookedSeats,
    required String status,
    this.isRecurring = false,
    this.recurringDays = const [],
    this.communityName = '',
    this.departureDateTime,
    List<PassengerRequestModel> requests = const [],
    List<PassengerRequestModel> acceptedPassengers = const [],
  })  : currentDriverLat = currentDriverLat.obs,
        currentDriverLng = currentDriverLng.obs,
        time = time.obs,
        pricePerSeat = pricePerSeat.obs,
        totalSeats = totalSeats.obs,
        bookedSeats = bookedSeats.obs,
        status = status.obs,
        requests = RxList<PassengerRequestModel>.from(requests),
        acceptedPassengers =
            RxList<PassengerRequestModel>.from(acceptedPassengers);

  /// Driver can only start a ride 15 minutes before the scheduled start time or later
  bool get canStartRide {
    if (departureDateTime == null) return true;
    final now = DateTime.now();
    final allowedStartTime = departureDateTime!.subtract(const Duration(minutes: 15));
    return now.isAfter(allowedStartTime);
  }

  String get timeUntilCanStartMessage {
    if (departureDateTime == null) return '';
    final now = DateTime.now();
    final allowedStartTime = departureDateTime!.subtract(const Duration(minutes: 15));
    if (now.isAfter(allowedStartTime)) return '';

    final diff = allowedStartTime.difference(now);
    if (diff.inHours > 0) {
      return 'Can start 15m before (in ${diff.inHours}h ${diff.inMinutes % 60}m)';
    } else if (diff.inMinutes > 0) {
      return 'Can start 15m before (in ${diff.inMinutes}m)';
    } else {
      return 'Can start in less than 1m';
    }
  }
}

class PassengerRequestModel {
  final String id;
  final String? tripId;
  final String? passengerId;
  final String passengerName;
  final double rating;
  final String from;
  final String to;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final int seats;
  final double fare;
  final String time;
  final String travellingWith;
  final String detour;
  final int pastTrips;
  final RxString status; // 'Pending', 'Accepted', 'Declined'
  final RxString passengerStatus; // 'to_pickup', 'arrived', 'onboard', 'dropped_off'
  final String emergencyContactName;
  final String emergencyContactRelation;
  final String emergencyContactPhone;
  final String pickupOtp;
  final RxBool isRated;
  final RxDouble passengerRatingGiven;

  PassengerRequestModel({
    required this.id,
    this.tripId,
    this.passengerId,
    required this.passengerName,
    required this.rating,
    required this.from,
    required this.to,
    this.pickupLat = 0.0,
    this.pickupLng = 0.0,
    this.dropLat = 0.0,
    this.dropLng = 0.0,
    required this.seats,
    required this.fare,
    required this.time,
    this.travellingWith = '+1 passenger',
    this.detour = '+4 minutes only',
    this.pastTrips = 12,
    String status = 'Pending',
    String passengerStatus = 'to_pickup',
    this.emergencyContactName = 'Sarah Jenkins',
    this.emergencyContactRelation = 'Mother',
    this.emergencyContactPhone = '+61 412 345 678',
    this.pickupOtp = '1234',
    bool isRated = false,
    double passengerRatingGiven = 5.0,
  })  : status = status.obs,
        passengerStatus = passengerStatus.obs,
        isRated = isRated.obs,
        passengerRatingGiven = passengerRatingGiven.obs;

  bool get isWaitingPickup =>
      passengerStatus.value == 'to_pickup' || passengerStatus.value == 'arrived';
  bool get isOnboard => passengerStatus.value == 'onboard';
  bool get isDroppedOff => passengerStatus.value == 'dropped_off';
}

class SupportChatMessageModel {
  final String id;
  final String senderRole; // 'driver' | 'passenger' | 'admin'
  final String senderName;
  final String message;
  final DateTime timestamp;

  SupportChatMessageModel({
    required this.id,
    required this.senderRole,
    required this.senderName,
    required this.message,
    required this.timestamp,
  });

  bool get isAdmin => senderRole == 'admin';
}

class SupportTicketModel {
  final String id;
  final String subject;
  final String category;
  final String message;
  final DateTime createdAt;
  final RxString status; // 'Open', 'In Progress', 'Resolved'
  final RxList<SupportChatMessageModel> messages;

  SupportTicketModel({
    required this.id,
    required this.subject,
    required this.category,
    required this.message,
    required this.createdAt,
    String status = 'Open',
    List<SupportChatMessageModel>? initialMessages,
  })  : status = normalizeStatus(status).obs,
        messages = (initialMessages ??
                [
                  SupportChatMessageModel(
                    id: 'msg_init',
                    senderRole: 'driver',
                    senderName: 'Driver',
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

