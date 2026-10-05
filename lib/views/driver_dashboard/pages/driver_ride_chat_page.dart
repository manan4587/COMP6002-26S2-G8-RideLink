import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/preferences.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/trip_service.dart';
import 'package:ridelink/theme/app_text_style.dart';

class DriverChatMessage {
  final String text;
  final bool isMe; // true if driver sent it
  final String time;

  DriverChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}

class DriverRideChatPage extends StatefulWidget {
  final String? tripId;
  final String? passengerName;
  final String? route;
  final String? passengerPhone;

  const DriverRideChatPage({
    super.key,
    this.tripId,
    this.passengerName,
    this.route,
    this.passengerPhone,
  });

  @override
  State<DriverRideChatPage> createState() => _DriverRideChatPageState();
}

class _DriverRideChatPageState extends State<DriverRideChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late String _tripId;
  late String _passengerName;
  late String _route;
  late String _passengerPhone;

  StreamSubscription? _chatSubscription;

  final List<DriverChatMessage> _messages = [];
  bool _isLoading = true;

  final List<String> _quickReplies = [
    'I have arrived at the pickup spot',
    'Arriving in 2 minutes',
    'White Toyota Camry (1AB-2CD)',
    'Waiting with hazard lights on',
    'All set, ready to go!',
  ];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _tripId = widget.tripId ?? args?['tripId'] ?? 'trip_general';
    _passengerName =
        widget.passengerName ?? args?['passengerName'] ?? 'Passenger';
    _route = widget.route ?? args?['route'] ?? 'Trip Route';
    _passengerPhone =
        widget.passengerPhone ?? args?['passengerPhone'] ?? '';

    _subscribeToTripChat();
  }

  void _subscribeToTripChat() {
    if (_tripId.isEmpty || _tripId == 'trip_general') {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    _chatSubscription =
        TripService.instance.streamTripChatMessages(_tripId).listen((list) {
      final myUid = AuthService.instance.currentUser?.uid;
      final loaded = list.map((m) {
        final isMe =
            m.senderRole == 'driver' || (myUid != null && m.senderId == myUid);
        final hour = m.timestamp.hour.toString().padLeft(2, '0');
        final minute = m.timestamp.minute.toString().padLeft(2, '0');
        return DriverChatMessage(
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
    final driverUid = user?.uid ?? 'driver_demo';
    final driverName = Preferences.userName.isNotEmpty
        ? Preferences.userName
        : 'Driver';

    setState(() {
      _messages.add(
        DriverChatMessage(text: text, isMe: true, time: 'Just now'),
      );
      if (quickText == null) {
        _messageController.clear();
      }
    });

    _scrollToBottom();

    // Send to Firestore subcollection `rides/{tripId}/messages`
    if (_tripId.isNotEmpty && _tripId != 'trip_general') {
      TripService.instance.sendTripChatMessage(
        tripId: _tripId,
        senderId: driverUid,
        senderName: driverName,
        senderRole: 'driver',
        message: text,
      );
    }
  }

  Future<void> _callPassenger() async {
    try {
      await Utils.launchURL('tel:$_passengerPhone');
    } catch (_) {
      AppSnackBar.info(
        message: 'Dialing passenger $_passengerName at $_passengerPhone...',
      );
    }
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
                child: Text(
                  _passengerName.isNotEmpty ? _passengerName[0] : 'P',
                  style: AppTextStyle.text16Semibold.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            10.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _passengerName,
                    style: AppTextStyle.text16Semibold.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  2.verticalSpace,
                  Text(
                    'Carpool Passenger • $_route',
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
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(7.r),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.phone_fill,
                color: Color(0xFF2563EB),
                size: 18,
              ),
            ),
            onPressed: _callPassenger,
          ),
          10.horizontalSpace,
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Safe Ride Reminder Banner
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
                      'Trip in progress • Keep messages clear & brief while driving.',
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryColor,
                      ),
                    )
                  : _messages.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 64.r,
                                    height: 64.r,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFDBEAFE),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.chat_bubble_2_fill,
                                      color: Color(0xFF2563EB),
                                      size: 30,
                                    ),
                                  ),
                                  14.verticalSpace,
                                  Text(
                                    'No messages yet',
                                    style: AppTextStyle.text16Semibold.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  6.verticalSpace,
                                  Text(
                                    'Coordinate pickup with $_passengerName. Tap any quick reply below or type a message.',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyle.text12Regular.copyWith(
                                      color: const Color(0xFF64748B),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Align(
                      alignment: msg.isMe
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
                            color: msg.isMe
                                ? AppColors.primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.r),
                              topRight: Radius.circular(16.r),
                              bottomLeft: Radius.circular(
                                msg.isMe ? 16.r : 4.r,
                              ),
                              bottomRight: Radius.circular(
                                msg.isMe ? 4.r : 16.r,
                              ),
                            ),
                            border: msg.isMe
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
                            crossAxisAlignment: msg.isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.text,
                                style: AppTextStyle.text14Regular.copyWith(
                                  color: msg.isMe
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                  height: 1.3,
                                ),
                              ),
                              4.verticalSpace,
                              Text(
                                msg.time,
                                style: AppTextStyle.text10Medium.copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: msg.isMe
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
              ),
            ),

            // Driver Quick Replies Carousel
            Container(
              height: 42.h,
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _quickReplies.length,
                separatorBuilder: (_, _) => 8.horizontalSpace,
                itemBuilder: (context, index) {
                  final reply = _quickReplies[index];
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
            ),

            // Text Input Field
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Message $_passengerName...',
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
            ),
          ],
        ),
      ),
    );
  }
}
