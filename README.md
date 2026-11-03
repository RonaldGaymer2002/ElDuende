# 🌊 El Duende — SIMAR (Sistema de Monitoreo y Alerta Temprana de Riesgo)

> **Hackathon Gobernación de Santa Cruz 2026**  
> **Vertical:** 🌿 **GovRisk** — Prevención de inundaciones, turbiones y emergencias hidrometeorológicas en la cuenca del Río Piraí.

---

## 📌 Contexto y Problemática

El **Río Piraí** es uno de los afluentes más dinámicos y peligrosos de Bolivia. Su cuenca alta (Samaipata, Bermejo y La Angostura) recibe precipitaciones intensas que provocan **turbiones repentinos** que descienden hacia la zona metropolitana de Santa Cruz de la Sierra (Cabañas del Piraí, Warnes y Montero) en lapsos de entre **4 a 8 horas**.

### Desafíos identificados:
1. **Trampa climática en llanura:** En la ciudad suele haber sol radiante mientras que en las cabeceras llueve torrencialmente, exponiendo a bañistas, familias y dragueros a crecidas letales sin aviso previo.
2. **Puntos ciegos de conectividad:** Zonas vulnerables en riberas no siempre cuentan con acceso a internet móvil o datos.
3. **Falta de coordinación bidireccional:** Brecha entre las alertas técnicas del SEARPI / COED y los reportes en tiempo real de la ciudadanía en el territorio.

---

## 💡 Solución: SIMAR

**SIMAR (Sistema de Monitoreo y Alerta de Riesgo)** es una aplicación multiplataforma construida con **Flutter** y un **Gemelo Digital 2D interactivo (Flame Engine)** que conecta a la ciudadanía con el Centro de Operaciones de Emergencia Departamental (COED).

### ✨ Características Principales

- **🎮 Gemelo Digital Hidrológico en Tiempo Real (Flame Engine):**
  - Renderizado 2D interactivo del cauce del Río Piraí con física de flujo y oleaje dinámico.
  - Modelado de estaciones y nodos canónicos: *Samaipata/Bermejo, La Angostura, El Torno, Cabañas del Piraí, Puente Mario Foianini y La Bélgica*.
  - Cálculo dinámico de **ETA de crecida** (tiempo estimado de arribo del turbión según velocidad de caudal y distancia entre nodos).

- **🛡️ Modo Ciudadano & Vigía:**
  - **Semáforo inteligente de seguridad fluvial:**  
    🟢 *Apto para bañistas* | 🟡 *Prohibido entrar (trampa climática)* | ⛔ *Zona mortal permanente (dragas)* | 🚨 *Evacuación inmediata*.
  - **Ficha técnica por nodo:** Profundidad, caudal, nivel histórico y radio de seguridad.
  - **Reportes ciudadanos geolocalizados:** Envío y visualización de incidencias validadas comunitariamente.

- **📡 Centro de Comando COED (Tactical Command):**
  - Consola de control institucional para monitoreo de estaciones hidrométricas.
  - Panel *"Modo Dios"* / Simulador de escenarios: Día recreativo, Crecida ordinaria de cuenca alta y Turbión extraordinario crítico.
  - **Línea de tiempo (Time Slider):** Proyección predictiva hacia adelante (+1h a +8h) para anticipar áreas de impacto.

- **📴 Protocolo de Contingencia SMS Offline:**
  - Generador de paquetes de texto estructurados para emisión de alertas de emergencia masivas vía SMS / difusión celular sin depender de internet móvil.

---

## 🏗️ Arquitectura del Software

El proyecto sigue una arquitectura modular y desacoplada organizada en `lib/`:

```text
lib/
├── core/
│   └── theme/
│       └── tactical_theme.dart       # Paleta visual táctica y dark mode para salas de crisis
├── flame/
│   └── simar_flame_game.dart         # Motor 2D del Gemelo Digital con componentes y física de agua
├── models/
│   ├── citizen_report.dart           # Modelo y validación de reportes comunitarios
│   ├── river_node.dart               # Modelo de nodos de aforo, coordenadas y umbrales de seguridad
│   └── scenario_type.dart            # Definición de escenarios de riesgo hidrológico
├── state/
│   └── simar_controller.dart         # Gestor de estado reactivo y simulación hidrometeorológica
└── ui/
    ├── screens/
    │   ├── simar_home_screen.dart    # Pantalla principal ciudadana
    │   └── coed_command_screen.dart  # Pantalla táctica para autoridades del COED
    └── widgets/
        ├── god_mode_panel.dart       # Panel de simulación de escenarios en vivo
        ├── node_safety_sheet.dart    # Hoja de detalle de seguridad de nodo seleccionado
        ├── offline_sms_dialog.dart   # Generador y despachador de alertas SMS offline
        ├── push_notification_banner.dart # Banner flotante reactivo a alertas rojas
        ├── tactical_header.dart      # Header con telemetría y métricas en vivo
        ├── time_slider_bar.dart      # Control deslizante temporal predictivo
        └── vigia_report_sheet.dart   # Formulario de reporte ciudadano
```

---

## 🛠️ Stack Tecnológico

- **Framework:** [Flutter](https://flutter.dev) (SDK Dart `>=3.10.0 <4.0.0`)
- **Motor 2D / Simulación:** [Flame Engine](https://flame-engine.org) (`^1.35.0`)
- **Diseño de Interfaz:** Material 3 con tema táctico personalizado (Dark & High-Contrast Safety)
- **Gestión de Estado:** `ChangeNotifier` / Reactive State Pattern

---

## 🚀 Instalación y Ejecución

### Prerrequisitos
- Tener instalado **Flutter SDK** (versión 3.10 o superior).
- Dispositivo Android/iOS físico, emulador o soporte para Chrome/Desktop.

### Pasos

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/RonaldGaymer2002/ElDuende.git
   cd ElDuende
   ```

2. **Obtener las dependencias:**
   ```bash
   flutter pub get
   ```

3. **Verificar el entorno:**
   ```bash
   flutter analyze
   ```

4. **Ejecutar la aplicación:**
   ```bash
   # En navegador web
   flutter run -d chrome

   # En Windows Desktop
   flutter run -d windows

   # En dispositivo móvil o emulador
   flutter run
   ```

---

## 👥 Equipo — Hackathon 2026

- **Proyecto:** El Duende (SIMAR)
- **Gobernación Departamental de Santa Cruz**
