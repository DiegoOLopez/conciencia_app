// ConciencIA — Pantalla principal tipo Maps.
// Permite elegir destino tocando el mapa y buscar rutas.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/route_request.dart';
import '../models/route_loading_state.dart';
import '../services/api_service.dart';
import '../widgets/route_loading_overlay.dart';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _PointSelection { origin, destination }

class _HomeScreenState extends State<HomeScreen> {
  final _mapController = MapController();
  bool _isLoading = false;

  LatLng _origin = const LatLng(
    AppConfig.demoOriginLat,
    AppConfig.demoOriginLon,
  );
  LatLng _destination = const LatLng(
    AppConfig.demoDestinationLat,
    AppConfig.demoDestinationLon,
  );
  _PointSelection _activeSelection = _PointSelection.destination;
  DateTime _departureTime = DateTime.now();
  TravelPriority _priority = TravelPriority.balanced;
  final Set<TransportMode> _selectedModes = {
    TransportMode.walk,
    TransportMode.metro,
    TransportMode.metrobus,
  };

  Future<void> _onSearchRoutes() async {
    if (_selectedModes.isEmpty) {
      _showError('Selecciona al menos un modo de transporte');
      return;
    }

    final request = RouteRequest(
      origin: Coordinate(lat: _origin.latitude, lon: _origin.longitude),
      destination: Coordinate(
        lat: _destination.latitude,
        lon: _destination.longitude,
      ),
      departureTime: _departureTime,
      transportModes: _selectedModes.toList(),
      priority: _priority,
    );

    setState(() => _isLoading = true);

    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.calculateRoutes(request);

      if (!mounted) return;

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ResultsScreen(response: response, request: request),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 420),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      _showError('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _selectPoint(LatLng point) {
    setState(() {
      if (_activeSelection == _PointSelection.origin) {
        _origin = point;
      } else {
        _destination = point;
      }
    });
  }

  void _moveToDemoDestination() {
    const point = LatLng(
      AppConfig.demoDestinationLat,
      AppConfig.demoDestinationLon,
    );
    setState(() => _destination = point);
    _mapController.move(point, 15.8);
  }

  void _swapRoutePoints() {
    setState(() {
      final previousOrigin = _origin;
      _origin = _destination;
      _destination = previousOrigin;
    });
  }

  void _centerDemoArea() {
    _mapController.move(
      const LatLng(AppConfig.defaultLat, AppConfig.defaultLon),
      AppConfig.defaultZoom,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildMap()),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: _buildSearchBar(),
          ),
          Positioned(
            right: 16,
            bottom: 218 + bottomPadding,
            child: Column(
              children: [
                _buildFloatingButton(
                  icon: Icons.school_rounded,
                  tooltip: 'Tec CCM',
                  onTap: _moveToDemoDestination,
                ),
                const SizedBox(height: 10),
                _buildFloatingButton(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Centrar Tlalpan',
                  onTap: _centerDemoArea,
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomPanel(bottomPadding),
          ),
          
          // Overlay de carga mientras se calculan rutas
          if (_isLoading)
            Positioned.fill(
              child: RouteLoadingOverlay(
                message: RouteLoadingState.calculating.message,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(AppConfig.defaultLat, AppConfig.defaultLon),
        initialZoom: AppConfig.defaultZoom,
        onTap: (tapPosition, point) => _selectPoint(point),
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
              color: const Color(0xFF1A73E8).withValues(alpha: 0.07),
              borderColor: const Color(0xFF1A73E8).withValues(alpha: 0.22),
              borderStrokeWidth: 2,
            ),
          ],
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: [_origin, _destination],
              color: Colors.white.withValues(alpha: 0.95),
              strokeWidth: 8,
            ),
            Polyline(
              points: [_origin, _destination],
              color: const Color(0xFF1A73E8),
              strokeWidth: 4,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            _buildMapMarker(
              point: _origin,
              icon: Icons.trip_origin_rounded,
              color: const Color(0xFF188038),
              label: 'Origen',
            ),
            _buildMapMarker(
              point: _destination,
              icon: Icons.place_rounded,
              color: const Color(0xFFD93025),
              label: 'Destino',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Material(
      color: Colors.white,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(height: 15),
                _buildRouteDot(const Color(0xFF188038), hollow: true),
                Container(
                  width: 2,
                  height: 28,
                  color: const Color(0xFFDADCE0),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
                _buildRouteDot(const Color(0xFFD93025)),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  _buildLocationField(
                    label: 'Origen',
                    value: _formatPoint(_origin),
                    selection: _PointSelection.origin,
                  ),
                  const Divider(height: 14, color: Color(0xFFE8EAED)),
                  _buildLocationField(
                    label: 'Destino',
                    value: _formatPoint(_destination),
                    selection: _PointSelection.destination,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _activeSelection == _PointSelection.origin
                          ? 'Toca el mapa para seleccionar origen'
                          : 'Toca el mapa para seleccionar destino',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1A73E8),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Column(
              children: [
                IconButton(
                  tooltip: 'Intercambiar origen y destino',
                  onPressed: _swapRoutePoints,
                  icon: const Icon(Icons.swap_vert_rounded),
                  color: const Color(0xFF5F6368),
                ),
                Text(
                  'ConciencIA',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF1A73E8),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteDot(Color color, {bool hollow = false}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: hollow ? Colors.white : color,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
    );
  }

  Widget _buildLocationField({
    required String label,
    required String value,
    required _PointSelection selection,
  }) {
    final selected = _activeSelection == selection;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() => _activeSelection = selection),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8F0FE) : const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFF1A73E8) : const Color(0xFFE8EAED),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: selected
                          ? const Color(0xFF1A73E8)
                          : const Color(0xFF5F6368),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF202124),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.touch_app_rounded
                  : Icons.edit_location_alt_outlined,
              color: selected
                  ? const Color(0xFF1A73E8)
                  : const Color(0xFF5F6368),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  String _formatPoint(LatLng point) {
    return '${point.latitude.toStringAsFixed(4)}, '
        '${point.longitude.toStringAsFixed(4)}';
  }

  Widget _buildBottomPanel(double bottomPadding) {
    return Material(
      color: Colors.white,
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.24),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 14, 16, bottomPadding + 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDADCE0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildTimeRow(),
            const SizedBox(height: 10),
            _buildPriorityControl(),
            const SizedBox(height: 12),
            _buildModeChips(),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _onSearchRoutes,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.directions_rounded),
                label: Text(
                  _isLoading ? 'Buscando rutas' : 'Buscar rutas seguras',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow() {
    return Row(
      children: [
        const Icon(Icons.schedule_rounded, size: 18, color: Color(0xFF5F6368)),
        const SizedBox(width: 8),
        Text(
          DateFormat('HH:mm · d MMM').format(_departureTime),
          style: GoogleFonts.inter(
            color: const Color(0xFF5F6368),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _departureTime = DateTime.now().add(const Duration(minutes: 15));
            });
          },
          icon: const Icon(Icons.add_alarm_rounded, size: 16),
          label: const Text('En 15 min'),
        ),
      ],
    );
  }

  Widget _buildPriorityControl() {
    return SegmentedButton<TravelPriority>(
      segments: TravelPriority.values.map((priority) {
        return ButtonSegment<TravelPriority>(
          value: priority,
          icon: Icon(_priorityIcon(priority), size: 17),
          label: Text(priority.label),
        );
      }).toList(),
      selected: {_priority},
      showSelectedIcon: false,
      onSelectionChanged: (selection) {
        setState(() => _priority = selection.first);
      },
    );
  }

  Widget _buildModeChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TransportMode.values.map((mode) {
        final selected = _selectedModes.contains(mode);
        return FilterChip(
          selected: selected,
          showCheckmark: false,
          avatar: Icon(
            _modeIcon(mode),
            size: 17,
            color: selected ? const Color(0xFF1A73E8) : const Color(0xFF5F6368),
          ),
          label: Text(mode.label),
          onSelected: (value) {
            setState(() {
              if (value) {
                _selectedModes.add(mode);
              } else {
                _selectedModes.remove(mode);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        elevation: 5,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: const Color(0xFF1A73E8), size: 22),
          ),
        ),
      ),
    );
  }

  Marker _buildMapMarker({
    required LatLng point,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Marker(
      point: point,
      width: 150,
      height: 70,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDADCE0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 15),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF202124),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Icon(Icons.location_pin, color: color, size: 32),
        ],
      ),
    );
  }

  IconData _priorityIcon(TravelPriority priority) {
    return switch (priority) {
      TravelPriority.speed => Icons.speed_rounded,
      TravelPriority.safety => Icons.shield_outlined,
      TravelPriority.balanced => Icons.tune_rounded,
    };
  }

  IconData _modeIcon(TransportMode mode) {
    return switch (mode) {
      TransportMode.walk => Icons.directions_walk_rounded,
      TransportMode.bike => Icons.directions_bike_rounded,
      TransportMode.lightRail => Icons.tram_rounded,
      TransportMode.rtp => Icons.directions_bus_rounded,
      TransportMode.bus => Icons.directions_bus_rounded,
      TransportMode.metro => Icons.subway_rounded,
      TransportMode.metrobus => Icons.directions_bus_filled_rounded,
      TransportMode.trolleybus => Icons.ev_station_rounded,
      TransportMode.car => Icons.directions_car_rounded,
    };
  }
}
