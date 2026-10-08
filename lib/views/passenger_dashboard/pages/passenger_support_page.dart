import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/pages/passenger_support_chat_page.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';
import 'package:ridelink/widgets/app_border_container.dart';
import 'package:ridelink/widgets/app_button.dart';
import 'package:ridelink/widgets/app_main_container.dart';

class PassengerSupportPage extends StatefulWidget {
  const PassengerSupportPage({super.key});

  @override
  State<PassengerSupportPage> createState() => _PassengerSupportPageState();
}

class _PassengerSupportPageState extends State<PassengerSupportPage> {
  final PassengerDashboardController controller =
      Get.find<PassengerDashboardController>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedCategory = 'Cash Payments & Fares';
  String _selectedStatusFilter = 'All';

  final List<String> _categories = [
    'Cash Payments & Fares',
    'Booking & Ride Scheduling',
    'Driver / Trip Issue',
    'Lost Property',
    'Account & Profile',
    'Other Inquiries',
  ];

  final RxBool _isSubmitting = false.obs;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting.value) return;
    if (_formKey.currentState?.validate() ?? false) {
      _isSubmitting.value = true;
      try {
        final newTicket = await controller.submitSupportTicket(
          subject: _subjectController.text.trim(),
          category: _selectedCategory,
          message: _messageController.text.trim(),
        );
        if (newTicket != null) {
          _subjectController.clear();
          _messageController.clear();
          // Automatically open live chat for the newly created ticket
          Get.to(() => PassengerSupportChatPage(ticket: newTicket));
        }
      } finally {
        _isSubmitting.value = false;
      }
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
                      'Help & Customer Support',
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
                              'Submit your question or issue below. Our admin team will store your ticket in database and reply to your registered email.',
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
                Text(
                  'Submit a Query',
                  style: AppTextStyle.text16Semibold.copyWith(
                    color: AppColors.primaryTextColor,
                  ),
                ),
                10.verticalSpace,

                AppBorderContainer(
                  margin: EdgeInsets.symmetric(horizontal: 0),
                  padding: EdgeInsets.all(14.w),
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: AppTextStyle.text12Medium.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                          6.verticalSpace,
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColors.secondaryTextColor,
                                ),
                                items: _categories.map((cat) {
                                  return DropdownMenuItem(
                                    value: cat,
                                    child: Text(
                                      cat,
                                      style: AppTextStyle.text14Medium,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedCategory = val);
                                  }
                                },
                              ),
                            ),
                          ),

                          14.verticalSpace,

                          Text(
                            'Subject',
                            style: AppTextStyle.text12Medium.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                          6.verticalSpace,
                          TextFormField(
                            controller: _subjectController,
                            decoration: InputDecoration(
                              hintText: 'Brief summary of your query',
                              hintStyle: AppTextStyle.text14Regular.copyWith(
                                color: AppColors.hintTextColor,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
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
                            ),
                            style: AppTextStyle.text14Medium,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter a subject';
                              }
                              return null;
                            },
                          ),

                          14.verticalSpace,

                          Text(
                            'Detailed Message',
                            style: AppTextStyle.text12Medium.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                          6.verticalSpace,
                          TextFormField(
                            controller: _messageController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText:
                                  'Explain your query in detail. Include date, route, or driver details if applicable.',
                              hintStyle: AppTextStyle.text14Regular.copyWith(
                                color: AppColors.hintTextColor,
                              ),
                              contentPadding: EdgeInsets.all(12.w),
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
                            ),
                            style: AppTextStyle.text14Medium,
                            validator: (v) {
                              if (v == null || v.trim().length < 10) {
                                return 'Please describe your query (min 10 characters)';
                              }
                              return null;
                            },
                          ),

                          18.verticalSpace,

                          Obx(() => AppButton(
                            onPressed: _handleSubmit,
                            isLoading: _isSubmitting.value,
                            label: 'Submit Ticket to Admin',
                          )),
                        ],
                      ),
                    ),
                  ],
                ),

                18.verticalSpace,

                // Ticket History Section Header + Filter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Support Ticket History',
                      style: AppTextStyle.text16Semibold.copyWith(
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    Obx(() => Text(
                          '${controller.supportTickets.length} tickets',
                          style: AppTextStyle.text12Medium.copyWith(
                            color: AppColors.secondaryTextColor,
                          ),
                        )),
                  ],
                ),
                10.verticalSpace,

                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Open', 'Resolved'].map((filter) {
                      final isSelected = _selectedStatusFilter == filter;
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: ChoiceChip(
                          label: Text(
                            filter,
                            style: AppTextStyle.text12Medium.copyWith(
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.primaryTextColor,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primaryColor,
                          backgroundColor: AppColors.white,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.borderColor,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() => _selectedStatusFilter = filter);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                12.verticalSpace,

                Obx(() {
                  final filteredTickets = controller.supportTickets.where((t) {
                    final normalizedStatus = t.displayStatus;
                    if (_selectedStatusFilter == 'All') return true;
                    if (_selectedStatusFilter == 'Resolved') return t.isLocked;
                    if (_selectedStatusFilter == 'Open') return !t.isLocked;
                    return normalizedStatus.toLowerCase() ==
                        _selectedStatusFilter
                            .toLowerCase()
                            .replaceAll('-', '_')
                            .replaceAll(' ', '_');
                  }).toList();

                  if (filteredTickets.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Center(
                        child: Text(
                          controller.supportTickets.isEmpty
                              ? 'No support queries submitted yet.'
                              : 'No $_selectedStatusFilter tickets found.',
                          style: AppTextStyle.text12Regular.copyWith(
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: filteredTickets.map((ticket) {
                      return InkWell(
                        onTap: () =>
                            Get.to(() => PassengerSupportChatPage(ticket: ticket)),
                        borderRadius: BorderRadius.circular(16.r),
                        child: Container(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    ticket.id,
                                    style:
                                        AppTextStyle.text12Semibold.copyWith(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  Obx(() {
                                    final isResolved = ticket.isLocked;
                                    final Color badgeBg = isResolved
                                        ? const Color(0xFFDCFCE7)
                                        : const Color(0xFFEFF6FF);
                                    final Color badgeTextColor = isResolved
                                        ? const Color(0xFF16A34A)
                                        : AppColors.primaryColor;
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 3.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: badgeBg,
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (isResolved) ...[
                                            Icon(
                                              Icons.lock_rounded,
                                              size: 11.sp,
                                              color: badgeTextColor,
                                            ),
                                            3.horizontalSpace,
                                          ],
                                          Text(
                                            isResolved ? 'Resolved' : 'Open',
                                            style: AppTextStyle.text10Medium
                                                .copyWith(
                                              color: badgeTextColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
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
                                  height: 1.35,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              10.verticalSpace,
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
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor
                                          .withValues(alpha: 0.08),
                                      borderRadius:
                                          BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          CupertinoIcons.chat_bubble_2_fill,
                                          size: 13.sp,
                                          color: AppColors.primaryColor,
                                        ),
                                        5.horizontalSpace,
                                        Obx(() => Text(
                                              ticket.isLocked
                                                  ? 'View Closed Chat'
                                                  : 'Open Chat',
                                              style: AppTextStyle
                                                  .text11Semibold
                                                  .copyWith(
                                                color: AppColors.primaryColor,
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),

                24.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
