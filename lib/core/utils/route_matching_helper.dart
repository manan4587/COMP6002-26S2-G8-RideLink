import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EnRouteMatchResult {
  final bool isMatch;
  final double detourKm;
  final int detourMinutes;
  final double pickupDetourKm;
  final double dropoffDetourKm;
  final double subRouteDistanceKm;
  final double recommendedFare;
  final String matchReason;

  const EnRouteMatchResult({
    required this.isMatch,
    this.detourKm = 0.0,
    this.detourMinutes = 0,
    this.pickupDetourKm = 0.0,
    this.dropoffDetourKm = 0.0,
    this.subRouteDistanceKm = 0.0,
    this.recommendedFare = 0.0,
    this.matchReason = '',
  });

  static const noMatch = EnRouteMatchResult(isMatch: false, matchReason: 'Not along driver route');
}

class RouteMatchingHelper {
  RouteMatchingHelper._();

  static const double earthRadiusKm = 6371.0;
  static const double defaultMaxDetourKm = 5.0; // User confirmed 5km max detour

  /// Calculate distance between two points in kilometers (Haversine formula)
  static double distanceKm(LatLng p1, LatLng p2) {
    final dLat = _deg2rad(p2.latitude - p1.latitude);
    final dLng = _deg2rad(p2.longitude - p1.longitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(p1.latitude)) *
            math.cos(_deg2rad(p2.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _deg2rad(double deg) => deg * (math.pi / 180.0);

  /// Find perpendicular distance in km from point P to line segment AB
  static double distanceToSegmentKm(LatLng p, LatLng a, LatLng b) {
    final dAB = distanceKm(a, b);
    if (dAB < 0.001) return distanceKm(p, a);

    // Vector projection
    final latP = p.latitude;
    final lngP = p.longitude;
    final latA = a.latitude;
    final lngA = a.longitude;
    final latB = b.latitude;
    final lngB = b.longitude;

    final dx = latB - latA;
    final dy = lngB - lngA;

    final t = ((latP - latA) * dx + (lngP - lngA) * dy) / (dx * dx + dy * dy);

    if (t <= 0.0) return distanceKm(p, a);
    if (t >= 1.0) return distanceKm(p, b);

    final proj = LatLng(latA + t * dx, lngA + t * dy);
    return distanceKm(p, proj);
  }

  /// Calculates minimum distance from a point to an entire route polyline (or line segment if polyline empty)
  static double distanceToRouteKm(LatLng point, List<LatLng> polyline) {
    if (polyline.isEmpty) return double.infinity;
    if (polyline.length == 1) return distanceKm(point, polyline.first);

    double minDistance = double.infinity;
    for (int i = 0; i < polyline.length - 1; i++) {
      final dist = distanceToSegmentKm(point, polyline[i], polyline[i + 1]);
      if (dist < minDistance) {
        minDistance = dist;
      }
    }
    return minDistance;
  }

  /// Find fractional progress [0.0 ... 1.0] along the route closest to a point
  static double findProgressAlongRoute(LatLng point, List<LatLng> polyline) {
    if (polyline.length < 2) return 0.0;

    double totalRouteDist = 0.0;
    final List<double> segmentStartDist = [0.0];
    for (int i = 0; i < polyline.length - 1; i++) {
      totalRouteDist += distanceKm(polyline[i], polyline[i + 1]);
      segmentStartDist.add(totalRouteDist);
    }
    if (totalRouteDist < 0.001) return 0.0;

    double bestDistance = double.infinity;
    double bestProgress = 0.0;

    for (int i = 0; i < polyline.length - 1; i++) {
      final a = polyline[i];
      final b = polyline[i + 1];

      final latP = point.latitude;
      final lngP = point.longitude;
      final dx = b.latitude - a.latitude;
      final dy = b.longitude - a.longitude;
      final lenSq = dx * dx + dy * dy;

      double t = 0.0;
      if (lenSq > 0.00000001) {
        t = (((latP - a.latitude) * dx + (lngP - a.longitude) * dy) / lenSq)
            .clamp(0.0, 1.0);
      }

      final proj = LatLng(a.latitude + t * dx, a.longitude + t * dy);
      final distToP = distanceKm(point, proj);

      if (distToP < bestDistance) {
        bestDistance = distToP;
        final segDist = distanceKm(a, b);
        final distAlong = segmentStartDist[i] + t * segDist;
        bestProgress = (distAlong / totalRouteDist).clamp(0.0, 1.0);
      }
    }

    return bestProgress;
  }

  /// Evaluates whether a passenger's pickup and drop-off points form an en-route match along the driver's route
  static EnRouteMatchResult evaluateEnRouteMatch({
    required LatLng driverOrigin,
    required LatLng driverDestination,
    List<LatLng>? driverPolyline,
    required LatLng passengerPickup,
    required LatLng passengerDropoff,
    double driverFullSeatPrice = 20.0,
    double maxDetourKm = defaultMaxDetourKm,
  }) {
    // Construct simplified polyline if full polyline is not cached
    final route = (driverPolyline != null && driverPolyline.length >= 2)
        ? driverPolyline
        : [driverOrigin, driverDestination];

    // 1. Check pickup proximity to route corridor
    final pickupDetour = distanceToRouteKm(passengerPickup, route);
    if (pickupDetour > maxDetourKm) {
      return EnRouteMatchResult(
        isMatch: false,
        matchReason: 'Pickup is ${(pickupDetour).toStringAsFixed(1)} km away (max allowed is ${maxDetourKm.toStringAsFixed(0)} km)',
      );
    }

    // 2. Check dropoff proximity to route corridor
    final dropoffDetour = distanceToRouteKm(passengerDropoff, route);
    if (dropoffDetour > maxDetourKm) {
      return EnRouteMatchResult(
        isMatch: false,
        matchReason: 'Drop-off is ${(dropoffDetour).toStringAsFixed(1)} km away (max allowed is ${maxDetourKm.toStringAsFixed(0)} km)',
      );
    }

    // 3. Directionality check: Pickup must precede drop-off along the route
    final pickupProgress = findProgressAlongRoute(passengerPickup, route);
    final dropoffProgress = findProgressAlongRoute(passengerDropoff, route);

    if (dropoffProgress <= pickupProgress + 0.02) {
      return const EnRouteMatchResult(
        isMatch: false,
        matchReason: 'Travel direction does not match driver route orientation',
      );
    }

    // 4. Calculate total detour distance
    final totalDetourKm = (pickupDetour + dropoffDetour);
    final detourMins = math.max(1, (totalDetourKm * 2.2).round());

    // 5. Calculate recommended sub-route fare proportional to distance
    final fullDriverDistance = distanceKm(driverOrigin, driverDestination);
    final subRouteDistance = distanceKm(passengerPickup, passengerDropoff);

    double fareFraction = 1.0;
    if (fullDriverDistance > 1.0) {
      fareFraction = (subRouteDistance / fullDriverDistance).clamp(0.25, 1.0);
    }

    // Round recommended fare to nearest integer AUD (minimum $5)
    final recommendedFare = math.max(
      5.0,
      ((driverFullSeatPrice * fareFraction)).roundToDouble(),
    );

    return EnRouteMatchResult(
      isMatch: true,
      detourKm: totalDetourKm,
      detourMinutes: detourMins,
      pickupDetourKm: pickupDetour,
      dropoffDetourKm: dropoffDetour,
      subRouteDistanceKm: subRouteDistance,
      recommendedFare: recommendedFare,
      matchReason: 'En-route match • ~${detourMins}m detour',
    );
  }
}

