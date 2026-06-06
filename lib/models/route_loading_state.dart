// ConciencIA — Estados de carga de rutas.
// Define los diferentes estados durante el proceso de cálculo y renderizado.

enum RouteLoadingState {
  /// Estado inicial, sin rutas cargadas
  idle,
  
  /// Calculando rutas en el backend
  calculating,
  
  /// Renderizando rutas en el mapa
  rendering,
  
  /// Rutas completamente cargadas y mostradas
  complete,
}

extension RouteLoadingStateExtension on RouteLoadingState {
  /// Mensaje descriptivo para mostrar al usuario
  String get message {
    switch (this) {
      case RouteLoadingState.idle:
        return '';
      case RouteLoadingState.calculating:
        return 'Calculando las mejores rutas...';
      case RouteLoadingState.rendering:
        return 'Preparando visualización...';
      case RouteLoadingState.complete:
        return '';
    }
  }

  /// Indica si se debe mostrar el overlay de carga
  bool get showOverlay {
    return this == RouteLoadingState.calculating || 
           this == RouteLoadingState.rendering;
  }
}

// Made with Bob
