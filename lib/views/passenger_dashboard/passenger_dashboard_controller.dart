import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink/data/models/passenger/passenger_models.dart';
import 'package:ridelink/routes/routes_name.dart';
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

    _applyRouteArguments();
  }

  void _applyRouteArguments() {
    final args = Get.arguments;
    if (args is Map) {
      if (args['tab'] is int) {
        currentTabIndex.value = (args['tab'] as int).clamp(0, 4);
      }
      if (args['tripsTab'] is int) {
        tripsController.selectedTripsTab.value = (args['tripsTab'] as int).clamp(0, 2);
      }
    }
  }

  void switchTab(int index) {
    currentTabIndex.value = index;
  }

  /// Cleanly returns to the My Trips tab (index 2) without destroying route state
  void returnToTripsTab({int tripsTab = 0}) {
    switchTab(2);
    tripsController.selectedTripsTab.value = tripsTab.clamp(0, 2);

    bool poppedToDashboard = false;
    try {
      Get.until((route) => route.settings.name == AppRoutes.passengerDashboard);
      if (Get.currentRoute == AppRoutes.passengerDashboard) {
        poppedToDashboard = true;
      }
    } catch (_) {}

    if (!poppedToDashboard) {
      Get.offAllNamed(
        AppRoutes.passengerDashboard,
        arguments: {'tab': 2, 'tripsTab': tripsTab},
      );
    }
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

  @override
  void onReady() {
    super.onReady();
    _applyRouteArguments();
    reloadDashboard();
  }

  void reloadDashboard() {
    currentTabIndex.value = currentTabIndex.value.clamp(0, 4);
    homeController.reloadHome();
    tripsController.reloadTrips();
    communityController.reloadCommunities();
    profileController.reloadProfile();
  }

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
    double latitude = 0.0,
    double longitude = 0.0,
  }) =>
      profileController.addSavedLocation(
        title: title,
        address: address,
        category: category,
        latitude: latitude,
        longitude: longitude,
      );


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
  RxString get activeDatePreset => searchController.activeDatePreset;
  RxString get activeTimePreset => searchController.activeTimePreset;
  void selectToday() => searchController.selectToday();
  void selectTomorrow() => searchController.selectTomorrow();
  void selectWeekend() => searchController.selectWeekend();
  void selectMorning() => searchController.selectMorning();
  void selectNoon() => searchController.selectNoon();
  void selectEvening() => searchController.selectEvening();
  RxString get selectedDate => searchController.selectedDate;
  RxString get preferredTime => searchController.preferredTime;
  Rx<DateTime> get selectedSearchDate => searchController.selectedSearchDate;
  Rx<TimeOfDay> get selectedSearchTime => searchController.selectedSearchTime;
  String get formattedSearchDate => searchController.formattedSearchDate;
  String get formattedSearchTime => searchController.formattedSearchTime;
  Future<void> pickSearchDate(BuildContext context) =>
      searchController.pickSearchDate(context);
  Future<void> pickSearchTime(BuildContext context) =>
      searchController.pickSearchTime(context);
  RxString get timeFlexibility => searchController.timeFlexibility;
  RxInt get requestedSeats => searchController.requestedSeats;
  RxString get seatsNote => searchController.seatsNote;
  RxString get selectedFilter => searchController.selectedFilter;
  RxBool get hasSearched => searchController.hasSearched;
  RxBool get isSearching => searchController.isSearching;
  RxList<RideModel> get availableRides => searchController.availableRides;
  List<RideModel> get filteredRides => searchController.filteredRides;
  void swapLocations() => searchController.swapLocations();
  void performSearch() => searchController.performSearch();

  // -------------------------------------------------------------
  // TRIPS & BOOKINGS DELEGATES
  // -------------------------------------------------------------
  RxBool get isLoadingBookings => tripsController.isLoadingBookings;
  RxList<PassengerPendingRequestModel> get pendingRequests =>
      tripsController.pendingRequests;
  RxList<BookingModel> get myBookings => tripsController.myBookings;
  RxList<CompletedTripModel> get completedTrips => tripsController.completedTrips;
  Rx<RideModel?> get selectedRide => tripsController.selectedRide;
  Rx<RideModel?> get currentSelectedRide => tripsController.currentSelectedRide;
  RxInt get selectedTripsTab => tripsController.selectedTripsTab;
  RxString get tripsSearchQuery => tripsController.searchQuery;
  RxString get lastCreatedBookingId => tripsController.lastCreatedBookingId;

  void switchTripsTab(int index) => tripsController.switchTripsTab(index);
  void openRideDetails(RideModel ride) => tripsController.openRideDetails(ride);
  void selectRideForDetails(RideModel ride) =>
      tripsController.selectRideForDetails(ride);
  void requestToJoinRide(RideModel ride, {int? seats, String? notes}) =>
      tripsController.requestToJoinRide(ride, seats: seats, notes: notes);
  void cancelPendingRequest(dynamic req, {String reason = 'Cancelled by passenger'}) =>
      tripsController.cancelPendingRequest(req, reason: reason);
  void cancelBooking(dynamic booking, {String reason = 'Cancelled by passenger'}) =>
      tripsController.cancelBooking(booking, reason: reason);
  void bookRide(RideModel ride, int seats) =>
      tripsController.bookRide(ride, seats);
  void rateTrip(CompletedTripModel trip, double rating, String comment) =>
      tripsController.rateTrip(trip, rating, comment);
  void rateDriver({
    required String tripId,
    required double rating,
    String comment = '',
    String driverId = '',
    String? bookingId,
  }) =>
      tripsController.rateDriver(
        tripId: tripId,
        rating: rating,
        comment: comment,
        driverId: driverId,
        bookingId: bookingId,
      );
  Future<void> reloadTrips() => tripsController.reloadTrips();

  // -------------------------------------------------------------
  // COMMUNITY DELEGATES
  // -------------------------------------------------------------
  Rx<CommunityModel?> get selectedCommunity => communityController.selectedCommunity;
  RxList<CommunityModel> get communities => communityController.communities;
  RxBool get isCommunitiesLoading => communityController.isLoading;
  void joinCommunity(CommunityModel comm) =>
      communityController.joinCommunity(comm);
  void toggleCommunityJoin(CommunityModel comm) =>
      communityController.toggleCommunityJoin(comm);
  Future<void> confirmLeaveCommunity(BuildContext? context, CommunityModel comm) =>
      communityController.confirmLeaveCommunity(context, comm);
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

  /// Cancels all active Firestore listeners across child controllers
  void cleanupAll() {
    if (Get.isRegistered<PassengerHomeController>()) {
      homeController.clearState();
    }
    if (Get.isRegistered<PassengerTripsController>()) {
      tripsController.clearState();
    }
    if (Get.isRegistered<PassengerCommunityController>()) {
      communityController.clearState();
    }
    if (Get.isRegistered<PassengerSupportController>()) {
      supportController.clearState();
    }
    if (Get.isRegistered<PassengerProfileController>()) {
      profileController.clearState();
    }
  }

  @override
  void onClose() {
    cleanupAll();
    super.onClose();
  }
}
