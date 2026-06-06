// ConciencIA — Formulario de captura de ruta.
// Captura origen, destino, hora y preferencias.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../models/route_request.dart';
import '../screens/location_picker_screen.dart';

class RouteInputForm extends StatefulWidget {
  final Function(RouteRequest) onSubmit;
  final bool isLoading;

  const RouteInputForm({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<RouteInputForm> createState() => _RouteInputFormState();
}

class _RouteInputFormState extends State<RouteInputForm> {
  // Coordenadas default: Bellas Artes a Ángel de la Independencia
  LatLng _origin = const LatLng(19.4352, -99.1412);
  LatLng _destination = const LatLng(19.4270, -99.1676);

  DateTime _departureTime = DateTime.now();
  TravelPriority _priority = TravelPriority.balanced;

  final Set<TransportMode> _selectedModes = {
    TransportMode.walk,
    TransportMode.metro,
    TransportMode.metrobus,
  };

  void _submit() {
    if (_selectedModes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un modo de transporte'),
        ),
      );
      return;
    }

    widget.onSubmit(
      RouteRequest(
        origin: Coordinate(lat: _origin.latitude, lon: _origin.longitude),
        destination: Coordinate(
          lat: _destination.latitude,
          lon: _destination.longitude,
        ),
        departureTime: _departureTime,
        transportModes: _selectedModes.toList(),
        priority: _priority,
      ),
    );
  }

  Future<void> _pickLocation(bool isOrigin) async {
    final initialLoc = isOrigin ? _origin : _destination;
    final title = isOrigin ? 'Selecciona Origen' : 'Selecciona Destino';

    final LatLng? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LocationPickerScreen(initialLocation: initialLoc, title: title),
      ),
    );

    if (pickedLocation != null) {
      setState(() {
        if (isOrigin) {
          _origin = pickedLocation;
        } else {
          _destination = pickedLocation;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Origen y Destino (Interactivos con Mapa) ---
          _buildSectionLabel('📍 Origen', 'Toca para ubicar en el mapa'),
          const SizedBox(height: 8),
          _buildLocationSelector(
            icon: Icons.my_location_rounded,
            color: const Color(0xFF6C63FF),
            location: _origin,
            onTap: () => _pickLocation(true),
          ),

          const SizedBox(height: 20),

          _buildSectionLabel('🏁 Destino', 'Toca para ubicar en el mapa'),
          const SizedBox(height: 8),
          _buildLocationSelector(
            icon: Icons.flag_rounded,
            color: const Color(0xFFFF6B6B),
            location: _destination,
            onTap: () => _pickLocation(false),
          ),

          const SizedBox(height: 24),

          // --- Hora de salida ---
          _buildSectionLabel('🕐 Hora de salida', null),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: Color(0xFF00D9A6),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat(
                        'HH:mm — d MMMM yyyy',
                        'es',
                      ).format(_departureTime),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.edit_rounded,
                      color: Colors.white38,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- Prioridad ---
          _buildSectionLabel('⚡ Prioridad', '¿Qué prefieres optimizar?'),
          const SizedBox(height: 10),
          Row(
            children: TravelPriority.values.map((p) {
              final isSelected = _priority == p;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _priority = p),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6C63FF).withValues(alpha: 0.15)
                              : const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF6C63FF).withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.06),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(p.icon, style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 4),
                            Text(
                              p.label,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // --- Modos de transporte ---
          _buildSectionLabel(
            '🚌 Transporte',
            'Selecciona los modos permitidos',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TransportMode.values.map((mode) {
              final isSelected = _selectedModes.contains(mode);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedModes.remove(mode);
                      } else {
                        _selectedModes.add(mode);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF00D9A6).withValues(alpha: 0.12)
                          : const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF00D9A6).withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(mode.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          mode.label,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? const Color(0xFF00D9A6)
                                : Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // --- Botón de búsqueda ---
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                disabledBackgroundColor: const Color(
                  0xFF6C63FF,
                ).withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.route_rounded, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'Buscar rutas',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title, String? subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
          ),
      ],
    );
  }

  Widget _buildLocationSelector({
    required IconData icon,
    required Color color,
    required LatLng location,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.map_rounded, color: Colors.white38, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_departureTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFF6C63FF)),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _departureTime = DateTime(
          _departureTime.year,
          _departureTime.month,
          _departureTime.day,
          time.hour,
          time.minute,
        );
      });
    }
  }
}
