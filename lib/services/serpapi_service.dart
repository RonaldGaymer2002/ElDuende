import 'dart:convert';
import 'package:http/http.dart' as http;

class SerpApiPlaceResult {
  final String title;
  final String? placeId;
  final double? latitude;
  final double? longitude;
  final String? address;
  final double? rating;
  final int? reviews;
  final String? thumbnailUrl;
  final String? openState;

  const SerpApiPlaceResult({
    required this.title,
    this.placeId,
    this.latitude,
    this.longitude,
    this.address,
    this.rating,
    this.reviews,
    this.thumbnailUrl,
    this.openState,
  });

  factory SerpApiPlaceResult.fromJson(Map<String, dynamic> json) {
    double? lat;
    double? lng;
    if (json['gps_coordinates'] != null) {
      lat = (json['gps_coordinates']['latitude'] as num?)?.toDouble();
      lng = (json['gps_coordinates']['longitude'] as num?)?.toDouble();
    }

    return SerpApiPlaceResult(
      title: json['title'] ?? 'Lugar en Santa Cruz',
      placeId: json['place_id'],
      latitude: lat,
      longitude: lng,
      address: json['address'],
      rating: (json['rating'] as num?)?.toDouble(),
      reviews: (json['reviews'] as num?)?.toInt(),
      thumbnailUrl: json['thumbnail'],
      openState: json['open_state'],
    );
  }
}

class SerpApiService {
  // URL base configurable del backend en Render
  static String renderBackendUrl = 'https://simar-backend.onrender.com';
  static String directSerpApiUrl = 'https://serpapi.com/search';

  // API Key para conexiones directas
  static String defaultApiKey = '';

  Future<String> _getJson(String url) async {
    final response = await http.get(Uri.parse(url)).timeout(
          const Duration(seconds: 8),
        );
    if (response.statusCode != 200) {
      throw Exception('HTTP Error ${response.statusCode}');
    }
    return response.body;
  }

  /// Consulta lugares en vivo usando SerpAPI Google Maps Engine (vía Render o conexión directa)
  Future<List<SerpApiPlaceResult>> searchGoogleMapsPlaces(String query, {String? apiKey}) async {
    final keyToUse = apiKey ?? defaultApiKey;

    // 1. Intento primario: a través del servidor en Render
    try {
      final renderUrl = '$renderBackendUrl/api/v1/maps/search?q=${Uri.encodeComponent(query)}';
      final jsonStr = await _getJson(renderUrl);
      final data = jsonDecode(jsonStr);

      if (data['success'] == true && data['local_results'] != null) {
        final List list = data['local_results'];
        return list.map((item) => SerpApiPlaceResult.fromJson(item)).toList();
      }
    } catch (_) {
      // Si Render está iniciando (cold-start), pasamos a conexión directa con SerpAPI
    }

    // 2. Conexión directa a SerpAPI Google Maps Engine
    // https://serpapi.com/search?engine=google_maps&q=...
    try {
      final directUrl =
          '$directSerpApiUrl?engine=google_maps&q=${Uri.encodeComponent(query)}'
          '&hl=es&gl=bo${keyToUse.isNotEmpty ? '&api_key=$keyToUse' : ''}';

      final jsonStr = await _getJson(directUrl);
      final data = jsonDecode(jsonStr);

      final List<SerpApiPlaceResult> results = [];
      if (data['place_results'] != null) {
        results.add(SerpApiPlaceResult.fromJson(data['place_results']));
      }
      if (data['local_results'] != null) {
        final List locals = data['local_results'];
        results.addAll(locals.map((item) => SerpApiPlaceResult.fromJson(item)));
      }
      return results;
    } catch (_) {
      // Fallback local enriquecido de Santa Cruz si no hay conexión
      return _getLocalFallbackPlaces(query);
    }
  }

  List<SerpApiPlaceResult> _getLocalFallbackPlaces(String query) {
    return [
      const SerpApiPlaceResult(
        title: 'Cabañas del Río Piraí',
        address: 'Final 4to Anillo, Costanera Piraí, Santa Cruz de la Sierra',
        rating: 4.5,
        reviews: 2450,
        latitude: -17.7833,
        longitude: -63.2200,
        openState: 'Abierto hasta las 20:00',
      ),
      const SerpApiPlaceResult(
        title: 'Espejillos Balneario Natural',
        address: 'Municipio El Torno, 42 km de Santa Cruz de la Sierra',
        rating: 4.7,
        reviews: 1120,
        latitude: -17.9625,
        longitude: -63.3980,
        openState: 'Parque Natural Ecoturístico',
      ),
      const SerpApiPlaceResult(
        title: 'Puente Mario Foianini (Urubó)',
        address: 'Conexión 4to Anillo Santa Cruz - Porongo',
        rating: 4.2,
        reviews: 890,
        latitude: -17.7600,
        longitude: -63.2100,
        openState: 'Vía pública / Prohibido bañistas',
      ),
    ];
  }
}
