import 'dart:convert';
import 'dart:io';

class LiveTelemetryData {
  final double temperatureC;
  final double apparentTempC;
  final int uvIndex;
  final int windSpeedKmh;
  final int windGustsKmh;
  final int airQualityIndex; // ICA (US AQI)
  final String airQualityLabel;
  final double samaipataRainMm;
  final double angosturaRainMm;
  final double sczRainMm;
  final String? lastEarthquakeTitle;
  final double? lastEarthquakeMagnitude;
  final DateTime lastUpdated;
  final bool isLive;

  const LiveTelemetryData({
    required this.temperatureC,
    required this.apparentTempC,
    required this.uvIndex,
    required this.windSpeedKmh,
    required this.windGustsKmh,
    required this.airQualityIndex,
    required this.airQualityLabel,
    required this.samaipataRainMm,
    required this.angosturaRainMm,
    required this.sczRainMm,
    this.lastEarthquakeTitle,
    this.lastEarthquakeMagnitude,
    required this.lastUpdated,
    required this.isLive,
  });

  factory LiveTelemetryData.fallback() {
    return LiveTelemetryData(
      temperatureC: 29.0,
      apparentTempC: 31.0,
      uvIndex: 7,
      windSpeedKmh: 20,
      windGustsKmh: 35,
      airQualityIndex: 58,
      airQualityLabel: 'Moderado',
      samaipataRainMm: 0.0,
      angosturaRainMm: 0.0,
      sczRainMm: 0.0,
      lastUpdated: DateTime.now(),
      isLive: false,
    );
  }
}

class RealTelemetryService {
  // URL base configurable del servidor desplegado en Render
  static String renderUrl = 'https://simar-backend.onrender.com';

  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 8);

  Future<String> _getJson(String url) async {
    final request = await _client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('HTTP Error ${response.statusCode}');
    }
    return await response.transform(utf8.decoder).join();
  }

  /// Consulta simultánea de todas las APIs reales para Santa Cruz y la cuenca del Piraí
  Future<LiveTelemetryData> fetchAllLiveTelemetry() async {
    // 0. Intento primario: Servidor SIMAR desplegado en Render
    try {
      final renderJsonStr = await _getJson('$renderUrl/api/v1/telemetry');
      final renderResp = jsonDecode(renderJsonStr);
      if (renderResp['success'] == true && renderResp['data'] != null) {
        final d = renderResp['data'];
        return LiveTelemetryData(
          temperatureC: (d['temperatureC'] as num?)?.toDouble() ?? 29.0,
          apparentTempC: (d['apparentTempC'] as num?)?.toDouble() ?? 31.0,
          uvIndex: 7,
          windSpeedKmh: (d['windSpeedKmh'] as num?)?.toInt() ?? 20,
          windGustsKmh: (d['windGustsKmh'] as num?)?.toInt() ?? 35,
          airQualityIndex: (d['airQualityIndex'] as num?)?.toInt() ?? 58,
          airQualityLabel: 'Render Server',
          samaipataRainMm: (d['samaipataRainMm'] as num?)?.toDouble() ?? 0.0,
          angosturaRainMm: 0.0,
          sczRainMm: (d['sczRainMm'] as num?)?.toDouble() ?? 0.0,
          lastUpdated: DateTime.now(),
          isLive: true,
        );
      }
    } catch (_) {
      // Si el servidor Render está en frío o sin conexión, pasamos a conexión directa
    }

    double temp = 29.0;
    double apparent = 31.0;
    int wind = 20;
    int gusts = 35;
    int uv = 7;
    double sczRain = 0.0;

    double samRain = 0.0;
    double angRain = 0.0;

    int aqi = 55;
    String aqiLabel = 'Moderado';

    String? quakeTitle;
    double? quakeMag;

    // 1. API Open-Meteo: Clima en Tiempo Real en Santa Cruz de la Sierra
    try {
      final weatherUrl =
          'https://api.open-meteo.com/v1/forecast?latitude=-17.7833&longitude=-63.2200'
          '&current=temperature_2m,apparent_temperature,precipitation,wind_speed_10m,wind_gusts_10m'
          '&hourly=uv_index&timezone=America%2FLa_Paz';
      final jsonStr = await _getJson(weatherUrl);
      final data = jsonDecode(jsonStr);

      final current = data['current'];
      if (current != null) {
        temp = (current['temperature_2m'] as num?)?.toDouble() ?? temp;
        apparent = (current['apparent_temperature'] as num?)?.toDouble() ?? apparent;
        wind = ((current['wind_speed_10m'] as num?)?.toDouble() ?? 20).round();
        gusts = ((current['wind_gusts_10m'] as num?)?.toDouble() ?? 35).round();
        sczRain = (current['precipitation'] as num?)?.toDouble() ?? 0.0;
      }

      final hourly = data['hourly'];
      if (hourly != null && hourly['uv_index'] != null) {
        final List uvs = hourly['uv_index'];
        if (uvs.isNotEmpty) {
          final nowHour = DateTime.now().hour;
          if (nowHour < uvs.length && uvs[nowHour] != null) {
            uv = ((uvs[nowHour] as num).toDouble()).round();
          }
        }
      }
    } catch (_) {}

    // 2. API Open-Meteo Air Quality: Calidad del Aire (ICA) en Vivo para Santa Cruz
    try {
      final aqiUrl =
          'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=-17.7833&longitude=-63.2200'
          '&current=us_aqi,pm10,pm2_5&timezone=America%2FLa_Paz';
      final jsonStr = await _getJson(aqiUrl);
      final data = jsonDecode(jsonStr);
      final current = data['current'];
      if (current != null && current['us_aqi'] != null) {
        aqi = (current['us_aqi'] as num).toInt();
        if (aqi <= 50) {
          aqiLabel = 'Bueno';
        } else if (aqi <= 100) {
          aqiLabel = 'Moderado';
        } else if (aqi <= 150) {
          aqiLabel = 'Dañino sensible';
        } else {
          aqiLabel = 'Dañino por Humo';
        }
      }
    } catch (_) {}

    // 3. API Open-Meteo: Lluvias en Cabecera (Samaipata y La Angostura)
    try {
      final samUrl =
          'https://api.open-meteo.com/v1/forecast?latitude=-18.1794&longitude=-63.8756'
          '&current=precipitation,rain&timezone=America%2FLa_Paz';
      final samJson = await _getJson(samUrl);
      final samData = jsonDecode(samJson);
      if (samData['current'] != null) {
        samRain = (samData['current']['precipitation'] as num?)?.toDouble() ?? 0.0;
      }

      final angUrl =
          'https://api.open-meteo.com/v1/forecast?latitude=-18.0683&longitude=-63.5042'
          '&current=precipitation,rain&timezone=America%2FLa_Paz';
      final angJson = await _getJson(angUrl);
      final angData = jsonDecode(angJson);
      if (angData['current'] != null) {
        angRain = (angData['current']['precipitation'] as num?)?.toDouble() ?? 0.0;
      }
    } catch (_) {}

    // 4. API USGS: Sismicidad Real en Bolivia (Radio de 600km de Santa Cruz)
    try {
      final quakeUrl =
          'https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson'
          '&latitude=-17.8&longitude=-63.5&maxradiuskm=600&minmagnitude=2.5&limit=1';
      final jsonStr = await _getJson(quakeUrl);
      final data = jsonDecode(jsonStr);
      final features = data['features'] as List?;
      if (features != null && features.isNotEmpty) {
        final first = features.first;
        final props = first['properties'];
        quakeMag = (props['mag'] as num?)?.toDouble();
        quakeTitle = props['place'] as String?;
      }
    } catch (_) {}

    return LiveTelemetryData(
      temperatureC: temp,
      apparentTempC: apparent,
      uvIndex: uv,
      windSpeedKmh: wind,
      windGustsKmh: gusts,
      airQualityIndex: aqi,
      airQualityLabel: aqiLabel,
      samaipataRainMm: samRain,
      angosturaRainMm: angRain,
      sczRainMm: sczRain,
      lastEarthquakeTitle: quakeTitle,
      lastEarthquakeMagnitude: quakeMag,
      lastUpdated: DateTime.now(),
      isLive: true,
    );
  }
}
