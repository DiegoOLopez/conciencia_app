// ConciencIA — Tarjeta de ruta.
// Muestra score, tiempo, riesgo y desglose de segmentos por modo.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/route_request.dart';
import '../models/route_response.dart';

class RouteCard extends StatelessWidget {
  final RouteOption route;
  final bool isSelected;
  final Color color;

  const RouteCard({
    super.key,
    required this.route,
    required this.isSelected,
    required this.color,
  });

  // Colores de modos (espeja map_widget)
  static Color _modeColor(TransportMode mode) {
    switch (mode) {
      case TransportMode.walk:
        return const Color(0xFF757575);
      case TransportMode.bike:
        return const Color(0xFF34A853);
      case TransportMode.lightRail:
        return const Color(0xFF7B1FA2);
      case TransportMode.rtp:
        return const Color(0xFF00897B);
      case TransportMode.metro:
        return const Color(0xFFE53935);
      case TransportMode.metrobus:
        return const Color(0xFFD81B60);
      case TransportMode.bus:
        return const Color(0xFF1976D2);
      case TransportMode.car:
        return const Color(0xFF424242);
      case TransportMode.trolleybus:
        return const Color(0xFF0288D1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isSelected ? 0.12 : 0.05),
            blurRadius: isSelected ? 24 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Colors.white.withValues(alpha: 0.95) 
                  : Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? color.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.4),
                width: isSelected ? 2.5 : 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // ── Header: Rank + Tiempo + Íconos ──────────────────────────────
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '#${route.rank}',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${route.totalTimeMinutes.toStringAsFixed(0)} min',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF202124),
                      ),
                    ),
                    Text(
                      route.summary,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF5F6368),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: route.transportModesUsed
                    .take(3)
                    .map(
                      (mode) => Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(
                          mode.icon,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Barra de segmentos proporcional (estilo Google Maps) ─────────
          _buildSegmentBar(),

          const SizedBox(height: 10),

          // ── Barra de riesgo ──────────────────────────────────────────────
          _buildRiskBar(),

          const SizedBox(height: 10),

          // ── Explicación ──────────────────────────────────────────────────
          Flexible(
            child: Text(
              route.explanation,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF3C4043),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 8),

          // ── Tags ─────────────────────────────────────────────────────────
          if (route.tags.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: route.tags.take(3).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF5F6368),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
          ),
        ),
      ),
    );
  }

  /// Barra proporcional por segmento + chips de modo con distancia
  Widget _buildSegmentBar() {
    if (route.segments.isEmpty) return const SizedBox.shrink();

    final totalDist = route.totalDistanceKm > 0 ? route.totalDistanceKm : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de color proporcional
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: route.segments.map((seg) {
              final frac = (seg.distanceKm / totalDist).clamp(0.03, 1.0);
              final col = _modeColor(seg.mode);
              final isWalk = seg.mode == TransportMode.walk;
              return Expanded(
                flex: (frac * 1000).round(),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: isWalk ? col.withValues(alpha: 0.4) : col,
                    border: isWalk
                        ? Border.all(color: col.withValues(alpha: 0.6), width: 0.5)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 6),
        // Chips por segmento
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: route.segments.map((seg) {
            final col = _modeColor(seg.mode);
            final isWalk = seg.mode == TransportMode.walk;
            final distLabel = isWalk
                ? '${(seg.distanceKm * 1000).round()}m'
                : '${seg.distanceKm.toStringAsFixed(1)}km';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: col.withValues(alpha: isWalk ? 0.08 : 0.13),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: col.withValues(alpha: isWalk ? 0.22 : 0.38),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(seg.mode.icon, style: const TextStyle(fontSize: 11)),
                  const SizedBox(width: 3),
                  Text(
                    distLabel,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isWalk
                          ? col.withValues(alpha: 0.85)
                          : col,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRiskBar() {
    final riskNorm = route.riskScore / 100;
    final riskColor = Color.lerp(
      const Color(0xFF188038),
      const Color(0xFFD93025),
      riskNorm,
    )!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shield_outlined, size: 14, color: riskColor),
            const SizedBox(width: 4),
            Text(
              'Riesgo: ${route.riskScore.toStringAsFixed(0)}/100',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: riskColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${route.totalDistanceKm.toStringAsFixed(1)} km',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF5F6368),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: riskNorm,
            backgroundColor: const Color(0xFFE8EAED),
            valueColor: AlwaysStoppedAnimation(riskColor),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
