import 'package:flutter/material.dart';
import '../../core/theme/tactical_theme.dart';
import '../../state/simar_controller.dart';

class TacticalHeader extends StatelessWidget {
  final SimarController controller;
  final VoidCallback onOpenGodMode;
  final VoidCallback onOpenVigiaReport;
  final VoidCallback onOpenSosSms;

  const TacticalHeader({
    super.key,
    required this.controller,
    required this.onOpenGodMode,
    required this.onOpenVigiaReport,
    required this.onOpenSosSms,
  });

  @override
  Widget build(BuildContext context) {
    final meta = controller.activeMetadata;
    final isLive = controller.isLiveMode;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xF50B0F19),
        border: const Border(
          bottom: BorderSide(color: Color(0x3338BDF8), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Fila 1: Logo SIMAR + Indicador de APIs Reales + Switch Modo COED + Botón Modo Dios
            Row(
              children: [
                // Insignia SIMAR
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF38BDF8), width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'SIMAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Badge En Vivo vs Simulación
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isLive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isLive ? 'APIS EN VIVO (OPEN-METEO/USGS)' : 'MODO DEMO SIMULADO',
                            style: TextStyle(
                              color: isLive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        isLive ? 'Santa Cruz • Piraí • Samaipata' : 'Escenario de Jurado Activo',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 9.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Botón Volver a En Vivo si está en simulación
                if (!isLive) ...[
                  InkWell(
                    onTap: () => controller.enableLiveMode(),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF10B981), width: 1),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.sensors_rounded, color: Color(0xFF10B981), size: 12),
                          SizedBox(width: 3),
                          Text(
                            'EN VIVO',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ] else ...[
                  // Botón Refrescar APIs
                  IconButton(
                    tooltip: 'Actualizar Telemetría Real',
                    icon: controller.isLoadingLive
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF38BDF8)),
                          )
                        : const Icon(Icons.refresh_rounded, size: 16),
                    color: const Color(0xFF38BDF8),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => controller.fetchLiveTelemetry(),
                  ),
                  const SizedBox(width: 8),
                ],

                // Switch Dual: Ciudadano vs Comando COED
                InkWell(
                  onTap: () => controller.toggleCoedMode(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: controller.isCoedMode
                          ? const Color(0xFFDC2626).withOpacity(0.25)
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: controller.isCoedMode
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF475569),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.isCoedMode
                              ? Icons.admin_panel_settings_rounded
                              : Icons.person_rounded,
                          size: 13,
                          color: controller.isCoedMode
                              ? const Color(0xFFEF4444)
                              : TacticalTheme.accentCyan,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.isCoedMode ? 'COED' : 'CIUDAD',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: controller.isCoedMode
                                ? const Color(0xFFEF4444)
                                : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Botón Consola "Modo Dios"
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: onOpenGodMode,
                  icon: const Icon(Icons.flash_on_rounded, size: 14),
                  label: const Text(
                    'MODO DIOS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Fila 2: Métricas en vivo (Temperatura, UV, Ráfagas, ICA)
            Row(
              children: [
                // Estrés Térmico "La Calor" en tiempo real
                _buildMetricChip(
                  icon: Icons.thermostat_rounded,
                  iconColor: meta.temperatureC >= 33 ? const Color(0xFFF97316) : TacticalTheme.accentCyan,
                  label: 'CALOR REAL',
                  value: '${meta.temperatureC.toStringAsFixed(1)}°C',
                  sub: 'Sens ${controller.liveData?.apparentTempC.toStringAsFixed(0) ?? meta.temperatureC.toStringAsFixed(0)}°',
                ),
                const SizedBox(width: 6),

                // Radiación UV
                _buildMetricChip(
                  icon: Icons.wb_sunny_rounded,
                  iconColor: meta.uvIndex >= 11
                      ? const Color(0xFF8B5CF6)
                      : (meta.uvIndex >= 8 ? const Color(0xFFEF4444) : const Color(0xFFFBBF24)),
                  label: 'ÍNDICE UV',
                  value: '${meta.uvIndex}',
                  sub: meta.uvIndex >= 8 ? 'Alto' : 'Bajo',
                ),
                const SizedBox(width: 6),

                // Ráfagas de Viento reales
                _buildMetricChip(
                  icon: Icons.air_rounded,
                  iconColor: meta.windSpeedKmh >= 40 ? const Color(0xFFEF4444) : Colors.white70,
                  label: 'VIENTO REAL',
                  value: '${meta.windSpeedKmh}k/h',
                  sub: '${controller.liveData?.windGustsKmh ?? meta.windSpeedKmh}k ráf.',
                ),
                const SizedBox(width: 6),

                // Calidad del Aire / Humo (ICA) en tiempo real
                _buildMetricChip(
                  icon: Icons.cloud_outlined,
                  iconColor: meta.airQualityIndex >= 100
                      ? const Color(0xFFEF4444)
                      : (meta.airQualityIndex >= 50 ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                  label: 'AIRE ICA',
                  value: '${meta.airQualityIndex}',
                  sub: controller.liveData?.airQualityLabel.split(' ').first ?? 'Mod.',
                ),

                const Spacer(),

                // Botón Vigía SCZ
                IconButton(
                  tooltip: 'Reporte Ciudadano Vigía SCZ',
                  icon: const Icon(Icons.add_a_photo_rounded, size: 20),
                  color: TacticalTheme.accentCyan,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    padding: const EdgeInsets.all(7),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: onOpenVigiaReport,
                ),
                const SizedBox(width: 6),

                // Botón SOS Offline
                IconButton(
                  tooltip: 'Modo SOS Offline por SMS',
                  icon: const Icon(Icons.sos_rounded, size: 20),
                  color: const Color(0xFFEF4444),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF7F1D1D).withOpacity(0.4),
                    padding: const EdgeInsets.all(7),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: onOpenSosSms,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF131C2E),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0x3338BDF8), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 7.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    sub,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
