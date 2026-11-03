import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/citizen_report.dart';
import '../models/river_node.dart';
import '../models/scenario_type.dart';

class SimarController extends ChangeNotifier {
  List<RiverNode> _nodes = RiverNode.canonicalNodes;
  GovRiskScenario _currentScenario = GovRiskScenario.swimmingDay;
  double _timeOffsetHours = 0.0;
  bool _isPlaying = false;
  Timer? _playbackTimer;

  RiverNode? _selectedNode;
  bool _isPushBannerVisible = true;
  bool _isCoedMode = false;
  final List<CitizenReport> _reports = List.from(CitizenReport.mockReports);

  // Getters
  List<RiverNode> get nodes => _nodes;
  GovRiskScenario get currentScenario => _currentScenario;
  double get timeOffsetHours => _timeOffsetHours;
  bool get isPlaying => _isPlaying;
  RiverNode? get selectedNode => _selectedNode;
  bool get isPushBannerVisible => _isPushBannerVisible;
  bool get isCoedMode => _isCoedMode;
  List<CitizenReport> get reports => List.unmodifiable(_reports);

  ScenarioMetadata get activeMetadata =>
      ScenarioMetadata.allScenarios[_currentScenario]!;

  FlameVisualState get visualState => activeMetadata.visualState;

  void selectNode(RiverNode? node) {
    _selectedNode = node;
    notifyListeners();
  }

  void toggleCoedMode() {
    _isCoedMode = !_isCoedMode;
    notifyListeners();
  }

  void setCoedMode(bool value) {
    if (_isCoedMode != value) {
      _isCoedMode = value;
      notifyListeners();
    }
  }

  void dismissPushBanner() {
    _isPushBannerVisible = false;
    notifyListeners();
  }

  void showPushBanner() {
    _isPushBannerVisible = true;
    notifyListeners();
  }

  /// Dispara de inmediato uno de los 8 escenarios clave de la demo
  void triggerScenario(GovRiskScenario scenario) {
    _currentScenario = scenario;
    _timeOffsetHours = 0.0;
    _isPushBannerVisible = true;

    // Si el escenario es de zona prohibida, auto-seleccionamos el nodo de dragas
    if (scenario == GovRiskScenario.forbiddenZoneAlert) {
      _selectedNode = _nodes.firstWhere((n) => n.id == 'dragas');
    } else if (scenario == GovRiskScenario.climateTrap) {
      _selectedNode = _nodes.firstWhere((n) => n.id == 'angostura');
    } else if (scenario == GovRiskScenario.redTurbion) {
      _selectedNode = _nodes.firstWhere((n) => n.id == 'espejillos');
    }

    _recalculateTelemetry();
    notifyListeners();
  }

  /// Cambia el tiempo de pronóstico (+0h a +6h)
  void setTimeOffsetHours(double hours) {
    _timeOffsetHours = hours.clamp(0.0, 6.0);
    _recalculateTelemetry();
    notifyListeners();
  }

  /// Inicia/Detiene la reproducción animada del avance de la onda
  void togglePlaySimulation() {
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _playbackTimer?.cancel();
      _playbackTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
        if (_timeOffsetHours >= 6.0) {
          _timeOffsetHours = 0.0;
        } else {
          _timeOffsetHours += 0.2;
        }
        _recalculateTelemetry();
        notifyListeners();
      });
    } else {
      _playbackTimer?.cancel();
    }
    notifyListeners();
  }

  /// Añade un reporte verificado ciudadano desde el Vigía SCZ
  void submitCitizenReport({
    required IncidentType type,
    required String title,
    required String locationName,
    required double latitude,
    required double longitude,
    required String description,
  }) {
    final newReport = CitizenReport(
      id: 'rep-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      title: title,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      verificationCount: 1,
      isVerifiedByTriangulation: true,
      description: description,
    );
    _reports.insert(0, newReport);
    notifyListeners();
  }

  /// Genera payload de rescate SOS comprimido para SMS satelital / GSM rural
  String generateCompressedSmsPayload({
    required int victimsCount,
    required String emergencyType,
    double latitude = -17.7833,
    double longitude = -63.2200,
  }) {
    // Formato ultraligero: SIMAR#<TIPO>#LAT,LON#VICTIMAS#TIMESTAMP
    final latStr = latitude.toStringAsFixed(4);
    final lonStr = longitude.toStringAsFixed(4);
    final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return 'SIMAR#$emergencyType#$latStr,$lonStr#P:$victimsCount#T:$ts#COED-SCZ';
  }

  /// Recalcula en vivo los niveles de agua y veredictos según el escenario y el slider de tiempo
  void _recalculateTelemetry() {
    final List<RiverNode> updated = [];

    for (final node in RiverNode.canonicalNodes) {
      double level = node.baselineLevelMeters;
      double speed = node.currentFlowSpeedMps;
      double rain = 0.0;
      SwimmingSafetyVerdict verdict = node.safetyVerdict;

      switch (_currentScenario) {
        case GovRiskScenario.swimmingDay:
          level = node.baselineLevelMeters;
          speed = node.currentFlowSpeedMps;
          rain = 0.0;
          verdict = node.isPermanentlyForbidden
              ? SwimmingSafetyVerdict.deadlyZoneYearRound
              : SwimmingSafetyVerdict.safe;
          break;

        case GovRiskScenario.forbiddenZoneAlert:
          level = node.baselineLevelMeters + 0.1;
          speed = node.currentFlowSpeedMps;
          verdict = node.isPermanentlyForbidden
              ? SwimmingSafetyVerdict.deadlyZoneYearRound
              : SwimmingSafetyVerdict.safe;
          break;

        case GovRiskScenario.climateTrap:
          // Tormenta en Samaipata y Angostura, pero sol abajo
          if (node.transitOrder <= 2) {
            rain = 0.85;
            level = node.baselineLevelMeters + 1.2;
            speed = node.currentFlowSpeedMps + 1.2;
            verdict = SwimmingSafetyVerdict.weatherTrap;
          } else {
            // Abajo aún no llega la onda pero está prohibido porque ya viene
            rain = 0.0;
            level = node.baselineLevelMeters + 0.15;
            verdict = node.isPermanentlyForbidden
                ? SwimmingSafetyVerdict.deadlyZoneYearRound
                : SwimmingSafetyVerdict.weatherTrap;
          }
          break;

        case GovRiskScenario.redTurbion:
          // La onda del turbión viaja en el tiempo:
          // Orden 1 (Samaipata): pico a t=0.0h
          // Orden 2 (Angostura): pico a t=1.0h
          // Orden 3 (Espejillos): pico a t=2.0h
          // Orden 4 (La Guardia): pico a t=3.2h
          // Orden 5 (Cabañas): pico a t=4.2h
          // Orden 6 (Puente Urubó): pico a t=5.0h
          final nodePeakHour = (node.transitOrder - 1) * 0.95;
          final timeDiff = (_timeOffsetHours - nodePeakHour).abs();

          // Campana de crecida
          final waveEffect = (1.0 - (timeDiff / 1.6)).clamp(0.0, 1.0);
          final turbionPeakHeight = 3.6; // metros de crecida extraordinaria

          level = node.baselineLevelMeters + (waveEffect * turbionPeakHeight);
          speed = node.currentFlowSpeedMps + (waveEffect * 3.2);
          rain = (_timeOffsetHours < 2.0 && node.transitOrder <= 2) ? 0.95 : 0.4;

          verdict = SwimmingSafetyVerdict.emergencyTurbion;
          break;

        case GovRiskScenario.urbanFlood:
          level = node.baselineLevelMeters + 0.8;
          speed = node.currentFlowSpeedMps + 1.0;
          rain = 0.9;
          verdict = SwimmingSafetyVerdict.weatherTrap;
          break;

        case GovRiskScenario.seismicAlert:
          level = node.baselineLevelMeters;
          speed = node.currentFlowSpeedMps;
          verdict = node.isPermanentlyForbidden
              ? SwimmingSafetyVerdict.deadlyZoneYearRound
              : SwimmingSafetyVerdict.safe;
          break;

        case GovRiskScenario.extremeHeat:
          level = (node.baselineLevelMeters * 0.8).clamp(0.2, 5.0);
          speed = node.currentFlowSpeedMps * 0.8;
          verdict = node.isPermanentlyForbidden
              ? SwimmingSafetyVerdict.deadlyZoneYearRound
              : SwimmingSafetyVerdict.safe;
          break;

        case GovRiskScenario.droughtSmokeSurazo:
          level = (node.baselineLevelMeters * 0.65).clamp(0.18, 5.0);
          speed = node.currentFlowSpeedMps * 0.9;
          verdict = node.isPermanentlyForbidden
              ? SwimmingSafetyVerdict.deadlyZoneYearRound
              : SwimmingSafetyVerdict.safe;
          break;
      }

      updated.add(node.copyWith(
        currentLevelMeters: double.parse(level.toStringAsFixed(2)),
        currentFlowSpeedMps: double.parse(speed.toStringAsFixed(2)),
        upstreamRainIntensity: double.parse(rain.toStringAsFixed(2)),
        safetyVerdict: verdict,
      ));
    }

    _nodes = updated;

    // Actualiza el nodo seleccionado en memoria si existe
    if (_selectedNode != null) {
      _selectedNode = _nodes.firstWhere(
        (n) => n.id == _selectedNode!.id,
        orElse: () => _selectedNode!,
      );
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }
}

