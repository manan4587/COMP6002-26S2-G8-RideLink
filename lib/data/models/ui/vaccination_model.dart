class VaccinationModal {
  final String title;
  final String subtitle;
  final String? smallSubtitle;
  final String image;
  final String prize;
  final String actualPrice;

  VaccinationModal({
    required this.title,
    required this.subtitle,
    this.smallSubtitle,
    required this.image,
    required this.prize,
    required this.actualPrice,
  });
}
