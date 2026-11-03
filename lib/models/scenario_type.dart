import 'package:flutter/material.dart';

enum FlameVisualState {
  recreationalGreen, // Agua azul cristalina, flujo suave, sol radiante
  weatherTrapYellow, // Nubes negras arriba en Samaipata/Angostura, río cambiando a greda
  turbionRed, // Cauce ensanchado, agua marrón greda turbulenta, palizada, sirena
  seismicPurple, // Temblor de cámara (CameraShake), ondas sísmicas expansivas
  extremeHeatAndSmoke, // Filtro cálido, ondas térmicas, partículas de humo/ceniza ICA alto
}

enum GovRiskScenario {
  swimmingDay, // 1. Push Día de Natación (Verde)
  forbiddenZoneAlert, // 2. Push Alerta de Zona Prohibida (Naranja)
  climateTrap, // 3. Push Trampa Climática (Amarillo)
  redTurbion, // 4. Push Alerta Roja de Turbión (Rojo)
  urbanFlood, // 5. Push Inundación Urbana y Canales (Azul/Rojo)
  seismicAlert, // 6. Push Alerta Sísmica (Morado)
  extremeHeat, // 7. Push 'La Calor' y Golpe de Calor (Naranja)
  droughtSmokeSurazo, // 8. Push Sequía, Surazo y Humo (Gris)
}

class ScenarioMetadata {
  final GovRiskScenario scenario;
  final String title;
  final String shortCode;
  final String pushTitle;
  final String pushMessage;
  final Color primaryColor;
  final IconData icon;
  final FlameVisualState visualState;
  final double temperatureC;
  final int uvIndex;
  final int airQualityIndex; // ICA
  final int windSpeedKmh;
  final String windDirection;
  final bool soundAlert;

  const ScenarioMetadata({
    required this.scenario,
    required this.title,
    required this.shortCode,
    required this.pushTitle,
    required this.pushMessage,
    required this.primaryColor,
    required this.icon,
    required this.visualState,
    required this.temperatureC,
    required this.uvIndex,
    required this.airQualityIndex,
    required this.windSpeedKmh,
    required this.windDirection,
    this.soundAlert = false,
  });

  static Map<GovRiskScenario, ScenarioMetadata> get allScenarios => {
        GovRiskScenario.swimmingDay: const ScenarioMetadata(
          scenario: GovRiskScenario.swimmingDay,
          title: 'Día de Natación y Familia',
          shortCode: 'NAT-01',
          pushTitle: '☀️ ¡Día perfecto de río en familia!',
          pushMessage:
              '¡Hoy el Río Piraí está bajo (0.4m) y cristalino! Cero lluvias en Samaipata. Excelente tarde para ir en familia a Espejillos o las Cabañas.',
          primaryColor: Color(0xFF10B981), // Verde Esmeralda
          icon: Icons.pool_rounded,
          visualState: FlameVisualState.recreationalGreen,
          temperatureC: 31.0,
          uvIndex: 7,
          airQualityIndex: 38,
          windSpeedKmh: 14,
          windDirection: 'Norte',
        ),
        GovRiskScenario.forbiddenZoneAlert: const ScenarioMetadata(
          scenario: GovRiskScenario.forbiddenZoneAlert,
          title: 'Peligro en Zona Prohibida',
          shortCode: 'DRAG-02',
          pushTitle: '⛔ ¡ALERTA: Zona de Dragas / Pilotes!',
          pushMessage:
              '¡Peligro! Estás cerca de una zona de Dragas / Puente Urubó. Prohibido nadar incluso con río bajo: riesgo mortal de pozas profundas y remolinos.',
          primaryColor: Color(0xFFF97316), // Naranja Advertencia
          icon: Icons.warning_amber_rounded,
          visualState: FlameVisualState.recreationalGreen,
          temperatureC: 32.5,
          uvIndex: 8,
          airQualityIndex: 45,
          windSpeedKmh: 18,
          windDirection: 'Noroeste',
          soundAlert: true,
        ),
        GovRiskScenario.climateTrap: const ScenarioMetadata(
          scenario: GovRiskScenario.climateTrap,
          title: 'Trampa Climática (Alerta de Cabecera)',
          shortCode: 'TRAP-03',
          pushTitle: '⚠️ ¡SAL DEL AGUA AHORA! Trampa Climática',
          pushMessage:
              '¡Sal del agua! Aunque hace sol de 35°C en Santa Cruz, cayó tormenta en La Angostura. El caudal subirá de golpe a las 16:30.',
          primaryColor: Color(0xFFEAB308), // Amarillo Alerta
          icon: Icons.thunderstorm_rounded,
          visualState: FlameVisualState.weatherTrapYellow,
          temperatureC: 35.0,
          uvIndex: 10,
          airQualityIndex: 52,
          windSpeedKmh: 28,
          windDirection: 'Sur',
          soundAlert: true,
        ),
        GovRiskScenario.redTurbion: const ScenarioMetadata(
          scenario: GovRiskScenario.redTurbion,
          title: 'Alerta Roja de Turbión (SEARPI)',
          shortCode: 'TURB-04',
          pushTitle: '🚨 ALERTA ROJA SEARPI: Crecida Extraordinaria',
          pushMessage:
              'ALERTA ROJA SEARPI: Turbión de 3.8m pasó por El Torno. Llegará a La Guardia en 35 min y al Puente Urubó en 1h 40m. Evacúe riberas inmediatamente.',
          primaryColor: Color(0xFFEF4444), // Rojo Crítico
          icon: Icons.flood_rounded,
          visualState: FlameVisualState.turbionRed,
          temperatureC: 24.0,
          uvIndex: 2,
          airQualityIndex: 40,
          windSpeedKmh: 45,
          windDirection: 'Sur',
          soundAlert: true,
        ),
        GovRiskScenario.urbanFlood: const ScenarioMetadata(
          scenario: GovRiskScenario.urbanFlood,
          title: 'Inundación Urbana y Canales',
          shortCode: 'URB-05',
          pushTitle: '🌊 Alerta Pluvial: Canales y Desniveles Rebalsados',
          pushMessage:
              'Lluvia torrencial en la ciudad: Canal Isuto al 95% y Paso a Desnivel del 4to Anillo inundado. Tome rutas alternas altas.',
          primaryColor: Color(0xFF0EA5E9), // Azul Pluvial
          icon: Icons.water_damage_rounded,
          visualState: FlameVisualState.turbionRed,
          temperatureC: 22.0,
          uvIndex: 1,
          airQualityIndex: 25,
          windSpeedKmh: 35,
          windDirection: 'Sur',
          soundAlert: true,
        ),
        GovRiskScenario.seismicAlert: const ScenarioMetadata(
          scenario: GovRiskScenario.seismicAlert,
          title: 'Alerta Sísmica (Falla Subandina)',
          shortCode: 'SIS-06',
          pushTitle: '🟣 ALERTA SÍSMICA DETECTADA: Magnitud 4.7',
          pushMessage:
              'Sismo de magnitud 4.7 detectado a 36 km (Samaipata/Valles). Si está en un edificio alto, aléjese de ventanas, no use ascensores y evacúe con calma.',
          primaryColor: Color(0xFF8B5CF6), // Morado Sísmico
          icon: Icons.vibration_rounded,
          visualState: FlameVisualState.seismicPurple,
          temperatureC: 28.0,
          uvIndex: 6,
          airQualityIndex: 48,
          windSpeedKmh: 12,
          windDirection: 'Calma',
          soundAlert: true,
        ),
        GovRiskScenario.extremeHeat: const ScenarioMetadata(
          scenario: GovRiskScenario.extremeHeat,
          title: 'Estrés Térmico: "La Calor" y UV Extremo',
          shortCode: 'HEAT-07',
          pushTitle: '🔥 ALERTA TÉRMICA: Sensación de 42°C y UV 11+',
          pushMessage:
              'Sensación térmica de 42°C y Radiación UV 11+ (Extremo) en Santa Cruz. Hidrátate cada 30 min y evita el sol entre 11:00 y 15:00.',
          primaryColor: Color(0xFFF97316), // Naranja Fuego
          icon: Icons.wb_sunny_rounded,
          visualState: FlameVisualState.extremeHeatAndSmoke,
          temperatureC: 39.5,
          uvIndex: 12,
          airQualityIndex: 85,
          windSpeedKmh: 20,
          windDirection: 'Norte Fuerte',
        ),
        GovRiskScenario.droughtSmokeSurazo: const ScenarioMetadata(
          scenario: GovRiskScenario.droughtSmokeSurazo,
          title: 'Sequía, Surazo y Humo Crítico',
          shortCode: 'SUR-08',
          pushTitle: '💨 Vientos 70 km/h y Aire Dañino (ICA 195)',
          pushMessage:
              'Ráfagas de viento de 70 km/h y calidad del aire dañina (ICA 195) por humo e incendios. Usa barbijo al salir y no estaciones bajo árboles frondosos.',
          primaryColor: Color(0xFF64748B), // Gris Pizarra
          icon: Icons.air_rounded,
          visualState: FlameVisualState.extremeHeatAndSmoke,
          temperatureC: 18.0,
          uvIndex: 3,
          airQualityIndex: 195,
          windSpeedKmh: 70,
          windDirection: 'Surazo Frío',
          soundAlert: true,
        ),
      };
}

