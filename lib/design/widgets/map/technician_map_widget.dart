// lib/design/widgets/map/technician_map_widget.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:serviceflow/data/models/agenda_event.dart';
import 'package:webview_windows/webview_windows.dart';

class TechnicianMapWidget extends StatefulWidget {
  final List<AgendaEvent> orders;
  final Map<String, List<double>> technicianLocations;
  final VoidCallback onExpand;
  final bool isExpanded;

  const TechnicianMapWidget({
    super.key,
    required this.orders,
    required this.technicianLocations,
    required this.onExpand,
    this.isExpanded = false,
  });

  @override
  State<TechnicianMapWidget> createState() => _TechnicianMapWidgetState();
}

class _TechnicianMapWidgetState extends State<TechnicianMapWidget>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true; // Mantener el estado vivo

  WebviewController? _controller;
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'CLAVE_NO_ENCONTRADA';
  bool _isLoading = true;
  bool _isInitialized = false;
  String _errorMessage = '';

  // Variables para comparar cambios
  String _lastOrdersHash = '';
  String _lastTechniciansHash = '';
  bool _hasDataChanged = false;

  @override
  void initState() {
    super.initState();
    _updateDataHashes();
    _initializeMap();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  // Generar hash de los datos para detectar cambios reales
  void _updateDataHashes() {
    final ordersData = widget.orders.map((order) => {
      'id': order.id,
      'lat': order.ordenOriginal.direccion.latitud,
      'lng': order.ordenOriginal.direccion.longitud,
      'title': order.title,
      'client': order.client,
    }).toList();

    _lastOrdersHash = ordersData.toString();
    _lastTechniciansHash = widget.technicianLocations.toString();
  }

  // Verificar si los datos realmente cambiaron
  bool _checkDataChanged() {
    final ordersData = widget.orders.map((order) => {
      'id': order.id,
      'lat': order.ordenOriginal.direccion.latitud,
      'lng': order.ordenOriginal.direccion.longitud,
      'title': order.title,
      'client': order.client,
    }).toList();

    final currentOrdersHash = ordersData.toString();
    final currentTechniciansHash = widget.technicianLocations.toString();

    return currentOrdersHash != _lastOrdersHash ||
        currentTechniciansHash != _lastTechniciansHash;
  }

  Future<void> _initializeMap() async {
    if (_isInitialized || !mounted) return;

    try {
      if (apiKey == 'CLAVE_NO_ENCONTRADA') {
        debugPrint('Error: La clave de API de Google Maps no está configurada en el archivo .env');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'La clave de API de Google Maps no está configurada';
          });
        }
        return;
      }

      _controller = WebviewController();
      await _controller!.initialize();
      _isInitialized = true;

      await _loadMapContent();

    } catch (e) {
      debugPrint('Error inicializando el mapa: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al inicializar el mapa: $e';
        });
      }
    }
  }

  Future<void> _loadMapContent() async {
    if (_controller == null || !_isInitialized || !mounted) return;

    try {
      final markers = <Map<String, dynamic>>[];

      // Agregar marcadores de órdenes
      for (var order in widget.orders) {
        if (order.ordenOriginal.direccion.latitud != 0 || order.ordenOriginal.direccion.longitud != 0) {
          markers.add({
            'lat': order.ordenOriginal.direccion.latitud,
            'lng': order.ordenOriginal.direccion.longitud,
            'title': '${order.title} (${order.client})',
            'type': 'service'
          });
        }
      }

      // Agregar marcadores de técnicos
      widget.technicianLocations.forEach((id, coords) {
        if (coords.length >= 2) {
          markers.add({
            'lat': coords[0],
            'lng': coords[1],
            'title': 'Técnico #${id.split('-').last}',
            'type': 'technician'
          });
        }
      });

      // Convertir marcadores a JSON válido
      final markersJson = jsonEncode(markers);
      final markersJsonEscaped = markersJson
          .replaceAll('\\', '\\\\')
          .replaceAll('"', '\\"')
          .replaceAll('\n', '\\n')
          .replaceAll('\r', '\\r');

      final htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
          <title>Mapa de Técnicos</title>
          <meta name="viewport" content="initial-scale=1.0, user-scalable=no">
          <meta charset="UTF-8">
          <style>
            html, body, #map { 
              height: 100%; 
              margin: 0; 
              padding: 0; 
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            }
            #loading {
              position: absolute;
              top: 50%;
              left: 50%;
              transform: translate(-50%, -50%);
              text-align: center;
              z-index: 1000;
              background: white;
              padding: 20px;
              border-radius: 8px;
              box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            .error-message {
              color: #d32f2f;
              background: #ffebee;
              padding: 16px;
              border-radius: 4px;
              margin: 16px;
              border-left: 4px solid #d32f2f;
            }
          </style>
        </head>
        <body>
          <div id="loading">Cargando mapa...</div>
          <div id="map"></div>
          
          <script>
            let map;
            let markers = [];
            
            function updateMap() {
              // Limpiar marcadores existentes
              markers.forEach(function(m) {
                if (m.marker) m.marker.setMap(null);
                if (m.infoWindow) m.infoWindow.close();
              });
              markers = [];
              
              try {
                const markersData = JSON.parse("$markersJsonEscaped");
                console.log('Actualizando mapa con', markersData.length, 'marcadores');
                
                // Agregar nuevos marcadores
                const bounds = new google.maps.LatLngBounds();
                let hasValidMarkers = false;
                
                markersData.forEach(function(markerData) {
                  if (markerData.lat && markerData.lng) {
                    let iconUrl;
                    
                    if (markerData.type === 'technician') {
                      iconUrl = 'https://maps.google.com/mapfiles/ms/icons/blue-dot.png';
                    } else {
                      iconUrl = 'https://maps.google.com/mapfiles/ms/icons/red-dot.png';
                    }
                    
                    const marker = new google.maps.Marker({
                      position: { lat: parseFloat(markerData.lat), lng: parseFloat(markerData.lng) },
                      map: map,
                      title: markerData.title || 'Sin título',
                      icon: {
                        url: iconUrl,
                        scaledSize: new google.maps.Size(32, 32)
                      }
                    });
                    
                    const infoWindow = new google.maps.InfoWindow({
                      content: '<div style="padding: 8px; font-size: 14px;"><strong>' + (markerData.title || 'Sin título') + '</strong></div>'
                    });
                    
                    marker.addListener('click', function() {
                      markers.forEach(m => {
                        if (m.infoWindow) m.infoWindow.close();
                      });
                      infoWindow.open(map, marker);
                    });
                    
                    markers.push({ marker: marker, infoWindow: infoWindow });
                    bounds.extend(marker.getPosition());
                    hasValidMarkers = true;
                  }
                });
                
                // Ajustar vista solo si hay marcadores
                if (hasValidMarkers && markersData.length > 1) {
                  map.fitBounds(bounds);
                  const listener = google.maps.event.addListener(map, 'idle', function() {
                    if (map.getZoom() > 16) map.setZoom(16);
                    google.maps.event.removeListener(listener);
                  });
                } else if (hasValidMarkers && markersData.length === 1) {
                  map.setCenter(bounds.getCenter());
                  map.setZoom(15);
                }
                
              } catch (error) {
                console.error('Error actualizando marcadores:', error);
              }
            }
            
            function initMap() {
              try {
                const loadingEl = document.getElementById('loading');
                if (loadingEl) loadingEl.style.display = 'none';
                
                const mapOptions = {
                  center: { lat: 17.9625, lng: -102.2033 },
                  zoom: 12,
                  mapTypeId: google.maps.MapTypeId.ROADMAP,
                  gestureHandling: 'cooperative',
                  zoomControl: true,
                  mapTypeControl: false,
                  scaleControl: false,
                  streetViewControl: false,
                  rotateControl: false,
                  fullscreenControl: false
                };
                
                map = new google.maps.Map(document.getElementById('map'), mapOptions);
                
                // Cargar marcadores iniciales
                updateMap();
                
                console.log('Mapa inicializado correctamente');
                
              } catch (error) {
                console.error('Error al inicializar el mapa:', error);
                const loadingEl = document.getElementById('loading');
                if (loadingEl) {
                  loadingEl.innerHTML = '<div class="error-message">Error al cargar el mapa: ' + error.message + '</div>';
                }
              }
            }
            
            function handleMapError() {
              console.error('Error al cargar Google Maps API');
              const loadingEl = document.getElementById('loading');
              if (loadingEl) {
                loadingEl.innerHTML = '<div class="error-message">No se pudo cargar Google Maps. Verifique la clave de API y la conexión a internet.</div>';
              }
            }
            
            window.gm_authFailure = function() {
              console.error('Error de autenticación de Google Maps');
              const loadingEl = document.getElementById('loading');
              if (loadingEl) {
                loadingEl.innerHTML = '<div class="error-message">Error de autenticación de Google Maps. Verifique su clave de API.</div>';
              }
            };
            
            // Función global para actualizar desde Flutter
            window.updateMapMarkers = updateMap;
          </script>
          
          <script async defer 
                  src="https://maps.googleapis.com/maps/api/js?key=$apiKey&callback=initMap&v=weekly"
                  onerror="handleMapError()">
          </script>
        </body>
        </html>
      """;

      await _controller!.loadStringContent(htmlContent);

      // Actualizar los hashes después de cargar
      _updateDataHashes();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '';
        });
      }

    } catch (e) {
      debugPrint('Error cargando contenido del mapa: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar el mapa: $e';
        });
      }
    }
  }

  Future<void> _updateMapMarkers() async {
    if (_controller == null || !_isInitialized || !mounted) return;

    try {
      // Ejecutar JavaScript para actualizar solo los marcadores
      await _controller!.executeScript('if (typeof updateMapMarkers === "function") { updateMapMarkers(); }');
      _updateDataHashes();
    } catch (e) {
      debugPrint('Error actualizando marcadores: $e');
      // Si falla la actualización, recargar todo el contenido
      await _loadMapContent();
    }
  }

  Future<void> _retryInitialization() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _isInitialized = false;
    });

    _controller?.dispose();
    _controller = null;

    await _initializeMap();
  }

  @override
  void didUpdateWidget(TechnicianMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Solo actualizar si los datos realmente cambiaron
    if (_checkDataChanged()) {
      debugPrint('Datos del mapa cambiaron, actualizando...');

      if (_isInitialized && _controller != null && !_isLoading) {
        // Solo actualizar marcadores en lugar de recargar todo
        _updateMapMarkers();
      } else if (!_isInitialized) {
        // Si no está inicializado, inicializar
        _initializeMap();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Requerido por AutomaticKeepAliveClientMixin

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.outline),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final headerHeight = 80.0;
          final availableHeight = constraints.maxHeight - headerHeight;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Componente separado para evitar reconstrucciones
              _MapHeader(
                orders: widget.orders,
                technicianLocations: widget.technicianLocations,
                isExpanded: widget.isExpanded,
                onExpand: widget.onExpand,
              ),
              // Contenido del mapa con altura fija
              SizedBox(
                height: availableHeight > 0 ? availableHeight : 300,
                child: _buildMapContent(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMapContent() {
    if (_isLoading) {
      return const _LoadingWidget();
    }

    if (_errorMessage.isNotEmpty) {
      return _ErrorWidget(
        errorMessage: _errorMessage,
        onRetry: _retryInitialization,
      );
    }

    if (_controller?.value.isInitialized == true) {
      return Webview(_controller!);
    }

    return const _EmptyMapWidget();
  }
}

// Widget separado para el header para evitar reconstrucciones
class _MapHeader extends StatelessWidget {
  final List<AgendaEvent> orders;
  final Map<String, List<double>> technicianLocations;
  final bool isExpanded;
  final VoidCallback onExpand;

  const _MapHeader({
    required this.orders,
    required this.technicianLocations,
    required this.isExpanded,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.map_outlined, color: AppColors.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Seguimiento de Técnicos',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (orders.isNotEmpty || technicianLocations.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${orders.length + technicianLocations.length}',
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(isExpanded ? Icons.fullscreen_exit : Icons.fullscreen),
            onPressed: onExpand,
            tooltip: isExpanded ? 'Regresar a la agenda' : 'Ver en pantalla completa',
          )
        ],
      ),
    );
  }
}

// Widget separado para loading
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando mapa...'),
        ],
      ),
    );
  }
}

// Widget separado para errores
class _ErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.errorColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.errorColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget separado para estado vacío
class _EmptyMapWidget extends StatelessWidget {
  const _EmptyMapWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.map_outlined,
            color: Colors.grey,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            "No se pudo inicializar el mapa.\nVerifique la clave de API y la conexión a internet.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}