import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  double bottomPadding([double value = 0]) {
    return MediaQuery.of(this).padding.bottom + value;
  }

  double topPadding([double value = 0]) {
    return MediaQuery.of(this).padding.top + value;
  }
}
