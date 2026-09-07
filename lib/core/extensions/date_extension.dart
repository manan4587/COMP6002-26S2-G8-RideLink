import '../utils/utils.dart';

extension DateExtension on DateTime {
  String toDate() {
    final String month = this.month >= 10
        ? this.month.toString()
        : '0${this.month}';
    final String day = this.day >= 10 ? this.day.toString() : '0${this.day}';
    return '$year-$month-$day';
  }

  int getDifference() {
    final DateTime currentDateTime = DateTime.now();
    final int days = difference(currentDateTime).inDays;
    return days;
  }

  String getDifferenceWithDayOrDays() {
    final DateTime currentDateTime = DateTime.now();
    int days = difference(currentDateTime).inDays;
    days += 1;
    return days == 1 ? '$days Day' : '$days Days';
  }

  String formatDate() {
    return Utils.changeDateFormat(date: this, outputFormat: 'dd/MM/yy');
  }

  String formatMonth() {
    return Utils.changeDateFormat(date: this, outputFormat: 'MMMM yyyy');
  }

  String formatDateForApi() {
    return Utils.changeDateFormat(date: this, outputFormat: 'yyyy-MM-dd');
  }

  String formatDateForBooking() {
    return Utils.changeDateFormat(date: this, outputFormat: 'MMM dd, yyyy');
  }
}
