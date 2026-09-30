import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/trip_service.dart';
import 'package:ridelink/theme/app_text_style.dart';

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;

  ChatMessage({required this.text, required this.isMe, required this.time});
}

class RideChatPage extends StatefulWidget {
  final String? tripId;
  final String? driverName;
  final String? carModel;
  final String? route;

  const RideChatPage({
    super.key,
    this.tripId,
    this.driverName,
    this.carModel,
    this.route,
  });

  @override
  State<RideChatPage> createState() => _RideChatPageState();
}

class _RideChatPageState extends State<RideChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late String _tripId;
  late String _driverName;
  late String _carModel;
  late String _route;

  StreamSubscription? _chatSubscription;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hi there! I am heading towards your pickup location now.',
      isMe: false,
      time: '08:14 AM',
    ),
    ChatMessage(
      text: 'Thanks! I am waiting near the Shell station entrance.',
      isMe: true,
      time: '08:16 AM',
    ),
  ];

  final List<String> _quickReplies = [
    'I am at the pickup point',
    'Running 2 mins late',
    'Which color is your car?',
    'I see your vehicle!',
  ];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _tripId = widget.tripId ?? args?['tripId'] ?? 'trip_general';
    _driverName = widget.driverName ?? args?['driverName'] ?? 'James Miller';
    _carModel = widget.carModel ?? args?['carModel'] ?? 'Toyota Camry (White)';
    _route = widget.route ?? args?['route'] ?? 'Landsdale → Curtin University';

    _subscribeToTripChat();
  }

  void _subscribeToTripChat() {
    if (_tripId.isEmpty || _tripId == 'trip_general') return;

    _chatSubscription =
        TripService.instance.streamTripChatMessages(_tripId).listen((list) {
      if (list.isEmpty) return;

      final myUid = AuthService.instance.currentUser?.uid;
      final loaded = list.map((m) {
        final isMe = m.senderRole == 'passenger' || (myUid != null && m.senderId == myUid);
        final hour = m.timestamp.hour.toString().padLeft(2, '0');
        final minute = m.timestamp.minute.toString().padLeft(2, '0');
        return ChatMessage(
          text: m.message,
          isMe: isMe,
          time: '$hour:$minute',
        );
      }).toList();

      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(loaded);
        });
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
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

    final user = AuthService.instance.currentUser;
    final passengerUid = user?.uid ?? 'passenger_demo';
    final passengerName = Preferences.userName.isNotEmpty
        ? Preferences.userName
        : 'Passenger';

    setState(() {
      _messages.add(ChatMessage(text: text, isMe: true, time: 'Just now'));
      if (quickText == null) {
        _messageController.clear();
      }
    });

    _scrollToBottom();

    // Send to Firestore subcollection `rides/{tripId}/messages`
    if (_tripId.isNotEmpty && _tripId != 'trip_general') {
      TripService.instance.sendTripChatMessage(
        tripId: _tripId,
        senderId: passengerUid,
        senderName: passengerName,
        senderRole: 'passenger',
        message: text,
      );
    }
  }

  Future<void> _callDriver() async {
    await Utils.launchURL('tel:+61400123456');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBgColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            size: 24.sp,
            color: AppColors.primaryTextColor,
          ),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: const Color(0xFFEFF6FF),
                  child: Text(
                    _driverName.isNotEmpty ? _driverName[0] : 'D',
                    style: AppTextStyle.text16Semibold.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 11.r,
                    height: 11.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _driverName,
                    style: AppTextStyle.text16Semibold.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  2.verticalSpace,
                  Text(
                    '$_carModel • Active now',
                    style: AppTextStyle.text10Medium.copyWith(
                      fontWeight: FontWeight.normal,
                      color: AppColors.secondaryTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _callDriver,
            tooltip: 'Call Driver',
            icon: Container(
              padding: EdgeInsets.all(8.r),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.phone_fill,
                size: 18,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          10.horizontalSpace,
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Route Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                border: Border(bottom: BorderSide(color: Color(0xFFDBEAFE))),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.car_detailed,
                    size: 15,
                    color: AppColors.primaryColor,
                  ),
                  8.horizontalSpace,
                  Expanded(
                    child: Text(
                      'Trip Route: $_route',
                      style: AppTextStyle.text10Medium.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Message List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            // Quick Reply Suggestions
            Container(
              height: 42.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _quickReplies.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final reply = _quickReplies[index];
                  return GestureDetector(
                    onTap: () => _sendMessage(reply),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        reply,
                        style: AppTextStyle.text10Medium.copyWith(
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            8.verticalSpace,

            // Message Input Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.borderColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBgColor,
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: TextField(
                        controller: _messageController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Message $_driverName...',
                          hintStyle: AppTextStyle.text14Regular.copyWith(
                            color: AppColors.hintTextColor,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                  ),
                  8.horizontalSpace,
                  GestureDetector(
                    onTap: () => _sendMessage(),
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: msg.isMe ? AppColors.primaryColor : AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(msg.isMe ? 16.r : 4.r),
            bottomRight: Radius.circular(msg.isMe ? 4.r : 16.r),
          ),
          border: msg.isMe
              ? null
              : Border.all(color: AppColors.borderColor, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: msg.isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: AppTextStyle.text14Regular.copyWith(
                color: msg.isMe ? Colors.white : AppColors.primaryTextColor,
                height: 1.35,
              ),
            ),
            4.verticalSpace,
            Text(
              msg.time,
              style: TextStyle(
                fontSize: 10.sp,
                color: msg.isMe
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppColors.hintTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
