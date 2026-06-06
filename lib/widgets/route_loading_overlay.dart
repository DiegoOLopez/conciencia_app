// ConciencIA — Overlay de carga de rutas.
// Muestra feedback visual mientras se calculan y renderizan las rutas.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RouteLoadingOverlay extends StatefulWidget {
  final String message;
  final VoidCallback? onCancel;

  const RouteLoadingOverlay({
    super.key,
    required this.message,
    this.onCancel,
  });

  @override
  State<RouteLoadingOverlay> createState() => _RouteLoadingOverlayState();
}

class _RouteLoadingOverlayState extends State<RouteLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Spinner animado
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF1A73E8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mensaje de estado
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF202124),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Submensaje
                  Text(
                    'Analizando opciones de transporte',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF5F6368),
                    ),
                  ),

                  // Botón de cancelar (opcional)
                  if (widget.onCancel != null) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: widget.onCancel,
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5F6368),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Made with Bob
