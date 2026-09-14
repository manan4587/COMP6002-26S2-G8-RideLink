import 'package:flutter/material.dart';
import 'package:ridelink/core/constants/app_colors.dart';

class AppMainContainer extends StatelessWidget {
  const AppMainContainer({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.secondaryBgColor,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: alignment,
        child: child,
      ),
    );
  }
}
