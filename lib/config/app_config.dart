/// ConciencIA — Configuración de la app.
class AppConfig {
  /// URL base del backend.
  /// En desarrollo local: http://10.0.2.2:8000 (emulador Android)
  /// o http://localhost:8000 (web/iOS simulator)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  /// Timeout para requests HTTP en segundos.
  static const int httpTimeoutSeconds = 60;

  /// Zona de demo: Tlalpan, alrededor de Tec de Monterrey Campus Ciudad de Mexico.
  static const double demoOriginLat = 19.2944;
  static const double demoOriginLon = -99.1627;
  static const double demoDestinationLat = 19.2836;
  static const double demoDestinationLon = -99.1369;

  /// Centro default para el mapa.
  static const double defaultLat = 19.2890;
  static const double defaultLon = -99.1498;
  static const double defaultZoom = 14.2;

  /// Tiles claros tipo navegacion para una lectura parecida a Google Maps.
  static const String osmTileUrl =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';

  /// Versión de la app.
  static const String appVersion = '1.0.0';
}
