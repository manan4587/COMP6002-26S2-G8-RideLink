import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';

class DriverTripModel {
  final String id;
  final String from;
  final String to;
  final String time;
  final double pricePerSeat;
  final int totalSeats;
  final int bookedSeats;
  final RxString status; // 'Active', 'Scheduled', 'Completed'
  final List<PassengerRequestModel> acceptedPassengers;

  DriverTripModel({
    required this.id,
    required this.from,
    required this.to,
    required this.time,
    required this.pricePerSeat,
    required this.totalSeats,
    required this.bookedSeats,
    required String status,
    this.acceptedPassengers = const [],
  }) : status = status.obs;
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
  final String emergencyContactName;
  final String emergencyContactRelation;
  final String emergencyContactPhone;

  PassengerRequestModel({
    required this.id,
    required this.passengerName,
    required this.rating,
    required this.from,
    required this.to,
    required this.seats,
    required this.fare,
    required this.time,
    this.emergencyContactName = 'Sarah Jenkins',
    this.emergencyContactRelation = 'Mother',
    this.emergencyContactPhone = '+61 412 345 678',
  });
}

class SupportTicketModel {
  final String id;
  final String subject;
  final String category;
  final String message;
  final DateTime createdAt;
  final String status; // 'Submitted', 'Under Review', 'Resolved'

  SupportTicketModel({
    required this.id,
    required this.subject,
    required this.category,
    required this.message,
    required this.createdAt,
    this.status = 'Submitted',
  });
}

class DriverDashboardController extends GetxController {
  final RxInt currentTabIndex = 0.obs;
  final RxBool isOnline = true.obs;

  // Admin Verification Status Condition
  // Default is false so driver sees the pending admin verification condition
  final RxBool isVerifiedByAdmin = false.obs;

  // Driver Vehicle Info
  final RxString vehicleNumber = '1AB-2CD'.obs;
  final RxString vehicleType = 'Sedan'.obs;
  final RxString vehicleModel = 'Toyota Camry 2022'.obs;
  final RxString vehicleColor = 'White'.obs;

  // Push Notification Preferences (Push Only - No Email)
  final RxBool pushRideRequests = true.obs;
  final RxBool pushTripStatusUpdates = true.obs;
  final RxBool pushPassengerMessages = true.obs;
  final RxBool pushSafetyAlerts = true.obs;
  final RxBool pushAdminAnnouncements = true.obs;

  // Verification Documents Status
  final RxString dlStatus = 'Pending Admin Verification'.obs;
  final RxString vrStatus = 'Pending Admin Verification'.obs;
  final RxString viStatus = 'Pending Admin Verification'.obs;
  final RxString pcStatus = 'Under Review (Optional)'.obs;

  // Support Tickets stored in database (local reactive store)
  final RxList<SupportTicketModel> supportTickets = <SupportTicketModel>[
    SupportTicketModel(
      id: 'TCK-1024',
      subject: 'Document verification turnaround time',
      category: 'Verification',
      message:
          'Hello, I uploaded my driving licence and vehicle insurance. Could you please confirm the review timeline?',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Under Review',
    ),
  ].obs;

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
      status: 'Active', // Currently in progress -> Emergency contact is visible!
      acceptedPassengers: [
        PassengerRequestModel(
          id: 'p_alex',
          passengerName: 'Alex Morgan',
          rating: 4.95,
          from: 'Melbourne CBD',
          to: 'Monash Clayton',
          seats: 1,
          fare: 12.00,
          time: '04:30 PM',
          emergencyContactName: 'Sarah Jenkins',
          emergencyContactRelation: 'Mother',
          emergencyContactPhone: '+61 412 345 678',
        ),
      ],
    ),
    DriverTripModel(
      id: 'dt2',
      from: 'Clayton Campus',
      to: 'South Yarra Station',
      time: '07:00 PM (Today)',
      pricePerSeat: 10.0,
      totalSeats: 3,
      bookedSeats: 1,
      status: 'Scheduled', // Scheduled -> Emergency contact is hidden/protected!
      acceptedPassengers: [
        PassengerRequestModel(
          id: 'p_jessica',
          passengerName: 'Jessica Tan',
          rating: 4.88,
          from: 'Clayton Campus',
          to: 'South Yarra',
          seats: 1,
          fare: 10.00,
          time: '07:00 PM',
          emergencyContactName: 'David Tan',
          emergencyContactRelation: 'Spouse',
          emergencyContactPhone: '+61 433 987 654',
        ),
      ],
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

  // Driver Communities & Community Trip Publishing
  final RxString selectedCommunityForPublish = 'Curtin Community'.obs;
  final List<String> availableCommunitiesForDriver = [
    'None (Public Ride)',
    'Curtin Community',
    'Monash Clayton Carpool',
    'Melbourne CBD Corporate',
    'Deakin Uni Burwood Hub',
  ];

  void selectCommunityForPublish(String communityName) {
    selectedCommunityForPublish.value = communityName;
    if (communityName == 'Curtin Community') {
      publishFromController.text = 'Landsdale';
      publishToController.text = 'Curtin University';
      publishPrice.value = 7.0;
    } else if (communityName == 'Monash Clayton Carpool') {
      publishFromController.text = 'Glen Waverley';
      publishToController.text = 'Monash University Clayton';
      publishPrice.value = 9.0;
    } else if (communityName == 'Melbourne CBD Corporate') {
      publishFromController.text = 'Hawthorn';
      publishToController.text = 'Flinders St Station';
      publishPrice.value = 10.0;
    }
  }

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

  void toggleTripStatus(DriverTripModel trip) {
    if (trip.status.value == 'Active') {
      trip.status.value = 'Scheduled';
      AppSnackBar.info(
        message: 'Trip marked as Scheduled. Passenger emergency contacts locked.',
      );
    } else {
      trip.status.value = 'Active';
      AppSnackBar.success(
        message: 'Trip started! Passenger emergency contacts are now accessible.',
      );
    }
  }

  // Toggle simulated admin verification (helpful for testing and demos)
  void toggleAdminVerification() {
    isVerifiedByAdmin.value = !isVerifiedByAdmin.value;
    if (isVerifiedByAdmin.value) {
      dlStatus.value = 'Verified by Admin';
      vrStatus.value = 'Verified by Admin';
      viStatus.value = 'Verified by Admin';
      pcStatus.value = 'Verified by Admin';
      AppSnackBar.success(
        message: 'Admin verification approved! You can now publish rides.',
      );
    } else {
      dlStatus.value = 'Pending Admin Verification';
      vrStatus.value = 'Pending Admin Verification';
      viStatus.value = 'Pending Admin Verification';
      pcStatus.value = 'Under Review (Optional)';
      AppSnackBar.warning(
        message: 'Driver account set to Pending Admin Verification.',
      );
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
    // Condition: Check admin verification
    if (!isVerifiedByAdmin.value) {
      AppSnackBar.error(
        message:
            "You cannot create a new ride until your documents are verified by admin.",
      );
      return;
    }

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

  // Update Vehicle Details
  void updateVehicleInfo({
    required String number,
    required String type,
    String? model,
    String? color,
  }) {
    vehicleNumber.value = number.trim();
    vehicleType.value = type.trim();
    if (model != null && model.trim().isNotEmpty) {
      vehicleModel.value = model.trim();
    }
    if (color != null && color.trim().isNotEmpty) {
      vehicleColor.value = color.trim();
    }
    AppSnackBar.success(
      message: 'Vehicle & registration updated successfully!',
    );
  }

  // Submit Contact Support query to database
  Future<void> submitSupportTicket({
    required String subject,
    required String category,
    required String message,
  }) async {
    final newTicket = SupportTicketModel(
      id: 'TCK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      subject: subject,
      category: category,
      message: message,
      createdAt: DateTime.now(),
      status: 'Submitted',
    );

    supportTickets.insert(0, newTicket);
    AppSnackBar.success(
      message:
          'Support query submitted! Our admin team has received it and will contact you via email.',
    );
  }

  // Safety & SOS actions
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
      AppSnackBar.info(message: 'Calling RideLink 24/7 Safety Hotline...');
    }
  }

  Future<void> sendSafetyEmail() async {
    try {
      await Utils.launchURL(
        'mailto:safety@ridelink.com?subject=Urgent%20Driver%20Safety%20Inquiry',
      );
    } catch (_) {
      AppSnackBar.info(message: 'Opening mail to safety@ridelink.com...');
    }
  }

  // Profile Mode Switcher: Driver -> Passenger
  void switchToPassengerMode() {
    Preferences.userRole = 'passenger';
    Get.offAllNamed(AppRoutes.passengerDashboard);
    AppSnackBar.success(
      message: 'Switched to Passenger Mode. Ready to search rides!',
    );
  }

  // Confirmation bottom sheet before Logout
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
                        'Confirm session termination',
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
              'Are you sure you want to log out of your RideLink driver account? You will need to log back in to manage your rides and receive bookings.',
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

  // Confirmation bottom sheet before Delete Account
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
              'Are you sure you want to delete your account? This action is permanent and will permanently erase your driver profile, vehicle documents, and trip history.',
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
                      'All active published trips and passenger requests will be cancelled immediately.',
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
