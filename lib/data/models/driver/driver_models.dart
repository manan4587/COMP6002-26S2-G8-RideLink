import 'package:get/get.dart';

class DriverTripModel {
  final String id;
  final String from;
  final String to;
  final double fromLat;
  final double fromLng;
  final double toLat;
  final double toLng;
  final RxString time;
  final RxDouble pricePerSeat;
  final RxInt totalSeats;
  final RxInt bookedSeats;
  final RxString status; // 'Active', 'Scheduled', 'Completed', 'Cancelled'
  final bool isRecurring;
  final RxList<PassengerRequestModel> requests;
  final RxList<PassengerRequestModel> acceptedPassengers;

  DriverTripModel({
    required this.id,
    required this.from,
    required this.to,
    this.fromLat = -31.8156,
    this.fromLng = 115.8452,
    this.toLat = -32.0044,
    this.toLng = 115.8947,
    required String time,
    required double pricePerSeat,
    required int totalSeats,
    required int bookedSeats,
    required String status,
    this.isRecurring = false,
    List<PassengerRequestModel> requests = const [],
    List<PassengerRequestModel> acceptedPassengers = const [],
  })  : time = time.obs,
        pricePerSeat = pricePerSeat.obs,
        totalSeats = totalSeats.obs,
        bookedSeats = bookedSeats.obs,
        status = status.obs,
        requests = requests.obs,
        acceptedPassengers = acceptedPassengers.obs;
}

class PassengerRequestModel {
  final String id;
  final String? tripId;
  final String? passengerId;
  final String passengerName;
  final double rating;
  final String from;
  final String to;
  final int seats;
  final double fare;
  final String time;
  final String travellingWith;
  final String detour;
  final int pastTrips;
  final RxString status; // 'Pending', 'Accepted', 'Declined'
  final String emergencyContactName;
  final String emergencyContactRelation;
  final String emergencyContactPhone;

  PassengerRequestModel({
    required this.id,
    this.tripId,
    this.passengerId,
    required this.passengerName,
    required this.rating,
    required this.from,
    required this.to,
    required this.seats,
    required this.fare,
    required this.time,
    this.travellingWith = '+1 passenger',
    this.detour = '+4 minutes only',
    this.pastTrips = 12,
    String status = 'Pending',
    this.emergencyContactName = 'Sarah Jenkins',
    this.emergencyContactRelation = 'Mother',
    this.emergencyContactPhone = '+61 412 345 678',
  }) : status = status.obs;
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

