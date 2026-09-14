import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';
import 'package:ridelink/views/passenger_dashboard/widgets/ride_details_sheet.dart';

class HomePage extends GetView<PassengerDashboardController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top User Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46.w,
                        height: 46.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFDBEAFE),
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'AM',
                            style: AppTextStyle.text16Semibold.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, Alex 👋',
                            style: AppTextStyle.text18Semibold,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14.sp,
                                color: AppColors.secondaryTextColor,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Melbourne, VIC',
                                style: AppTextStyle.text12Regular.copyWith(
                                  color: AppColors.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        CupertinoIcons.bell,
                        size: 20.sp,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Search Hero Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Where are you going today?',
                      style: AppTextStyle.text16Semibold,
                    ),
                    SizedBox(height: 14.h),

                    // Pickup
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.containerFillColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10.w,
                            height: 10.h,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              controller.fromLocationController.text,
                              style: AppTextStyle.text14Medium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Destination
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.containerFillColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10.w,
                            height: 10.h,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              controller.toLocationController.text,
                              style: AppTextStyle.text14Medium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Find Ride CTA
                    GestureDetector(
                      onTap: () => controller.switchTab(1),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.search,
                              size: 18.sp,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Search Available Rides',
                              style: AppTextStyle.buttonText.copyWith(
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 22.h),

              // Quick Location Chips
              Text(
                'Popular Destinations',
                style: AppTextStyle.text16Semibold,
              ),
              SizedBox(height: 10.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _DestinationChip(
                      icon: Icons.school_outlined,
                      label: 'Monash Uni',
                      onTap: () {
                        controller.toLocationController.text =
                            'Monash University, Clayton';
                        controller.switchTab(1);
                      },
                    ),
                    _DestinationChip(
                      icon: Icons.business_outlined,
                      label: 'Melbourne CBD',
                      onTap: () {
                        controller.toLocationController.text =
                            'Melbourne CBD, Flinders St';
                        controller.switchTab(1);
                      },
                    ),
                    _DestinationChip(
                      icon: Icons.flight_outlined,
                      label: 'Airport (MEL)',
                      onTap: () {
                        controller.toLocationController.text =
                            'Melbourne Airport (MEL)';
                        controller.switchTab(1);
                      },
                    ),
                    _DestinationChip(
                      icon: Icons.beach_access_outlined,
                      label: 'St Kilda Beach',
                      onTap: () {
                        controller.toLocationController.text =
                            'St Kilda Pier, Beach';
                        controller.switchTab(1);
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Available Rides List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Rides Today',
                    style: AppTextStyle.text18Semibold,
                  ),
                  TextButton(
                    onPressed: () => controller.switchTab(1),
                    child: Text(
                      'See All',
                      style: AppTextStyle.text14Semibold.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              Obx(
                () => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.availableRides.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final ride = controller.availableRides[index];
                    return _RideCard(
                      ride: ride,
                      onTap: () => RideDetailsSheet.show(context, ride),
                    );
                  },
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DestinationChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: AppColors.primaryColor),
            SizedBox(width: 6.w),
            Text(
              label,
              style: AppTextStyle.text12Semibold,
            ),
          ],
        ),
      ),
    );
  }
}

class _RideCard extends StatelessWidget {
  final RideModel ride;
  final VoidCallback onTap;

  const _RideCard({required this.ride, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          children: [
            // Driver Row
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: const Color(0xFFEFF6FF),
                  child: Text(
                    ride.driverName.substring(0, 1),
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
                      Row(
                        children: [
                          Text(ride.driverName, style: AppTextStyle.text14Semibold),
                          SizedBox(width: 4.w),
                          if (ride.isVerified)
                            Icon(
                              Icons.verified,
                              size: 15.sp,
                              color: AppColors.primaryColor,
                            ),
                        ],
                      ),
                      Text(
                        ride.carModel,
                        style: AppTextStyle.text12Regular.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${ride.pricePerSeat.toStringAsFixed(0)}',
                      style: AppTextStyle.text18Semibold.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Text(
                      'per seat',
                      style: AppTextStyle.text10Medium.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12.h),
            const Divider(color: AppColors.borderColor, height: 1),
            SizedBox(height: 12.h),

            // Route Timeline
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
                      height: 24.h,
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
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ride.origin,
                              style: AppTextStyle.text12Semibold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            ride.departureTime,
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ride.destination,
                              style: AppTextStyle.text12Semibold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            ride.estimatedDuration,
                            style: AppTextStyle.text10Medium.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Seats and Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.airline_seat_recline_normal,
                        size: 14.sp,
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${ride.seatsAvailable} seats available',
                        style: AppTextStyle.text10Medium.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Tap to view details →',
                  style: AppTextStyle.text12Semibold.copyWith(
                    color: AppColors.primaryColor,
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
