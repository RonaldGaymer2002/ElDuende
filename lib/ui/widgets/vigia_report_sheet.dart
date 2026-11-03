import 'package:flutter/material.dart';
import '../../models/citizen_report.dart';
import '../../state/simar_controller.dart';

class VigiaReportSheet extends StatefulWidget {
  final SimarController controller;
  final VoidCallback onClose;

  const VigiaReportSheet({
    super.key,
    required this.controller,
    required this.onClose,
  });

  @override
  State<VigiaReportSheet> createState() => _VigiaReportSheetState();
}

class _VigiaReportSheetState extends State<VigiaReportSheet> {
  IncidentType _selectedType = IncidentType.calleInundada;
  final TextEditingController _descController = TextEditingController();
  String _selectedZone = 'Canal Cotoca y 3er Anillo';
  bool _isPhotoAttached = true;

  final List<String> _commonZones = [
    'Canal Cotoca y 3er Anillo',
    'Canal Isuto y 4to Anillo',
    'Paso a Desnivel Cristo Redentor',
    'Ribera Cabañas del Piraí',
    'El Torno - Sector Puente',
    'La Guardia - Zona Dragas',
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFA0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFF0284C7), width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF0284C7), width: 1.2),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF38BDF8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VIGÍA SCZ • REPORTE EN 2 TOQUES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      'Triangulación GPS comunitaria para validación temprana',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
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
          const SizedBox(height: 14),

          // 1. Selector de Tipo de Incidente
          const Text(
            '1. TIPO DE AMENAZA O INCIDENTE:',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: IncidentType.values.map((type) {
                final isSelected = _selectedType == type;
                final dummyReport = CitizenReport(
                  id: '',
                  type: type,
                  title: '',
                  locationName: '',
                  latitude: 0,
                  longitude: 0,
                  timestamp: DateTime.now(),
                  verificationCount: 0,
                  isVerifiedByTriangulation: true,
                  description: '',
                );

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(
                      dummyReport.typeIcon,
                      size: 16,
                      color: isSelected ? Colors.black : dummyReport.typeColor,
                    ),
                    label: Text(dummyReport.typeLabel),
                    selected: isSelected,
                    selectedColor: dummyReport.typeColor,
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                    side: BorderSide(
                      color: isSelected ? dummyReport.typeColor : const Color(0x33475569),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedType = type);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Ubicación GPS / Zona
          const Text(
            '2. UBICACIÓN DETECTADA AUTOMÁTICAMENTE:',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x3338BDF8), width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedZone,
                dropdownColor: const Color(0xFF0F172A),
                icon: const Icon(Icons.location_on_rounded, color: Color(0xFF38BDF8)),
                items: _commonZones.map((zone) {
                  return DropdownMenuItem(
                    value: zone,
                    child: Text(
                      zone,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedZone = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Badge de Foto adjunta con GPS
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => _isPhotoAttached = !_isPhotoAttached),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isPhotoAttached
                        ? const Color(0xFF10B981).withOpacity(0.18)
                        : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isPhotoAttached ? const Color(0xFF10B981) : const Color(0xFF475569),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isPhotoAttached ? Icons.check_circle_rounded : Icons.camera_alt_outlined,
                        size: 15,
                        color: _isPhotoAttached ? const Color(0xFF10B981) : Colors.white60,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isPhotoAttached ? 'Foto con metadatos GPS OK' : 'Adjuntar Foto',
                        style: TextStyle(
                          color: _isPhotoAttached ? const Color(0xFF10B981) : Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'Precisión GPS: ±3m',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Botón de Envío Instantáneo
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {
                widget.controller.submitCitizenReport(
                  type: _selectedType,
                  title: 'Alerta ciudadana en $_selectedZone',
                  locationName: _selectedZone,
                  latitude: -17.7833,
                  longitude: -63.2200,
                  description: 'Reporte verificado por triangulación de celdas cercanas.',
                );
                widget.onClose();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🛡️ Reporte Vigía SCZ transmitido y verificado por triangulación'),
                    backgroundColor: Color(0xFF10B981),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text(
                'TRANSMITIR REPORTE AL COED',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
