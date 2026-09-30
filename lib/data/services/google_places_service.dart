import 'package:dio/dio.dart';
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
}

