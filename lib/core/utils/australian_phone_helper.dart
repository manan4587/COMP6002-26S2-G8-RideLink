import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';

/// Helper for Australian (+61) phone number formatting, validation, and inputs.
/// RideLink strictly operates in Australia:
/// - Country code is +61 by default across the entire app.
/// - '+' and '91' (India) are strictly disallowed.
class AustralianPhoneHelper {
  AustralianPhoneHelper._();

  static const String defaultCountryCode = '+61';
  static const String defaultCountryDigits = '61';
  static const String defaultPlaceholder = '04xx xxx xxx';
  static const String defaultSampleNumber = '+61 412 345 678';

  /// Extracts digits only from an input string.
  static String cleanDigits(String? input) {
    if (input == null) return '';
    return input.replaceAll(RegExp(r'\D'), '');
  }

  /// Checks if input contains an explicit '+' character.
  static bool containsPlus(String? input) {
    return input?.contains('+') ?? false;
  }

  /// Checks if input appears to be an Indian number (starts with +91 or 91).
  static bool isIndianNumber(String? input) {
    if (input == null) return false;
    final trimmed = input.trim();
    if (trimmed.startsWith('+91')) return true;
    final digits = cleanDigits(trimmed);
    return digits.startsWith('91');
  }

  /// Formats any valid Australian mobile number to standard international format: `+61 4xx xxx xxx`.
  /// Strips redundant leading 0 or existing +61 before formatting.
  static String formatToAustralian(String? input) {
    if (input == null || input.trim().isEmpty) return '';
    var text = input.trim();

    // Remove existing +61 prefix if present to reformat cleanly
    if (text.startsWith('+61')) {
      text = text.substring(3).trim();
    } else if (text.startsWith('61') && text.length > 9) {
      text = text.substring(2).trim();
    }

    var digits = cleanDigits(text);
    if (digits.isEmpty) return '';

    // If starting with 0 (e.g. 0412345678), remove leading 0
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    // Format 9-digit Australian mobile nicely: +61 4XX XXX XXX
    if (digits.length == 9) {
      return '+61 ${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    }

    // Fallback if not strictly 9 digits
    return '+61 $digits';
  }

  /// Converts a stored international number (`+61 412 345 678` or `+61412345678`)
  /// into a local display number for text fields where `+61` is already shown as a prefix.
  /// E.g. returns `0412 345 678`.
  static String stripToLocal(String? input) {
    if (input == null || input.trim().isEmpty) return '';
    var text = input.trim();

    if (text.startsWith('+61')) {
      text = text.substring(3).trim();
    } else if (text.startsWith('61') && text.length > 9) {
      text = text.substring(2).trim();
    }

    var digits = cleanDigits(text);
    if (digits.isEmpty) return '';

    // Remove leading 0 if present (e.g. 0469 712 617 -> 469 712 617)
    if (digits.startsWith('0')) {
      digits = digits.replaceFirst(RegExp(r'^0+'), '');
    }

    if (digits.length == 9) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    }

    return digits;
  }
}

/// A custom input formatter that:
/// 1. Denies '+' symbol (since +61 is already fixed as the prefix)
/// 2. Automatically removes leading '0' so input starts directly with '4' (e.g. 469 712 617)
/// 3. Denies numbers starting with '91' (disallows Indian country code)
/// 4. Allows only digits and spaces, capped at 9 digits (e.g. '469 712 617')
class AustralianPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    // Disallow '+'
    if (text.contains('+')) {
      return oldValue;
    }

    // Extract digits only
    String digits = text.replaceAll(RegExp(r'\D'), '');

    // Remove leading '0' automatically (e.g. '04...' becomes '4...')
    if (digits.startsWith('0')) {
      digits = digits.replaceFirst(RegExp(r'^0+'), '');
    }

    // Disallow numbers starting with 91
    if (digits.startsWith('91')) {
      return oldValue;
    }

    // Cap at 9 digits
    if (digits.length > 9) {
      digits = digits.substring(0, 9);
    }

    // Format as 3-3-3: e.g. 469 712 617
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// A standard prefix widget displaying a phone icon, `+61` badge, and divider.
class AustralianPhonePrefix extends StatelessWidget {
  final Widget? icon;

  const AustralianPhonePrefix({super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          icon!,
          8.horizontalSpace,
        ],
        Text(
          '+61',
          style: AppTextStyle.text14Medium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryTextColor,
          ),
        ),
        8.horizontalSpace,
        Container(
          height: 18.h,
          width: 1,
          color: AppColors.borderColor,
        ),
        8.horizontalSpace,
      ],
    );
  }
}

