// ConciencIA — Widget de mapa con flutter_map.
// Muestra rutas con polylines de colores sobre tiles claros tipo navegacion.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/app_config.dart';
import '../models/route_request.dart';
import '../models/route_response.dart';

class ConcienciaMapWidget extends StatefulWidget {
  final List<RouteOption> routes;
  final List<ParadaTransporte>? paradasTransporte;
  final int selectedIndex;
  final double originLat;
  final double originLon;
  final double destLat;
  final double destLon;

  const ConcienciaMapWidget({
    super.key,
    required this.routes,
    this.paradasTransporte,
    required this.selectedIndex,
    required this.originLat,
    required this.originLon,
    required this.destLat,
    required this.destLon,
  });

  @override
  State<ConcienciaMapWidget> createState() => _ConcienciaMapWidgetState();
}

class _ConcienciaMapWidgetState extends State<ConcienciaMapWidget> {
  late final MapController _mapController;

  // Colores específicos por modo de transporte
  static Color _getModeColor(String mode) {
    switch (mode) {
      case 'WALK':
        return const Color(0xFF5F6368); // Gris
      case 'BIKE':
        return const Color(0xFF34A853); // Verde
      case 'LIGHT_RAIL':
        return const Color(0xFFFF6D00); // Naranja (Tren Ligero)
      case 'RTP':
        return const Color(0xFF00897B); // Verde azulado (RTP)
      case 'METRO':
        return const Color(0xFFFF1744); // Rojo (Metro)
      case 'METROBUS':
        return const Color(0xFFD81B60); // Rosa (Metrobús)
      case 'BUS':
        return const Color(0xFF1976D2); // Azul (Bus)
      case 'CAR':
        return const Color(0xFF424242); // Gris oscuro
      default:
        return const Color(0xFF1A73E8); // Azul por defecto
    }
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(ConcienciaMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _fitSelectedRoute();
    }
  }

  void _fitSelectedRoute() {
    if (widget.routes.isEmpty ||
        widget.selectedIndex < 0 ||
        widget.selectedIndex >= widget.routes.length) {
      _mapController.move(
        const LatLng(AppConfig.defaultLat, AppConfig.defaultLon),
        AppConfig.defaultZoom,
      );
      return;
    }

    final route = widget.routes[widget.selectedIndex];
    final allPoints = <LatLng>[
      LatLng(widget.originLat, widget.originLon),
      LatLng(widget.destLat, widget.destLon),
    ];

    for (final segment in route.segments) {
      for (final point in segment.polyline) {
        if (point.length >= 2) {
          allPoints.add(LatLng(point[0], point[1]));
        }
      }
    }

    if (allPoints.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(allPoints);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.fromLTRB(60, 100, 60, 300),
          maxZoom: 16.2,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(
          (widget.originLat + widget.destLat) / 2,
          (widget.originLon + widget.destLon) / 2,
        ),
        initialZoom: AppConfig.defaultZoom,
        onMapReady: _fitSelectedRoute,
      ),
      children: [
        TileLayer(
          urlTemplate: AppConfig.osmTileUrl,
          userAgentPackageName: 'com.conciencia.app',
          subdomains: const ['a', 'b', 'c', 'd'],
          retinaMode: RetinaMode.isHighDensity(context),
          maxNativeZoom: 20,
          errorTileCallback: (tile, error, stackTrace) {},
        ),

        CircleLayer(
          circles: [
            CircleMarker(
              point: const LatLng(
                AppConfig.demoDestinationLat,
                AppConfig.demoDestinationLon,
              ),
              radius: 1150,
              useRadiusInMeter: true,
              color: const Color(0xFF1A73E8).withValues(alpha: 0.08),
              borderColor: const Color(0xFF1A73E8).withValues(alpha: 0.28),
              borderStrokeWidth: 2,
            ),
          ],
        ),

        PolylineLayer(polylines: _buildPolylines()),

        MarkerLayer(
          markers: [
            if (widget.paradasTransporte != null)
              ...widget.paradasTransporte!.map((p) => _buildTransitMarker(p)),
            _buildMarker(
              widget.originLat,
              widget.originLon,
              Icons.my_location_rounded,
              const Color(0xFF1A73E8),
              'Origen',
            ),
            _buildMarker(
              widget.destLat,
              widget.destLon,
              Icons.flag_rounded,
              const Color(0xFFEA4335),
              'Destino',
            ),
            _buildAreaLabel(),
          ],
        ),
      ],
    );
  }

  Marker _buildTransitMarker(ParadaTransporte parada) {
    Color color = Color(int.parse(parada.color.replaceFirst('#', '0xFF')));
    IconData icon = parada.tipo == 'RTP' ? Icons.directions_bus : Icons.tram;
    return Marker(
      point: LatLng(parada.lat, parada.lon),
      width: 24,
      height: 24,
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }

  List<Polyline> _buildPolylines() {
    final polylines = <Polyline>[];

    // ── Rutas no seleccionadas (tenues, sin borde) ──────────────────────────
    for (int i = 0; i < widget.routes.length; i++) {
      if (i == widget.selectedIndex) continue;

      for (final segment in widget.routes[i].segments) {
        final points = segment.polyline
            .where((p) => p.length >= 2)
            .map((p) => LatLng(p[0], p[1]))
            .toList();
        if (points.isEmpty) continue;

        final modeColor = _getModeColor(segment.mode.value);
        final isWalk = segment.mode == TransportMode.walk;

        polylines.add(
          Polyline(
            points: points,
            color: modeColor.withValues(alpha: 0.35),
            strokeWidth: isWalk ? 3 : 4,
            pattern: isWalk
                ? const StrokePattern.dotted(spacingFactor: 1.5)
                : const StrokePattern.solid(),
          ),
        );
      }
    }

    // ── Ruta seleccionada (encima, con borde blanco) ────────────────────────
    if (widget.selectedIndex < widget.routes.length) {
      final selectedRoute = widget.routes[widget.selectedIndex];

      for (final segment in selectedRoute.segments) {
        final points = segment.polyline
            .where((p) => p.length >= 2)
            .map((p) => LatLng(p[0], p[1]))
            .toList();
        if (points.isEmpty) continue;

        final modeColor = _getModeColor(segment.mode.value);
        final isWalk = segment.mode == TransportMode.walk;

        if (isWalk) {
          // Caminata: línea punteada gris oscuro sin borde (visualmente distinta)
          polylines.add(
            Polyline(
              points: points,
              color: modeColor.withValues(alpha: 0.9),
              strokeWidth: 4,
              pattern: const StrokePattern.dotted(spacingFactor: 1.8),
            ),
          );
        } else {
          // Transporte/auto: línea sólida con borde blanco
          polylines.add(
            Polyline(
              points: points,
              color: Colors.white.withValues(alpha: 0.96),
              strokeWidth: 10,
            ),
          );
          polylines.add(
            Polyline(
              points: points,
              color: modeColor,
              strokeWidth: 6,
            ),
          );
        }
      }
    }

    return polylines;
  }


  Marker _buildMarker(
    double lat,
    double lon,
    IconData icon,
    Color color,
    String label,
  ) {
    return Marker(
      point: LatLng(lat, lon),
      width: 150,
      height: 76,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF202124),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.24),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildAreaLabel() {
    return Marker(
      point: const LatLng(
        AppConfig.demoDestinationLat,
        AppConfig.demoDestinationLon,
      ),
      width: 180,
      height: 36,
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF1A73E8).withValues(alpha: 0.24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'Zona demo Tlalpan',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1A73E8),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
