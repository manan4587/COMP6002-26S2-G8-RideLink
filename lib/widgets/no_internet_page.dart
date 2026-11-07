import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/services/network_controller.dart';
import 'package:ridelink/theme/app_text_style.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final networkController = NetworkController.instance;

    return Material(
      color: AppColors.secondaryBgColor,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular WiFi off icon container
                Container(
                  width: 96.w,
                  height: 96.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFBFDBFE),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.wifi_off_rounded,
                      size: 46.sp,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),

                24.verticalSpace,

                // Title
                Text(
                  'No Internet Connection',
                  style: AppTextStyle.text20Semibold.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryTextColor,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                10.verticalSpace,

                // Description
                Text(
                  'Please check your Wi-Fi or mobile data settings and tap refresh to continue using RideLink.',
                  style: AppTextStyle.text14Regular.copyWith(
                    color: AppColors.secondaryTextColor,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                32.verticalSpace,

                // Refresh Button
                Obx(() {
                  final isChecking = networkController.isChecking.value;
                  return GestureDetector(
                    onTap: isChecking
                        ? null
                        : () => networkController.checkConnectionManually(),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        gradient: isChecking
                            ? null
                            : const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                        color: isChecking ? const Color(0xFF94A3B8) : null,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          if (!isChecking)
                            BoxShadow(
                              color: const Color(0xFF2563EB)
                                  .withValues(alpha: 0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isChecking) ...[
                            SizedBox(
                              width: 18.r,
                              height: 18.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            ),
                            10.horizontalSpace,
                            Text(
                              'Checking Connection...',
                              style: AppTextStyle.text16Semibold.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ] else ...[
                            const Icon(
                              CupertinoIcons.arrow_clockwise,
                              color: Colors.white,
                              size: 18,
                            ),
                            8.horizontalSpace,
                            Text(
                              'Refresh',
                              style: AppTextStyle.text16Semibold.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
