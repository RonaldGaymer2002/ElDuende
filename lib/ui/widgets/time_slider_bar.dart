import 'package:flutter/material.dart';
import '../../core/theme/tactical_theme.dart';
import '../../state/simar_controller.dart';

class TimeSliderBar extends StatelessWidget {
  final SimarController controller;

  const TimeSliderBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final currentOffset = controller.timeOffsetHours;
    final now = DateTime.now();
    final simulatedTime = now.add(Duration(minutes: (currentOffset * 60).round()));
    final hourStr = '${simulatedTime.hour.toString().padLeft(2, '0')}:${simulatedTime.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: TacticalTheme.glassDecoration(
        borderColor: const Color(0xFF38BDF8),
        bgColor: const Color(0xF20B0F19),
        radius: 14,
        hasGlow: true,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila superior: Título, hora proyectada y control de reproducción
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: TacticalTheme.accentCyan.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.timelapse_rounded,
                  color: TacticalTheme.accentCyan,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SIMULACIÓN PREDICTIVA DE CUENCA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    'Hora proyectada: $hourStr (+${currentOffset.toStringAsFixed(1)}h)',
                    style: TextStyle(
                      color: TacticalTheme.accentCyan.withOpacity(0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Botón Play / Pause
              InkWell(
                onTap: () => controller.togglePlaySimulation(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: controller.isPlaying
                        ? const Color(0xFFEF4444)
                        : TacticalTheme.accentCyan,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        controller.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        controller.isPlaying ? 'PAUSAR' : 'SIMULAR',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),

          // Slider de tiempo
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: const Color(0xFF38BDF8),
              inactiveTrackColor: const Color(0xFF1E293B),
              thumbColor: Colors.white,
              overlayColor: const Color(0x3338BDF8),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: currentOffset,
              min: 0.0,
              max: 6.0,
              divisions: 30,
              onChanged: (val) {
                controller.setTimeOffsetHours(val);
              },
            ),
          ),

          // Etiquetas de hitos de llegada de la onda por municipio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStationMilestone('Samaipata', '+0h', currentOffset >= 0.0),
              _buildStationMilestone('Angostura', '+1h', currentOffset >= 1.0),
              _buildStationMilestone('Espejillos', '+2h', currentOffset >= 2.0),
              _buildStationMilestone('La Guardia', '+3.2h', currentOffset >= 3.2),
              _buildStationMilestone('Cabañas', '+4.2h', currentOffset >= 4.2),
              _buildStationMilestone('Urubó', '+5h', currentOffset >= 5.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStationMilestone(String station, String eta, bool isReached) {
    return Column(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isReached ? const Color(0xFF38BDF8) : const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          station,
          style: TextStyle(
            color: isReached ? Colors.white : const Color(0xFF64748B),
            fontSize: 7.5,
            fontWeight: isReached ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          eta,
          style: TextStyle(
            color: isReached ? TacticalTheme.accentCyan : const Color(0xFF475569),
            fontSize: 7.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

