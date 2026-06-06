// ConciencIA — Modelo de response de ruta.

import 'route_request.dart';

class Segment {
  final TransportMode mode;
  final List<List<double>> polyline;
  final double distanceKm;
  final double durationMinutes;
  final double riskScore;
  final String description;
  final String? transitLine;
  final int? transitStops;

  const Segment({
    required this.mode,
    required this.polyline,
    required this.distanceKm,
    required this.durationMinutes,
    required this.riskScore,
    required this.description,
    this.transitLine,
    this.transitStops,
  });

  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(
      mode: TransportMode.values.firstWhere(
        (m) => m.value == json['mode'],
        orElse: () => TransportMode.walk,
      ),
      polyline: (json['polyline'] as List)
          .map((p) => (p as List).map((c) => (c as num).toDouble()).toList())
          .toList(),
      distanceKm: (json['distance_km'] as num).toDouble(),
      durationMinutes: (json['duration_minutes'] as num).toDouble(),
      riskScore: (json['risk_score'] as num).toDouble(),
      description: json['description'] as String,
      transitLine: json['transit_line'] as String?,
      transitStops: json['transit_stops'] as int?,
    );
  }
}

class RouteOption {
  final int rank;
  final List<Segment> segments;
  final double totalTimeMinutes;
  final double totalDistanceKm;
  final double riskScore;
  final double accessibilityScore;
  final String explanation;
  final String summary;
  final List<TransportMode> transportModesUsed;
  final List<String> tags;

  const RouteOption({
    required this.rank,
    required this.segments,
    required this.totalTimeMinutes,
    required this.totalDistanceKm,
    required this.riskScore,
    required this.accessibilityScore,
    required this.explanation,
    required this.summary,
    required this.transportModesUsed,
    required this.tags,
  });

  factory RouteOption.fromJson(Map<String, dynamic> json) {
    return RouteOption(
      rank: json['rank'] as int,
      segments: (json['segments'] as List)
          .map((s) => Segment.fromJson(s as Map<String, dynamic>))
          .toList(),
      totalTimeMinutes: (json['total_time_minutes'] as num).toDouble(),
      totalDistanceKm: (json['total_distance_km'] as num).toDouble(),
      riskScore: (json['risk_score'] as num).toDouble(),
      accessibilityScore: (json['accessibility_score'] as num).toDouble(),
      explanation: json['explanation'] as String,
      summary: json['summary'] as String,
      transportModesUsed: (json['transport_modes_used'] as List)
          .map(
            (m) => TransportMode.values.firstWhere(
              (t) => t.value == m,
              orElse: () => TransportMode.walk,
            ),
          )
          .toList(),
      tags: (json['tags'] as List).map((t) => t as String).toList(),
    );
  }
}

class RouteRecommendation {
  final String rutaId;
  final double score;
  final String razon;

  const RouteRecommendation({
    required this.rutaId,
    required this.score,
    required this.razon,
  });

  factory RouteRecommendation.fromJson(Map<String, dynamic> json) {
    return RouteRecommendation(
      rutaId: json['ruta_id'] as String,
      score: (json['score'] as num).toDouble(),
      razon: json['razon'] as String,
    );
  }
}

class ParadaTransporte {
  final double lat;
  final double lon;
  final String nombre;
  final String tipo;
  final String color;

  const ParadaTransporte({
    required this.lat,
    required this.lon,
    required this.nombre,
    required this.tipo,
    required this.color,
  });

  factory ParadaTransporte.fromJson(Map<String, dynamic> json) {
    return ParadaTransporte(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      nombre: json['nombre'] as String,
      tipo: json['tipo'] as String,
      color: json['color'] as String,
    );
  }
}

class RouteResponse {
  final List<RouteOption> routes;
  final RouteRecommendation? recommendation;
  final List<ParadaTransporte>? paradasTransporte;
  final String requestId;
  final DateTime computedAt;
  final double computationTimeMs;

  const RouteResponse({
    required this.routes,
    this.recommendation,
    this.paradasTransporte,
    required this.requestId,
    required this.computedAt,
    required this.computationTimeMs,
  });

  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    return RouteResponse(
      routes: (json['routes'] as List)
          .map((r) => RouteOption.fromJson(r as Map<String, dynamic>))
          .toList(),
      recommendation: json['recomendacion'] != null 
          ? RouteRecommendation.fromJson(json['recomendacion'] as Map<String, dynamic>)
          : null,
      paradasTransporte: json['paradas_transporte'] != null
          ? (json['paradas_transporte'] as List)
              .map((p) => ParadaTransporte.fromJson(p as Map<String, dynamic>))
              .toList()
          : null,
      requestId: json['request_id'] as String,
      computedAt: DateTime.parse(json['computed_at'] as String),
      computationTimeMs: (json['computation_time_ms'] as num).toDouble(),
    );
  }
}
