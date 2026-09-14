import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_controller.dart';
import 'package:ridelink/widgets/app_button.dart';

class CreateRidePage extends GetView<DriverDashboardController> {
  const CreateRidePage({super.key});

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
              Text('Publish a Ride', style: AppTextStyle.text20Semibold),
              SizedBox(height: 6.h),
              Text(
                'Share your commute, reduce traffic, and cover petrol costs.',
                style: AppTextStyle.text14Regular.copyWith(
                  color: AppColors.secondaryTextColor,
                ),
              ),

              SizedBox(height: 16.h),

              // Route Input Card
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: controller.publishFromController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.trip_origin,
                          color: Color(0xFF16A34A),
                          size: 18,
                        ),
                        hintText: 'Pickup Location (e.g. Flinders St Station)',
                        hintStyle: AppTextStyle.text14Regular.copyWith(
                          color: AppColors.hintTextColor,
                        ),
                        border: InputBorder.none,
                      ),
                      style: AppTextStyle.text14Medium,
                    ),
                    const Divider(color: AppColors.borderColor, height: 1),
                    TextField(
                      controller: controller.publishToController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.location_on,
                          color: AppColors.primaryColor,
                          size: 18,
                        ),
                        hintText: 'Drop-off Destination (e.g. Clayton Campus)',
                        hintStyle: AppTextStyle.text14Regular.copyWith(
                          color: AppColors.hintTextColor,
                        ),
                        border: InputBorder.none,
                      ),
                      style: AppTextStyle.text14Medium,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Date & Time Selectors
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date', style: AppTextStyle.text10Medium.copyWith(color: AppColors.secondaryTextColor)),
                          SizedBox(height: 4.h),
                          Obx(
                            () => Text(
                              controller.departureDate.value,
                              style: AppTextStyle.text14Semibold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Departure Time', style: AppTextStyle.text10Medium.copyWith(color: AppColors.secondaryTextColor)),
                          SizedBox(height: 4.h),
                          TextField(
                            controller: controller.departureTimeController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: AppTextStyle.text14Semibold,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Seats & Price Row
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  children: [
                    // Available seats counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Available Passenger Seats', style: AppTextStyle.text14Semibold),
                        Obx(
                          () => Row(
                            children: [
                              IconButton(
                                onPressed: controller.publishSeats.value > 1
                                    ? () => controller.publishSeats.value--
                                    : null,
                                icon: const Icon(CupertinoIcons.minus_circle),
                                color: AppColors.primaryColor,
                              ),
                              Text(
                                '${controller.publishSeats.value}',
                                style: AppTextStyle.text16Semibold,
                              ),
                              IconButton(
                                onPressed: controller.publishSeats.value < 6
                                    ? () => controller.publishSeats.value++
                                    : null,
                                icon: const Icon(CupertinoIcons.plus_circle),
                                color: AppColors.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(color: AppColors.borderColor, height: 1),
                    SizedBox(height: 10.h),

                    // Price per seat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Price Per Seat', style: AppTextStyle.text14Semibold),
                        Obx(
                          () => Text(
                            '\$${controller.publishPrice.value.toStringAsFixed(0)}',
                            style: AppTextStyle.text18Semibold.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Trip Preferences Toggles
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  children: [
                    Obx(
                      () => SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Luggage Space Available', style: AppTextStyle.text14Semibold),
                        subtitle: Text('Passengers can bring small baggage/backpacks', style: AppTextStyle.text12Regular.copyWith(color: AppColors.secondaryTextColor)),
                        value: controller.allowLuggage.value,
                        activeColor: AppColors.primaryColor,
                        onChanged: (v) => controller.allowLuggage.value = v,
                      ),
                    ),
                    const Divider(color: AppColors.borderColor, height: 1),
                    Obx(
                      () => SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Pets Allowed', style: AppTextStyle.text14Semibold),
                        subtitle: Text('Allow small caged pets inside vehicle', style: AppTextStyle.text12Regular.copyWith(color: AppColors.secondaryTextColor)),
                        value: controller.allowPets.value,
                        activeColor: AppColors.primaryColor,
                        onChanged: (v) => controller.allowPets.value = v,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Publish CTA
              AppButton(
                onPressed: controller.publishNewTrip,
                label: 'Publish Ride Now',
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
