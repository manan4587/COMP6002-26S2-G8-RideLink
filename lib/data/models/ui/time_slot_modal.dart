import 'package:get/get.dart';

/// single text modal
class TimeSlotModal {
  final String? title;
  final String? subtitle;
  final String? image;
  final RxBool isSelected;
  final RxBool isDisabled;
  final RxList<TimeSlotModal> subList;

  TimeSlotModal({
    this.title,
    this.subtitle,
    this.image,
    bool isSelected = false,
    bool isDisabled = false,
    List<TimeSlotModal> subList = const [],
  })  : isSelected = RxBool(isSelected),
        isDisabled = RxBool(isDisabled),
        subList = RxList(subList);
}
