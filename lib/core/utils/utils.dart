import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../constants/app_colors.dart';
import 'color_print.dart';

/// Utility class for common functions used in Flutter development
class Utils {
  Utils._();

  static final ImagePicker _picker = ImagePicker();

  /// Set the status bar style to dark
  static void darkStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  /// Set the status bar style to light
  static void lightStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.white,
      ),
    );
  }

  /// Set the preferred screen orientation to portrait
  static Future<void> screenPortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Get the type of the device (Android or iOS)
  static String getDeviceType() => Platform.isAndroid ? 'Android' : 'iOS';

  /// Show a toast message
  static Future<void> showToast({required String message}) async {
    await Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
      textColor: Colors.white,
      backgroundColor: AppColors.primaryColor,
    );
  }

  /// Generate MD5 hash from a string
  static String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  /// Hide the keyboard
  static void hideKeyboard() {
    unawaited(SystemChannels.textInput.invokeMethod('TextInput.hide'));
  }

  /// Launches a URL
  static Future<void> launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw Exception('Could not open $url');
    }
  }

  /// Initialize platform state to get device information
  static Future<Map<String, String>> initPlatformState(String fcmToken) async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final RxString deviceId = ''.obs;
    final RxString deviceType = ''.obs;
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidDeviceInfo =
            await deviceInfoPlugin.androidInfo;
        deviceId.value = androidDeviceInfo.id;
        deviceType.value = 'Android';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
        deviceId.value = iosDeviceInfo.identifierForVendor ?? '';
        deviceType.value = 'iOS';
      }
      printData(type: 'device_id:', text: deviceId.value);
      printData(type: 'device_type:', text: deviceType.value);
    } catch (e) {
      debugPrint(e.toString());
    }

    return {'device_id': deviceId.value, 'device_type': deviceType.value};
  }

  /// Convert duration to minutes
  static String convertDurationToMinutes(String text) {
    final String data = '00:00:30';
    final List<String> splitData = data.toString().split(':');
    final int result =
        (int.parse(splitData[0].toString()) * 60) +
        int.parse(splitData[1].toString());
    int duration = result;
    if (splitData[2].toString() != '0') {
      duration = result + 1;
    }
    return '$duration Min';
  }

  /// Change date format
  static String changeDateFormat({DateTime? date, String? outputFormat}) {
    if (date != null && outputFormat != null) {
      final DateFormat formatter = DateFormat(outputFormat);
      final String formatted = formatter.format(date);
      return formatted;
    }
    return 'N/A';
  }

  /// Convert UTC date to local date
  static String utcToLocal(String utcDateTime) {
    final DateTime dateTime = DateTime.parse(utcDateTime).toLocal();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  /// Get time ago since a date
  static String timeAgoSinceDate(
    String dateString, {
    bool numericDates = true,
  }) {
    final DateTime dateUtc = DateTime.parse(dateString);
    final dateTime = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).parse(dateUtc.toString(), true);
    final DateTime date = dateTime.toLocal();
    final date2 = DateTime.now();
    final difference = date2.difference(date);

    if ((difference.inDays / 365).floor() >= 2) {
      return numericDates
          ? '${(difference.inDays / 365).floor()} Y'
          : '${(difference.inDays / 365).floor()} Years ago';
    } else if ((difference.inDays / 365).floor() >= 1) {
      return numericDates ? '1 Y' : 'Last year';
    } else if ((difference.inDays / 30).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} M';
    } else if ((difference.inDays / 30).floor() >= 1) {
      return numericDates ? '1 M' : 'Last Month';
    } else if ((difference.inDays / 7).floor() >= 2) {
      return numericDates
          ? '${(difference.inDays / 7).floor()} w'
          : '${(difference.inDays / 7).floor()} Weeks ago';
    } else if ((difference.inDays / 7).floor() >= 1) {
      return numericDates ? '1 w' : 'Last week';
    } else if (difference.inDays >= 2) {
      return numericDates
          ? '${difference.inDays} d'
          : '${difference.inDays} Days ago';
    } else if (difference.inDays >= 1) {
      return numericDates ? '1 d' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} h';
    } else if (difference.inHours >= 1) {
      return numericDates ? '1 h' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} min';
    } else if (difference.inMinutes >= 1) {
      return numericDates ? '1 min' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} sec';
    } else {
      return 'now';
    }
  }

  static Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? xFile = await _picker.pickImage(source: source);
      if (xFile != null) {
        return xFile;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // static Future<List<String>> pickMultipleImage() async {
  //   try {
  //     List<XFile> xFile = await _picker.pickMultiImage();
  //     if (xFile.isNotEmpty) {
  //       List<String> images = xFile.map((e) {
  //         String base64String = base64Encode(File(e.path).readAsBytesSync());
  //         return 'data:image/png;base64,$base64String';
  //       }).toList();
  //       return images;
  //     }
  //     return [];
  //   } catch (e) {
  //     return [];
  //   }
  // }
  //
  // static Future<Result<PlatformFile, String>> pickFile() async {
  //   try {
  //     FilePickerResult? result = await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //       allowedExtensions: ['pdf'],
  //       allowMultiple: false,
  //     );
  //
  //     if (result != null) {
  //       return Success(result.files.first);
  //     }
  //     return Failure(ErrorMessage.selectFile);
  //   } catch (e) {
  //     return Failure(ErrorMessage.selectFile);
  //   }
  // }

  static Future<String> getDownloadFolderPath() async {
    Directory? downloadDir;
    if (Platform.isAndroid) {
      downloadDir = await getDownloadsDirectory();
    } else if (Platform.isIOS) {
      downloadDir = await getApplicationDocumentsDirectory();
    }

    if (downloadDir == null) {
      throw Exception('Failed to get download folder path.');
    }

    return downloadDir.path;
  }

  static Future<String?> imageToBase64(ui.Image image) async {
    // Convert the image to PNG format
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (byteData == null) return null;

    // Convert the byte data to a list of integers
    final Uint8List pngBytes = byteData.buffer.asUint8List();

    // Encode the image bytes to base64
    final String base64Image = base64Encode(pngBytes);

    return base64Image;
  }
}
