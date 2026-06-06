// ConciencIA — Pantalla de resultados.
// Muestra mapa con 3 rutas y tarjetas con scores/explicaciones.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/route_request.dart';
import '../models/route_response.dart';
import '../models/route_loading_state.dart';
import '../widgets/map_widget.dart';
import '../widgets/route_card.dart';
import '../widgets/route_loading_overlay.dart';

class ResultsScreen extends StatefulWidget {
  final RouteResponse response;
  final RouteRequest request;

  const ResultsScreen({
    super.key,
    required this.response,
    required this.request,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedRouteIndex = 0;
  RouteLoadingState _loadingState = RouteLoadingState.rendering;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configurar animaciones
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Simular proceso de renderizado
    _startRenderingAnimation();
  }

  void _startRenderingAnimation() async {
    // Esperar un momento para que el usuario vea el estado de renderizado
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (mounted) {
      setState(() {
        _loadingState = RouteLoadingState.complete;
      });
      
      // Iniciar animaciones de entrada
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routes = widget.response.routes;

    return Scaffold(
      body: Stack(
        children: [
          // --- Mapa (fondo completo) ---
          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ConcienciaMapWidget(
                routes: routes,
                selectedIndex: _selectedRouteIndex,
                originLat: widget.request.origin.lat,
                originLon: widget.request.origin.lon,
                destLat: widget.request.destination.lat,
                destLon: widget.request.destination.lon,
              ),
            ),
          ),

          // --- Botón volver ---
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildBackButton(context),
            ),
          ),

          // --- Tiempo de cómputo ---
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildComputeTimeBadge(),
            ),
          ),

          // --- Panel inferior con rutas ---
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildRoutesPanel(routes),
              ),
            ),
          ),

          // --- Overlay de carga ---
          if (_loadingState.showOverlay)
            Positioned.fill(
              child: RouteLoadingOverlay(
                message: _loadingState.message,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDADCE0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFF202124),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildComputeTimeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDADCE0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: Color(0xFF188038), size: 16),
          const SizedBox(width: 4),
          Text(
            '${widget.response.computationTimeMs.toStringAsFixed(0)}ms',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF3C4043),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutesPanel(List<RouteOption> routes) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.88),
            Colors.white,
          ],
          stops: const [0.0, 0.15, 0.3],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título de sección
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Rutas encontradas',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF202124),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${routes.length}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A73E8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Lista horizontal de tarjetas
            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedRouteIndex = index);
                      },
                      child: RouteCard(
                        route: routes[index],
                        isSelected: index == _selectedRouteIndex,
                        color: _routeColors[index],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
          ],
        ),
      ),
    );
  }

  static const _routeColors = [
    Color(0xFF1A73E8),
    Color(0xFFF9AB00),
    Color(0xFFEA4335),
  ];
}
