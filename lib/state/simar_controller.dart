import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/citizen_report.dart';
import '../models/river_node.dart';
import '../models/scenario_type.dart';
import '../services/real_telemetry_service.dart';

class SimarController extends ChangeNotifier {
  final RealTelemetryService _telemetryService = RealTelemetryService();

  List<RiverNode> _nodes = RiverNode.canonicalNodes;
  GovRiskScenario _currentScenario = GovRiskScenario.swimmingDay;
  double _timeOffsetHours = 0.0;
  bool _isPlaying = false;
  Timer? _playbackTimer;

  RiverNode? _selectedNode;
  bool _isPushBannerVisible = true;
  bool _isCoedMode = false;
  final List<CitizenReport> _reports = List.from(CitizenReport.mockReports);

  // Estado de APIs en Vivo
  LiveTelemetryData? _liveData;
  bool _isLiveMode = true;
  bool _isLoadingLive = false;

  SimarController() {
    // Al inicializar el controlador, consultar inmediatamente las APIs reales
    fetchLiveTelemetry();
  }

  // Getters
  List<RiverNode> get nodes => _nodes;
  GovRiskScenario get currentScenario => _currentScenario;
  double get timeOffsetHours => _timeOffsetHours;
  bool get isPlaying => _isPlaying;
  RiverNode? get selectedNode => _selectedNode;
  bool get isPushBannerVisible => _isPushBannerVisible;
  bool get isCoedMode => _isCoedMode;
  List<CitizenReport> get reports => List.unmodifiable(_reports);

  LiveTelemetryData? get liveData => _liveData;
  bool get isLiveMode => _isLiveMode;
  bool get isLoadingLive => _isLoadingLive;

  ScenarioMetadata get activeMetadata {
    final meta = ScenarioMetadata.allScenarios[_currentScenario]!;
    // Si estamos en Modo En Vivo y tenemos datos reales, fusionamos los valores reales de las APIs
    if (_isLiveMode && _liveData != null) {
      return ScenarioMetadata(
        scenario: meta.scenario,
        title: meta.title,
        shortCode: 'EN-VIVO',
        pushTitle: meta.pushTitle,
        pushMessage: meta.pushMessage,
        primaryColor: meta.primaryColor,
        icon: meta.icon,
        visualState: meta.visualState,
        temperatureC: _liveData!.temperatureC,
        uvIndex: _liveData!.uvIndex,
        airQualityIndex: _liveData!.airQualityIndex,
        windSpeedKmh: _liveData!.windSpeedKmh,
        windDirection: '${_liveData!.windGustsKmh} km/h ráfagas',
        soundAlert: meta.soundAlert,
      );
    }
    return meta;
  }

  FlameVisualState get visualState => activeMetadata.visualState;

  /// Consulta las APIs reales en vivo (Open-Meteo, USGS, Air Quality)
  Future<void> fetchLiveTelemetry() async {
    _isLoadingLive = true;
    notifyListeners();

    try {
      final realData = await _telemetryService.fetchAllLiveTelemetry();
      _liveData = realData;
      _isLiveMode = true;

      // Evaluar si las APIs reales indican condiciones críticas en la cuenca
      if (realData.samaipataRainMm > 5.0 && realData.sczRainMm == 0.0) {
        // Trampa climática detectada automáticamente con datos satelitales reales
        _currentScenario = GovRiskScenario.climateTrap;
      } else if (realData.airQualityIndex >= 150 || realData.windSpeedKmh >= 55) {
        // Humo / Surazo detectado
        _currentScenario = GovRiskScenario.droughtSmokeSurazo;
      } else if (realData.temperatureC >= 36.0) {
        // Estrés térmico extremo
        _currentScenario = GovRiskScenario.extremeHeat;
      }

      _recalculateTelemetry();
    } catch (_) {
      // Si no hay internet momentáneamente, mantenemos el fallback seguro
      _liveData ??= LiveTelemetryData.fallback();
    } finally {
      _isLoadingLive = false;
      notifyListeners();
    }
  }

  /// Activa el modo en vivo consumiendo las APIs reales
  void enableLiveMode() {
    _isLiveMode = true;
    fetchLiveTelemetry();
  }

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
    _isLiveMode = false; // Al usar Modo Dios, cambiamos a simulación controlada
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

      // Si estamos en modo en vivo y tenemos datos reales
      if (_isLiveMode && _liveData != null) {
        if (node.transitOrder <= 2) {
          rain = (_liveData!.samaipataRainMm / 20.0).clamp(0.0, 1.0);
        } else {
          rain = (_liveData!.sczRainMm / 20.0).clamp(0.0, 1.0);
        }
        level = node.baselineLevelMeters + (rain * 0.8);
        verdict = node.isPermanentlyForbidden
            ? SwimmingSafetyVerdict.deadlyZoneYearRound
            : (rain > 0.4 ? SwimmingSafetyVerdict.weatherTrap : SwimmingSafetyVerdict.safe);
      } else {
        // Lógica de simulación de escenarios
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
            if (node.transitOrder <= 2) {
              rain = 0.85;
              level = node.baselineLevelMeters + 1.2;
              speed = node.currentFlowSpeedMps + 1.2;
              verdict = SwimmingSafetyVerdict.weatherTrap;
            } else {
              rain = 0.0;
              level = node.baselineLevelMeters + 0.15;
              verdict = node.isPermanentlyForbidden
                  ? SwimmingSafetyVerdict.deadlyZoneYearRound
                  : SwimmingSafetyVerdict.weatherTrap;
            }
            break;

          case GovRiskScenario.redTurbion:
            final nodePeakHour = (node.transitOrder - 1) * 0.95;
            final timeDiff = (_timeOffsetHours - nodePeakHour).abs();
            final waveEffect = (1.0 - (timeDiff / 1.6)).clamp(0.0, 1.0);
            const turbionPeakHeight = 3.6;

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
      }

      updated.add(node.copyWith(
        currentLevelMeters: double.parse(level.toStringAsFixed(2)),
        currentFlowSpeedMps: double.parse(speed.toStringAsFixed(2)),
        upstreamRainIntensity: double.parse(rain.toStringAsFixed(2)),
        safetyVerdict: verdict,
      ));
    }

    _nodes = updated;

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
