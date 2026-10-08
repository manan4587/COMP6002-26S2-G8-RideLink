import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/data/services/support_service.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class PassengerSupportChatPage extends StatefulWidget {
  final PassengerSupportTicketModel? ticket;

  const PassengerSupportChatPage({super.key, this.ticket});

  @override
  State<PassengerSupportChatPage> createState() =>
      _PassengerSupportChatPageState();
}

class _PassengerSupportChatPageState extends State<PassengerSupportChatPage> {
  final PassengerDashboardController controller =
      Get.find<PassengerDashboardController>();

  late final PassengerSupportTicketModel ticket;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _ticketStreamSub;

  final List<String> _quickSupportReplies = [
    'Checking booking status',
    'Payment inquiry update',
    'Thank you for the quick help!',
    'Please review my query',
    'All resolved, thank you',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.ticket != null) {
      ticket = widget.ticket!;
    } else if (Get.arguments is PassengerSupportTicketModel) {
      ticket = Get.arguments as PassengerSupportTicketModel;
    } else if (controller.supportTickets.isNotEmpty) {
      ticket = controller.supportTickets.first;
    } else {
      ticket = PassengerSupportTicketModel(
        id: 'ticket_general',
        subject: 'General Support',
        category: 'Account & Safety',
        message: 'Welcome to RideLink Support.',
        status: 'Open',
        createdAt: DateTime.now(),
      );
    }

    _ticketStreamSub =
        SupportService.instance.streamSupportTicket(ticket.id).listen((data) {
      if (data == null) return;
      if (data['status'] != null) {
        ticket.status.value =
            PassengerSupportTicketModel.normalizeStatus(data['status'].toString());
      } else if (data['isLocked'] == true) {
        ticket.status.value = 'Resolved';
      }
      final rawMsgs = data['messages'] as List<dynamic>?;
      if (rawMsgs != null && rawMsgs.isNotEmpty) {
        final parsed = rawMsgs.map((m) {
          return PassengerSupportChatMessageModel(
            id: m['id']?.toString() ?? 'm_0',
            senderRole: m['senderRole']?.toString() ?? 'passenger',
            senderName: m['senderName']?.toString() ?? '',
            message: m['message']?.toString() ?? '',
            timestamp: DateTime.tryParse(m['timestamp']?.toString() ?? '') ??
                DateTime.now(),
          );
        }).toList();
        ticket.messages.assignAll(parsed);
      }
    });
  }

  @override
  void dispose() {
    _ticketStreamSub?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? quickText]) {
    final text = (quickText ?? _messageController.text).trim();
    if (text.isEmpty) return;

    if (ticket.isLocked) return;

    controller.sendSupportChatMessage(ticketId: ticket.id, text: text);

    if (quickText == null) {
      _messageController.clear();
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.back,
            color: AppColors.primaryTextColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.primaryColor,
                  size: 20.sp,
                ),
              ),
            ),
            10.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RideLink Support',
                    style: AppTextStyle.text16Semibold.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  2.verticalSpace,
                  Text(
                    '${ticket.id} • ${ticket.category}',
                    style: AppTextStyle.text12Regular.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Obx(() {
            final isResolved = ticket.isLocked;
            return Container(
              margin: EdgeInsets.only(right: 14.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: isResolved
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isResolved
                      ? const Color(0xFF86EFAC)
                      : const Color(0xFFBFDBFE),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isResolved) ...[
                    Icon(
                      Icons.lock_rounded,
                      size: 11.sp,
                      color: const Color(0xFF16A34A),
                    ),
                    3.horizontalSpace,
                  ],
                  Text(
                    ticket.displayStatus,
                    style: AppTextStyle.text10Medium.copyWith(
                      color: isResolved
                          ? const Color(0xFF16A34A)
                          : AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Safe Support Reminder Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              color: const Color(0xFFEFF6FF),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.info_circle_fill,
                    color: const Color(0xFF2563EB),
                    size: 16.sp,
                  ),
                  8.horizontalSpace,
                  Expanded(
                    child: Text(
                      'Live Support Thread • Admin replies are logged for quality & safety.',
                      style: AppTextStyle.text12Regular.copyWith(
                        color: const Color(0xFF1E40AF),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Message List
            Expanded(
              child: Obx(() {
                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  itemCount: ticket.messages.length,
                  itemBuilder: (context, index) {
                    final msg = ticket.messages[index];
                    final isPassenger = msg.senderRole == 'passenger';

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Align(
                        alignment: isPassenger
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.76,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: isPassenger
                                  ? AppColors.primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16.r),
                                topRight: Radius.circular(16.r),
                                bottomLeft: Radius.circular(
                                  isPassenger ? 16.r : 4.r,
                                ),
                                bottomRight: Radius.circular(
                                  isPassenger ? 4.r : 16.r,
                                ),
                              ),
                              border: isPassenger
                                  ? null
                                  : Border.all(
                                      color: const Color(0xFFE2E8F0),
                                      width: 1,
                                    ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isPassenger
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (!isPassenger) ...[
                                  Text(
                                    'RideLink Admin Support',
                                    style: AppTextStyle.text10Semibold.copyWith(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  4.verticalSpace,
                                ],
                                Text(
                                  msg.message,
                                  style: AppTextStyle.text14Regular.copyWith(
                                    color: isPassenger
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                    height: 1.3,
                                  ),
                                ),
                                4.verticalSpace,
                                Text(
                                  '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: AppTextStyle.text10Medium.copyWith(
                                    fontWeight: FontWeight.normal,
                                    color: isPassenger
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // Quick Support Replies Carousel (if active)
            Obx(() {
              if (ticket.isLocked) return const SizedBox.shrink();

              return Container(
                height: 42.h,
                margin: EdgeInsets.only(bottom: 8.h),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _quickSupportReplies.length,
                  separatorBuilder: (_, _) => 8.horizontalSpace,
                  itemBuilder: (context, index) {
                    final reply = _quickSupportReplies[index];
                    return ActionChip(
                      label: Text(
                        reply,
                        style: AppTextStyle.text12Semibold.copyWith(
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      backgroundColor: const Color(0xFFEFF6FF),
                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      onPressed: () => _sendMessage(reply),
                    );
                  },
                ),
              );
            }),

            // Bottom Area: Chat Bar or Locked Notice
            Obx(() {
              if (ticket.isLocked) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    border: Border(top: BorderSide(color: Color(0xFFFCA5A5))),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        color: const Color(0xFFDC2626),
                        size: 20.sp,
                      ),
                      10.horizontalSpace,
                      Expanded(
                        child: Text(
                          'This query has been marked as Resolved by Support. Further replies are disabled. Please start a new query if you need assistance.',
                          style: AppTextStyle.text11Medium.copyWith(
                            color: const Color(0xFF991B1B),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(24.r),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: TextField(
                              controller: _messageController,
                              onSubmitted: (_) => _sendMessage(),
                              style: AppTextStyle.text14Regular,
                              decoration: InputDecoration(
                                hintText: 'Message Support...',
                                hintStyle: AppTextStyle.text14Regular.copyWith(
                                  color: const Color(0xFF94A3B8),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 10.h,
                                ),
                              ),
                            ),
                          ),
                        ),
                        10.horizontalSpace,
                        GestureDetector(
                          onTap: () => _sendMessage(),
                          child: Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.paperplane_fill,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
