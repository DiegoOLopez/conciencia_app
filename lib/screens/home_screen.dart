// ConciencIA — Pantalla principal tipo Maps.
// Permite elegir destino tocando el mapa y buscar rutas.

import 'dart:ui';
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 18),
                      _buildRouteDot(const Color(0xFF188038), hollow: true),
                      Container(
                        width: 2,
                        height: 32,
                        color: const Color(0xFFDADCE0),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      _buildRouteDot(const Color(0xFFD93025)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        _buildLocationField(
                          label: 'Origen',
                          value: _formatPoint(_origin),
                          selection: _PointSelection.origin,
                        ),
                        const Divider(height: 16, color: Color(0x66E8EAED)),
                        _buildLocationField(
                          label: 'Destino',
                          value: _formatPoint(_destination),
                          selection: _PointSelection.destination,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: _swapRoutePoints,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.swap_vert_rounded, color: Color(0xFF5F6368)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'C·IA',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF1A73E8),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _activeSelection = selection),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1A73E8).withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? const Color(0xFF1A73E8).withValues(alpha: 0.3) : Colors.transparent,
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
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF202124),
                        fontSize: 15,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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
                    : const Color(0xFF5F6368).withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPoint(LatLng point) {
    return '${point.latitude.toStringAsFixed(4)}, '
        '${point.longitude.toStringAsFixed(4)}';
  }

  Widget _buildBottomPanel(double bottomPadding) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.8))),
            ),
            padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPadding + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDADCE0).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTimeRow(),
                const SizedBox(height: 16),
                _buildPriorityControl(),
                const SizedBox(height: 16),
                _buildModeChips(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _onSearchRoutes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.directions_rounded, size: 24),
                    label: Text(
                      _isLoading ? 'Buscando rutas...' : 'Buscar rutas',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TravelPriority.values.map((priority) {
          final isSelected = _priority == priority;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(priority.label),
              avatar: Icon(
                _priorityIcon(priority),
                size: 16,
                color: isSelected ? const Color(0xFF1A73E8) : const Color(0xFF5F6368),
              ),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: const Color(0xFFE8F0FE),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? const Color(0xFF1A73E8).withValues(alpha: 0.5) : const Color(0xFFDADCE0),
              ),
              labelStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF1A73E8) : const Color(0xFF3C4043),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _priority = priority);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModeChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TransportMode.values.map((mode) {
          final selected = _selectedModes.contains(mode);
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
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
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Material(
              color: Colors.white.withValues(alpha: 0.85),
              child: InkWell(
                onTap: onTap,
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: Icon(icon, color: const Color(0xFF1A73E8), size: 24),
                ),
              ),
            ),
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
      TravelPriority.speed => Icons.flash_on_rounded,
      TravelPriority.fastest => Icons.bolt_rounded,
      TravelPriority.safety => Icons.shield_rounded,
      TravelPriority.balanced => Icons.balance_rounded,
      TravelPriority.shortest => Icons.straighten_rounded,
      TravelPriority.accessible => Icons.accessible_forward_rounded,
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
