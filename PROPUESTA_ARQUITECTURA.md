# 🌿 El Duende — Sistema de Gestión de Riesgo y Alerta Temprana (GovRisk)

> **Hackathon Gobernación de Santa Cruz**  
> **Vertical:** 🌿 **GovRisk** (Prevención de inundaciones, turbiones, sequías y emergencias hidrometeorológicas)  
> **Propuesta:** App ciudadana y dashboard institucional para monitoreo diario del Río Piraí, índices de confort térmico y sistema de alerta temprana ante turbiones y desastres.

---

## 1. Problema Real Cruceño

1. **Turbiones en el Río Piraí:** Avenidas repentinas de agua originadas en la cuenca alta (Bermejo / Angostura) tardan entre 4 a 8 horas en llegar a las cabañas del Piraí y zonas metropolitanas. Los bañistas y dragueros no tienen aviso anticipado local.
2. **Olas de calor y vientos extremos:** Temperaturas de más de 40°C e incendios forestales / sequías sin un índice de riesgo preventivo unificado.
3. **Falta de canal directo y bidireccional:** El ciudadano se entera tarde por redes sociales y no puede reportar incidentes geolocalizados en tiempo real hacia el SEARPI / Gobernación.

---

## 2. Propuesta de Arquitectura & Reutilización de Activos

Aprovechando la experiencia de **GeoPlan Web** (GIS / Mapas / Capas georreferenciadas) y **AgroLog / Google** (sensores, IoT, telemetría y predicción):

### 2.1 Módulos Clave
- **Dual-State App (Ciudadano):**
  - **Modo Diario (Día a Día):** Semáforo del Río Piraí (Verde / Amarillo / Rojo), niveles de radiación UV y calor extremo, zonas recreativas seguras.
  - **Modo Alerta (Simulador & Emergencia):** Cuando la cuenca alta supera umbrales críticos, la UI cambia a estado de emergencia con tiempo estimado de llegada del turbión (*ETA de crecida*), zonas de evacuación y mapas de calor.
- **Centro de Comando GovRisk (Web Dashboard):**
  - Vista geoespacial con capas de microcuencas del Piraí.
  - Telemetría simulada/real de estaciones hidrométricas.
  - Emisión de alertas por zonas/radios geográficos.
- **Reportes Ciudadanos Geolocalizados:** Validación comunitaria de incidentes con fotos y coordenadas (evitando falsas alarmas).

---

## 3. Stack Técnico Propuesto

- **Frontend & App PWA:** Next.js / React + Tailwind CSS + Mapbox GL / Leaflet (migrado desde GeoPlan).
- **Backend & Alertas:** Node.js (TypeScript) + Serverless / WebSockets para actualización en tiempo real de telemetría.
- **Capa Geoespacial:** GeoJSON de la cuenca del Piraí, radios de buffer y zonas de riesgo de inundación.

---

## 4. Estructura del Repositorio

```text
ElDuende/
├── apps/
│   ├── web-ciudadano/     # App PWA móvil-first para el cruceño
│   └── gov-dashboard/     # Panel administrativo para autoridades / SEARPI
├── packages/
│   ├── geo-core/          # Módulos de mapas y capas (GeoPlan)
│   ├── telemetry-engine/  # Cálculos de turbión, ETA y alertas (AgroLog)
│   └── ui/                # Componentes compartidos de alertas y semáforos
└── README.md
```
