// ConciencIA — Servicio de API.
// Se conecta al backend FastAPI para solicitar rutas.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/route_request.dart';
import '../models/route_response.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({String? baseUrl, http.Client? client})
    : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
      _client = client ?? http.Client();

  /// Solicita las 3 mejores rutas al backend.
  Future<RouteResponse> calculateRoutes(RouteRequest request) async {
    final url = Uri.parse('$baseUrl/api/v1/routes');

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return RouteResponse.fromJson(json);
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw ApiException(
          'Error de validación: ${error['detail'] ?? 'Request inválido'}',
          statusCode: 400,
        );
      } else if (response.statusCode == 429) {
        throw ApiException(
          'Demasiadas solicitudes. Espera un momento.',
          statusCode: 429,
        );
      } else {
        throw ApiException(
          'Error del servidor (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException {
      throw ApiException('Sin conexión al servidor. Verifica tu internet.');
    }
  }

  /// Solicita los puntos de crímenes para el mapa de calor.
  Future<List<List<double>>> getHeatmap(
      double minLat, double minLon, double maxLat, double maxLon) async {
    final url = Uri.parse(
        '$baseUrl/api/v1/heatmap?min_lat=$minLat&min_lon=$minLon&max_lat=$maxLat&max_lon=$maxLon');

    try {
      final response = await _client
          .get(url)
          .timeout(Duration(seconds: AppConfig.httpTimeoutSeconds));

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        return json.map((e) => [(e[0] as num).toDouble(), (e[1] as num).toDouble()]).toList();
      } else {
        throw ApiException(
          'Error obteniendo heatmap (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException {
      throw ApiException('Sin conexión al servidor al obtener heatmap.');
    }
  }

  /// Verifica que el backend esté disponible.
  Future<bool> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
