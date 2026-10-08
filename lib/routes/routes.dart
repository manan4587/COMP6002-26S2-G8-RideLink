import 'package:get/get.dart';
import 'package:ridelink/views/auth_flow/view/create_account_view.dart';
import 'package:ridelink/views/auth_flow/view/driver_verification_upload_view.dart';
import 'package:ridelink/views/auth_flow/view/email_verification_view.dart';
import 'package:ridelink/views/auth_flow/view/get_started_view.dart';
import 'package:ridelink/views/auth_flow/view/login_view.dart';
import 'package:ridelink/views/auth_flow/view/splash_view.dart';
import 'package:ridelink/views/auth_flow/view/verification_submitted_view.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_view.dart';
import 'package:ridelink/views/driver_dashboard/pages/create_ride_page.dart';
import 'package:ridelink/views/driver_dashboard/pages/driver_community_details_page.dart';
import 'package:ridelink/views/driver_dashboard/pages/driver_live_trip_page.dart';
import 'package:ridelink/views/driver_dashboard/pages/driver_notification_preferences_page.dart';
import 'package:ridelink/views/driver_dashboard/pages/driver_request_details_page.dart';
import 'package:ridelink/views/driver_dashboard/pages/driver_ride_chat_page.dart';
import 'package:ridelink/views/driver_dashboard/pages/driver_ride_requests_page.dart';
import 'package:ridelink/views/driver_dashboard/pages/driver_safety_sos_page.dart';
import 'package:ridelink/views/driver_dashboard/pages/driver_support_chat_page.dart';
import 'package:ridelink/views/driver_dashboard/pages/driver_support_page.dart';
import 'package:ridelink/views/driver_dashboard/pages/driver_verification_documents_page.dart';
import 'package:ridelink/views/driver_dashboard/pages/vehicle_registration_page.dart';
import 'package:ridelink/views/passenger_dashboard/pages/edit_passenger_profile_page.dart';
import 'package:ridelink/views/passenger_dashboard/pages/live_trip_tracking_page.dart';
import 'package:ridelink/views/passenger_dashboard/pages/passenger_community_details_page.dart';
import 'package:ridelink/views/passenger_dashboard/pages/passenger_emergency_contacts_page.dart';
import 'package:ridelink/views/passenger_dashboard/pages/passenger_notification_preferences_page.dart';
import 'package:ridelink/views/passenger_dashboard/pages/passenger_safety_sos_page.dart';
import 'package:ridelink/views/passenger_dashboard/pages/passenger_saved_locations_page.dart';
import 'package:ridelink/views/passenger_dashboard/pages/passenger_support_chat_page.dart';
import 'package:ridelink/views/passenger_dashboard/pages/passenger_support_page.dart';
import 'package:ridelink/views/passenger_dashboard/pages/request_approved_page.dart';
import 'package:ridelink/views/passenger_dashboard/pages/request_sent_page.dart';
import 'package:ridelink/views/passenger_dashboard/pages/ride_chat_page.dart';
import 'package:ridelink/views/passenger_dashboard/pages/ride_details_page.dart';
import 'package:ridelink/views/passenger_dashboard/pages/suggested_rides_page.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_view.dart';

import 'routes_name.dart';

GetPage getPage({
  String? name,
  GetPageBuilder? page,
  Bindings? binding,
  List<GetPage<dynamic>>? children,
}) {
  return GetPage(
    name: name!,
    page: page!,
    binding: binding,
    children: children ?? [],
    participatesInRootNavigator: true,
    popGesture: true,
  );
}

List<GetPage> pages = [
  getPage(name: AppRoutes.splashView, page: () => const SplashView()),
  getPage(name: AppRoutes.getStartedView, page: () => const GetStartedView()),
  getPage(name: AppRoutes.loginView, page: () => const LoginView()),
  getPage(
    name: AppRoutes.createAccountView,
    page: () => const CreateAccountView(),
  ),
  getPage(
    name: AppRoutes.driverVerificaitonUploadView,
    page: () => const DriverVerificationUploadView(),
  ),
  getPage(
    name: AppRoutes.verificationSubmittedView,
    page: () => const VerificationSubmittedView(),
  ),
  getPage(
    name: AppRoutes.emailVerificationView,
    page: () => const EmailVerificationView(),
  ),
  getPage(
    name: AppRoutes.passengerDashboard,
    page: () => const PassengerDashboardView(),
  ),
  getPage(
    name: AppRoutes.driverDashboard,
    page: () => const DriverDashboardView(),
  ),
  getPage(
    name: AppRoutes.vehicleRegistration,
    page: () => const VehicleRegistrationPage(),
  ),
  getPage(
    name: AppRoutes.driverVerificationDocuments,
    page: () => const DriverVerificationDocumentsPage(),
  ),
  getPage(
    name: AppRoutes.driverSafetySos,
    page: () => const DriverSafetySosPage(),
  ),
  getPage(name: AppRoutes.driverSupport, page: () => const DriverSupportPage()),
  getPage(
    name: AppRoutes.driverNotificationPreferences,
    page: () => const DriverNotificationPreferencesPage(),
  ),
  getPage(
    name: AppRoutes.passengerSavedLocations,
    page: () => const PassengerSavedLocationsPage(),
  ),
  getPage(
    name: AppRoutes.passengerSafetySos,
    page: () => const PassengerSafetySosPage(),
  ),
  getPage(
    name: AppRoutes.passengerEmergencyContacts,
    page: () => const PassengerEmergencyContactsPage(),
  ),
  getPage(
    name: AppRoutes.passengerNotificationPreferences,
    page: () => const PassengerNotificationPreferencesPage(),
  ),
  getPage(
    name: AppRoutes.passengerSupport,
    page: () => const PassengerSupportPage(),
  ),
  getPage(
    name: AppRoutes.passengerSupportChat,
    page: () => const PassengerSupportChatPage(),
  ),
  getPage(
    name: AppRoutes.suggestedRides,
    page: () => const SuggestedRidesPage(),
  ),
  getPage(name: AppRoutes.rideDetails, page: () => const RideDetailsPage()),
  getPage(name: AppRoutes.requestSent, page: () => const RequestSentPage()),
  getPage(
    name: AppRoutes.requestApproved,
    page: () => const RequestApprovedPage(),
  ),
  getPage(
    name: AppRoutes.liveTripTracking,
    page: () => const LiveTripTrackingPage(),
  ),
  getPage(name: AppRoutes.rideChat, page: () => const RideChatPage()),
  getPage(
    name: AppRoutes.passengerCommunityDetails,
    page: () => const PassengerCommunityDetailsPage(),
  ),
  getPage(
    name: AppRoutes.editPassengerProfile,
    page: () => const EditPassengerProfilePage(),
  ),
  getPage(
    name: AppRoutes.driverRideRequests,
    page: () => const DriverRideRequestsPage(),
  ),
  getPage(
    name: AppRoutes.driverRequestDetails,
    page: () => const DriverRequestDetailsPage(),
  ),
  getPage(
    name: AppRoutes.driverPublishRide,
    page: () => const CreateRidePage(),
  ),
  getPage(
    name: AppRoutes.driverLiveTrip,
    page: () => const DriverLiveTripPage(),
  ),
  getPage(
    name: AppRoutes.driverRideChat,
    page: () => const DriverRideChatPage(),
  ),
  getPage(
    name: AppRoutes.driverSupportChat,
    page: () => const DriverSupportChatPage(),
  ),
  getPage(
    name: AppRoutes.driverCommunityDetails,
    page: () => const DriverCommunityDetailsPage(),
  ),
];
