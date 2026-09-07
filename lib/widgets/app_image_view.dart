import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:ridelink/core/constants/app_assets.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/app_loader.dart';
import '../core/utils/simmer_utils.dart';

class AppImageView extends StatelessWidget {
  final String? imagePath;

  final double? height;
  final double? width;
  final BoxFit? fit;
  final Color? imageColor;
  final FilterQuality? filterQuality;
  final BlendMode? blendMode;

  final Alignment? alignment;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BoxShape? shape;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Color? borderColor;
  final double? borderWidth;

  final bool? showProgressIndicator;
  final double? indicatorSize;
  final double? indicatorStrokeWidth;

  final VoidCallback? onTap;
  final String? placeholder;

  const AppImageView({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.fit,
    this.imageColor,
    this.filterQuality,
    this.blendMode,
    this.alignment,
    this.backgroundColor,
    this.margin,
    this.padding,
    this.shape,
    this.borderRadius,
    this.boxShadow,
    this.borderColor,
    this.borderWidth,
    this.showProgressIndicator = false,
    this.indicatorSize,
    this.indicatorStrokeWidth,
    this.onTap,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        margin: margin,
        padding: padding,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.whiteTextColor,
          shape: shape ?? BoxShape.rectangle,
          borderRadius: borderRadius,
          boxShadow: boxShadow,
          border: Border.all(
            color: borderColor ?? Colors.transparent,
            width: borderWidth ?? 0,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: buildImageView(),
      ),
    );
  }

  Widget buildImageView() {
    if (imagePath != null) {
      switch (imagePath!.imageType) {
        // If image is not available then Place Holder image will show
        case ImageType.empty:
          return errorWidget();

        // If the image type is the SVG
        case ImageType.svg:
          return SvgPicture.asset(
            imagePath!,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            colorFilter: ColorFilter.mode(
              imageColor ?? Colors.transparent,
              BlendMode.srcIn,
            ),
          );

        // If the image type is the FIle
        case ImageType.file:
          return Image.file(
            File(imagePath!),
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            color: imageColor,
          );

        // If the image is in URL
        case ImageType.network:
          return CachedNetworkImage(
            imageUrl: imagePath!,
            height: height,
            width: width,
            fit: fit,
            color: imageColor,
            colorBlendMode: blendMode,
            filterQuality: filterQuality ?? FilterQuality.high,
            fadeInDuration: const Duration(milliseconds: 200),
            fadeOutDuration: const Duration(milliseconds: 200),
            placeholderFadeInDuration: const Duration(milliseconds: 200),
            progressIndicatorBuilder: (showProgressIndicator!
                ? (context, url, progress) => progressIndicatorWidget(context)
                : null),
            placeholder: (showProgressIndicator!
                ? null
                : (context, url) => placeHolderWidget()),
            errorWidget: (context, url, error) => errorWidget(),
          );

        // If the image type is the PNG
        case ImageType.png:
          return Image.asset(
            imagePath!,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            color: imageColor,
          );

        // If the image type is the Memory (Base64)
        case ImageType.memory:
          return Image.memory(
            base64Decode(imagePath!.replaceAll('data:image/png;base64,', '')),
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            color: imageColor,
          );

        // If the image type is the Assets
        default:
          return Image.asset(
            imagePath!,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            color: imageColor,
          );
      }
    }
    return errorWidget();
  }

  /// Error and Place holder image view
  Widget errorWidget() {
    if (placeholder?.imageType == ImageType.svg) {
      return SvgPicture.asset(
        placeholder ?? AppAssets.appLogo,
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        alignment: Alignment.center,
        fit: BoxFit.cover,
      );
    }
    return Image.asset(
      placeholder ?? AppAssets.appLogo,
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      alignment: Alignment.center,
      fit: BoxFit.cover,
    );
  }

  /// Place holder when image is loading
  Widget placeHolderWidget() {
    return shimmerWrapper(
      child: shimmerContainer(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        borderRadius: borderRadius,
      ),
    );
  }

  /// Progress Indicator View Widget
  Widget progressIndicatorWidget(BuildContext context) {
    return Container(
      height: height ?? double.infinity,
      width: width ?? double.infinity,
      color: Theme.of(context).iconTheme.color!.withAlpha(30),
      child: Center(child: CircularLoader(loaderSize: indicatorSize)),
    );
  }
}

/// ImageType Extension to get which type of image is coming and get his type base on image
extension ImageTypeExtension on String {
  ImageType get imageType {
    if (isEmpty) {
      return ImageType.empty;
    } else if (startsWith('http') || startsWith('https')) {
      return ImageType.network;
    } else if (endsWith('.svg')) {
      return ImageType.svg;
    } else if (startsWith('assets')) {
      return ImageType.png;
    } else if (startsWith('file: ') || isImageFileName) {
      return ImageType.file;
    } else if (startsWith('data:image/png;base64,')) {
      return ImageType.memory;
    } else {
      return ImageType.png;
    }
  }
}

enum ImageType { empty, svg, png, network, file, unknown, memory }
