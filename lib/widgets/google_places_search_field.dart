import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/data/services/google_places_service.dart';
import 'package:ridelink/theme/app_text_style.dart';

class GooglePlacesSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String label;
  final Color labelColor;
  final ValueChanged<PlaceDetails>? onPlaceSelected;
  final Widget? trailing;
  final bool readOnly;
  final bool enabled;
  final String? fixedBadgeText;

  const GooglePlacesSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.label,
    required this.labelColor,
    this.onPlaceSelected,
    this.trailing,
    this.readOnly = false,
    this.enabled = true,
    this.fixedBadgeText,
  });

  @override
  State<GooglePlacesSearchField> createState() =>
      _GooglePlacesSearchFieldState();
}

class _GooglePlacesSearchFieldState extends State<GooglePlacesSearchField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _debounce;
  final List<PlacePrediction> _predictions = [];
  bool _isLoading = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (widget.readOnly || !widget.enabled) {
        _hideOverlay();
        return;
      }
      if (!_focusNode.hasFocus) {
        _hideOverlay();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _hideOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String val) {
    if (widget.readOnly || !widget.enabled) return;
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final input = val.trim();
      if (input.length < 2) {
        _hideOverlay();
        return;
      }

      setState(() => _isLoading = true);
      final results = await GooglePlacesService.instance.searchPlaces(input);
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _predictions.clear();
        _predictions.addAll(results);
      });

      if (_predictions.isNotEmpty && _focusNode.hasFocus) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
  }

  void _showOverlay() {
    _hideOverlay();
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4.h),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(14.r),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 220.h),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                shrinkWrap: true,
                itemCount: _predictions.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  color: Color(0xFFF1F5F9),
                ),
                itemBuilder: (context, index) {
                  final prediction = _predictions[index];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 2.h,
                    ),
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    title: Text(
                      prediction.primaryText,
                      style: AppTextStyle.text12Semibold.copyWith(
                        color: AppColors.primaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: prediction.secondaryText.isNotEmpty
                        ? Text(
                            prediction.secondaryText,
                            style: AppTextStyle.text10Medium.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: () async {
                      widget.controller.text = prediction.primaryText;
                      _hideOverlay();
                      _focusNode.unfocus();

                      // Fetch place details (coordinates)
                      final details = await GooglePlacesService.instance
                          .getPlaceDetails(prediction.placeId);
                      if (details != null && widget.onPlaceSelected != null) {
                        widget.onPlaceSelected!(details);
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isLocked = widget.readOnly || !widget.enabled;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isLocked ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isLocked ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
            width: isLocked ? 1.2 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.label,
                  style: AppTextStyle.text10Medium.copyWith(
                    color: widget.labelColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                if (widget.fixedBadgeText != null &&
                    widget.fixedBadgeText!.isNotEmpty) ...[
                  8.horizontalSpace,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          size: 10.sp,
                          color: const Color(0xFF2563EB),
                        ),
                        4.horizontalSpace,
                        Text(
                          widget.fixedBadgeText!,
                          style: AppTextStyle.text10Medium.copyWith(
                            color: const Color(0xFF1D4ED8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                if (widget.trailing != null) ...[
                  widget.trailing!,
                  6.horizontalSpace,
                ],
                if (_isLoading)
                  SizedBox(
                    width: 12.w,
                    height: 12.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryColor,
                    ),
                  ),
              ],
            ),
            2.verticalSpace,
            TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              readOnly: widget.readOnly,
              enabled: widget.enabled,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppTextStyle.text12Regular.copyWith(
                  color: const Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 4.h),
              ),
              style: AppTextStyle.text14Medium.copyWith(
                color: isLocked
                    ? const Color(0xFF475569)
                    : AppColors.primaryTextColor,
                fontWeight: isLocked ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
