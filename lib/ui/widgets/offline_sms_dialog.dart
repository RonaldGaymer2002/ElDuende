import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../state/simar_controller.dart';

class OfflineSmsDialog extends StatefulWidget {
  final SimarController controller;

  const OfflineSmsDialog({super.key, required this.controller});

  @override
  State<OfflineSmsDialog> createState() => _OfflineSmsDialogState();
}

class _OfflineSmsDialogState extends State<OfflineSmsDialog> {
  int _victimCount = 2;
  String _emergencyType = 'TURBION';

  @override
  Widget build(BuildContext context) {
    final payload = widget.controller.generateCompressedSmsPayload(
      victimsCount: _victimCount,
      emergencyType: _emergencyType,
      latitude: widget.controller.selectedNode?.latitude ?? -17.7833,
      longitude: widget.controller.selectedNode?.longitude ?? -63.2200,
    );

    return AlertDialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      title: const Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Color(0xFFEF4444), size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'SOS OFFLINE POR SMS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Diseñado para zonas sin internet (El Torno, Angostura, orillas del Piraí). Comprime los datos vitales en un mensaje de texto tradicional directo a la central de rescate del COED.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, height: 1.3),
            ),
            const SizedBox(height: 14),

            // Selector de emergencia
            const Text(
              'TIPO DE RESCATE:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: ['TURBION', 'ATRAPADOS_ISLA', 'INUNDACION', 'MEDICA'].map((t) {
                final isSel = _emergencyType == t;
                return ChoiceChip(
                  label: Text(t),
                  selected: isSel,
                  selectedColor: const Color(0xFFEF4444),
                  backgroundColor: const Color(0xFF1E293B),
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : Colors.white70,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _emergencyType = t);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Personas en peligro
            Row(
              children: [
                const Text(
                  'PERSONAS EN PELIGRO:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                  color: Colors.white60,
                  onPressed: () {
                    if (_victimCount > 1) setState(() => _victimCount--);
                  },
                ),
                Text(
                  '$_victimCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  color: const Color(0xFF38BDF8),
                  onPressed: () {
                    setState(() => _victimCount++);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Cuadro del payload comprimido
            const Text(
              'PAYLOAD COMPRIMIDO (GSM / SMS SEGURO):',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x44EF4444), width: 1),
              ),
              child: SelectableText(
                payload,
                style: const TextStyle(
                  color: Color(0xFFFCA5A5),
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Destino: 800-148139 / 773-COED (Gobernación Santa Cruz)',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: payload));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('📱 Código SOS copiado al portapapeles y preparado para SMS.'),
                backgroundColor: Color(0xFFEF4444),
              ),
            );
          },
          icon: const Icon(Icons.sms_rounded, size: 16),
          label: const Text(
            'ENVIAR SMS AHORA',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
