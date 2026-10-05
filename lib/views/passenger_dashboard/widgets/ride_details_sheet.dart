import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';
import 'package:ridelink/widgets/app_button.dart';

class RideDetailsSheet extends StatelessWidget {
  final RideModel ride;

  const RideDetailsSheet({super.key, required this.ride});

  static void show(BuildContext context, RideModel ride) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RideDetailsSheet(ride: ride),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PassengerDashboardController>();
    final RxInt selectedSeats = 1.obs;

    return Container(
      padding: EdgeInsets.only(
        top: 16.h,
        left: 20.w,
        right: 20.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

            // Header: Driver Details with Real-time Online Indicator
            StreamBuilder<bool>(
              stream: AuthService.instance.streamUserOnlineStatus(ride.driverId),
              initialData: ride.isDriverOnline,
              builder: (context, snapshot) {
                final bool isDriverOnline = snapshot.data ?? true;

                return Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 26.r,
                              backgroundColor: const Color(0xFFEFF6FF),
                              child: Text(
                                ride.driverName.isNotEmpty
                                    ? ride.driverName.substring(0, 1)
                                    : 'D',
                                style: AppTextStyle.text18Semibold.copyWith(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 14.r,
                                height: 14.r,
                                decoration: BoxDecoration(
                                  color: isDriverOnline
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.2,
                                  ),
                                ),
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
                                children: [
                                  Text(
                                    ride.driverName,
                                    style: AppTextStyle.text16Semibold,
                                  ),
                                  SizedBox(width: 6.w),
                                  if (ride.isVerified)
                                    Icon(
                                      Icons.verified,
                                      size: 16.sp,
                                      color: AppColors.primaryColor,
                                    ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 14.sp,
                                    color: const Color(0xFFFFB900),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${ride.rating} (${ride.totalRides} trips) • ${isDriverOnline ? 'Online' : 'Offline'}',
                                    style: AppTextStyle.text12Regular.copyWith(
                                      color: isDriverOnline
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFFDC2626),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Column(
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
                        ),
                      ],
                    ),

                    if (!isDriverOnline) ...[
                      12.verticalSpace,
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: const Color(0xFFFDE68A),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.info_circle_fill,
                              color: const Color(0xFFD97706),
                              size: 15.sp,
                            ),
                            8.horizontalSpace,
                            Expanded(
                              child: Text(
                                'Driver is currently offline. Your request will notify them, but approval may take slightly longer.',
                                style: AppTextStyle.text12Regular.copyWith(
                                  color: const Color(0xFF92400E),
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),


            SizedBox(height: 18.h),
            const Divider(color: AppColors.borderColor, height: 1),
            SizedBox(height: 16.h),

            // Car Info
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.containerFillColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.car_detailed,
                    color: AppColors.primaryColor,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ride.carModel, style: AppTextStyle.text14Semibold),
                        Text(
                          ride.carPlate,
                          style: AppTextStyle.text12Regular.copyWith(
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),

            // Route Details
            Text('Trip Route', style: AppTextStyle.text14Semibold),
            SizedBox(height: 12.h),

            // Route timeline
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    Container(
                      width: 2.w,
                      height: 38.h,
                      color: AppColors.borderColor,
                    ),
                    Container(
                      width: 10.w,
                      height: 10.h,
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
                              style: AppTextStyle.text14Semibold,
                            ),
                          ),
                          Text(
                            ride.departureTime,
                            style: AppTextStyle.text14Semibold.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Pickup Point',
                        style: AppTextStyle.text12Regular.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ride.destination,
                              style: AppTextStyle.text14Semibold,
                            ),
                          ),
                          Text(
                            ride.estimatedDuration,
                            style: AppTextStyle.text12Regular.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Drop-off Destination',
                        style: AppTextStyle.text12Regular.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (ride.stops.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Wrap(
                spacing: 6.w,
                children: ride.stops
                    .map(
                      (s) => Chip(
                        label: Text(
                          'Stop: $s',
                          style: AppTextStyle.text10Medium,
                        ),
                        backgroundColor: AppColors.containerFillColor,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            ],

            if (ride.isEnRouteMatch) ...[
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.alt_route_rounded,
                      color: Color(0xFF16A34A),
                      size: 20,
                    ),
                    10.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'En-Route Ride Corridor',
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: const Color(0xFF15803D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Driver picks you up along their way (~${ride.detourMinutes} min detour). Proportional sub-route fare applies.',
                            style: AppTextStyle.text10Medium.copyWith(
                              color: const Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              14.verticalSpace,
            ],

            SizedBox(height: 20.h),
            const Divider(color: AppColors.borderColor, height: 1),
            SizedBox(height: 16.h),

            // Seats Counter & Price Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Seats to Book', style: AppTextStyle.text14Semibold),
                    Text(
                      '${ride.seatsAvailable} seats available',
                      style: AppTextStyle.text12Regular.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                Obx(
                  () => Row(
                    children: [
                      IconButton(
                        onPressed: selectedSeats.value > 1
                            ? () => selectedSeats.value--
                            : null,
                        icon: const Icon(CupertinoIcons.minus_circle),
                        color: selectedSeats.value > 1
                            ? AppColors.primaryColor
                            : AppColors.secondaryTextColor,
                      ),
                      Text(
                        '${selectedSeats.value}',
                        style: AppTextStyle.text16Semibold,
                      ),
                      IconButton(
                        onPressed: selectedSeats.value < ride.seatsAvailable
                            ? () => selectedSeats.value++
                            : null,
                        icon: const Icon(CupertinoIcons.plus_circle),
                        color: selectedSeats.value < ride.seatsAvailable
                            ? AppColors.primaryColor
                            : AppColors.secondaryTextColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Total Price Calculation Card
            Obx(() {
              final double seatPrice = (ride.isEnRouteMatch && ride.enRouteSubFare != null)
                  ? ride.enRouteSubFare!
                  : ride.pricePerSeat;
              final double total = seatPrice * selectedSeats.value;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.containerFillColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Fare (${selectedSeats.value} seat${selectedSeats.value > 1 ? 's' : ''})',
                      style: AppTextStyle.text14Medium,
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: AppTextStyle.text18Semibold.copyWith(
                        color: (ride.isEnRouteMatch && ride.enRouteSubFare != null)
                            ? const Color(0xFF16A34A)
                            : AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 20.h),

            // Book Button
            AppButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.bookRide(ride, selectedSeats.value);
              },
              label: 'Confirm & Book Seat',
            ),
          ],
        ),
      ),
    );
  }
}
