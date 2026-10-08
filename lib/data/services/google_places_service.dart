import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridelink/data/handler/api_endpoints_url.dart';

class PlacePrediction {
  final String placeId;
  final String fullText;
  final String primaryText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.fullText,
    required this.primaryText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final prediction = json['placePrediction'] ?? {};
    final structured = prediction['structuredFormat'] ?? {};
    final textObj = prediction['text'] ?? {};

    return PlacePrediction(
      placeId: prediction['placeId'] ?? '',
      fullText: textObj['text'] ?? '',
      primaryText: structured['mainText']?['text'] ?? textObj['text'] ?? '',
      secondaryText: structured['secondaryText']?['text'] ?? '',
    );
  }
}

class PlaceDetails {
  final String placeId;
  final String formattedAddress;
  final String displayName;
  final double latitude;
  final double longitude;

  PlaceDetails({
    required this.placeId,
    required this.formattedAddress,
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    final displayNameObj = json['displayName'] ?? {};

    return PlaceDetails(
      placeId: json['id'] ?? '',
      formattedAddress: json['formattedAddress'] ?? '',
      displayName: displayNameObj['text'] ?? json['formattedAddress'] ?? '',
      latitude: (location['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (location['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class GooglePlacesService {
  GooglePlacesService._();
  static final GooglePlacesService instance = GooglePlacesService._();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  String get _apiKey => APIKeys.map;

  /// Search places autocomplete using Google Places API (New)
  Future<List<PlacePrediction>> searchPlaces(String input) async {
    final query = input.trim();
    if (query.length < 2) return [];

    try {
      final response = await _dio.post(
        'https://places.googleapis.com/v1/places:autocomplete',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': _apiKey,
          },
        ),
        data: {
          'input': query,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final suggestions = response.data['suggestions'] as List<dynamic>? ?? [];
        return suggestions
            .map((item) => PlacePrediction.fromJson(item as Map<String, dynamic>))
            .where((p) => p.placeId.isNotEmpty)
            .toList();
      }
    } catch (_) {
      // In case of any network timeout or network offline
    }
    return [];
  }

  /// Fetch coordinates & formatted address for a selected place
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    if (placeId.isEmpty) return null;

    try {
      final response = await _dio.get(
        'https://places.googleapis.com/v1/places/$placeId',
        queryParameters: {
          'fields': 'id,displayName,location,formattedAddress',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': _apiKey,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return PlaceDetails.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  /// Geocode free-text address to coordinates using Google Geocoding API
  Future<PlaceDetails?> getCoordinatesForAddress(String address) async {
    final query = address.trim();
    if (query.isEmpty) return null;

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'address': query,
          'key': _apiKey,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final results = response.data['results'] as List<dynamic>? ?? [];
        if (results.isNotEmpty) {
          final first = results.first as Map<String, dynamic>;
          final geom = first['geometry']?['location'] ?? {};
          final lat = (geom['lat'] as num?)?.toDouble() ?? 0.0;
          final lng = (geom['lng'] as num?)?.toDouble() ?? 0.0;
          final formatted = first['formatted_address']?.toString() ?? query;
          final placeId = first['place_id']?.toString() ?? '';

          if (lat != 0.0 || lng != 0.0) {
            return PlaceDetails(
              placeId: placeId,
              formattedAddress: formatted,
              displayName: formatted,
              latitude: lat,
              longitude: lng,
            );
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Reverse geocode coordinates to a readable address string using Google Geocoding API
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    if (lat == 0.0 && lng == 0.0) return null;
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '$lat,$lng',
          'key': _apiKey,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final results = response.data['results'] as List<dynamic>? ?? [];
        if (results.isNotEmpty) {
          // 1. Search for high-precision building/street level address (ignoring plus codes)
          for (final item in results) {
            final map = item as Map<String, dynamic>;
            final formatted = map['formatted_address']?.toString() ?? '';
            final types = (map['types'] as List<dynamic>?)
                    ?.map((t) => t.toString())
                    .toList() ??
                [];
            final locationType =
                map['geometry']?['location_type']?.toString() ?? '';

            // Skip compound plus codes (e.g., "7JVW+88 Surat, Gujarat")
            final isPlusCode =
                RegExp(r'^[A-Z0-9]{4,8}\+[A-Z0-9]{2,4}').hasMatch(formatted);
            if (isPlusCode) continue;

            if (locationType == 'ROOFTOP' ||
                locationType == 'RANGE_INTERPOLATED' ||
                types.contains('street_address') ||
                types.contains('premise') ||
                types.contains('subpremise') ||
                types.contains('route') ||
                types.contains('point_of_interest') ||
                types.contains('establishment')) {
              return formatted;
            }
          }

          // 2. Fallback: first non-plus-code formatted address
          for (final item in results) {
            final formatted =
                (item as Map<String, dynamic>)['formatted_address']?.toString() ??
                    '';
            final isPlusCode =
                RegExp(r'^[A-Z0-9]{4,8}\+[A-Z0-9]{2,4}').hasMatch(formatted);
            if (!isPlusCode && formatted.isNotEmpty) {
              return formatted;
            }
          }

          // 3. Fallback to first available result
          final first = results.first as Map<String, dynamic>;
          final formatted = first['formatted_address']?.toString();
          if (formatted != null && formatted.isNotEmpty) {
            return formatted;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Validate that coordinates are non-zero and within valid global lat/lng ranges
  bool isValidCoordinate(LatLng? loc) {
    if (loc == null) return false;
    if (loc.latitude == 0.0 && loc.longitude == 0.0) return false;
    if (loc.latitude < -90.0 ||
        loc.latitude > 90.0 ||
        loc.longitude < -180.0 ||
        loc.longitude > 180.0) {
      return false;
    }
    return true;
  }

  /// Fetch road route polyline from Google Routes API (v2) or Directions API
  Future<List<LatLng>> getDirectionsRoute(
    LatLng origin,
    LatLng destination,
  ) async {
    if (!isValidCoordinate(origin) || !isValidCoordinate(destination)) {
      return [];
    }

    // 1. Try Google Routes API (v2:computeRoutes)
    try {
      final response = await _dio.post(
        'https://routes.googleapis.com/directions/v2:computeRoutes',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask':
                'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
          },
        ),
        data: {
          'origin': {
            'location': {
              'latLng': {
                'latitude': origin.latitude,
                'longitude': origin.longitude,
              },
            },
          },
          'destination': {
            'location': {
              'latLng': {
                'latitude': destination.latitude,
                'longitude': destination.longitude,
              },
            },
          },
          'travelMode': 'DRIVE',
          'routingPreference': 'TRAFFIC_UNAWARE',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final routes = response.data['routes'] as List<dynamic>? ?? [];
        if (routes.isNotEmpty) {
          final encoded = routes.first['polyline']?['encodedPolyline'] as String?;
          if (encoded != null && encoded.isNotEmpty) {
            final decoded = decodePolyline(encoded);
            if (decoded.isNotEmpty) {
              return decoded;
            }
          }
        }
      }
    } catch (_) {}

    // 2. Fallback to legacy Directions API if enabled
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'mode': 'driving',
          'key': _apiKey,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final routes = response.data['routes'] as List<dynamic>? ?? [];
        if (routes.isNotEmpty) {
          final overviewPolyline =
              routes.first['overview_polyline']?['points'] as String?;
          if (overviewPolyline != null && overviewPolyline.isNotEmpty) {
            final decoded = decodePolyline(overviewPolyline);
            if (decoded.isNotEmpty) {
              return decoded;
            }
          }
        }
      }
    } catch (_) {}

    // 3. Fallback: Interpolate smooth road corridor waypoints between origin and destination
    return _generateCorridorWaypoints(origin, destination);
  }

  /// Interpolate smooth road corridor waypoints between origin and destination
  List<LatLng> _generateCorridorWaypoints(LatLng start, LatLng end) {
    if (!isValidCoordinate(start) || !isValidCoordinate(end)) {
      return [];
    }
    const int segments = 8;
    final List<LatLng> points = [start];
    for (int i = 1; i < segments; i++) {
      final double fraction = i / segments;
      final double lat = start.latitude + (end.latitude - start.latitude) * fraction;
      final double lng = start.longitude + (end.longitude - start.longitude) * fraction;
      points.add(LatLng(lat, lng));
    }
    points.add(end);
    return points;
  }

  /// Decode Google encoded polyline string into List of LatLng
  static List<LatLng> decodePolyline(String encoded) {
    final List<LatLng> poly = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }
}

