import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../flame/simar_flame_game.dart';
import '../../state/simar_controller.dart';
import '../widgets/god_mode_panel.dart';
import '../widgets/node_safety_sheet.dart';
import '../widgets/offline_sms_dialog.dart';
import '../widgets/push_notification_banner.dart';
import '../widgets/tactical_header.dart';
import '../widgets/time_slider_bar.dart';
import '../widgets/vigia_report_sheet.dart';
import 'coed_command_screen.dart';

class SimarHomeScreen extends StatefulWidget {
  final SimarController controller;

  const SimarHomeScreen({super.key, required this.controller});

  @override
  State<SimarHomeScreen> createState() => _SimarHomeScreenState();
}

class _SimarHomeScreenState extends State<SimarHomeScreen> {
  late SimarFlameGame _flameGame;

  @override
  void initState() {
    super.initState();
    _flameGame = SimarFlameGame(controller: widget.controller);
    widget.controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _showGodModeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GodModePanel(
        controller: widget.controller,
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showVigiaReportModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VigiaReportSheet(
        controller: widget.controller,
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showSosSmsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => OfflineSmsDialog(controller: widget.controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    // Si está en Modo Comando COED, mostrar la pantalla táctica de autoridades
    if (controller.isCoedMode) {
      return CoedCommandScreen(controller: controller);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      body: Stack(
        children: [
          // Capa 0: Gemelo Digital de la Cuenca en Flame Engine
          Positioned.fill(
            child: GameWidget(
              game: _flameGame,
            ),
          ),

          // Capa 1: Header Táctico y Métricas de Recreación Diaria
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TacticalHeader(
              controller: controller,
              onOpenGodMode: _showGodModeModal,
              onOpenVigiaReport: _showVigiaReportModal,
              onOpenSosSms: _showSosSmsDialog,
            ),
          ),

          // Capa 2: Banner Interactivo de Notificación Push Oficial
          Positioned(
            top: MediaQuery.of(context).padding.top + 98,
            left: 0,
            right: 0,
            child: PushNotificationBanner(controller: controller),
          ),

          // Capa 3: Modal de Seguridad de Nodo (si hay uno tocado)
          if (controller.selectedNode != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 125,
              child: NodeSafetySheet(
                node: controller.selectedNode!,
                controller: controller,
                onClose: () => controller.selectNode(null),
              ),
            ),

          // Capa 4: Barra Deslizante Predictiva de Tiempo (+0h a +6h)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: TimeSliderBar(controller: controller),
            ),
          ),
        ],
      ),
    );
  }
}
