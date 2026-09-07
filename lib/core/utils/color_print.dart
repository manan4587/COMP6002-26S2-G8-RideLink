// ignore_for_file: type_annotate_public_apis, strict_top_level_inference

import 'dart:io';

import 'package:flutter/material.dart';

/// Prints text in red color.
void printRed(text) => _printColoredMessage(text, '\x1B[91m');

/// Prints text in green color.
void printGreen(text) => _printColoredMessage(text, '\x1B[92m');

/// Prints text in yellow color.
void printYellow(text) => _printColoredMessage(text, '\x1B[93m');

/// Prints text in blue color.
void printBlue(text) => _printColoredMessage(text, '\x1B[94m');

/// Prints text in purple color.
void printPurple(text) => _printColoredMessage(text, '\x1B[95m');

/// Prints text in white color.
void printWhite(text) => _printColoredMessage(text, '\x1B[97m');

/// Prints an error message with specified type.
void printError({required type, required text}) =>
    _printColoredMessage('$type: $text', '\x1B[51m\x1B[91m');

/// Prints a general message with specified type.
void printMessage({required type, required text}) =>
    _printColoredMessage('$type: $text', '\x1B[51m\x1B[96m');

/// Prints data with specified type.
void printData({required type, required text}) =>
    _printColoredMessage('$type:\n$text', '\x1B[7m');

/// Internal function to print colored messages based on platform.
void _printColoredMessage(text, String colorCode) {
  if (Platform.isAndroid) {
    debugPrint('$colorCode$text\x1B[0m', wrapWidth: 99999);
  } else {
    debugPrint(text.toString(), wrapWidth: 99999);
  }
}
