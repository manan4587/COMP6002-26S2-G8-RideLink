import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/routes/routes_name.dart';

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
  });
}

class BookingModel {
  final String id;
  final RideModel ride;
  final int bookedSeats;
  final double totalPrice;
  final String status; // 'Upcoming', 'Completed', 'Cancelled'
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

class PassengerDashboardController extends GetxController {
  // Navigation
  final RxInt currentTabIndex = 0.obs;

  // Search Inputs
  final TextEditingController fromLocationController =
      TextEditingController(text: 'Flinders St, Melbourne');
  final TextEditingController toLocationController =
      TextEditingController(text: 'Clayton, Monash Uni');
  final RxString selectedDate = 'Today, Oct 5'.obs;
  final RxInt requestedSeats = 1.obs;
  final RxString selectedFilter = 'All'.obs;

  // Mock Available Rides
  final RxList<RideModel> availableRides = <RideModel>[
    RideModel(
      id: 'r1',
      driverName: 'James Miller',
      driverAvatar: '',
      rating: 4.9,
      totalRides: 142,
      carModel: 'Toyota Camry Hybrid (White)',
      carPlate: 'VIC • 1AB-2CD',
      origin: 'Flinders St Station, Melbourne',
      destination: 'Monash University, Clayton',
      departureTime: '08:30 AM',
      estimatedDuration: '35 mins',
      pricePerSeat: 12.0,
      seatsAvailable: 3,
      stops: ['Richmond', 'Oakleigh', 'Clayton'],
    ),
    RideModel(
      id: 'r2',
      driverName: 'Emily Watson',
      driverAvatar: '',
      rating: 4.8,
      totalRides: 98,
      carModel: 'Hyundai Tucson (Silver)',
      carPlate: 'VIC • 3XY-9ZZ',
      origin: 'Southern Cross Station',
      destination: 'Melbourne Airport (MEL)',
      departureTime: '10:15 AM',
      estimatedDuration: '28 mins',
      pricePerSeat: 18.0,
      seatsAvailable: 2,
      stops: ['Tullamarine Fwy', 'Terminal 2'],
    ),
    RideModel(
      id: 'r3',
      driverName: 'David Chen',
      driverAvatar: '',
      rating: 5.0,
      totalRides: 210,
      carModel: 'Tesla Model 3 (Blue)',
      carPlate: 'VIC • EV-889',
      origin: 'Box Hill Central',
      destination: 'St Kilda Beach',
      departureTime: '01:00 PM',
      estimatedDuration: '40 mins',
      pricePerSeat: 14.5,
      seatsAvailable: 1,
      stops: ['Hawthorn', 'South Yarra'],
    ),
    RideModel(
      id: 'r4',
      driverName: 'Marcus Bell',
      driverAvatar: '',
      rating: 4.7,
      totalRides: 64,
      carModel: 'Mazda CX-5 (Red)',
      carPlate: 'VIC • 7KL-4OP',
      origin: 'Geelong City Centre',
      destination: 'Melbourne CBD',
      departureTime: '06:45 AM',
      estimatedDuration: '55 mins',
      pricePerSeat: 16.0,
      seatsAvailable: 3,
      stops: ['Werribee', 'Docklands'],
    ),
  ].obs;

  // Mock Bookings
  final RxList<BookingModel> myBookings = <BookingModel>[].obs;

  // Selected Ride for Details
  final Rx<RideModel?> selectedRide = Rx<RideModel?>(null);

  @override
  void onInit() {
    super.onInit();
    // Pre-populate with an upcoming booking
    if (availableRides.isNotEmpty) {
      myBookings.add(
        BookingModel(
          id: 'b101',
          ride: availableRides[0],
          bookedSeats: 1,
          totalPrice: 12.0,
          status: 'Upcoming',
          bookingDate: 'Today, 08:30 AM',
        ),
      );
    }
  }

  void switchTab(int index) {
    currentTabIndex.value = index;
  }

  void swapLocations() {
    final temp = fromLocationController.text;
    fromLocationController.text = toLocationController.text;
    toLocationController.text = temp;
  }

  void bookRide(RideModel ride, int seats) {
    final double total = ride.pricePerSeat * seats;
    final booking = BookingModel(
      id: 'b${DateTime.now().millisecondsSinceEpoch}',
      ride: ride,
      bookedSeats: seats,
      totalPrice: total,
      status: 'Upcoming',
      bookingDate: '${ride.departureTime} (Today)',
    );
    myBookings.insert(0, booking);
    Get.back(); // Close modal
    AppSnackBar.success(
      message: 'Ride booked successfully with ${ride.driverName}!',
    );
    currentTabIndex.value = 2; // Switch to My Rides
  }

  void cancelBooking(String bookingId) {
    final index = myBookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      myBookings.removeAt(index);
      AppSnackBar.info(message: 'Booking has been cancelled.');
    }
  }

  // Profile Mode Switcher: Passenger -> Driver
  void switchToDriverMode() {
    Get.offAllNamed(AppRoutes.driverDashboard);
    AppSnackBar.success(
      message: 'Switched to Driver Mode. Welcome back!',
    );
  }

  void onLogout() {
    Get.offAllNamed(AppRoutes.getStartedView);
  }
}
