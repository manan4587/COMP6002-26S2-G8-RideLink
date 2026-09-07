import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Custom scroll behavior class that modifies scrolling behavior based on the platform.
class ScrollBehaviorModified extends CupertinoScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Check platform and return appropriate scroll physics
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // For iOS, return BouncingScrollPhysics
      return const BouncingScrollPhysics();
    } else {
      // For other platforms, return CustomScrollPhysics
      return CustomScrollPhysics();
    }
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return StretchingOverscrollIndicator(
      axisDirection: details.direction,
      child: child,
    );
  }
}

/// Custom scroll physics class for non-iOS platforms.
class CustomScrollPhysics extends ClampingScrollPhysics {
  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    // Override createBallisticSimulation to customize scroll physics
    final Tolerance tolerance = toleranceFor(position);
    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      // For Android and other platforms, use BouncingScrollSimulation
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity,
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: tolerance,
      );
    }
    return null;
  }
}
