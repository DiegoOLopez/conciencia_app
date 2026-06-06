// ConciencIA — Tarjeta de ruta.
// Muestra score, tiempo, riesgo y explicación.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? color.withValues(alpha: 0.72)
              : const Color(0xFFDADCE0),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isSelected ? 0.18 : 0.1),
            blurRadius: isSelected ? 18 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header: Rank + Tiempo + Badge ---
          Row(
            children: [
              // Badge de rank
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

              // Tiempo estimado
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

              // Íconos de modos de transporte
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

          const SizedBox(height: 12),

          // --- Barra de riesgo ---
          _buildRiskBar(),

          const SizedBox(height: 12),

          // --- Explicación ---
          Expanded(
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

          // --- Tags ---
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
