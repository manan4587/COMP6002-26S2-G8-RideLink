import 'package:intl/intl.dart';

extension NumberFormatting on int {
  String formatNumber() {
    final format = NumberFormat("##,##,##,##0", "en_IN");
    return format.format(this);
  }
}

extension NumberDoubleFormatting on double {
  String formatNumber() {
    final format = NumberFormat("##,##,##,##0.00", "en_IN");
    return format.format(this);
  }
}

extension StringFormatting on String {
  String formatNumber() {
    final format = NumberFormat("##,##,##,##0.00", "en_IN");
    return format.format(double.parse(this));
  }

  double toDouble() {
    return double.parse(this);
  }

  num toNum() {
    return num.parse(this);
  }

  int toInt() {
    return int.parse(this);
  }
}
