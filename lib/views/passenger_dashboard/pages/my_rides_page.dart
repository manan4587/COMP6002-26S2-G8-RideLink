import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';
import 'package:ridelink/views/passenger_dashboard/widgets/ride_chat_sheet.dart';
import 'package:ridelink/views/passenger_dashboard/widgets/trip_tracking_sheet.dart';

class MyRidesPage extends GetView<PassengerDashboardController> {
  const MyRidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final RxInt selectedSegment = 0.obs;

    return Scaffold(
      backgroundColor: AppColors.secondaryBgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Bookings', style: AppTextStyle.text20Semibold),
              SizedBox(height: 14.h),

              // Segmented Tabs
              Obx(
                () => Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => selectedSegment.value = 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: BoxDecoration(
                              color: selectedSegment.value == 0
                                  ? AppColors.primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Upcoming (${controller.myBookings.length})',
                              style: AppTextStyle.text12Semibold.copyWith(
                                color: selectedSegment.value == 0
                                    ? Colors.white
                                    : AppColors.secondaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => selectedSegment.value = 1,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: BoxDecoration(
                              color: selectedSegment.value == 1
                                  ? AppColors.primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Completed (3)',
                              style: AppTextStyle.text12Semibold.copyWith(
                                color: selectedSegment.value == 1
                                    ? Colors.white
                                    : AppColors.secondaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 18.h),

              // Bookings List
              Expanded(
                child: Obx(() {
                  if (selectedSegment.value == 0) {
                    if (controller.myBookings.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.car,
                              size: 48.sp,
                              color: AppColors.secondaryTextColor,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'No upcoming rides',
                              style: AppTextStyle.text16Semibold,
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'Book your next trip from the search tab!',
                              style: AppTextStyle.text12Regular.copyWith(
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.myBookings.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 14.h),
                      itemBuilder: (context, index) {
                        final booking = controller.myBookings[index];
                        return _BookingCard(
                          booking: booking,
                          onTrack: () =>
                              TripTrackingSheet.show(context, booking),
                          onChat: () => RideChatSheet.show(
                            context,
                            driverName: booking.ride.driverName,
                          ),
                          onCancel: () => controller.cancelBooking(booking.id),
                        );
                      },
                    );
                  }

                  // Past Completed Rides Mock
                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _CompletedRideCard(
                        driverName: 'Emily Watson',
                        route: 'Southern Cross → MEL Airport',
                        date: 'Yesterday, Oct 4',
                        fare: '\$18.00',
                      ),
                      SizedBox(height: 12.h),
                      _CompletedRideCard(
                        driverName: 'David Chen',
                        route: 'Box Hill Central → St Kilda',
                        date: 'Oct 2, 2026',
                        fare: '\$14.50',
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTrack;
  final VoidCallback onChat;
  final VoidCallback onCancel;

  const _BookingCard({
    required this.booking,
    required this.onTrack,
    required this.onChat,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Confirmed Booking',
                  style: AppTextStyle.text10Medium.copyWith(
                    color: const Color(0xFF16A34A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                booking.bookingDate,
                style: AppTextStyle.text12Semibold.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Driver
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  booking.ride.driverName[0],
                  style: AppTextStyle.text14Semibold.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.ride.driverName,
                      style: AppTextStyle.text14Semibold,
                    ),
                    Text(
                      booking.ride.carModel,
                      style: AppTextStyle.text12Regular.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${booking.totalPrice.toStringAsFixed(2)}',
                style: AppTextStyle.text18Semibold.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),
          const Divider(color: AppColors.borderColor, height: 1),
          SizedBox(height: 12.h),

          // Route
          Row(
            children: [
              Icon(Icons.directions_car, size: 16.sp, color: AppColors.primaryColor),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '${booking.ride.origin} → ${booking.ride.destination}',
                  style: AppTextStyle.text12Semibold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onTrack,
                  icon: const Icon(CupertinoIcons.location_fill, size: 16, color: Colors.white),
                  label: Text('Track Ride', style: AppTextStyle.buttonText.copyWith(fontSize: 12.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                onPressed: onChat,
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.containerFillColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Icon(
                    CupertinoIcons.chat_bubble_2_fill,
                    size: 16.sp,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              IconButton(
                onPressed: onCancel,
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.xmark,
                    size: 16.sp,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletedRideCard extends StatelessWidget {
  final String driverName;
  final String route;
  final String date;
  final String fare;

  const _CompletedRideCard({
    required this.driverName,
    required this.route,
    required this.date,
    required this.fare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                driverName,
                style: AppTextStyle.text14Semibold,
              ),
              Text(
                fare,
                style: AppTextStyle.text14Semibold.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(route, style: AppTextStyle.text12Regular),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: AppTextStyle.text10Medium.copyWith(
                  color: AppColors.secondaryTextColor,
                ),
              ),
              Text(
                '★ 5.0 Rated',
                style: AppTextStyle.text10Medium.copyWith(
                  color: const Color(0xFFFFB900),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
