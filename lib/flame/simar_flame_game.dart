import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../models/river_node.dart';
import '../models/scenario_type.dart';
import '../state/simar_controller.dart';

class SimarFlameGame extends FlameGame with TapCallbacks {
  final SimarController controller;

  // Animaciones y tiempo
  double _elapsedTime = 0.0;
  final List<DebrisLog> _floatingDebris = [];
  final List<RainDrop> _rainDrops = [];
  final List<SmokeParticle> _smokeParticles = [];

  SimarFlameGame({required this.controller});

  @override
  Color backgroundColor() => const Color(0xFF070B12); // Fondo topográfico oscuro

  @override
  void onLoad() {
    super.onLoad();
    // Inicializar partículas
    for (int i = 0; i < 70; i++) {
      _rainDrops.add(RainDrop.random(size.x > 0 ? size.x : 400, size.y > 0 ? size.y : 800));
    }
    for (int i = 0; i < 35; i++) {
      _smokeParticles.add(SmokeParticle.random(size.x > 0 ? size.x : 400, size.y > 0 ? size.y : 800));
    }
    for (int i = 0; i < 8; i++) {
      _floatingDebris.add(DebrisLog.random(i / 8.0));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedTime += dt;

    final width = size.x;
    final height = size.y;
    if (width <= 0 || height <= 0) return;

    // Actualizar lluvia si hay lluvia
    final isRaining = controller.visualState == FlameVisualState.turbionRed ||
        controller.currentScenario == GovRiskScenario.climateTrap ||
        controller.currentScenario == GovRiskScenario.urbanFlood;

    if (isRaining) {
      for (final drop in _rainDrops) {
        drop.update(dt, width, height);
      }
    }

    // Actualizar humo si hay surazo o sequía
    if (controller.visualState == FlameVisualState.extremeHeatAndSmoke) {
      for (final particle in _smokeParticles) {
        particle.update(dt, width, height);
      }
    }

    // Actualizar palizada si hay turbión
    if (controller.visualState == FlameVisualState.turbionRed) {
      for (final log in _floatingDebris) {
        log.update(dt * 0.25);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final width = size.x;
    final height = size.y;
    if (width <= 0 || height <= 0) return;

    // Si hay sismo, aplicar camera shake
    if (controller.visualState == FlameVisualState.seismicPurple) {
      final shakeX = math.sin(_elapsedTime * 45.0) * 3.5;
      final shakeY = math.cos(_elapsedTime * 38.0) * 3.0;
      canvas.save();
      canvas.translate(shakeX, shakeY);
    }

    // 1. Dibujar malla topográfica táctica y curvas de nivel de Santa Cruz
    _drawTacticalBasinGrid(canvas, width, height);

    // 2. Calcular puntos del cauce a partir de los nodos
    final nodePoints = _computeNodeScreenPoints(width, height);

    // 3. Dibujar el cauce del Río Piraí con dinámica de fluidos y color según estado
    _drawRiverBedAndFlow(canvas, nodePoints);

    // 4. Dibujar palizada flotante arrastrada durante el turbión
    if (controller.visualState == FlameVisualState.turbionRed) {
      _drawFloatingDebris(canvas, nodePoints);
    }

    // 5. Dibujar efectos meteorológicos / ambientales
    _drawWeatherAtmosphere(canvas, width, height, nodePoints);

    // 6. Si es sismo, dibujar ondas concéntricas de choque desde Samaipata (nodo 0)
    if (controller.visualState == FlameVisualState.seismicPurple && nodePoints.isNotEmpty) {
      _drawSeismicShockwaves(canvas, nodePoints.first);
    }

    // 7. Dibujar los 6 nodos interactivos con sus balizas, semáforos y etiquetas tácticas
    _drawRiverNodes(canvas, nodePoints);

    if (controller.visualState == FlameVisualState.seismicPurple) {
      canvas.restore();
    }
  }

  /// Calcula las posiciones en pantalla de los nodos
  List<Offset> _computeNodeScreenPoints(double width, double height) {
    // Margen táctico superior e inferior para HUDs de Flutter
    final topMargin = height * 0.17;
    final bottomMargin = height * 0.24;
    final usableHeight = height - topMargin - bottomMargin;
    final horizontalPadding = width * 0.12;
    final usableWidth = width - (horizontalPadding * 2);

    return controller.nodes.map((node) {
      final x = horizontalPadding + (node.normalizedX * usableWidth);
      final y = topMargin + (node.normalizedY * usableHeight);
      return Offset(x, y);
    }).toList();
  }

  /// Dibuja la rejilla táctica y líneas de cuenca
  void _drawTacticalBasinGrid(Canvas canvas, double width, double height) {
    final gridPaint = Paint()
      ..color = const Color(0xFF131D31).withOpacity(0.4)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const step = 45.0;
    for (double x = 0; x < width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }
    for (double y = 0; y < height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Anillos concéntricos de referencia de Santa Cruz (Anillos de circunvalación simulados en la cuenca baja)
    final ringPaint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final sczCenter = Offset(width * 0.76, height * 0.72);
    canvas.drawCircle(sczCenter, 40, ringPaint);
    canvas.drawCircle(sczCenter, 75, ringPaint);
    canvas.drawCircle(sczCenter, 115, ringPaint);
  }

  /// Dibuja el cuerpo del río Piraí con transiciones dinámicas de caudal y turbidez
  void _drawRiverBedAndFlow(Canvas canvas, List<Offset> points) {
    if (points.length < 2) return;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      final midY = (p0.dy + p1.dy) / 2;
      // Curva Bézier fluida natural
      path.quadraticBezierTo(p0.dx, p0.dy, midX, midY);
    }
    path.lineTo(points.last.dx, points.last.dy);

    // Calcular ancho del río según turbión o sequía
    double riverWidth = 16.0;
    Color riverDeepColor = const Color(0xFF0284C7);
    Color riverFlowColor = const Color(0xFF38BDF8);
    Color riverBorderColor = const Color(0xFF0369A1);

    switch (controller.visualState) {
      case FlameVisualState.recreationalGreen:
        riverWidth = 16.0;
        riverDeepColor = const Color(0xFF0284C7);
        riverFlowColor = const Color(0xFF38BDF8);
        riverBorderColor = const Color(0xFF0EA5E9);
        break;

      case FlameVisualState.weatherTrapYellow:
        riverWidth = 22.0;
        // Gradiente de cabecera turbia a llanura cristalina
        riverDeepColor = const Color(0xFF78350F);
        riverFlowColor = const Color(0xFFD97706);
        riverBorderColor = const Color(0xFFB45309);
        break;

      case FlameVisualState.turbionRed:
        riverWidth = 36.0; // Gran crecida y ensanchamiento
        riverDeepColor = const Color(0xFF451A03); // Barro greda
        riverFlowColor = const Color(0xFF92400E);
        riverBorderColor = const Color(0xFFEF4444); // Borde de alerta roja
        break;

      case FlameVisualState.seismicPurple:
        riverWidth = 16.0;
        riverDeepColor = const Color(0xFF312E81);
        riverFlowColor = const Color(0xFF818CF8);
        riverBorderColor = const Color(0xFF6366F1);
        break;

      case FlameVisualState.extremeHeatAndSmoke:
        riverWidth = 12.0; // Caudal bajo por estiaje
        riverDeepColor = const Color(0xFF475569);
        riverFlowColor = const Color(0xFF94A3B8);
        riverBorderColor = const Color(0xFF64748B);
        break;
    }

    // Lecho exterior / orillas
    final bankPaint = Paint()
      ..color = riverBorderColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = riverWidth + 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, bankPaint);

    // Cuerpo principal del agua
    final waterPaint = Paint()
      ..color = riverDeepColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = riverWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, waterPaint);

    // Corriente animada en el centro del cauce
    final dashPaint = Paint()
      ..color = riverFlowColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = riverWidth * 0.35
      ..strokeCap = StrokeCap.round;

    // Efecto de flujo continuo desfasado en el tiempo
    final metrics = path.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final metric = metrics.first;
      final totalLen = metric.length;
      final speedFactor = controller.visualState == FlameVisualState.turbionRed ? 2.8 : 1.0;
      final offset = (_elapsedTime * 60.0 * speedFactor) % 80.0;

      for (double d = offset; d < totalLen; d += 60.0) {
        final tangent1 = metric.getTangentForOffset(d);
        final tangent2 = metric.getTangentForOffset(math.min(d + 24.0, totalLen));
        if (tangent1 != null && tangent2 != null) {
          canvas.drawLine(tangent1.position, tangent2.position, dashPaint);
        }
      }
    }
  }

  /// Dibuja la palizada flotante (troncos y ramas) arrastrada por el río durante turbión
  void _drawFloatingDebris(Canvas canvas, List<Offset> points) {
    if (points.length < 2) return;
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      path.quadraticBezierTo(p0.dx, p0.dy, (p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
    }
    path.lineTo(points.last.dx, points.last.dy);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final length = metric.length;

    final logPaint = Paint()
      ..color = const Color(0xFF713F12)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final branchPaint = Paint()
      ..color = const Color(0xFF854D0E)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    for (final debris in _floatingDebris) {
      final currentPos = (debris.progress * length) % length;
      final tangent = metric.getTangentForOffset(currentPos);
      if (tangent != null) {
        final pos = tangent.position;
        final angle = tangent.angle;

        canvas.save();
        canvas.translate(pos.dx, pos.dy);
        canvas.rotate(angle + debris.rotation);

        // Tronco principal
        canvas.drawLine(const Offset(-8, 0), const Offset(8, 0), logPaint);
        // Ramas
        canvas.drawLine(const Offset(-2, 0), const Offset(2, -4), branchPaint);
        canvas.drawLine(const Offset(3, 0), const Offset(6, 4), branchPaint);

        canvas.restore();
      }
    }
  }

  /// Dibuja efectos atmosféricos según el escenario
  void _drawWeatherAtmosphere(
      Canvas canvas, double width, double height, List<Offset> nodePoints) {
    // Escenario Trampa Climática: Lluvia concentrada en cabecera (Samaipata/Angostura) y sol abajo
    if (controller.currentScenario == GovRiskScenario.climateTrap) {
      // Nube de tormenta en la parte superior
      final stormRect = Rect.fromLTWH(0, 0, width, height * 0.42);
      final stormGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1E293B).withOpacity(0.85),
          const Color(0xFF0F172A).withOpacity(0.5),
          Colors.transparent,
        ],
      );
      canvas.drawRect(
        stormRect,
        Paint()..shader = stormGradient.createShader(stormRect),
      );

      // Gotas de lluvia solo en cabecera
      final rainPaint = Paint()
        ..color = const Color(0xFF60A5FA).withOpacity(0.8)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;

      for (final drop in _rainDrops) {
        if (drop.y < height * 0.45) {
          canvas.drawLine(
            Offset(drop.x, drop.y),
            Offset(drop.x + drop.slant, drop.y + drop.length),
            rainPaint,
          );
        }
      }

      // Sol radiante en Santa Cruz (zona baja)
      if (nodePoints.length >= 5) {
        final sunPos = Offset(nodePoints[4].dx + 40, nodePoints[4].dy - 30);
        final sunGlow = Paint()
          ..color = const Color(0xFFFBBF24).withOpacity(0.25 + 0.1 * math.sin(_elapsedTime * 3))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
        canvas.drawCircle(sunPos, 28, sunGlow);

        final sunCore = Paint()..color = const Color(0xFFF59E0B);
        canvas.drawCircle(sunPos, 14, sunCore);
      }
    } else if (controller.visualState == FlameVisualState.turbionRed ||
        controller.currentScenario == GovRiskScenario.urbanFlood) {
      // Lluvia torrencial en todo el lienzo
      final rainPaint = Paint()
        ..color = const Color(0xFF93C5FD).withOpacity(0.7)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;

      for (final drop in _rainDrops) {
        canvas.drawLine(
          Offset(drop.x, drop.y),
          Offset(drop.x + drop.slant, drop.y + drop.length),
          rainPaint,
        );
      }
    } else if (controller.visualState == FlameVisualState.extremeHeatAndSmoke) {
      // Si es calor extremo / humo
      if (controller.currentScenario == GovRiskScenario.extremeHeat) {
        // Shimmer térmico dorado
        final heatOverlay = Paint()
          ..color = const Color(0xFFEA580C).withOpacity(0.12 + 0.04 * math.sin(_elapsedTime * 2.5));
        canvas.drawRect(Rect.fromLTWH(0, 0, width, height), heatOverlay);
      } else {
        // Partículas de humo y ceniza flotando por Surazo
        final smokePaint = Paint()..style = PaintingStyle.fill;
        for (final p in _smokeParticles) {
          smokePaint.color = const Color(0xFF94A3B8).withOpacity(p.opacity);
          canvas.drawCircle(Offset(p.x, p.y), p.radius, smokePaint);
        }
      }
    }
  }

  /// Dibuja ondas sísmicas concéntricas desde el epicentro (Samaipata/Valles)
  void _drawSeismicShockwaves(Canvas canvas, Offset epicenter) {
    for (int i = 0; i < 4; i++) {
      final phase = (_elapsedTime * 1.8 + (i * 0.35)) % 1.5;
      final radius = phase * 180.0;
      final opacity = (1.0 - (phase / 1.5)).clamp(0.0, 1.0);

      final shockPaint = Paint()
        ..color = const Color(0xFF8B5CF6).withOpacity(opacity * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawCircle(epicenter, radius, shockPaint);
    }

    // Epicentro destello
    final epiPaint = Paint()..color = const Color(0xFFA855F7);
    canvas.drawCircle(epicenter, 8, epiPaint);
  }

  /// Dibuja los 6 nodos interactivos con semáforos, radio-pulsos y badges
  void _drawRiverNodes(Canvas canvas, List<Offset> points) {
    final nodes = controller.nodes;

    for (int i = 0; i < nodes.length && i < points.length; i++) {
      final node = nodes[i];
      final pos = points[i];
      final isSelected = controller.selectedNode?.id == node.id;

      // 1. Radio-pulso de fondo
      final pulsePhase = (_elapsedTime * 2.0 + (i * 0.4)) % 1.0;
      final pulseRadius = 14.0 + (pulsePhase * 20.0);
      final pulseOpacity = (1.0 - pulsePhase).clamp(0.0, 1.0);

      final pulsePaint = Paint()
        ..color = node.statusColor.withOpacity(pulseOpacity * 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawCircle(pos, pulseRadius, pulsePaint);

      // 2. Anillo de selección si está activo
      if (isSelected) {
        final selectPaint = Paint()
          ..color = const Color(0xFF38BDF8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(pos, 22.0, selectPaint);
      }

      // 3. Disco del nodo
      final nodeCorePaint = Paint()
        ..color = node.statusColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 12.0, nodeCorePaint);

      // Borde interior blanco táctico
      final innerBorder = Paint()
        ..color = Colors.white.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(pos, 12.0, innerBorder);

      // Ícono de advertencia si es zona mortal permanente (Dragas o Puente Urubó)
      if (node.isPermanentlyForbidden) {
        final skullBorder = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 5.0, skullBorder);
      }

      // 4. Etiqueta de Telemetría Flotante (Nombre + Nivel SEARPI)
      _drawNodeHUDLabel(canvas, pos, node, isSelected);
    }
  }

  /// Dibuja la tarjeta HUD flotante junto al nodo
  void _drawNodeHUDLabel(Canvas canvas, Offset pos, RiverNode node, bool isSelected) {
    final isLeft = pos.dx > size.x * 0.55;
    final labelX = isLeft ? pos.dx - 145 : pos.dx + 22;
    final labelY = pos.dy - 18;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(labelX, labelY, 138, 38),
      const Radius.circular(8),
    );

    // Fondo del label
    final bgPaint = Paint()
      ..color = (isSelected ? const Color(0xFF0F172A) : const Color(0xE6111827))
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rect, bgPaint);

    // Borde de color de alerta
    final borderPaint = Paint()
      ..color = (isSelected ? const Color(0xFF38BDF8) : node.statusColor.withOpacity(0.6))
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 1.5 : 1.0;
    canvas.drawRRect(rect, borderPaint);

    // Texto: Nombre corto y Nivel de agua
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${node.name}\n',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: 'SEARPI: ${node.currentLevelMeters.toStringAsFixed(2)}m • ',
            style: TextStyle(
              color: node.statusColor,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: node.isPermanentlyForbidden ? 'PROHIBIDO' : (node.currentLevelMeters > 1.5 ? 'CRECIDA' : 'NORMAL'),
            style: TextStyle(
              color: node.isPermanentlyForbidden ? const Color(0xFFEF4444) : Colors.white70,
              fontSize: 9.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: 130);
    textPainter.paint(canvas, Offset(labelX + 6, labelY + 4));
  }

  @override
  void onTapDown(TapDownEvent event) {
    final touchPos = event.localPosition;
    final points = _computeNodeScreenPoints(size.x, size.y);
    final nodes = controller.nodes;

    for (int i = 0; i < points.length && i < nodes.length; i++) {
      final point = points[i];
      final distance = (touchPos.toOffset() - point).distance;
      // Radio de tolerancia al toque amplio para facilitar el uso táctil en móviles
      if (distance <= 42.0) {
        controller.selectNode(nodes[i]);
        return;
      }
    }

    // Si toca fuera de los nodos, deselecciona
    controller.selectNode(null);
  }
}

/// Clases auxiliares para física de partículas de lluvia, humo y palizada
class RainDrop {
  double x;
  double y;
  double speed;
  double length;
  double slant;

  RainDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
    required this.slant,
  });

  factory RainDrop.random(double maxX, double maxY) {
    final rand = math.Random();
    return RainDrop(
      x: rand.nextDouble() * maxX,
      y: rand.nextDouble() * maxY,
      speed: 380 + rand.nextDouble() * 220,
      length: 12 + rand.nextDouble() * 10,
      slant: -2.5 + rand.nextDouble() * 1.5,
    );
  }

  void update(double dt, double maxX, double maxY) {
    y += speed * dt;
    x += slant * speed * dt * 0.1;
    if (y > maxY) {
      y = -length;
      x = math.Random().nextDouble() * maxX;
    }
  }
}

class SmokeParticle {
  double x;
  double y;
  double radius;
  double opacity;
  double speedX;
  double speedY;

  SmokeParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
    required this.speedX,
    required this.speedY,
  });

  factory SmokeParticle.random(double maxX, double maxY) {
    final rand = math.Random();
    return SmokeParticle(
      x: rand.nextDouble() * maxX,
      y: rand.nextDouble() * maxY,
      radius: 4.0 + rand.nextDouble() * 10.0,
      opacity: 0.15 + rand.nextDouble() * 0.35,
      speedX: -25.0 + rand.nextDouble() * 50.0,
      speedY: -15.0 - rand.nextDouble() * 25.0,
    );
  }

  void update(double dt, double maxX, double maxY) {
    x += speedX * dt;
    y += speedY * dt;
    if (y < -20 || x < -20 || x > maxX + 20) {
      y = maxY + 10;
      x = math.Random().nextDouble() * maxX;
    }
  }
}

class DebrisLog {
  double progress;
  double rotation;

  DebrisLog({required this.progress, required this.rotation});

  factory DebrisLog.random(double initialProgress) {
    return DebrisLog(
      progress: initialProgress,
      rotation: (math.Random().nextDouble() - 0.5) * 0.8,
    );
  }

  void update(double step) {
    progress += step;
    if (progress > 1.0) progress = 0.0;
  }
}

