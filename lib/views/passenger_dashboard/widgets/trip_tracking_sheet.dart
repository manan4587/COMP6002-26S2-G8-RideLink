import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';
import 'package:ridelink/views/passenger_dashboard/widgets/ride_chat_sheet.dart';

class TripTrackingSheet extends StatelessWidget {
  final BookingModel booking;

  const TripTrackingSheet({super.key, required this.booking});

  static void show(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TripTrackingSheet(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w, bottom: 20.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Live Trip Tracking', style: AppTextStyle.text18Semibold),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Driver On The Way',
                      style: AppTextStyle.text10Medium.copyWith(
                        color: const Color(0xFF16A34A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Simulated Interactive Map Route Graphic
          Container(
            height: 180.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.map_pin_ellipse,
                        size: 42.sp,
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'En Route to Pickup Point',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      Text(
                        'Driver arriving in ~8 mins',
                        style: AppTextStyle.text12Regular.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.speed,
                          size: 16.sp,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(width: 4.w),
                        Text('60 km/h', style: AppTextStyle.text12Semibold),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 18.h),

          // Driver & Vehicle Card
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.containerFillColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: const Color(0xFFDBEAFE),
                  child: Text(
                    booking.ride.driverName[0],
                    style: AppTextStyle.text16Semibold.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.ride.driverName,
                        style: AppTextStyle.text16Semibold,
                      ),
                      Text(
                        '${booking.ride.carModel} • ${booking.ride.carPlate}',
                        style: AppTextStyle.text12Regular.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Get.back();
                    Get.toNamed(
                      AppRoutes.rideChat,
                      arguments: {
                        'driverName': booking.ride.driverName,
                        'carModel': booking.ride.carModel,
                        'route':
                            '${booking.ride.origin} → ${booking.ride.destination}',
                      },
                    );
                  },
                  icon: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.chat_bubble_fill,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 18.h),

          // Route Details
          Text('Your Journey', style: AppTextStyle.text14Semibold),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  Container(
                    width: 2.w,
                    height: 28.h,
                    color: AppColors.borderColor,
                  ),
                  Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.ride.origin,
                      style: AppTextStyle.text12Semibold,
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      booking.ride.destination,
                      style: AppTextStyle.text12Semibold,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // SOS Emergency Button & Close
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(CupertinoIcons.shield_fill, color: Colors.red),
                  label: Text(
                    'Safety Center',
                    style: AppTextStyle.text14Semibold.copyWith(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    Get.find<PassengerDashboardController>()
                        .currentSelectedRide
                        .value = booking.ride;
                    Get.toNamed(AppRoutes.liveTripTracking);
                  },
                  icon: const Icon(
                    CupertinoIcons.map_fill,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Full Map View',
                    style: AppTextStyle.buttonText.copyWith(fontSize: 13.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
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
