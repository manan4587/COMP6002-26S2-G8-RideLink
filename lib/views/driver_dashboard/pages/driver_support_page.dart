import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_assets.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_controller.dart';
import 'package:ridelink/widgets/app_border_container.dart';
import 'package:ridelink/widgets/app_button.dart';
import 'package:ridelink/widgets/app_main_container.dart';

class DriverSupportPage extends StatefulWidget {
  const DriverSupportPage({super.key});

  @override
  State<DriverSupportPage> createState() => _DriverSupportPageState();
}

class _DriverSupportPageState extends State<DriverSupportPage> {
  final DriverDashboardController controller =
      Get.find<DriverDashboardController>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedCategory = 'Verification & Documents';

  final List<String> _categories = [
    'Verification & Documents',
    'Ride Scheduling & Routes',
    'Cash Payments & Fares',
    'Passenger Issue',
    'App Bug or Technical Support',
    'Other Inquiries',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      controller.submitSupportTicket(
        subject: _subjectController.text.trim(),
        category: _selectedCategory,
        message: _messageController.text.trim(),
      );
      _subjectController.clear();
      _messageController.clear();
    }
  }

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Navigation Bar
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        CupertinoIcons.back,
                        size: 22.sp,
                        color: AppColors.primaryTextColor,
                      ),
                      splashRadius: 22.r,
                    ),
                    Text(
                      'Help & Driver Support',
                      style: AppTextStyle.text18Semibold.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                12.verticalSpace,

                // Support Intro Banner
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.containerFillColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.mail_solid,
                          color: AppColors.primaryColor,
                          size: 18.sp,
                        ),
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contact Admin Support',
                              style: AppTextStyle.text14Semibold.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            2.verticalSpace,
                            Text(
                              'Submit your question or issue below. Our admin team stores your ticket in database and will reply to your email directly.',
                              style: AppTextStyle.text12Regular.copyWith(
                                color: AppColors.secondaryTextColor,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                18.verticalSpace,

                // Contact Support Form Card
                AppBorderContainer(
                  margin: EdgeInsets.symmetric(horizontal: 0),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 18.h,
                  ),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submit a Support Query',
                      style: AppTextStyle.text16Semibold.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    14.verticalSpace,

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Selector
                          Text(
                            'Query Category',
                            style: AppTextStyle.text14Medium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          8.verticalSpace,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedCategory,
                                items: _categories.map((c) {
                                  return DropdownMenuItem(
                                    value: c,
                                    child: Text(
                                      c,
                                      style: AppTextStyle.text14Medium,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedCategory = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),

                          14.verticalSpace,

                          // Subject Field
                          Text(
                            'Subject',
                            style: AppTextStyle.text14Medium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          8.verticalSpace,
                          TextFormField(
                            controller: _subjectController,
                            style: AppTextStyle.text14Medium,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter a subject.';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText:
                                  'e.g. Question about driver verification',
                              hintStyle: AppTextStyle.text14Regular.copyWith(
                                color: AppColors.hintTextColor,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 12.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: const BorderSide(
                                  color: AppColors.borderColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: const BorderSide(
                                  color: AppColors.borderColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),

                          14.verticalSpace,

                          // Message / Description Field
                          Text(
                            'Message Details',
                            style: AppTextStyle.text14Medium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          8.verticalSpace,
                          TextFormField(
                            controller: _messageController,
                            maxLines: 4,
                            style: AppTextStyle.text14Medium,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please provide details of your query.';
                              }
                              if (val.trim().length < 10) {
                                return 'Please provide at least 10 characters.';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText:
                                  'Explain your query clearly so admin can assist you efficiently...',
                              hintStyle: AppTextStyle.text14Regular.copyWith(
                                color: AppColors.hintTextColor,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 12.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: const BorderSide(
                                  color: AppColors.borderColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: const BorderSide(
                                  color: AppColors.borderColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),

                          20.verticalSpace,

                          AppButton(
                            onPressed: _handleSubmit,
                            label: 'Send Support Query',
                            icon: AppAssets.checkIcon,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                20.verticalSpace,

                // Ticket History Section
                Text(
                  'Submitted Queries & Tickets',
                  style: AppTextStyle.text16Semibold.copyWith(
                    color: AppColors.primaryTextColor,
                  ),
                ),
                10.verticalSpace,

                Obx(() {
                  if (controller.supportTickets.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(20.h),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Text(
                        'No support tickets submitted yet.',
                        style: AppTextStyle.text12Regular.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: controller.supportTickets.map((ticket) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 10.h),
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
                                  ticket.id,
                                  style: AppTextStyle.text12Semibold.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ticket.status == 'Resolved'
                                        ? const Color(0xFFDCFCE7)
                                        : const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    ticket.status,
                                    style: AppTextStyle.text10Medium.copyWith(
                                      color: ticket.status == 'Resolved'
                                          ? const Color(0xFF16A34A)
                                          : AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            6.verticalSpace,
                            Text(
                              ticket.subject,
                              style: AppTextStyle.text14Semibold,
                            ),
                            4.verticalSpace,
                            Text(
                              ticket.message,
                              style: AppTextStyle.text12Regular.copyWith(
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                            8.verticalSpace,
                            Row(
                              children: [
                                Icon(
                                  Icons.tag,
                                  size: 14.sp,
                                  color: AppColors.secondaryTextColor,
                                ),
                                4.horizontalSpace,
                                Text(
                                  ticket.category,
                                  style: AppTextStyle.text10Medium.copyWith(
                                    color: AppColors.secondaryTextColor,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Admin will reply via email',
                                  style: AppTextStyle.text10Medium.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }),

                20.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
