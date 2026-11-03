import 'package:flutter/material.dart';
import '../../core/theme/tactical_theme.dart';
import '../../models/river_node.dart';
import '../../services/serpapi_service.dart';
import '../../state/simar_controller.dart';

class NodeSafetySheet extends StatefulWidget {
  final RiverNode node;
  final SimarController controller;
  final VoidCallback onClose;

  const NodeSafetySheet({
    super.key,
    required this.node,
    required this.controller,
    required this.onClose,
  });

  @override
  State<NodeSafetySheet> createState() => _NodeSafetySheetState();
}

class _NodeSafetySheetState extends State<NodeSafetySheet> {
  final SerpApiService _serpApiService = SerpApiService();
  SerpApiPlaceResult? _mapsPlace;
  bool _isLoadingMaps = false;

  @override
  void initState() {
    super.initState();
    _loadSerpApiData();
  }

  @override
  void didUpdateWidget(covariant NodeSafetySheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.node.id != widget.node.id) {
      _loadSerpApiData();
    }
  }

  Future<void> _loadSerpApiData() async {
    setState(() => _isLoadingMaps = true);
    try {
      final results = await _serpApiService.searchGoogleMapsPlaces(
        '${widget.node.name} Santa Cruz Bolivia',
      );
      if (mounted && results.isNotEmpty) {
        setState(() {
          _mapsPlace = results.first;
          _isLoadingMaps = false;
        });
      } else {
        if (mounted) setState(() => _isLoadingMaps = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMaps = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: const Color(0xF70F172A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: node.statusColor.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: TacticalTheme.glowShadow(node.statusColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de arrastre superior
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Encabezado con Nombre y Botón de cierre
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: node.statusColor.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: node.statusColor, width: 1.5),
                ),
                child: Icon(
                  node.isPermanentlyForbidden
                      ? Icons.dangerous_rounded
                      : (node.safetyVerdict == SwimmingSafetyVerdict.safe
                          ? Icons.pool_rounded
                          : Icons.warning_amber_rounded),
                  color: node.statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Municipio: ${node.municipality}',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: Colors.white60,
                onPressed: widget.onClose,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Veredicto Central de Seguridad
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: node.statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: node.statusColor, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.verdictBadgeText,
                  style: TextStyle(
                    color: node.statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getVerdictExplanation(node),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tarjetas de Telemetría Oficial SEARPI
          Row(
            children: [
              Expanded(
                child: _buildTelemetryMetric(
                  icon: Icons.height_rounded,
                  title: 'NIVEL DE AGUA',
                  value: '${node.currentLevelMeters.toStringAsFixed(2)} m',
                  status: node.currentLevelMeters > 1.2 ? 'Crecida' : 'Normal',
                  color: node.currentLevelMeters > 1.2
                      ? const Color(0xFFEF4444)
                      : TacticalTheme.accentCyan,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTelemetryMetric(
                  icon: Icons.speed_rounded,
                  title: 'VELOCIDAD',
                  value: '${node.currentFlowSpeedMps.toStringAsFixed(1)} m/s',
                  status: '${(node.currentFlowSpeedMps * 3.6).toStringAsFixed(0)} km/h',
                  color: node.currentFlowSpeedMps > 1.8
                      ? const Color(0xFFEF4444)
                      : TacticalTheme.accentEmerald,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTelemetryMetric(
                  icon: Icons.grain_rounded,
                  title: 'LLUVIA CABECERA',
                  value: '${(node.upstreamRainIntensity * 100).toInt()}%',
                  status: node.upstreamRainIntensity > 0.4 ? 'Tormenta' : 'Seco',
                  color: node.upstreamRainIntensity > 0.4
                      ? const Color(0xFFF59E0B)
                      : Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tarjeta de Datos Google Maps vía SerpAPI Engine
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF131D31),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x4438BDF8), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.map_rounded, color: Color(0xFF38BDF8), size: 14),
                    const SizedBox(width: 6),
                    const Text(
                      'GOOGLE MAPS (SERPAPI ENGINE: GOOGLE_MAPS)',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    if (_isLoadingMaps)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF38BDF8)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _mapsPlace?.title ?? node.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_mapsPlace?.address != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _mapsPlace!.address!,
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5),
                  ),
                ],
                if (_mapsPlace?.rating != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${_mapsPlace!.rating} (${_mapsPlace!.reviews ?? 0} opiniones en Google Maps)',
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Descripción y advertencias específicas del lugar
          Text(
            node.description,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 11.5,
              height: 1.3,
            ),
          ),
          if (node.forbiddenReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0x33EF4444),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFEF4444), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_rounded, color: Color(0xFFEF4444), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      node.forbiddenReason!,
                      style: const TextStyle(
                        color: Color(0xFFFECACA),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getVerdictExplanation(RiverNode node) {
    if (node.isPermanentlyForbidden) {
      return 'Prohibido el ingreso de bañistas todo el año. El lecho del río en este sector tiene anomalías hidráulicas artificiales o estructurales que impiden el rescate.';
    }
    switch (node.safetyVerdict) {
      case SwimmingSafetyVerdict.safe:
        return 'Caudal bajo seguro (<0.6m) y sin lluvias en Samaipata. Excelente momento para disfrutar en orilla con supervisión de niños.';
      case SwimmingSafetyVerdict.weatherTrap:
        return 'Aunque veas sol en el cielo de la ciudad, se registraron fuertes precipitaciones en la cuenca alta. El río subirá con fuerza y turbidez sin previo aviso sonoro.';
      case SwimmingSafetyVerdict.emergencyTurbion:
        return 'Onda de turbión extraordinaria en curso con palizada. Desaloje inmediatamente playas, islotes y zonas bajas del río hacia terreno alto.';
      case SwimmingSafetyVerdict.deadlyZoneYearRound:
        return 'Zona con peligro permanente de pozas y remolinos.';
    }
  }

  Widget _buildTelemetryMetric({
    required IconData icon,
    required String title,
    required String value,
    required String status,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x3338BDF8), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
