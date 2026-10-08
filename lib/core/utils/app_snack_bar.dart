import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';

class AppSnackBar {
  const AppSnackBar._();

  /// Retained for backwards compatibility with any root setup.
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static OverlayEntry? _currentEntry;

  static void _show({
    required String message,
    required Color backgroundColor,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    void Function()? onPress,
    String? buttonText,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    if (message.trim().isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTopBanner(
        message: message,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        icon: icon,
        iconColor: iconColor,
        onPress: onPress,
        buttonText: buttonText,
        duration: duration,
      );
    });
  }

  static void _showTopBanner({
    required String message,
    required Color backgroundColor,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    void Function()? onPress,
    String? buttonText,
    required Duration duration,
  }) {
    // Dismiss any existing top banner cleanly
    _removeCurrent();

    final overlayState =
        Get.key.currentState?.overlay ??
        (Get.overlayContext != null
            ? Overlay.maybeOf(Get.overlayContext!)
            : null);

    if (overlayState == null) return;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: _TopBannerWidget(
              message: message,
              backgroundColor: backgroundColor,
              borderColor: borderColor,
              icon: icon,
              iconColor: iconColor,
              onPress: onPress,
              buttonText: buttonText,
              duration: duration,
              onDismissed: () {
                if (_currentEntry == entry) {
                  _removeCurrent();
                }
              },
            ),
          ),
        );
      },
    );

    _currentEntry = entry;
    overlayState.insert(entry);
  }

  static void _removeCurrent() {
    try {
      _currentEntry?.remove();
    } catch (_) {}
    _currentEntry = null;
  }

  static void success({
    required String message,
    void Function()? onPress,
    String? buttonText,
  }) {
    _show(
      message: message,
      backgroundColor: const Color(0xFFEAF8EA),
      borderColor: const Color(0xFF32BC32),
      icon: CupertinoIcons.check_mark_circled_solid,
      iconColor: const Color(0xFF15803D),
      onPress: onPress,
      buttonText: buttonText,
    );
  }

  static void info({
    required String message,
    void Function()? onPress,
    String? buttonText,
  }) {
    _show(
      message: message,
      backgroundColor: const Color(0xFFEDF7FF),
      borderColor: const Color(0xFF47AFFF),
      icon: CupertinoIcons.info_circle_fill,
      iconColor: const Color(0xFF0284C7),
      onPress: onPress,
      buttonText: buttonText,
    );
  }

  static void warning({
    required String message,
    void Function()? onPress,
    String? buttonText,
  }) {
    _show(
      message: message,
      backgroundColor: const Color(0xFFFFF8E5),
      borderColor: const Color(0xFFFFB600),
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFD97706),
      onPress: onPress,
      buttonText: buttonText,
    );
  }

  static void error({
    required String message,
    void Function()? onPress,
    String? buttonText,
  }) {
    _show(
      message: message,
      backgroundColor: const Color(0xFFFFEBEA),
      borderColor: const Color(0xFFFF3A30),
      icon: CupertinoIcons.clear_circled_solid,
      iconColor: const Color(0xFFDC2626),
      onPress: onPress,
      buttonText: buttonText,
    );
  }
}

class _TopBannerWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final void Function()? onPress;
  final String? buttonText;
  final Duration duration;
  final VoidCallback onDismissed;

  const _TopBannerWidget({
    required this.message,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    this.onPress,
    this.buttonText,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_TopBannerWidget> createState() => _TopBannerWidgetState();
}

class _TopBannerWidgetState extends State<_TopBannerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curve = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.1),
      end: Offset.zero,
    ).animate(curve);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curve);

    _animController.forward();

    _dismissTimer = Timer(widget.duration, () {
      _dismiss();
    });
  }

  void _dismiss() {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    _dismissTimer?.cancel();
    _animController.reverse().then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Dismissible(
              key: const Key('top_snack_bar_dismissible'),
              direction: DismissDirection.up,
              onDismissed: (_) {
                _dismissTimer?.cancel();
                widget.onDismissed();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: widget.borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: widget.iconColor, size: 22.sp),
                    12.horizontalSpace,
                    Expanded(
                      child: Text(
                        widget.message,
                        style: AppTextStyle.text13Medium.copyWith(
                          color: AppColors.primaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (widget.onPress != null &&
                        widget.buttonText != null) ...[
                      8.horizontalSpace,
                      GestureDetector(
                        onTap: () {
                          _dismiss();
                          widget.onPress!();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          child: Text(
                            widget.buttonText!,
                            style: AppTextStyle.text13Semibold.copyWith(
                              color: widget.iconColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
