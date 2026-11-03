import 'package:flutter/material.dart';
import '../../core/theme/tactical_theme.dart';
import '../../state/simar_controller.dart';

class PushNotificationBanner extends StatefulWidget {
  final SimarController controller;

  const PushNotificationBanner({super.key, required this.controller});

  @override
  State<PushNotificationBanner> createState() => _PushNotificationBannerState();
}

class _PushNotificationBannerState extends State<PushNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant PushNotificationBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller.currentScenario !=
        widget.controller.currentScenario) {
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.isPushBannerVisible) return const SizedBox.shrink();

    final metadata = widget.controller.activeMetadata;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: TacticalTheme.glassDecoration(
          borderColor: metadata.primaryColor,
          bgColor: const Color(0xF20F172A),
          hasGlow: true,
          radius: 14,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Ícono circular de alerta con pulso
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: metadata.primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: metadata.primaryColor,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    metadata.icon,
                    color: metadata.primaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: metadata.primaryColor.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'PUSH OFICIAL • ${metadata.shortCode}',
                              style: TextStyle(
                                color: metadata.primaryColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Ahora mismo',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        metadata.pushTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: Colors.white60,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => widget.controller.dismissPushBanner(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              metadata.pushMessage,
              style: TextStyle(
                color: Colors.white.withOpacity(0.88),
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (metadata.soundAlert) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.volume_up_rounded,
                        size: 13,
                        color: metadata.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Sirena audible simulada',
                        style: TextStyle(
                          color: metadata.primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => widget.controller.dismissPushBanner(),
                  child: Text(
                    'Entendido',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: metadata.primaryColor,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    // Si hay un nodo relacionado, centrar o abrir modal
                    if (widget.controller.selectedNode != null) {
                      // Ya está seleccionado
                    }
                  },
                  child: const Text(
                    'Ver Telemetría',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
