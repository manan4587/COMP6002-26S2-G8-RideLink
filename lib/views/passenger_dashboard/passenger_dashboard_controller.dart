import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';

class RideModel {
  final String id;
  final String driverName;
  final String driverAvatar;
  final double rating;
  final int totalRides;
  final String carModel;
  final String carPlate;
  final String origin;
  final String destination;
  final String departureTime;
  final String estimatedDuration;
  final double pricePerSeat;
  final int seatsAvailable;
  final bool isVerified;
  final List<String> stops;
  final int matchPercentage;
  final int detourMinutes;
  final String pickupSuggestion;
  final String dropOffPlan;

  RideModel({
    required this.id,
    required this.driverName,
    required this.driverAvatar,
    required this.rating,
    required this.totalRides,
    required this.carModel,
    required this.carPlate,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.estimatedDuration,
    required this.pricePerSeat,
    required this.seatsAvailable,
    this.isVerified = true,
    this.stops = const [],
    this.matchPercentage = 95,
    this.detourMinutes = 4,
    this.pickupSuggestion = 'Shell Station, Landsdale',
    this.dropOffPlan = 'Landsdale → Curtin University',
  });
}

class PassengerPendingRequestModel {
  final String id;
  final RideModel ride;
  final int requestedSeats;
  final String passengerLabel;
  final double totalPrice;
  final String requestTime;
  final RxString status;

  PassengerPendingRequestModel({
    required this.id,
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
  final RideModel ride;
  final int bookedSeats;
  final double totalPrice;
  final String status; // 'Confirmed', 'Upcoming', 'Completed', 'Cancelled'
  final String bookingDate;

  BookingModel({
    required this.id,
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

class PassengerSupportTicketModel {
  final String id;
  final String subject;
  final String category;
  final String message;
  final DateTime createdAt;
  final String status;

  PassengerSupportTicketModel({
    required this.id,
    required this.subject,
    required this.category,
    required this.message,
    required this.createdAt,
    this.status = 'Submitted',
  });
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
}

class PassengerDashboardController extends GetxController {
  // Navigation
  final RxInt currentTabIndex = 0.obs;

  // Selected Community for Details Page
  final Rx<CommunityModel?> selectedCommunity = Rx<CommunityModel?>(null);

  // Communities List
  final RxList<CommunityModel> communities = <CommunityModel>[
    CommunityModel(
      id: 'comm_curtin',
      name: 'Curtin Community',
      routeSummary: 'Landsdale → Curtin University',
      commonTime: '7:30 AM - 9:00 AM',
      description: 'Daily shared rides for Curtin University students & staff commuting from northern and western suburbs.',
      passengersCount: 12,
      driversCount: 4,
      nextRideTime: 'Tomorrow 8:00 AM',
      nextRideSeatsOpen: 3,
      isJoined: true,
      icon: Icons.school_outlined,
    ),
    CommunityModel(
      id: 'comm_monash',
      name: 'Monash Clayton Carpool',
      routeSummary: 'Clayton ⇄ Eastern Suburbs',
      commonTime: '8:00 AM - 9:30 AM',
      description: 'Daily campus commuters splitting petrol costs along Princes Highway and Wellington Rd.',
      passengersCount: 28,
      driversCount: 7,
      nextRideTime: 'Tomorrow 8:30 AM',
      nextRideSeatsOpen: 2,
      isJoined: false,
      icon: Icons.school_outlined,
    ),
    CommunityModel(
      id: 'comm_cbd',
      name: 'Melbourne CBD Corporate',
      routeSummary: 'Inner Suburbs → Flinders St Station',
      commonTime: '7:45 AM - 8:45 AM',
      description: 'City professionals sharing morning and evening work commutes to cut congestion and parking fees.',
      passengersCount: 45,
      driversCount: 11,
      nextRideTime: 'Today 5:30 PM',
      nextRideSeatsOpen: 4,
      isJoined: false,
      icon: Icons.business_outlined,
    ),
    CommunityModel(
      id: 'comm_deakin',
      name: 'Deakin Uni Burwood Hub',
      routeSummary: 'Burwood ⇄ Box Hill & Ringwood',
      commonTime: '8:15 AM - 9:45 AM',
      description: 'Student and faculty carpool network connecting Burwood highway corridors.',
      passengersCount: 19,
      driversCount: 5,
      nextRideTime: 'Tomorrow 9:00 AM',
      nextRideSeatsOpen: 2,
      isJoined: false,
      icon: Icons.menu_book_outlined,
    ),
  ].obs;

  void toggleCommunityJoin(CommunityModel community) {
    community.isJoined.value = !community.isJoined.value;
    if (community.isJoined.value) {
      community.passengersCount.value++;
      AppSnackBar.success(
        message: 'Joined ${community.name} community!',
      );
    } else {
      community.passengersCount.value =
          (community.passengersCount.value - 1).clamp(0, 9999);
      AppSnackBar.info(
        message: 'Left ${community.name} community.',
      );
    }
  }

  void openCommunityDetails(CommunityModel community) {
    selectedCommunity.value = community;
    Get.toNamed(AppRoutes.passengerCommunityDetails);
  }

  // Push Notification Preferences (Push Only - No Email)
  final RxBool pushBookingConfirmations = true.obs;
  final RxBool pushDriverArrivalAlerts = true.obs;
  final RxBool pushTripStatusUpdates = true.obs;
  final RxBool pushDriverChatMessages = true.obs;
  final RxBool pushSafetyAlerts = true.obs;

  // Saved Locations
  final RxList<SavedLocationModel> savedLocations = <SavedLocationModel>[
    SavedLocationModel(
      id: 'loc_home',
      title: 'Home',
      address: '24 Collins Street, Melbourne VIC 3000',
      category: 'home',
    ),
    SavedLocationModel(
      id: 'loc_work',
      title: 'Office (CBD)',
      address: '120 Spencer Street, Docklands VIC 3008',
      category: 'work',
    ),
    SavedLocationModel(
      id: 'loc_uni',
      title: 'Monash Clayton Campus',
      address: 'Wellington Rd, Clayton VIC 3800',
      category: 'university',
    ),
    SavedLocationModel(
      id: 'loc_gym',
      title: 'Fitness First South Yarra',
      address: 'Toorak Rd & Chapel St, South Yarra VIC 3141',
      category: 'gym',
    ),
  ].obs;

  // Emergency Contacts (Visible to driver only during active trips)
  final RxList<PassengerEmergencyContactModel> emergencyContacts = <PassengerEmergencyContactModel>[
    PassengerEmergencyContactModel(
      id: 'emg_1',
      name: 'Sarah Jenkins',
      relation: 'Mother',
      phone: '+61 412 345 678',
      isPrimary: true,
    ),
    PassengerEmergencyContactModel(
      id: 'emg_2',
      name: 'Michael Morgan',
      relation: 'Brother',
      phone: '+61 498 765 432',
      isPrimary: false,
    ),
  ].obs;

  // Passenger Support Tickets (Stored locally in database/reactive state)
  final RxList<PassengerSupportTicketModel>
  supportTickets = <PassengerSupportTicketModel>[
    PassengerSupportTicketModel(
      id: 'PS-8921',
      subject: 'Question about cash payments during trip',
      category: 'Cash Payments & Fares',
      message:
          'Hi, what happens if I do not have exact cash change? Can I negotiate with the driver beforehand in chat?',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      status: 'Resolved',
    ),
  ].obs;

  // Passenger Stats
  final RxDouble trustRating = 4.90.obs;

  // Recent Routes
  final RxList<RecentRouteModel> recentRoutes = <RecentRouteModel>[
    RecentRouteModel(
      id: 'rr1',
      from: 'Curtin',
      to: 'Landsdale',
      subtitle: 'Usually 5:00 PM',
    ),
    RecentRouteModel(
      id: 'rr2',
      from: 'Curtin',
      to: 'Joondalup',
      subtitle: 'Best shared corridor',
    ),
  ].obs;

  void selectRecentRoute(RecentRouteModel route) {
    fromLocationController.text = route.from;
    toLocationController.text = route.to;
    switchTab(1); // Jump to Search Page
  }

  // Search Inputs
  final TextEditingController fromLocationController = TextEditingController(
    text: 'Landsdale',
  );
  final TextEditingController toLocationController = TextEditingController(
    text: 'Curtin University',
  );
  final RxString selectedDate = 'Today, Oct 5'.obs;
  final RxString preferredTime = '8:00 AM'.obs;
  final RxString timeFlexibility = '±15 minutes'.obs;
  final RxInt requestedSeats = 2.obs;
  final RxString seatsNote = '2 seats - me + my brother'.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxBool hasSearched = false.obs;

  // Mock Available Rides (Aligned with AI Suggested Rides)
  final RxList<RideModel> availableRides = <RideModel>[
    RideModel(
      id: 'r_kasper',
      driverName: 'Kasper Li',
      driverAvatar: '',
      rating: 4.98,
      totalRides: 184,
      carModel: 'Toyota Corolla',
      carPlate: 'Plate 1ABC234',
      origin: 'Landsdale',
      destination: 'Curtin University',
      departureTime: '08:00 AM',
      estimatedDuration: '28 mins',
      pricePerSeat: 7.0,
      seatsAvailable: 3,
      matchPercentage: 96,
      detourMinutes: 4,
      pickupSuggestion: 'Shell Station, Landsdale',
      dropOffPlan: 'Landsdale → Curtin University',
      stops: ['Landsdale', 'Alexander Dr', 'Curtin Bus Timetable Hub'],
    ),
    RideModel(
      id: 'r_khushi',
      driverName: 'Khushi Patel',
      driverAvatar: '',
      rating: 4.85,
      totalRides: 92,
      carModel: 'Hyundai i30',
      carPlate: 'Plate 2XYZ789',
      origin: 'Landsdale',
      destination: 'Curtin University',
      departureTime: '08:15 AM',
      estimatedDuration: '32 mins',
      pricePerSeat: 8.0,
      seatsAvailable: 2,
      matchPercentage: 91,
      detourMinutes: 7,
      pickupSuggestion: 'Landsdale Forum Shopping Centre',
      dropOffPlan: 'Landsdale → Curtin University',
      stops: ['Landsdale Forum', 'Reid Hwy', 'Curtin Bentley'],
    ),
    RideModel(
      id: 'r_mishri',
      driverName: 'Mishri Rao',
      driverAvatar: '',
      rating: 4.79,
      totalRides: 64,
      carModel: 'Mazda 3 Hatchback',
      carPlate: 'Plate 3MNO456',
      origin: 'Landsdale',
      destination: 'Curtin University',
      departureTime: '08:30 AM',
      estimatedDuration: '30 mins',
      pricePerSeat: 6.0,
      seatsAvailable: 2,
      matchPercentage: 87,
      detourMinutes: 9,
      pickupSuggestion: 'Warradale Park, Landsdale',
      dropOffPlan: 'Landsdale → Curtin University',
      stops: ['Warradale Park', 'Mirrabooka Ave', 'Curtin University'],
    ),
  ].obs;

  // Trips Page State
  final RxInt selectedTripsTab = 0.obs; // 0: Pending Requests, 1: Confirmed, 2: Completed

  // Pending Requests (Tab 0)
  final RxList<PassengerPendingRequestModel> pendingRequests = <PassengerPendingRequestModel>[].obs;

  // Confirmed Bookings (Tab 1)
  final RxList<BookingModel> myBookings = <BookingModel>[].obs;

  // Completed / Past Trips (Tab 2)
  final RxList<CompletedTripModel> completedTrips = <CompletedTripModel>[].obs;

  // Selected Ride for Details
  final Rx<RideModel?> selectedRide = Rx<RideModel?>(null);

  @override
  void onInit() {
    super.onInit();
    // Pre-populate with realistic trips matching user flow & reference design
    if (availableRides.isNotEmpty) {
      // 1 Pending Request (Matching reference: Landsdale -> Curtin, Manan + 1 • Waiting for driver approval)
      pendingRequests.add(
        PassengerPendingRequestModel(
          id: 'pr_101',
          ride: availableRides.first,
          requestedSeats: 2,
          passengerLabel: 'Manan + 1',
          totalPrice: availableRides.first.pricePerSeat * 2,
          requestTime: '15 mins ago',
        ),
      );

      // 1 Confirmed Trip (Matching reference: Landsdale -> Curtin, Today 8:00 AM • 2 seats approved)
      myBookings.add(
        BookingModel(
          id: 'b_101',
          ride: availableRides.first,
          bookedSeats: 2,
          totalPrice: availableRides.first.pricePerSeat * 2,
          status: 'Confirmed',
          bookingDate: 'Today 8:00 AM',
        ),
      );
    }

    // Completed Trips (Includes unrated trip to showcase Rate Driver button functionality!)
    completedTrips.addAll([
      CompletedTripModel(
        id: 'comp_1',
        driverName: 'Emily Watson',
        carModel: 'Hyundai Tucson (Silver)',
        carPlate: 'VIC • 3XY-9ZZ',
        route: 'Landsdale → Curtin University',
        date: 'Yesterday, 08:30 AM',
        fare: '\$16.00',
        isRated: false, // Not rated yet -> Rate Driver button is active!
      ),
      CompletedTripModel(
        id: 'comp_2',
        driverName: 'David Chen',
        carModel: 'Tesla Model 3 (Blue)',
        carPlate: 'VIC • EV-889',
        route: 'Landsdale → Curtin University',
        date: 'Oct 2, 2026',
        fare: '\$14.50',
        isRated: true, // Already rated 5.0 -> Badge only, button hidden
        rating: 5.0,
        reviewComment: 'Very smooth and quiet ride, on time!',
      ),
      CompletedTripModel(
        id: 'comp_3',
        driverName: 'Marcus Bell',
        carModel: 'Mazda CX-5 (Red)',
        carPlate: 'VIC • 7KL-4OP',
        route: 'Richmond Station → Clayton',
        date: 'Sep 28, 2026',
        fare: '\$12.00',
        isRated: true,
        rating: 4.8,
        reviewComment: 'Great music and friendly driver.',
      ),
    ]);
  }

  void switchTab(int index) {
    currentTabIndex.value = index;
  }

  void switchTripsTab(int index) {
    selectedTripsTab.value = index;
  }

  void swapLocations() {
    final temp = fromLocationController.text;
    fromLocationController.text = toLocationController.text;
    toLocationController.text = temp;
  }

  // Selected Ride for Details & Request Flow
  final Rx<RideModel?> currentSelectedRide = Rx<RideModel?>(null);

  void selectRideForDetails(RideModel ride) {
    currentSelectedRide.value = ride;
    Get.toNamed(AppRoutes.rideDetails);
  }

  void requestToJoinRide(RideModel ride) {
    currentSelectedRide.value = ride;
    // Add to pending requests list
    final pending = PassengerPendingRequestModel(
      id: 'pr_${DateTime.now().millisecondsSinceEpoch}',
      ride: ride,
      requestedSeats: requestedSeats.value,
      passengerLabel: requestedSeats.value > 1
          ? 'Manan + ${requestedSeats.value - 1}'
          : 'Manan',
      totalPrice: ride.pricePerSeat * requestedSeats.value,
      requestTime: 'Just now',
    );
    pendingRequests.insert(0, pending);
    Get.toNamed(AppRoutes.requestSent);
  }

  void cancelPendingRequest(String requestId) {
    final index = pendingRequests.indexWhere((p) => p.id == requestId);
    if (index != -1) {
      pendingRequests.removeAt(index);
      AppSnackBar.info(message: 'Ride request cancelled successfully.');
    }
  }

  void approvePendingRequest(String requestId) {
    final index = pendingRequests.indexWhere((p) => p.id == requestId);
    if (index != -1) {
      final req = pendingRequests[index];
      pendingRequests.removeAt(index);
      final booking = BookingModel(
        id: 'b_${DateTime.now().millisecondsSinceEpoch}',
        ride: req.ride,
        bookedSeats: req.requestedSeats,
        totalPrice: req.totalPrice,
        status: 'Confirmed',
        bookingDate: 'Today, ${req.ride.departureTime}',
      );
      myBookings.insert(0, booking);
      selectedTripsTab.value = 1; // Switch to Confirmed tab
      AppSnackBar.success(
        message: 'Driver approved! Your seat is confirmed with ${req.ride.driverName}.',
      );
    }
  }

  void simulateDriverApproval() {
    if (currentSelectedRide.value != null) {
      final ride = currentSelectedRide.value!;
      pendingRequests.removeWhere((p) => p.ride.id == ride.id);
      final booking = BookingModel(
        id: 'b_${DateTime.now().millisecondsSinceEpoch}',
        ride: ride,
        bookedSeats: requestedSeats.value,
        totalPrice: ride.pricePerSeat * requestedSeats.value,
        status: 'Confirmed',
        bookingDate: '${ride.departureTime} (Today)',
      );
      myBookings.insert(0, booking);
      selectedTripsTab.value = 1;
    }
    Get.toNamed(AppRoutes.requestApproved);
  }

  void bookRide(RideModel ride, int seats) {
    final double total = ride.pricePerSeat * seats;
    final booking = BookingModel(
      id: 'b_${DateTime.now().millisecondsSinceEpoch}',
      ride: ride,
      bookedSeats: seats,
      totalPrice: total,
      status: 'Confirmed',
      bookingDate: '${ride.departureTime} (Today)',
    );
    myBookings.insert(0, booking);
    Get.back(); // Close modal
    AppSnackBar.success(
      message: 'Ride booked successfully with ${ride.driverName}!',
    );
    currentTabIndex.value = 2; // Switch to Trips tab
    selectedTripsTab.value = 1; // Confirmed tab
  }

  void cancelBooking(String bookingId) {
    final index = myBookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      myBookings.removeAt(index);
      AppSnackBar.info(message: 'Booking has been cancelled.');
    }
  }

  void rateDriver({
    required String tripId,
    required double rating,
    String comment = '',
  }) {
    final tripIndex = completedTrips.indexWhere((t) => t.id == tripId);
    if (tripIndex != -1) {
      final trip = completedTrips[tripIndex];
      trip.rating.value = rating;
      trip.reviewComment.value = comment;
      trip.isRated.value = true;
      AppSnackBar.success(
        message: 'Thank you! Your ${rating.toStringAsFixed(1)} ★ rating for ${trip.driverName} has been submitted.',
      );
    }
  }

  // Profile Mode Switcher: Passenger -> Driver
  void switchToDriverMode() {
    Preferences.userRole = 'driver';
    Get.offAllNamed(AppRoutes.driverDashboard);
    AppSnackBar.success(message: 'Switched to Driver Mode. Welcome back!');
  }

  // Saved Location Actions
  void addSavedLocation({
    required String title,
    required String address,
    required String category,
  }) {
    final newLoc = SavedLocationModel(
      id: 'loc_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      address: address,
      category: category,
    );
    savedLocations.add(newLoc);
    AppSnackBar.success(message: 'Added "$title" to your saved locations!');
  }

  void removeSavedLocation(String id) {
    savedLocations.removeWhere((item) => item.id == id);
    AppSnackBar.info(message: 'Location removed.');
  }

  // Emergency Contact Actions
  void addEmergencyContact({
    required String name,
    required String relation,
    required String phone,
    bool isPrimary = false,
  }) {
    if (isPrimary) {
      for (final c in emergencyContacts) {
        c.isPrimary.value = false;
      }
    }
    emergencyContacts.add(
      PassengerEmergencyContactModel(
        id: 'emg_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        relation: relation,
        phone: phone,
        isPrimary: isPrimary,
      ),
    );
    AppSnackBar.success(message: 'Emergency contact added successfully.');
  }

  void updateEmergencyContact({
    required String id,
    required String name,
    required String relation,
    required String phone,
    bool isPrimary = false,
  }) {
    final index = emergencyContacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      if (isPrimary) {
        for (final c in emergencyContacts) {
          c.isPrimary.value = false;
        }
      }
      emergencyContacts[index] = PassengerEmergencyContactModel(
        id: id,
        name: name,
        relation: relation,
        phone: phone,
        isPrimary: isPrimary,
      );
      AppSnackBar.success(message: 'Emergency contact updated.');
    }
  }

  void removeEmergencyContact(String id) {
    emergencyContacts.removeWhere((c) => c.id == id);
    AppSnackBar.info(message: 'Emergency contact removed.');
  }

  void setPrimaryEmergencyContact(String id) {
    for (final c in emergencyContacts) {
      c.isPrimary.value = (c.id == id);
    }
    AppSnackBar.success(message: 'Primary emergency contact updated.');
  }

  // Safety & SOS Actions
  Future<void> callEmergencyServices() async {
    try {
      await Utils.launchURL('tel:000');
    } catch (_) {
      AppSnackBar.info(message: 'Calling Emergency Services (000)...');
    }
  }

  Future<void> callSafetyHotline() async {
    try {
      await Utils.launchURL('tel:1800743354');
    } catch (_) {
      AppSnackBar.info(
        message: 'Calling RideLink 24/7 Passenger Safety Hotline...',
      );
    }
  }

  Future<void> sendSafetyEmail() async {
    try {
      await Utils.launchURL(
        'mailto:safety@ridelink.com?subject=Urgent%20Passenger%20Safety%20Inquiry',
      );
    } catch (_) {
      AppSnackBar.info(message: 'Opening mail to safety@ridelink.com...');
    }
  }

  // Passenger Support Ticket Submission
  void submitSupportTicket({
    required String subject,
    required String category,
    required String message,
  }) {
    final newTicket = PassengerSupportTicketModel(
      id: 'PS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      subject: subject,
      category: category,
      message: message,
      createdAt: DateTime.now(),
      status: 'Submitted',
    );
    supportTickets.insert(0, newTicket);
    AppSnackBar.success(
      message:
          'Support inquiry submitted! Admin will email your registered address shortly.',
    );
  }

  // Consistent Bottom Sheet for Logout
  void confirmLogout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          top: 12.h,
          left: 20.w,
          right: 20.w,
          bottom: MediaQuery.of(context).padding.bottom + 20.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            16.verticalSpace,
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.red,
                    size: 24,
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log Out',
                        style: AppTextStyle.text18Semibold.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      2.verticalSpace,
                      Text(
                        'Confirm passenger session end',
                        style: AppTextStyle.text12Regular.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            16.verticalSpace,
            Text(
              'Are you sure you want to log out of your RideLink passenger account? You will need to log back in to book rides or view your scheduled carpools.',
              style: AppTextStyle.text14Medium.copyWith(
                color: AppColors.primaryTextColor,
                height: 1.4,
              ),
            ),
            20.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderColor),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.text14Medium.copyWith(
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    onPressed: () {
                      Preferences.logout();
                      Navigator.of(ctx).pop();
                      Get.offAllNamed(AppRoutes.getStartedView);
                      AppSnackBar.info(message: 'Logged out successfully.');
                    },
                    child: Text(
                      'Log Out',
                      style: AppTextStyle.text14Semibold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Consistent Bottom Sheet for Delete Account
  void confirmDeleteAccount(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          top: 12.h,
          left: 20.w,
          right: 20.w,
          bottom: MediaQuery.of(context).padding.bottom + 20.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            16.verticalSpace,
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.red,
                    size: 24,
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delete Account',
                        style: AppTextStyle.text18Semibold.copyWith(
                          color: AppColors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      2.verticalSpace,
                      Text(
                        'Permanent action • Cannot be undone',
                        style: AppTextStyle.text12Regular.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            16.verticalSpace,
            Text(
              'Are you sure you want to delete your passenger account? This action is permanent and will permanently erase your passenger profile, saved favourite locations, and booking history.',
              style: AppTextStyle.text14Medium.copyWith(
                color: AppColors.primaryTextColor,
                height: 1.4,
              ),
            ),
            12.verticalSpace,
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.red,
                    size: 18,
                  ),
                  8.horizontalSpace,
                  Expanded(
                    child: Text(
                      'Any upcoming or active ride bookings will be automatically cancelled with the drivers.',
                      style: AppTextStyle.text12Regular.copyWith(
                        color: const Color(0xFF991B1B),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            20.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderColor),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      'Keep Account',
                      style: AppTextStyle.text14Medium.copyWith(
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    onPressed: () {
                      Preferences.logout();
                      Navigator.of(ctx).pop();
                      Get.offAllNamed(AppRoutes.getStartedView);
                      AppSnackBar.success(
                        message: 'Your account has been deleted permanently.',
                      );
                    },
                    child: Text(
                      'Delete Forever',
                      style: AppTextStyle.text14Semibold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
