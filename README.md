# ConciencIA - Aplicación Móvil

## Descripción General

Aplicación móvil desarrollada en Flutter para movilidad urbana segura en la Ciudad de México (CDMX). El sistema proporciona rutas optimizadas considerando tiempo, seguridad y accesibilidad mediante integración con un backend impulsado por inteligencia artificial.

## Tabla de Contenidos

- [Características Principales](#características-principales)
- [Arquitectura de la Aplicación](#arquitectura-de-la-aplicación)
- [Requisitos del Sistema](#requisitos-del-sistema)
- [Instalación](#instalación)
- [Configuración](#configuración)
- [Uso de la Aplicación](#uso-de-la-aplicación)
- [Funcionalidades](#funcionalidades)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Dependencias](#dependencias)
- [Diseño y Estilo](#diseño-y-estilo)
- [Compilación y Despliegue](#compilación-y-despliegue)
- [Pruebas](#pruebas)
- [Resolución de Problemas](#resolución-de-problemas)
- [Optimización y Rendimiento](#optimización-y-rendimiento)
- [Contribución](#contribución)
- [Licencia](#licencia)

## Características Principales

### Funcionalidades Core

- **Cálculo de Rutas Inteligentes**: Obtención de tres opciones de ruta optimizadas mediante inteligencia artificial
- **Múltiples Modos de Transporte**: Soporte para caminar, bicicleta, Metro, Metrobús, RTP y Tren Ligero
- **Prioridades Personalizables**: Selección entre velocidad, seguridad o balance
- **Visualización Cartográfica**: Mapas interactivos mediante OpenStreetMap (sin requerimiento de API key)
- **Evaluación de Seguridad**: Scores de riesgo para cada opción de ruta
- **Explicaciones Generadas por IA**: Descripciones en lenguaje natural de cada alternativa
- **Geolocalización**: Detección automática de ubicación del usuario
- **Interfaz Moderna**: Diseño basado en Material Design 3

### Ventajas Técnicas

- Sin dependencias de servicios propietarios de Google Maps
- Funcionamiento completamente offline para visualización de mapas (con caché)
- Arquitectura escalable y mantenible
- Soporte multiplataforma (Android, iOS, Web)

## Arquitectura de la Aplicación

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Application                       │
├─────────────────────────────────────────────────────────────┤
│  Screens          │  Widgets          │  Models             │
│  • HomeScreen     │  • MapWidget      │  • RouteRequest     │
│  • ResultsScreen  │  • RouteCard      │  • RouteResponse    │
│  • LocationPicker │  • InputForm      │  • RouteOption      │
├─────────────────────────────────────────────────────────────┤
│  Services         │  State Management │  Config             │
│  • ApiService     │  • Provider       │  • AppConfig        │
├─────────────────────────────────────────────────────────────┤
│                    External Services                         │
│  • Backend API    │  • OpenStreetMap  │  • Geolocator      │
└─────────────────────────────────────────────────────────────┘
```

### Patrón de Arquitectura

La aplicación implementa una arquitectura en capas:

1. **Capa de Presentación**: Screens y Widgets
2. **Capa de Lógica de Negocio**: Services y State Management
3. **Capa de Datos**: Models y API Client
4. **Capa de Configuración**: AppConfig

## Requisitos del Sistema

### Software Requerido

- Flutter SDK 3.11.5 o superior
- Dart SDK 3.11.5 o superior
- Android Studio (para desarrollo Android)
- Xcode (para desarrollo iOS, solo en macOS)
- Visual Studio Code o Android Studio como IDE

### Plataformas Soportadas

| Plataforma | Versión Mínima | Estado |
|------------|----------------|--------|
| Android | 5.0 (API 21) | Soportado |
| iOS | 12.0 | Soportado |
| Web | Navegadores modernos | Soportado |

### Requisitos de Hardware

- **Desarrollo**: 8GB RAM mínimo, 16GB recomendado
- **Dispositivos**: GPS funcional para geolocalización

## Instalación

### Paso 1: Instalación de Flutter

Seguir la guía oficial de instalación de Flutter para su sistema operativo:
[https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)

Verificar la instalación:

```bash
flutter doctor
```

### Paso 2: Obtención del Código Fuente

```bash
git clone <repository-url>
cd app
```

### Paso 3: Instalación de Dependencias

```bash
flutter pub get
```

### Paso 4: Verificación de la Configuración

```bash
flutter doctor -v
```

Resolver cualquier problema reportado antes de continuar.

## Configuración

### Configuración del Backend

Editar el archivo `lib/config/app_config.dart` para especificar la URL del backend:

```dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://192.168.1.69:8000',
);
```

#### Configuración por Plataforma

| Plataforma | URL Recomendada | Descripción |
|------------|-----------------|-------------|
| Android Emulator | `http://10.0.2.2:8000` | IP especial del emulador |
| iOS Simulator | `http://localhost:8000` | Localhost estándar |
| Dispositivo Físico | `http://[IP_LOCAL]:8000` | IP de la red local |
| Producción | `https://backend.dominio.com` | URL del servidor |

### Configuración de Permisos

#### Android

Los permisos ya están configurados en `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

#### iOS

La configuración de permisos está en `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>ConciencIA necesita acceso a su ubicación para calcular rutas óptimas</string>
```

### Variables de Configuración

Editar `lib/config/app_config.dart` para ajustar:

```dart
// Timeout para solicitudes HTTP
static const int httpTimeoutSeconds = 60;

// Coordenadas de demostración (Tlalpan)
static const double demoOriginLat = 19.2944;
static const double demoOriginLon = -99.1627;

// Configuración del mapa
static const double defaultZoom = 14.2;
```

## Uso de la Aplicación

### Ejecución en Modo Desarrollo

#### Android

```bash
flutter run
```

#### iOS

```bash
flutter run
# Alternativamente, abrir en Xcode:
open ios/Runner.xcworkspace
```

#### Web

```bash
flutter run -d chrome
```

### Especificar Dispositivo

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en dispositivo específico
flutter run -d <device-id>
```

## Funcionalidades

### Pantalla Principal (Home Screen)

#### Componentes

1. **Mapa Interactivo**
   - Visualización mediante OpenStreetMap
   - Controles de zoom y navegación
   - Marcadores de origen y destino

2. **Formulario de Búsqueda**
   - Selección de punto de origen
   - Selección de punto de destino
   - Configuración de modos de transporte
   - Selección de prioridad de ruta

3. **Controles de Ubicación**
   - Botón de ubicación actual
   - Centrado automático en posición GPS

#### Validaciones

- Verificación de coordenadas dentro de CDMX
- Validación de selección de al menos un modo de transporte
- Comprobación de conectividad con el backend

### Pantalla de Resultados (Results Screen)

#### Información Presentada

1. **Visualización de Rutas**
   - Tres opciones ordenadas por relevancia
   - Polylines de colores diferenciados en el mapa
   - Marcadores de inicio y fin

2. **Detalles de Cada Ruta**
   - Tiempo total estimado
   - Distancia total
   - Score de riesgo (0-100)
   - Score de accesibilidad (0-100)
   - Explicación generada por IA
   - Resumen de una línea
   - Tags descriptivos

3. **Segmentos Individuales**
   - Modo de transporte
   - Distancia y duración
   - Instrucciones detalladas
   - Información de líneas de transporte

### Selector de Ubicación (Location Picker)

#### Funcionalidades

- Selección mediante toque en el mapa
- Búsqueda por nombre (funcionalidad futura)
- Uso de ubicación actual GPS
- Validación de coordenadas en CDMX

## Estructura del Proyecto

```
app/
├── lib/
│   ├── main.dart              # Punto de entrada de la aplicación
│   │
│   ├── config/
│   │   └── app_config.dart    # Configuración global
│   │
│   ├── models/
│   │   ├── route_request.dart     # Modelo de solicitud de ruta
│   │   ├── route_response.dart    # Modelo de respuesta de ruta
│   │   └── route_loading_state.dart  # Estados de carga
│   │
│   ├── screens/
│   │   ├── home_screen.dart           # Pantalla principal
│   │   ├── results_screen.dart        # Pantalla de resultados
│   │   └── location_picker_screen.dart # Selector de ubicación
│   │
│   ├── widgets/
│   │   ├── map_widget.dart            # Widget de mapa
│   │   ├── route_card.dart            # Tarjeta de ruta
│   │   ├── route_input_form.dart      # Formulario de entrada
│   │   └── route_loading_overlay.dart # Overlay de carga
│   │
│   └── services/
│       └── api_service.dart           # Cliente HTTP para backend
│
├── android/                   # Configuración específica de Android
├── ios/                       # Configuración específica de iOS
├── web/                       # Configuración específica de Web
├── test/                      # Suite de pruebas
├── pubspec.yaml              # Archivo de dependencias
└── README.md                 # Este archivo
```

## Dependencias

### Dependencias Principales

```yaml
dependencies:
  flutter_map: ^7.0.2          # Mapas con OpenStreetMap
  latlong2: ^0.9.1             # Manejo de coordenadas geográficas
  http: ^1.2.0                 # Cliente HTTP
  provider: ^6.1.0             # Gestión de estado
  geolocator: ^13.0.2          # Servicios de geolocalización
  google_fonts: ^6.2.1         # Fuentes tipográficas premium
  intl: ^0.20.0                # Internacionalización y formateo
  shimmer: ^3.0.0              # Efectos de carga animados
```

### Dependencias de Desarrollo

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0        # Análisis estático de código
```

## Diseño y Estilo

### Sistema de Diseño

La aplicación implementa un sistema de diseño personalizado basado en Material Design 3, inspirado en la interfaz de Google Maps.

#### Paleta de Colores

| Color | Código Hex | Uso |
|-------|-----------|------|
| Primary | `#1A73E8` | Botones principales, enlaces |
| Secondary | `#188038` | Elementos secundarios, éxito |
| Tertiary | `#F9AB00` | Advertencias, destacados |
| Error | `#D93025` | Errores, alertas |
| Surface | `#FFFFFF` | Fondos de tarjetas |
| Background | `#F8FAFD` | Fondo de pantalla |

#### Tipografía

- **Cuerpo de Texto**: Inter (Google Fonts)
- **Títulos y Encabezados**: Outfit (Google Fonts)

#### Componentes

- **Cards**: Elevación 2, bordes redondeados de 8px
- **Botones**: Bordes redondeados de 8px, padding consistente
- **Inputs**: Bordes de 1px, focus con color primary

### Iconografía de Transporte

| Modo | Icono | Descripción |
|------|-------|-------------|
| WALK | 🚶 | Caminar |
| BIKE | 🚴 | Bicicleta |
| METRO | 🚇 | Metro |
| METROBUS | 🚌 | Metrobús |
| RTP | 🚎 | Red de Transporte de Pasajeros |
| LIGHT_RAIL | 🚊 | Tren Ligero |
| TROLLEYBUS | 🚐 | Trolebús |
| CAR | 🚗 | Automóvil |

## Compilación y Despliegue

### Compilación para Android

#### APK de Depuración

```bash
flutter build apk --debug
```

#### APK de Producción

```bash
flutter build apk --release
```

Ubicación del archivo: `build/app/outputs/flutter-apk/app-release.apk`

#### Android App Bundle (Google Play)

```bash
flutter build appbundle --release
```

Ubicación del archivo: `build/app/outputs/bundle/release/app-release.aab`

### Compilación para iOS

```bash
flutter build ios --release
```

Posteriormente, abrir el proyecto en Xcode para firma y distribución:

```bash
open ios/Runner.xcworkspace
```

### Compilación para Web

```bash
flutter build web --release
```

Los archivos compilados estarán en: `build/web/`

### Configuración de Firma (Android)

1. Generar keystore:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Configurar en `android/key.properties`:

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<ruta-al-keystore>
```

## Pruebas

### Ejecución de Pruebas Unitarias

```bash
flutter test
```

### Ejecución de Pruebas de Integración

```bash
flutter test integration_test/
```

### Análisis Estático de Código

```bash
flutter analyze
```

### Formateo de Código

```bash
flutter format .
```

## Resolución de Problemas

### Error: Conexión con Backend Fallida

**Síntomas**: La aplicación no puede comunicarse con el backend.

**Soluciones**:
1. Verificar que el backend esté en ejecución
2. Comprobar la URL configurada en `app_config.dart`
3. En Android Emulator, usar `10.0.2.2` en lugar de `localhost`
4. Verificar configuración de firewall
5. Comprobar permisos de Internet en AndroidManifest.xml

### Error: Permisos de Ubicación Denegados

**Síntomas**: La aplicación no puede acceder a la ubicación del dispositivo.

**Soluciones**:
1. Verificar permisos en `AndroidManifest.xml` (Android) o `Info.plist` (iOS)
2. Solicitar permisos manualmente en configuración del dispositivo
3. Reiniciar la aplicación después de otorgar permisos
4. Verificar que el dispositivo tenga GPS habilitado

### Error: Coordenadas Fuera de CDMX

**Síntomas**: El backend rechaza las coordenadas proporcionadas.

**Causa**: Las coordenadas están fuera de los límites de CDMX.

**Límites Válidos**:
- Latitud: 19.0° - 19.6°
- Longitud: -99.5° - -98.9°

### Error: Mapa No Se Visualiza

**Síntomas**: El widget del mapa aparece en blanco.

**Soluciones**:
1. Verificar conexión a Internet
2. Comprobar accesibilidad de tiles de OpenStreetMap
3. Revisar logs: `flutter logs`
4. Limpiar caché: `flutter clean && flutter pub get`

### Error: Compilación Fallida en iOS

**Síntomas**: Errores durante `flutter build ios`.

**Soluciones**:
1. Actualizar CocoaPods: `pod repo update`
2. Limpiar proyecto: `flutter clean && flutter pub get`
3. Eliminar Pods: `cd ios && rm -rf Pods Podfile.lock && pod install`
4. Verificar configuración de firma en Xcode

## Optimización y Rendimiento

### Optimizaciones Implementadas

1. **Lazy Loading**: Carga diferida de widgets no visibles
2. **Caché de Tiles**: Almacenamiento local de tiles del mapa
3. **Debouncing**: Retraso en búsquedas para reducir solicitudes
4. **Shimmer Effects**: Feedback visual durante operaciones asíncronas
5. **Manejo de Errores**: Sistema robusto de recuperación de errores

### Métricas de Rendimiento Objetivo

| Métrica | Objetivo | Descripción |
|---------|----------|-------------|
| Tiempo de Carga Inicial | < 2s | Desde inicio hasta pantalla principal |
| Tiempo de Respuesta | < 3s | Cálculo y visualización de rutas |
| Uso de Memoria | < 150MB | Consumo máximo en ejecución |
| Tamaño de APK | < 30MB | Tamaño del archivo de instalación |

### Recomendaciones de Optimización

1. Implementar paginación para listas largas
2. Utilizar `const` constructors donde sea posible
3. Minimizar rebuilds innecesarios de widgets
4. Implementar caché de imágenes y datos
5. Optimizar tamaño de assets e imágenes

## Contribución

### Proceso de Contribución

1. Fork del repositorio
2. Crear branch de feature: `git checkout -b feature/nueva-funcionalidad`
3. Realizar cambios siguiendo las guías de estilo
4. Ejecutar pruebas: `flutter test`
5. Commit de cambios: `git commit -am 'Descripción clara del cambio'`
6. Push al branch: `git push origin feature/nueva-funcionalidad`
7. Crear Pull Request con descripción detallada

### Guías de Estilo

1. Seguir [Effective Dart](https://dart.dev/guides/language/effective-dart)
2. Utilizar `flutter format` antes de cada commit
3. Mantener widgets pequeños y reutilizables (< 300 líneas)
4. Documentar funciones públicas con comentarios de documentación
5. Escribir pruebas para nueva funcionalidad
6. Mantener cobertura de pruebas > 70%

### Convenciones de Nomenclatura

- **Archivos**: `snake_case.dart`
- **Clases**: `PascalCase`
- **Variables y Funciones**: `camelCase`
- **Constantes**: `camelCase` con `const` o `final`

## Licencia

Este proyecto es parte de un hackathon y está disponible para fines educativos y de investigación.

## Referencias y Recursos

### Documentación Oficial

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design 3](https://m3.material.io/)

### Paquetes Utilizados

- [flutter_map](https://pub.dev/packages/flutter_map)
- [geolocator](https://pub.dev/packages/geolocator)
- [provider](https://pub.dev/packages/provider)
- [http](https://pub.dev/packages/http)

### Recursos Externos

- [OpenStreetMap](https://www.openstreetmap.org/)
- [CartoDB Basemaps](https://carto.com/basemaps/)

## Roadmap de Desarrollo

### Funcionalidades Planificadas

#### Corto Plazo
- [ ] Búsqueda de lugares por nombre
- [ ] Historial de rutas recientes
- [ ] Guardado de ubicaciones favoritas

#### Mediano Plazo
- [ ] Notificaciones de alertas de tráfico
- [ ] Modo offline con caché de mapas
- [ ] Compartir rutas con otros usuarios
- [ ] Integración con calendario

#### Largo Plazo
- [ ] Soporte multiidioma (inglés, español)
- [ ] Modo oscuro
- [ ] Mejoras de accesibilidad (TalkBack, VoiceOver)
- [ ] Widget de pantalla de inicio
- [ ] Integración con wearables

## Contacto y Soporte

Para reportar problemas, solicitar funcionalidades o contribuir al proyecto:

1. Revisar la sección de [Resolución de Problemas](#resolución-de-problemas)
2. Consultar los logs de la aplicación: `flutter logs`
3. Verificar la configuración del backend
4. Comprobar permisos y configuración del dispositivo

## Demostración

### Configuración Rápida para Demo

Para probar la aplicación rápidamente con datos de demostración:

1. Utilizar las coordenadas preconfiguradas de Tlalpan
2. Seleccionar modos: WALK, RTP, LIGHT_RAIL
3. Establecer prioridad: BALANCED
4. Presionar "Calcular Rutas"

**Zona de Demostración**: Área circundante al Tecnológico de Monterrey Campus Ciudad de México en Tlalpan.

**Coordenadas de Referencia**:
- Origen: 19.2944°N, 99.1627°W
- Destino: 19.2836°N, 99.1369°W
