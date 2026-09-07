import 'package:get/get.dart';

class AppModal {
  final String? title;
  final String? subtitle;
  final String? image;
  final RxBool isSelected;
  final List<AppModal>? subList;

  AppModal({
    this.title,
    this.subtitle,
    this.image,
    bool isSelected = false,
    this.subList,
  }) : isSelected = RxBool(isSelected);
}
