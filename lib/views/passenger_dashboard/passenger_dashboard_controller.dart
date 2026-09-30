import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink/data/models/passenger/passenger_models.dart';
import 'package:ridelink/views/passenger_dashboard/controllers/passenger_community_controller.dart';
import 'package:ridelink/views/passenger_dashboard/controllers/passenger_home_controller.dart';
import 'package:ridelink/views/passenger_dashboard/controllers/passenger_profile_controller.dart';
import 'package:ridelink/views/passenger_dashboard/controllers/passenger_search_controller.dart';
import 'package:ridelink/views/passenger_dashboard/controllers/passenger_support_controller.dart';
import 'package:ridelink/views/passenger_dashboard/controllers/passenger_trips_controller.dart';

export 'package:ridelink/data/models/passenger/passenger_models.dart';
export 'package:ridelink/views/passenger_dashboard/controllers/passenger_community_controller.dart';
export 'package:ridelink/views/passenger_dashboard/controllers/passenger_home_controller.dart';
export 'package:ridelink/views/passenger_dashboard/controllers/passenger_profile_controller.dart';
export 'package:ridelink/views/passenger_dashboard/controllers/passenger_search_controller.dart';
export 'package:ridelink/views/passenger_dashboard/controllers/passenger_support_controller.dart';
export 'package:ridelink/views/passenger_dashboard/controllers/passenger_trips_controller.dart';

class PassengerDashboardController extends GetxController {
  // Navigation
  final RxInt currentTabIndex = 0.obs;

  // Domain Sub-Controllers
  late final PassengerHomeController homeController;
  late final PassengerSearchController searchController;
  late final PassengerTripsController tripsController;
  late final PassengerCommunityController communityController;
  late final PassengerSupportController supportController;
  late final PassengerProfileController profileController;

  @override
  void onInit() {
    super.onInit();
    homeController = Get.isRegistered<PassengerHomeController>()
        ? Get.find<PassengerHomeController>()
        : Get.put<PassengerHomeController>(PassengerHomeController());

    searchController = Get.isRegistered<PassengerSearchController>()
        ? Get.find<PassengerSearchController>()
        : Get.put<PassengerSearchController>(PassengerSearchController());

    tripsController = Get.isRegistered<PassengerTripsController>()
        ? Get.find<PassengerTripsController>()
        : Get.put<PassengerTripsController>(PassengerTripsController());

    communityController = Get.isRegistered<PassengerCommunityController>()
        ? Get.find<PassengerCommunityController>()
        : Get.put<PassengerCommunityController>(PassengerCommunityController());

    supportController = Get.isRegistered<PassengerSupportController>()
        ? Get.find<PassengerSupportController>()
        : Get.put<PassengerSupportController>(PassengerSupportController());

    profileController = Get.isRegistered<PassengerProfileController>()
        ? Get.find<PassengerProfileController>()
        : Get.put<PassengerProfileController>(PassengerProfileController());
  }

  void switchTab(int index) {
    currentTabIndex.value = index;
  }

  // -------------------------------------------------------------
  // PROFILE DELEGATES
  // -------------------------------------------------------------
  RxString get passengerName => profileController.passengerName;
  RxString get passengerEmail => profileController.passengerEmail;
  RxString get passengerPhone => profileController.passengerPhone;
  RxDouble get passengerRating => profileController.passengerRating;
  RxInt get tripsCount => profileController.tripsCount;
  String get passengerInitials => profileController.passengerInitials;
  RxList<SavedLocationModel> get savedLocations => profileController.savedLocations;
  RxList<PassengerEmergencyContactModel> get emergencyContacts =>
      profileController.emergencyContacts;
  RxBool get pushBookingConfirmations => profileController.pushBookingConfirmations;
  RxBool get pushDriverArrivalAlerts => profileController.pushDriverArrivalAlerts;
  RxBool get pushTripStatusUpdates => profileController.pushTripStatusUpdates;
  RxBool get pushDriverChatMessages => profileController.pushDriverChatMessages;
  RxBool get pushSafetyAlerts => profileController.pushSafetyAlerts;

  Future<void> reloadProfile() => profileController.reloadProfile();
  Future<void> updatePassengerProfile({
    required String name,
    required String email,
    required String phone,
  }) =>
      profileController.updatePassengerProfile(name: name, email: email, phone: phone);

  Future<void> addSavedLocation({
    required String title,
    required String address,
    required String category,
  }) =>
      profileController.addSavedLocation(title: title, address: address, category: category);


  Future<void> deleteSavedLocation(String id) =>
      profileController.deleteSavedLocation(id);
  Future<void> removeSavedLocation(String id) =>
      profileController.removeSavedLocation(id);

  Future<void> addEmergencyContact({
    required String name,
    required String relation,
    required String phone,
    bool isPrimary = false,
  }) =>
      profileController.addEmergencyContact(
        name: name,
        relation: relation,
        phone: phone,
        isPrimary: isPrimary,
      );

  Future<void> deleteEmergencyContact(String id) =>
      profileController.deleteEmergencyContact(id);
  Future<void> removeEmergencyContact(String id) =>
      profileController.removeEmergencyContact(id);

  Future<void> updateEmergencyContact({
    required String id,
    required String name,
    required String relation,
    required String phone,
    bool isPrimary = false,
  }) =>
      profileController.updateEmergencyContact(
        id: id,
        name: name,
        relation: relation,
        phone: phone,
        isPrimary: isPrimary,
      );

  Future<void> setPrimaryEmergencyContact(String id) =>
      profileController.setPrimaryEmergencyContact(id);

  void switchToDriverMode() => profileController.switchToDriverMode();

  Future<void> callEmergencyServices() => profileController.callEmergencyServices();
  Future<void> callSafetyHotline() => profileController.callSafetyHotline();
  Future<void> sendSafetyEmail() => profileController.sendSafetyEmail();
  void confirmLogout(BuildContext context) => profileController.confirmLogout(context);
  void confirmDeleteAccount(BuildContext context) =>
      profileController.confirmDeleteAccount(context);

  // -------------------------------------------------------------
  // HOME DELEGATES
  // -------------------------------------------------------------
  RxDouble get trustRating => homeController.trustRating;
  RxList<RecentRouteModel> get recentRoutes => homeController.recentRoutes;
  void selectRecentRoute(RecentRouteModel route) =>
      homeController.selectRecentRoute(route);

  // -------------------------------------------------------------
  // SEARCH DELEGATES
  // -------------------------------------------------------------
  TextEditingController get fromLocationController =>
      searchController.fromLocationController;
  TextEditingController get toLocationController =>
      searchController.toLocationController;
  RxDouble get fromLat => searchController.fromLat;
  RxDouble get fromLng => searchController.fromLng;
  RxDouble get toLat => searchController.toLat;
  RxDouble get toLng => searchController.toLng;
  RxString get selectedDate => searchController.selectedDate;
  RxString get preferredTime => searchController.preferredTime;
  RxString get timeFlexibility => searchController.timeFlexibility;
  RxInt get requestedSeats => searchController.requestedSeats;
  RxString get seatsNote => searchController.seatsNote;
  RxString get selectedFilter => searchController.selectedFilter;
  RxBool get hasSearched => searchController.hasSearched;
  RxList<RideModel> get availableRides => searchController.availableRides;
  List<RideModel> get filteredRides => searchController.filteredRides;
  void swapLocations() => searchController.swapLocations();
  void performSearch() => searchController.performSearch();

  // -------------------------------------------------------------
  // TRIPS & BOOKINGS DELEGATES
  // -------------------------------------------------------------
  RxList<PassengerPendingRequestModel> get pendingRequests =>
      tripsController.pendingRequests;
  RxList<BookingModel> get myBookings => tripsController.myBookings;
  RxList<CompletedTripModel> get completedTrips => tripsController.completedTrips;
  Rx<RideModel?> get selectedRide => tripsController.selectedRide;
  Rx<RideModel?> get currentSelectedRide => tripsController.currentSelectedRide;
  RxInt get selectedTripsTab => tripsController.selectedTripsTab;

  void switchTripsTab(int index) => tripsController.switchTripsTab(index);
  void openRideDetails(RideModel ride) => tripsController.openRideDetails(ride);
  void selectRideForDetails(RideModel ride) =>
      tripsController.selectRideForDetails(ride);
  void requestToJoinRide(RideModel ride, {int? seats, String? notes}) =>
      tripsController.requestToJoinRide(ride, seats: seats, notes: notes);
  void cancelPendingRequest(dynamic req) =>
      tripsController.cancelPendingRequest(req);
  void cancelBooking(dynamic booking) => tripsController.cancelBooking(booking);
  void approvePendingRequest(String requestId) =>
      tripsController.approvePendingRequest(requestId);
  void simulateDriverApproval() => tripsController.simulateDriverApproval();
  void bookRide(RideModel ride, int seats) =>
      tripsController.bookRide(ride, seats);
  void rateTrip(CompletedTripModel trip, double rating, String comment) =>
      tripsController.rateTrip(trip, rating, comment);
  void rateDriver({
    required String tripId,
    required double rating,
    String comment = '',
  }) =>
      tripsController.rateDriver(
        tripId: tripId,
        rating: rating,
        comment: comment,
      );

  // -------------------------------------------------------------
  // COMMUNITY DELEGATES
  // -------------------------------------------------------------
  Rx<CommunityModel?> get selectedCommunity => communityController.selectedCommunity;
  RxList<CommunityModel> get communities => communityController.communities;
  RxBool get isCommunitiesLoading => communityController.isLoading;
  void toggleCommunityJoin(CommunityModel comm) =>
      communityController.toggleCommunityJoin(comm);
  void confirmLeaveCommunity(CommunityModel comm) =>
      communityController.confirmLeaveCommunity(comm);
  void openCommunityDetails(CommunityModel comm) =>
      communityController.openCommunityDetails(comm);

  // -------------------------------------------------------------
  // SUPPORT DELEGATES
  // -------------------------------------------------------------
  RxList<PassengerSupportTicketModel> get supportTickets =>
      supportController.supportTickets;

  Future<PassengerSupportTicketModel?> submitSupportTicket({
    required String subject,
    required String category,
    required String message,
  }) =>
      supportController.submitSupportTicket(
        subject: subject,
        category: category,
        message: message,
      );

  Future<void> sendSupportChatMessage({
    required String ticketId,
    required String text,
  }) =>
      supportController.sendSupportChatMessage(ticketId: ticketId, text: text);

  void resolveSupportTicket(String ticketId) =>
      supportController.resolveSupportTicket(ticketId);
}
