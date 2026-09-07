import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// Function to wrap a child widget with shimmer effect based on condition
Widget shimmerWrapper({
  required Widget child,
  Color? baseColor,
  Color? highlightColor,
  bool showShimmer = true,
}) {
  if (showShimmer) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey.shade300,
      highlightColor:
          highlightColor ?? Colors.grey.withAlpha((255.0 * .2).round()),
      child: child,
    );
  } else {
    return child;
  }
}

// Function to create a shimmer container with optional parameters
Widget shimmerContainer({
  double? height,
  double? width,
  BorderRadiusGeometry? borderRadius,
  Widget? child,
  Decoration? decoration,
}) =>
    Container(
      height: height,
      width: width,
      decoration: decoration ??
          BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(8.0),
            color: Colors.grey,
          ),
      child: child,
    );
