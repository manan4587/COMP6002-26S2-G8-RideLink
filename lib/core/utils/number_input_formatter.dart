// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/services.dart';

class DoubleRangeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    final regex = RegExp(r'^\d*\.?\d*$');
    if (!regex.hasMatch(newValue.text)) {
      return oldValue;
    }
    final doubleValue = double.tryParse(newValue.text);
    if (doubleValue != null) {
      return newValue;
    }
    return oldValue;
  }
}
