import 'package:flutter/material.dart';
import '../../state/simar_controller.dart';

class CoedCommandScreen extends StatelessWidget {
  final SimarController controller;

  const CoedCommandScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF070B12),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de título del comando
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7F1D1D), Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEF4444), width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.security_rounded,
                      color: Color(0xFFEF4444),
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SALA DE SITUACIÓN COED GOBERNACIÓN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Centro de Operaciones de Emergencia Departamental • SCZ',
                            style: TextStyle(
                              color: Color(0xFFFECACA),
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => controller.setCoedMode(false),
                      icon: const Icon(Icons.arrow_back_rounded, size: 14),
                      label: const Text('Vista Ciudadana', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Fila de Métricas Operativas Rápidas
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      title: 'ALBERGUES ACTIVOS',
                      value: '4 / 8',
                      subtitle: 'Capacidad: 1,200 pers.',
                      icon: Icons.night_shelter_rounded,
                      color: const Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'CUADRILLAS EN CAMPO',
                      value: '18',
                      subtitle: 'SAR, Bomberos, COED',
                      icon: Icons.groups_rounded,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'ALERTAS VIGENTES',
                      value: '2 ROJAS',
                      subtitle: 'Piraí Cuenca Media',
                      icon: Icons.warning_rounded,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Sección: Despacho Masivo de Alertas Tempranas
              const Text(
                'DESPACHO MASIVO DE ALERTA POR MUNICIPIO:',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              _buildDispatchCard(context),
              const SizedBox(height: 16),

              // Sección: Capacidad y Ocupación de Albergues
              const Text(
                'MONITOREO DE ALBERGUES OFICIALES HABILITADOS:',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              _buildShelterItem('Coliseo Santa Rosita (Distrito 1)', 0.65, 325, 500, 'Activo'),
              const SizedBox(height: 6),
              _buildShelterItem('Coliseo Gilberto Pareja (Calle Ingavi)', 0.40, 160, 400, 'Activo'),
              const SizedBox(height: 6),
              _buildShelterItem('Módulo Educativo El Torno (Km 32)', 0.88, 176, 200, 'Alerta Saturación'),
              const SizedBox(height: 6),
              _buildShelterItem('Coliseo Municipal La Guardia', 0.15, 45, 300, 'Habilitado'),
              const SizedBox(height: 16),

              // Sección: Triage de Reportes Ciudadanos "Vigía SCZ"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TRIAGE EN TIEMPO REAL • REPORTES VIGÍA SCZ:',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    '${controller.reports.length} reportes',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.reports.length,
                itemBuilder: (context, index) {
                  final report = controller.reports[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: report.typeColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: report.typeColor.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(report.typeIcon, color: report.typeColor, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    report.typeLabel,
                                    style: TextStyle(
                                      color: report.typeColor,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'VERIFICADO',
                                      style: TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${report.verificationCount} vecinos',
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                report.locationName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                report.description,
                                style: const TextStyle(
                                  color: Color(0xFFCBD5E1),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 8.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDispatchCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x33475569), width: 1),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.cell_tower_rounded, color: Color(0xFF38BDF8), size: 18),
              SizedBox(width: 8),
              Text(
                'Difusión Geocercada a Dispositivos Móviles (Cell Broadcast)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMunicipalityButton(context, 'El Torno', const Color(0xFFEF4444)),
              const SizedBox(width: 6),
              _buildMunicipalityButton(context, 'La Guardia', const Color(0xFFF59E0B)),
              const SizedBox(width: 6),
              _buildMunicipalityButton(context, 'Santa Cruz', const Color(0xFF0284C7)),
              const SizedBox(width: 6),
              _buildMunicipalityButton(context, 'Porongo', const Color(0xFF10B981)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMunicipalityButton(BuildContext context, String name, Color color) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.7)),
          backgroundColor: color.withOpacity(0.12),
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📢 Alerta masiva emitida a todos los terminales en $name.'),
              backgroundColor: color,
            ),
          );
        },
        child: Text(
          name,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildShelterItem(
    String name,
    double occupancyRate,
    int occupied,
    int total,
    String badge,
  ) {
    final isCritical = occupancyRate > 0.8;
    final color = isCritical ? const Color(0xFFEF4444) : const Color(0xFF38BDF8);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: occupancyRate,
              backgroundColor: const Color(0xFF0F172A),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ocupación: $occupied / $total personas',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5),
              ),
              Text(
                '${(occupancyRate * 100).toInt()}%',
                style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
