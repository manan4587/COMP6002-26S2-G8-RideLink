import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/routes/routes_name.dart';

class DriverTripModel {
  final String id;
  final String from;
  final String to;
  final String time;
  final double pricePerSeat;
  final int totalSeats;
  final int bookedSeats;
  final String status; // 'Active', 'Scheduled', 'Completed'

  DriverTripModel({
    required this.id,
    required this.from,
    required this.to,
    required this.time,
    required this.pricePerSeat,
    required this.totalSeats,
    required this.bookedSeats,
    required this.status,
  });
}

class PassengerRequestModel {
  final String id;
  final String passengerName;
  final double rating;
  final String from;
  final String to;
  final int seats;
  final double fare;
  final String time;

  PassengerRequestModel({
    required this.id,
    required this.passengerName,
    required this.rating,
    required this.from,
    required this.to,
    required this.seats,
    required this.fare,
    required this.time,
  });
}

class DriverDashboardController extends GetxController {
  final RxInt currentTabIndex = 0.obs;
  final RxBool isOnline = true.obs;

  // Earnings stats
  final RxDouble todayEarnings = 84.50.obs;
  final RxInt completedTripsCount = 3.obs;
  final RxDouble weeklyEarnings = 420.00.obs;

  // Published Trips
  final RxList<DriverTripModel> myTrips = <DriverTripModel>[
    DriverTripModel(
      id: 'dt1',
      from: 'Melbourne CBD (Flinders St)',
      to: 'Monash University (Clayton)',
      time: '04:30 PM (Today)',
      pricePerSeat: 12.0,
      totalSeats: 3,
      bookedSeats: 2,
      status: 'Scheduled',
    ),
    DriverTripModel(
      id: 'dt2',
      from: 'Clayton Campus',
      to: 'South Yarra Station',
      time: '07:00 PM (Today)',
      pricePerSeat: 10.0,
      totalSeats: 3,
      bookedSeats: 0,
      status: 'Scheduled',
    ),
  ].obs;

  // Pending Passenger Requests
  final RxList<PassengerRequestModel> pendingRequests = <PassengerRequestModel>[
    PassengerRequestModel(
      id: 'pr1',
      passengerName: 'Sarah Jenkins',
      rating: 4.9,
      from: 'Richmond Station',
      to: 'Clayton Campus',
      seats: 1,
      fare: 12.00,
      time: '04:35 PM',
    ),
    PassengerRequestModel(
      id: 'pr2',
      passengerName: 'Michael Brown',
      rating: 4.8,
      from: 'Oakleigh Station',
      to: 'Monash Clayton',
      seats: 1,
      fare: 10.00,
      time: '04:50 PM',
    ),
  ].obs;

  // Publish Ride Form Controllers
  final TextEditingController publishFromController = TextEditingController();
  final TextEditingController publishToController = TextEditingController();
  final TextEditingController departureTimeController = TextEditingController(
    text: '08:00 AM',
  );
  final RxString departureDate = 'Tomorrow, Oct 6'.obs;
  final RxInt publishSeats = 3.obs;
  final RxDouble publishPrice = 14.0.obs;
  final RxBool allowLuggage = true.obs;
  final RxBool allowPets = false.obs;

  void switchTab(int index) {
    currentTabIndex.value = index;
  }

  void toggleOnlineStatus() {
    isOnline.value = !isOnline.value;
    if (isOnline.value) {
      AppSnackBar.success(
        message: 'You are now Online and accepting passengers!',
      );
    } else {
      AppSnackBar.info(message: 'You are now Offline.');
    }
  }

  void acceptRequest(PassengerRequestModel req) {
    pendingRequests.remove(req);
    todayEarnings.value += req.fare;
    AppSnackBar.success(
      message: 'Accepted booking request for ${req.passengerName}!',
    );
  }

  void declineRequest(PassengerRequestModel req) {
    pendingRequests.remove(req);
    AppSnackBar.info(message: 'Declined request for ${req.passengerName}.');
  }

  void publishNewTrip() {
    final from = publishFromController.text.trim();
    final to = publishToController.text.trim();

    if (from.isEmpty || to.isEmpty) {
      AppSnackBar.warning(
        message: 'Please enter pickup and drop-off locations.',
      );
      return;
    }

    final newTrip = DriverTripModel(
      id: 'dt_${DateTime.now().millisecondsSinceEpoch}',
      from: from,
      to: to,
      time: '${departureTimeController.text} (${departureDate.value})',
      pricePerSeat: publishPrice.value,
      totalSeats: publishSeats.value,
      bookedSeats: 0,
      status: 'Scheduled',
    );

    myTrips.insert(0, newTrip);
    publishFromController.clear();
    publishToController.clear();

    AppSnackBar.success(message: 'Your trip has been published successfully!');
    currentTabIndex.value = 0; // Go to trips list
  }

  // Profile Mode Switcher: Driver -> Passenger
  void switchToPassengerMode() {
    Get.offAllNamed(AppRoutes.passengerDashboard);
    AppSnackBar.success(
      message: 'Switched to Passenger Mode. Ready to search rides!',
    );
  }

  void onLogout() {
    Get.offAllNamed(AppRoutes.getStartedView);
  }
}
