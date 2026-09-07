import 'dart:ui';

/// Home Category Model For Category List
class HomeCategoryModel {
  HomeCategoryModel({
    required this.title,
    required this.subTitle,
    required this.bgColor,
    required this.image,
    required this.route,
    this.description = '',
    this.slug,
    this.id = '',
    this.discountedAmount = 0,
    this.amount = 0,
  });

  final String title;
  final String subTitle;
  final String description;
  final Color bgColor;
  final String image;
  final String route;
  final HomeCategoryType? slug;
  final String id;
  final num discountedAmount;
  final num amount;

  HomeCategoryModel copyWith({
    String? title,
    String? subTitle,
    String? description,
    Color? bgColor,
    String? image,
    String? route,
    HomeCategoryType? slug,
    String? id,
    num? discountedAmount,
    num? amount,
  }) {
    return HomeCategoryModel(
      title: title ?? this.title,
      subTitle: subTitle ?? this.subTitle,
      description: description ?? this.description,
      bgColor: bgColor ?? this.bgColor,
      image: image ?? this.image,
      route: route ?? this.route,
      slug: slug ?? this.slug,
      id: id ?? this.id,
      discountedAmount: discountedAmount ?? this.discountedAmount,
      amount: amount ?? this.amount,
    );
  }
}

enum HomeCategoryType {
  surgery,
  checkUps,
  hospitalVisit,
  grooming,
  vaccinations,
  bloodTests,
  pharmacy,
  travelCertificate,
}

extension HomeCategoryTypeExtension on HomeCategoryType {
  String get key {
    switch (this) {
      case HomeCategoryType.surgery:
        return 'surgery';
      case HomeCategoryType.checkUps:
        return 'check-ups';
      case HomeCategoryType.hospitalVisit:
        return 'hospital-visit';
      case HomeCategoryType.grooming:
        return 'grooming';
      case HomeCategoryType.vaccinations:
        return 'vaccinations';
      case HomeCategoryType.bloodTests:
        return 'blood-tests';
      case HomeCategoryType.pharmacy:
        return 'pharmacy';
      case HomeCategoryType.travelCertificate:
        return 'travel-certificate';
    }
  }
}
