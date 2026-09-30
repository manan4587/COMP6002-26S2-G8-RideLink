import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_assets.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/auth_flow/auth_controller.dart';
import 'package:ridelink/widgets/app_border_container.dart';
import 'package:ridelink/widgets/app_button.dart';
import 'package:ridelink/widgets/app_main_container.dart';

class EmailVerificationView extends GetView<AuthController> {
  const EmailVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBgColor,
      body: AppMainContainer(
        alignment: AlignmentGeometry.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Navigation Bar
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      CupertinoIcons.back,
                      size: 22.sp,
                      color: AppColors.primaryTextColor,
                    ),
                    splashRadius: 22.r,
                  ),
                ),

                8.verticalSpace,

                // Animated / Styled Mail Hero Badge
                Container(
                  height: 100.h,
                  width: 100.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.borderColor,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.12),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    height: 68.h,
                    width: 68.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDBEAFE),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.mark_email_unread_rounded,
                      size: 36.sp,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),

                18.verticalSpace,

                // Title & Subtitle
                Text(
                  'Verify Your Email',
                  style: AppTextStyle.text24Semibold.copyWith(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),

                6.verticalSpace,

                Text(
                  'We have sent a confirmation link to',
                  style: AppTextStyle.text14Regular.copyWith(
                    color: AppColors.secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                10.verticalSpace,

                // Highlighted User Email Chip
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryTextColor.withValues(
                          alpha: 0.03,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 16.sp,
                        color: AppColors.primaryColor,
                      ),
                      8.horizontalSpace,
                      Flexible(
                        child: Text(
                          controller.emailController.text.isNotEmpty
                              ? controller.emailController.text
                              : 'your email address',
                          style: AppTextStyle.text14Semibold.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                22.verticalSpace,

                // Instructions & Live Waiting Card
                AppBorderContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 18.h,
                  ),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live Status Banner
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.containerFillColor,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor,
                              ),
                            ),
                          ),
                          10.horizontalSpace,
                          Expanded(
                            child: Text(
                              'Listening for email confirmation...',
                              style: AppTextStyle.text12Semibold.copyWith(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    16.verticalSpace,

                    // Steps
                    _VerificationStep(
                      stepNumber: '1',
                      icon: Icons.inbox_rounded,
                      title: 'Check your Inbox',
                      text:
                          'Look for an email from RideLink with your verification link.',
                    ),
                    12.verticalSpace,
                    _VerificationStep(
                      stepNumber: '2',
                      icon: Icons.touch_app_rounded,
                      title: 'Tap Confirm Link',
                      text:
                          'Click the verification link inside the email to activate your account.',
                    ),
                    12.verticalSpace,
                    _VerificationStep(
                      stepNumber: '3',
                      icon: Icons.check_circle_outline_rounded,
                      title: 'Confirm and Continue',
                      text:
                          'Return to RideLink and tap the verification button below.',
                    ),

                    16.verticalSpace,

                    // Spam Folder Alert Note
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF9C3),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: const Color(0xFFFDE047),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16.sp,
                            color: const Color(0xFFA16207),
                          ),
                          8.horizontalSpace,
                          Expanded(
                            child: Text(
                              "Can't find the email? Please check your Spam or Promotions folder.",
                              style: AppTextStyle.text12Medium.copyWith(
                                color: const Color(0xFFA16207),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                20.verticalSpace,

                // Primary Action Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Obx(
                    () => AppButton(
                      onPressed: controller.onEmailVerified,
                      label: "I've Verified My Email",
                      isLoading: controller.isCheckingVerification.value,
                      icon: AppAssets.checkIcon,
                    ),
                  ),
                ),

                16.verticalSpace,

                // Resend Email Section
                Obx(() {
                  final countdown = controller.resendEmailCountdown.value;
                  final isResending = controller.isResendingEmail.value;

                  if (isResending) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor,
                            ),
                          ),
                        ),
                        8.horizontalSpace,
                        Text(
                          'Resending email...',
                          style: AppTextStyle.text14Medium.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the email? ",
                        style: AppTextStyle.text14Medium.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      if (countdown > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.containerFillColor,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'Resend in ${countdown}s',
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: controller.onResendEmail,
                          child: Text(
                            'Resend Email',
                            style: AppTextStyle.text14Semibold.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,

                              decorationColor: AppColors.primaryColor,
                            ),
                          ),
                        ),
                    ],
                  );
                }),

                14.verticalSpace,

                // Change Email Link
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 14.sp,
                          color: AppColors.secondaryTextColor,
                        ),
                        6.horizontalSpace,
                        Text(
                          'Change email address',
                          style: AppTextStyle.text12Medium.copyWith(
                            color: AppColors.secondaryTextColor,

                            decorationColor: AppColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                16.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerificationStep extends StatelessWidget {
  const _VerificationStep({
    required this.stepNumber,
    required this.icon,
    required this.title,
    required this.text,
  });

  final String stepNumber;
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26.w,
          height: 26.h,
          decoration: const BoxDecoration(
            color: Color(0xFFDBEAFE),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            stepNumber,
            style: AppTextStyle.text12Semibold.copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        12.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyle.text14Semibold.copyWith(
                  color: AppColors.primaryTextColor,
                ),
              ),
              2.verticalSpace,
              Text(
                text,
                style: AppTextStyle.text12Regular.copyWith(
                  color: AppColors.secondaryTextColor,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
