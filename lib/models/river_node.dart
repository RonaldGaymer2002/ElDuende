import 'package:flutter/material.dart';

enum SwimmingSafetyVerdict {
  safe, // Apto para nadar y familia (Caudal bajo <0.6m y 0% lluvia cabeceras)
  weatherTrap, // Prohibido entrar al agua hoy (Llovió en cuenca alta)
  deadlyZoneYearRound, // Zona mortal prohibida todo el año (Dragas, remolinos pilotes)
  emergencyTurbion, // Alerta roja turbión - evacuación inmediata
}

class RiverNode {
  final String id;
  final String name;
  final String municipality;
  final String description;
  final double latitude;
  final double longitude;
  final double normalizedX; // Coordenada X relativa en el lienzo 2D (0.0 - 1.0)
  final double normalizedY; // Coordenada Y relativa en el lienzo 2D (0.0 - 1.0)
  final bool isPermanentlyForbidden;
  final String? forbiddenReason;
  final double baselineLevelMeters;
  final double currentLevelMeters;
  final double currentFlowSpeedMps; // Metros por segundo
  final double upstreamRainIntensity; // 0.0 a 1.0
  final SwimmingSafetyVerdict safetyVerdict;
  final int transitOrder; // 1 = Cabecera (Samaipata), 6 = Cuenca Baja
  final double distanceToNextKm;
  final int etaMinutesFromCabecera; // Tiempo estimado que tarda la onda en llegar

  const RiverNode({
    required this.id,
    required this.name,
    required this.municipality,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.normalizedX,
    required this.normalizedY,
    required this.isPermanentlyForbidden,
    this.forbiddenReason,
    required this.baselineLevelMeters,
    required this.currentLevelMeters,
    required this.currentFlowSpeedMps,
    required this.upstreamRainIntensity,
    required this.safetyVerdict,
    required this.transitOrder,
    required this.distanceToNextKm,
    required this.etaMinutesFromCabecera,
  });

  RiverNode copyWith({
    double? currentLevelMeters,
    double? currentFlowSpeedMps,
    double? upstreamRainIntensity,
    SwimmingSafetyVerdict? safetyVerdict,
  }) {
    return RiverNode(
      id: id,
      name: name,
      municipality: municipality,
      description: description,
      latitude: latitude,
      longitude: longitude,
      normalizedX: normalizedX,
      normalizedY: normalizedY,
      isPermanentlyForbidden: isPermanentlyForbidden,
      forbiddenReason: forbiddenReason,
      baselineLevelMeters: baselineLevelMeters,
      currentLevelMeters: currentLevelMeters ?? this.currentLevelMeters,
      currentFlowSpeedMps: currentFlowSpeedMps ?? this.currentFlowSpeedMps,
      upstreamRainIntensity: upstreamRainIntensity ?? this.upstreamRainIntensity,
      safetyVerdict: safetyVerdict ?? this.safetyVerdict,
      transitOrder: transitOrder,
      distanceToNextKm: distanceToNextKm,
      etaMinutesFromCabecera: etaMinutesFromCabecera,
    );
  }

  Color get statusColor {
    switch (safetyVerdict) {
      case SwimmingSafetyVerdict.safe:
        return const Color(0xFF10B981); // Esmeralda seguro
      case SwimmingSafetyVerdict.weatherTrap:
        return const Color(0xFFF59E0B); // Ámbar trampa climática
      case SwimmingSafetyVerdict.deadlyZoneYearRound:
        return const Color(0xFFEF4444); // Rojo zona mortal dragas/puente
      case SwimmingSafetyVerdict.emergencyTurbion:
        return const Color(0xFFDC2626); // Rojo crítico turbión
    }
  }

  String get verdictBadgeText {
    switch (safetyVerdict) {
      case SwimmingSafetyVerdict.safe:
        return '🟢 APTO PARA BAÑISTAS';
      case SwimmingSafetyVerdict.weatherTrap:
        return '🟡 PROHIBIDO BAÑARSE HOY';
      case SwimmingSafetyVerdict.deadlyZoneYearRound:
        return '⛔ ZONA MORTAL PERMANENTE';
      case SwimmingSafetyVerdict.emergencyTurbion:
        return '🚨 EVACUACIÓN INMEDIATA';
    }
  }

  /// Nodos canónicos de la cuenca del Río Piraí en Santa Cruz de la Sierra
  static List<RiverNode> get canonicalNodes => [
        const RiverNode(
          id: 'samaipata',
          name: 'Samaipata / Bermejo',
          municipality: 'Florida / Valles Cruceños',
          description:
              'Cabecera de cuenca alta del Piraí. Las lluvias aquí originan los turbiones que bajan a la llanura.',
          latitude: -18.1794,
          longitude: -63.8756,
          normalizedX: 0.22,
          normalizedY: 0.14,
          isPermanentlyForbidden: false,
          baselineLevelMeters: 0.40,
          currentLevelMeters: 0.45,
          currentFlowSpeedMps: 0.8,
          upstreamRainIntensity: 0.0,
          safetyVerdict: SwimmingSafetyVerdict.safe,
          transitOrder: 1,
          distanceToNextKm: 34.0,
          etaMinutesFromCabecera: 0,
        ),
        const RiverNode(
          id: 'angostura',
          name: 'La Angostura',
          municipality: 'El Torno',
          description:
              'Estación limnimétrica clave SEARPI. Encajonamiento de cordillera; mide la crecida inicial.',
          latitude: -18.0683,
          longitude: -63.5042,
          normalizedX: 0.35,
          normalizedY: 0.29,
          isPermanentlyForbidden: false,
          baselineLevelMeters: 0.50,
          currentLevelMeters: 0.55,
          currentFlowSpeedMps: 1.1,
          upstreamRainIntensity: 0.0,
          safetyVerdict: SwimmingSafetyVerdict.safe,
          transitOrder: 2,
          distanceToNextKm: 22.0,
          etaMinutesFromCabecera: 65,
        ),
        const RiverNode(
          id: 'espejillos',
          name: 'Espejillos / El Torno',
          municipality: 'El Torno',
          description:
              'Destino ecoturístico de pozas cristalinas y cascadas. Peligro de quedar atrapado por subidas repentinas.',
          latitude: -17.9625,
          longitude: -63.3980,
          normalizedX: 0.48,
          normalizedY: 0.44,
          isPermanentlyForbidden: false,
          baselineLevelMeters: 0.35,
          currentLevelMeters: 0.40,
          currentFlowSpeedMps: 0.6,
          upstreamRainIntensity: 0.0,
          safetyVerdict: SwimmingSafetyVerdict.safe,
          transitOrder: 3,
          distanceToNextKm: 18.0,
          etaMinutesFromCabecera: 130,
        ),
        const RiverNode(
          id: 'dragas',
          name: 'La Guardia - Sector Dragas',
          municipality: 'La Guardia',
          description:
              'Zona industrial de extracción de áridos con dragas mecánicas. Trampa mortal de pozas ciegas.',
          latitude: -17.8920,
          longitude: -63.3250,
          normalizedX: 0.60,
          normalizedY: 0.59,
          isPermanentlyForbidden: true,
          forbiddenReason:
              'Pozas ciegas artificiales de más de 4 metros de profundidad con lodos succionantes. Prohibido el baño todo el año sin excepción.',
          baselineLevelMeters: 0.60,
          currentLevelMeters: 0.65,
          currentFlowSpeedMps: 1.4,
          upstreamRainIntensity: 0.0,
          safetyVerdict: SwimmingSafetyVerdict.deadlyZoneYearRound,
          transitOrder: 4,
          distanceToNextKm: 15.0,
          etaMinutesFromCabecera: 185,
        ),
        const RiverNode(
          id: 'cabanas',
          name: 'Cabañas del Río Piraí',
          municipality: 'Santa Cruz de la Sierra (Fin del 4to Anillo)',
          description:
              'Patrimonio cultural, gastronómico y recreativo tradicional de la familia cruceña en el margen derecho.',
          latitude: -17.7833,
          longitude: -63.2200,
          normalizedX: 0.72,
          normalizedY: 0.73,
          isPermanentlyForbidden: false,
          baselineLevelMeters: 0.45,
          currentLevelMeters: 0.50,
          currentFlowSpeedMps: 0.7,
          upstreamRainIntensity: 0.0,
          safetyVerdict: SwimmingSafetyVerdict.safe,
          transitOrder: 5,
          distanceToNextKm: 9.0,
          etaMinutesFromCabecera: 240,
        ),
        const RiverNode(
          id: 'puente_urubo',
          name: 'Puente Mario Foianini / Urubó',
          municipality: 'Santa Cruz - Porongo (Cuatro Ojos)',
          description:
              'Puente metropolitano y defensivos fluviales con espigones y pilotes de alta velocidad.',
          latitude: -17.7600,
          longitude: -63.2100,
          normalizedX: 0.83,
          normalizedY: 0.86,
          isPermanentlyForbidden: true,
          forbiddenReason:
              'Estructuras de espigones y pilotes de puente generan remolinos de fondo con efecto vórtice de succión. Zona prohibida para bañistas los 365 días.',
          baselineLevelMeters: 0.70,
          currentLevelMeters: 0.75,
          currentFlowSpeedMps: 1.6,
          upstreamRainIntensity: 0.0,
          safetyVerdict: SwimmingSafetyVerdict.deadlyZoneYearRound,
          transitOrder: 6,
          distanceToNextKm: 0.0,
          etaMinutesFromCabecera: 285,
        ),
      ];
}

