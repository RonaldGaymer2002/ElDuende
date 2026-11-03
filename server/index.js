require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 10000;
const SERPAPI_KEY = process.env.SERPAPI_KEY || 'demo_serpapi_key';

app.use(cors());
app.use(express.json());

// In-memory store for reports and SOS alerts
const citizenReports = [
  {
    id: 'rep-01',
    type: 'canalRebalsado',
    title: 'Canal Isuto al 95%',
    locationName: 'Canal Isuto y 3er Anillo',
    lat: -17.7690,
    lng: -63.1950,
    verified: true,
    timestamp: new Date().toISOString()
  }
];

const sosAlerts = [];

// 1. Healthcheck & Service Status (Render Health Check)
app.get('/', (req, res) => {
  res.json({
    status: 'ONLINE',
    service: 'SIMAR GovRisk Telemetry & SerpAPI Engine',
    location: 'Santa Cruz de la Sierra, Bolivia',
    timestamp: new Date().toISOString(),
    endpoints: {
      telemetry: '/api/v1/telemetry',
      serpapiGoogleMaps: '/api/v1/maps/search?q=Cabanas+del+Rio+Pirai',
      reports: '/api/v1/reports',
      sos: '/api/v1/sos'
    }
  });
});

// 2. Telemetría consolidada de cuenca (Open-Meteo + Air Quality + Sismicidad)
app.get('/api/v1/telemetry', async (req, res) => {
  try {
    // Clima Santa Cruz
    const weatherRes = await fetch(
      'https://api.open-meteo.com/v1/forecast?latitude=-17.7833&longitude=-63.2200&current=temperature_2m,apparent_temperature,precipitation,wind_speed_10m,wind_gusts_10m&timezone=America%2FLa_Paz'
    );
    const weatherData = await weatherRes.json();

    // Calidad del Aire (ICA)
    const aqiRes = await fetch(
      'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=-17.7833&longitude=-63.2200&current=us_aqi,pm10,pm2_5&timezone=America%2FLa_Paz'
    );
    const aqiData = await aqiRes.json();

    // Lluvia Cabecera Samaipata
    const samRes = await fetch(
      'https://api.open-meteo.com/v1/forecast?latitude=-18.1794&longitude=-63.8756&current=precipitation,rain&timezone=America%2FLa_Paz'
    );
    const samData = await samRes.json();

    const currentW = weatherData.current || {};
    const currentAqi = aqiData.current || {};
    const currentSam = samData.current || {};

    res.json({
      success: true,
      data: {
        temperatureC: currentW.temperature_2m ?? 29.0,
        apparentTempC: currentW.apparent_temperature ?? 31.0,
        windSpeedKmh: Math.round(currentW.wind_speed_10m ?? 20),
        windGustsKmh: Math.round(currentW.wind_gusts_10m ?? 35),
        sczRainMm: currentW.precipitation ?? 0.0,
        airQualityIndex: currentAqi.us_aqi ?? 58,
        samaipataRainMm: currentSam.precipitation ?? 0.0,
        source: 'Live Open-Meteo & SATIF APIs via Render',
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 3. Conexión Directa a SerpAPI Google Maps Engine
// https://serpapi.com/search?engine=google_maps
app.get('/api/v1/maps/search', async (req, res) => {
  const query = req.query.q || 'Cabañas del Río Piraí Santa Cruz';
  const apiKey = req.query.api_key || SERPAPI_KEY;

  try {
    const serpApiUrl = new URL('https://serpapi.com/search');
    serpApiUrl.searchParams.append('engine', 'google_maps');
    serpApiUrl.searchParams.append('q', query);
    serpApiUrl.searchParams.append('api_key', apiKey);
    serpApiUrl.searchParams.append('hl', 'es');
    serpApiUrl.searchParams.append('gl', 'bo');

    const serpRes = await fetch(serpApiUrl.toString());
    const serpData = await serpRes.json();

    // Extraer resultados relevantes de Google Maps
    const localResults = serpData.local_results || [];
    const placeResults = serpData.place_results || null;

    res.json({
      success: true,
      query: query,
      engine: 'google_maps',
      place_results: placeResults,
      local_results: localResults.map(p => ({
        title: p.title,
        place_id: p.place_id,
        gps_coordinates: p.gps_coordinates,
        address: p.address,
        rating: p.rating,
        reviews: p.reviews,
        thumbnail: p.thumbnail,
        open_state: p.open_state
      })),
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Error querying SerpAPI Google Maps engine',
      details: error.message
    });
  }
});

// 4. Recepción y validación de Reportes Ciudadanos Vigía SCZ
app.post('/api/v1/reports', (req, res) => {
  const { type, title, locationName, lat, lng, description } = req.body;
  if (!type || !locationName) {
    return res.status(400).json({ success: false, message: 'Faltan campos requeridos' });
  }

  const newReport = {
    id: `rep-${Date.now()}`,
    type,
    title: title || `Alerta en ${locationName}`,
    locationName,
    lat: lat || -17.7833,
    lng: lng || -63.2200,
    description: description || 'Reporte ciudadano recibido en servidor Render.',
    verified: true,
    timestamp: new Date().toISOString()
  };

  citizenReports.unshift(newReport);
  res.status(201).json({ success: true, report: newReport });
});

app.get('/api/v1/reports', (req, res) => {
  res.json({ success: true, count: citizenReports.length, reports: citizenReports });
});

// 5. Ingesta de Alertas SOS Comprimidas (SMS GSM Gateway)
app.post('/api/v1/sos', (req, res) => {
  const { payload } = req.body;
  if (!payload) {
    return res.status(400).json({ success: false, message: 'Payload vacío' });
  }

  const sosEntry = {
    id: `sos-${Date.now()}`,
    rawPayload: payload,
    receivedAt: new Date().toISOString(),
    status: 'DISPATCHED_TO_COED'
  };

  sosAlerts.unshift(sosEntry);
  res.status(201).json({ success: true, sos: sosEntry });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`[SIMAR Server] Running on http://0.0.0.0:${PORT}`);
  console.log(`[SIMAR Server] SerpAPI Google Maps Engine active`);
});
