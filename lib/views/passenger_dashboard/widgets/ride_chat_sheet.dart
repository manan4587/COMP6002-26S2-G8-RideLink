import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/chat_service.dart';
import 'package:ridelink/theme/app_text_style.dart';

class MessageItem {
  final String text;
  final bool isMe;
  final String time;

  MessageItem({required this.text, required this.isMe, required this.time});
}

class RideChatSheet extends StatefulWidget {
  final String driverName;
  final String? tripId;

  const RideChatSheet({
    super.key,
    required this.driverName,
    this.tripId,
  });

  static void show(
    BuildContext context, {
    required String driverName,
    String? tripId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RideChatSheet(
        driverName: driverName,
        tripId: tripId,
      ),
    );
  }

  @override
  State<RideChatSheet> createState() => _RideChatSheetState();
}

class _RideChatSheetState extends State<RideChatSheet> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _sub;
  final List<MessageItem> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    final tripId = widget.tripId;
    if (tripId == null || tripId.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    _sub = ChatService.instance.streamTripChatMessages(tripId).listen((list) {
      final myUid = AuthService.instance.currentUser?.uid;
      final loaded = list.map((m) {
        final isMe =
            m.senderRole == 'passenger' || (myUid != null && m.senderId == myUid);
        final hour = m.timestamp.hour.toString().padLeft(2, '0');
        final minute = m.timestamp.minute.toString().padLeft(2, '0');
        return MessageItem(
          text: m.message,
          isMe: isMe,
          time: '$hour:$minute',
        );
      }).toList();

      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(loaded);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }, onError: (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final user = AuthService.instance.currentUser;
    final senderId = user?.uid ?? 'passenger_demo';
    final senderName =
        Preferences.userName.isNotEmpty ? Preferences.userName : 'Passenger';

    setState(() {
      _messages.add(
        MessageItem(
          text: text,
          isMe: true,
          time: 'Just now',
        ),
      );
      _msgController.clear();
    });
    _scrollToBottom();

    final tripId = widget.tripId;
    if (tripId != null && tripId.isNotEmpty) {
      ChatService.instance.sendTripChatMessage(
        tripId: tripId,
        senderId: senderId,
        senderName: senderName,
        senderRole: 'passenger',
        message: text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
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
          SizedBox(height: 12.h),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: const Color(0xFFEFF6FF),
                  child: Text(
                    widget.driverName.trim().isNotEmpty
                        ? widget.driverName.trim()[0].toUpperCase()
                        : 'D',
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
                      Text(widget.driverName, style: AppTextStyle.text16Semibold),
                      Text(
                        'Online • Assigned Driver',
                        style: AppTextStyle.text10Medium.copyWith(
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(CupertinoIcons.xmark_circle_fill),
                  color: AppColors.secondaryTextColor,
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.borderColor, height: 1),

          // Messages List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryColor,
                    ),
                  )
                : _messages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.chat_bubble_2,
                                size: 40.sp,
                                color: AppColors.secondaryTextColor,
                              ),
                              8.verticalSpace,
                              Text(
                                'No messages yet',
                                style: AppTextStyle.text14Semibold,
                              ),
                              4.verticalSpace,
                              Text(
                                'Send a message to coordinate with ${widget.driverName}.',
                                textAlign: TextAlign.center,
                                style: AppTextStyle.text12Regular.copyWith(
                                  color: AppColors.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        itemCount: _messages.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment:
                      msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isMe
                          ? AppColors.primaryColor
                          : AppColors.containerFillColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.r),
                        topRight: Radius.circular(16.r),
                        bottomLeft: Radius.circular(msg.isMe ? 16.r : 4.r),
                        bottomRight: Radius.circular(msg.isMe ? 4.r : 16.r),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: msg.isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: AppTextStyle.text14Medium.copyWith(
                            color: msg.isMe
                                ? Colors.white
                                : AppColors.primaryTextColor,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          msg.time,
                          style: AppTextStyle.text10Medium.copyWith(
                            color: msg.isMe
                                ? Colors.white70
                                : AppColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input Field
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.borderColor)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: AppColors.containerFillColor,
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: TextField(
                        controller: _msgController,
                        decoration: InputDecoration(
                          hintText: 'Type message to driver...',
                          hintStyle: AppTextStyle.text14Regular.copyWith(
                            color: AppColors.hintTextColor,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: AppTextStyle.text14Medium,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
