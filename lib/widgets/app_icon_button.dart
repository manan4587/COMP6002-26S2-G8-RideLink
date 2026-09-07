import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ridelink/core/constants/app_assets.dart';

import '../core/constants/app_colors.dart';

class AppIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final String icon;
  final Color iconColor;

  const AppIconButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.iconColor = AppColors.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(
          icon == AppAssets.notificationIcon ? 12.w : 10.w,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.stroke),
        ),
        child: SvgPicture.asset(
          icon,
          height: 20.h,
          width: 20.w,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
      ),
    );
  }
}
