// ConciencIA — Modelo de request de ruta.
// Espeja los schemas Pydantic del backend.

class Coordinate {
  final double lat;
  final double lon;

  const Coordinate({required this.lat, required this.lon});

  Map<String, dynamic> toJson() => {'lat': lat, 'lon': lon};

  factory Coordinate.fromJson(Map<String, dynamic> json) =>
      Coordinate(lat: json['lat'] as double, lon: json['lon'] as double);
}

enum TransportMode {
  walk('WALK', 'Caminar', '🚶'),
  bus('BUS', 'Camión', '🚌'),
  metro('METRO', 'Metro', '🚇'),
  metrobus('METROBUS', 'Metrobús', '🚍'),
  trolleybus('TROLLEYBUS', 'Trolebús', '🚎'),
  bike('BIKE', 'Bicicleta', '🚲'),
  car('CAR', 'Auto', '🚗');

  const TransportMode(this.value, this.label, this.icon);
  final String value;
  final String label;
  final String icon;
}

enum TravelPriority {
  speed('SPEED', 'Rápido', '🚀'),
  safety('SAFETY', 'Seguro', '🛡️'),
  balanced('BALANCED', 'Equilibrado', '⚖️');

  const TravelPriority(this.value, this.label, this.icon);
  final String value;
  final String label;
  final String icon;
}

class RouteRequest {
  final Coordinate origin;
  final Coordinate destination;
  final DateTime departureTime;
  final List<TransportMode> transportModes;
  final TravelPriority priority;

  const RouteRequest({
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.transportModes,
    required this.priority,
  });

  Map<String, dynamic> toJson() => {
    'origin': origin.toJson(),
    'destination': destination.toJson(),
    'departure_time': departureTime.toIso8601String(),
    'transport_modes': transportModes.map((m) => m.value).toList(),
    'priority': priority.value,
  };
}
