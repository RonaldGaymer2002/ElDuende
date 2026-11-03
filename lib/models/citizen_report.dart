import 'package:flutter/material.dart';

enum IncidentType {
  calleInundada,
  canalRebalsado,
  subidaRio,
  socavacionDefensivo,
  focoCalor,
}

class CitizenReport {
  final String id;
  final IncidentType type;
  final String title;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final int verificationCount; // Número de vecinos que validaron
  final bool isVerifiedByTriangulation;
  final String description;
  final String? imageUrl;

  const CitizenReport({
    required this.id,
    required this.type,
    required this.title,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.verificationCount,
    required this.isVerifiedByTriangulation,
    required this.description,
    this.imageUrl,
  });

  String get typeLabel {
    switch (type) {
      case IncidentType.calleInundada:
        return 'Calle Inundada';
      case IncidentType.canalRebalsado:
        return 'Canal Rebalsado';
      case IncidentType.subidaRio:
        return 'Subida Extraordinaria de Río';
      case IncidentType.socavacionDefensivo:
        return 'Socavación de Defensivo';
      case IncidentType.focoCalor:
        return 'Foco de Incendio / Quema';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case IncidentType.calleInundada:
        return Icons.water_rounded;
      case IncidentType.canalRebalsado:
        return Icons.waves_rounded;
      case IncidentType.subidaRio:
        return Icons.flood_rounded;
      case IncidentType.socavacionDefensivo:
        return Icons.warning_rounded;
      case IncidentType.focoCalor:
        return Icons.local_fire_department_rounded;
    }
  }

  Color get typeColor {
    switch (type) {
      case IncidentType.calleInundada:
        return const Color(0xFF0284C7);
      case IncidentType.canalRebalsado:
        return const Color(0xFF2563EB);
      case IncidentType.subidaRio:
        return const Color(0xFFDC2626);
      case IncidentType.socavacionDefensivo:
        return const Color(0xFFEA580C);
      case IncidentType.focoCalor:
        return const Color(0xFFD97706);
    }
  }

  static List<CitizenReport> get mockReports => [
        CitizenReport(
          id: 'rep-01',
          type: IncidentType.canalRebalsado,
          title: 'Canal Isuto al 95% de capacidad',
          locationName: 'Canal Isuto y 3er Anillo Interno',
          latitude: -17.7690,
          longitude: -63.1950,
          timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
          verificationCount: 14,
          isVerifiedByTriangulation: true,
          description:
              'El agua casi rebalsa a la calzada. Basura atascada en la rejilla del puente peatonal.',
        ),
        CitizenReport(
          id: 'rep-02',
          type: IncidentType.calleInundada,
          title: 'Paso a Desnivel Anegado',
          locationName: 'Túnel 4to Anillo y Av. Cristo Redentor',
          latitude: -17.7490,
          longitude: -63.1720,
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
          verificationCount: 22,
          isVerifiedByTriangulation: true,
          description:
              'Vehículos parados, agua llega a media rueda. Bomberos en camino.',
        ),
        CitizenReport(
          id: 'rep-03',
          type: IncidentType.subidaRio,
          title: 'Palizada bajando a gran velocidad',
          locationName: 'Ribera de La Guardia (Sector Dragas)',
          latitude: -17.8920,
          longitude: -63.3250,
          timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
          verificationCount: 8,
          isVerifiedByTriangulation: true,
          description:
              'Río color chocolate oscuro arrastrando troncos grandes. Trabajadores evacuando maquinaria.',
        ),
      ];
}

