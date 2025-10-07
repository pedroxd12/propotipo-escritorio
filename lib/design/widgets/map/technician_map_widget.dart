// lib/design/widgets/map/technician_map_widget.dart
import 'dart:convert';
import 'dart:async';
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
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {

  @override
  bool get wantKeepAlive => true;

  WebviewController? _controller;
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'CLAVE_NO_ENCONTRADA';
  bool _isLoading = true;
  bool _isInitialized = false;
  String _errorMessage = '';

  // Variables para comparar cambios
  String _lastOrdersHash = '';
  String _lastTechniciansHash = '';

  // Suscripción única para mensajes del WebView
  StreamSubscription<dynamic>? _webMessageSub;

  // Animación para el header
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _updateDataHashes();
    _initializeMap();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _webMessageSub?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  // Generar hash de los datos para detectar cambios
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

      // Suscribirse al stream solo una vez, sin duplicar la suscripción
      _webMessageSub ??= _controller!.webMessage.listen((message) {
        if (message == 'map_initialized') {
          final markersJson = _buildMarkersJsonFromCurrentData();
          _updateMapMarkers(markersJson);
        }
      });

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        await _loadMapContent();
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al inicializar el mapa: $e';
        });
      }
    }
  }

  String _buildMarkersJsonFromCurrentData() {
    final markers = <Map<String, dynamic>>[];
    for (var order in widget.orders) {
      if (order.ordenOriginal.direccion.latitud != 0 ||
          order.ordenOriginal.direccion.longitud != 0) {
        markers.add({
          'lat': order.ordenOriginal.direccion.latitud,
          'lng': order.ordenOriginal.direccion.longitud,
          'title': '${order.title} (${order.client})',
          'type': 'service'
        });
      }
    }
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
    return jsonEncode(markers);
  }

  Future<void> _loadMapContent() async {
    if (_controller == null || !_isInitialized || !mounted || !_controller!.value.isInitialized) return;

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


      final htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
          <title>Mapa de Técnicos</title>
          <meta name="viewport" content="initial-scale=1.0, user-scalable=no">
          <meta charset="UTF-8">
          <style>
            * {
              margin: 0;
              padding: 0;
              box-sizing: border-box;
            }
            
            html, body, #map { 
              height: 100%; 
              width: 100%;
              margin: 0; 
              padding: 0; 
              font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
              overflow: hidden;
            }
            
            #loading {
              position: absolute;
              top: 50%;
              left: 50%;
              transform: translate(-50%, -50%);
              text-align: center;
              z-index: 1000;
              background: rgba(255, 255, 255, 0.95);
              backdrop-filter: blur(10px);
              padding: 32px 48px;
              border-radius: 20px;
              box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
              animation: fadeIn 0.3s ease-out;
            }
            
            @keyframes fadeIn {
              from { opacity: 0; transform: translate(-50%, -45%); }
              to { opacity: 1; transform: translate(-50%, -50%); }
            }
            
            @keyframes spin {
              to { transform: rotate(360deg); }
            }
            
            .spinner {
              width: 48px;
              height: 48px;
              border: 4px solid #e3f2fd;
              border-top-color: #2196F3;
              border-radius: 50%;
              animation: spin 1s linear infinite;
              margin: 0 auto 16px;
            }
            
            .loading-text {
              color: #424242;
              font-size: 16px;
              font-weight: 500;
              margin-top: 12px;
            }
            
            .error-message {
              color: #c62828;
              background: linear-gradient(135deg, #ffebee 0%, #ffcdd2 100%);
              padding: 20px 24px;
              border-radius: 16px;
              margin: 16px;
              border-left: 5px solid #d32f2f;
              font-size: 14px;
              line-height: 1.6;
              box-shadow: 0 4px 12px rgba(198, 40, 40, 0.15);
              animation: slideIn 0.3s ease-out;
            }
            
            @keyframes slideIn {
              from { opacity: 0; transform: translateY(-10px); }
              to { opacity: 1; transform: translateY(0); }
            }
            
            /* Estilos modernos para los InfoWindows */
            .gm-style .gm-style-iw-c {
              border-radius: 16px !important;
              padding: 0 !important;
              box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15) !important;
            }
            
            .gm-style .gm-style-iw-d {
              overflow: hidden !important;
            }
            
            .info-window-content {
              padding: 16px 20px;
              font-size: 14px;
              color: #212121;
              font-weight: 500;
              line-height: 1.5;
            }
          </style>
        </head>
        <body>
          <div id="loading">
            <div class="spinner"></div>
            <div class="loading-text">Cargando mapa...</div>
          </div>
          <div id="map"></div>
          
          <script>
            let map;
            let markers = [];
            
            function updateMap(markersData) {
              markers.forEach(function(m) {
                if (m.marker) m.marker.setMap(null);
                if (m.infoWindow) m.infoWindow.close();
              });
              markers = [];
              
              try {
                console.log('Actualizando mapa con', markersData.length, 'marcadores');
                
                const bounds = new google.maps.LatLngBounds();
                let hasValidMarkers = false;
                
                markersData.forEach(function(markerData) {
                  if (markerData.lat && markerData.lng) {
                    let iconUrl;
                    let iconScale = 40;
                    
                    if (markerData.type === 'technician') {
                      iconUrl = 'data:image/svg+xml;base64,' + btoa('<svg xmlns="http://www.w3.org/2000/svg" width="40" height="50" viewBox="0 0 40 50"><defs><filter id="shadow" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur in="SourceAlpha" stdDeviation="2"/><feOffset dx="0" dy="2" result="offsetblur"/><feComponentTransfer><feFuncA type="linear" slope="0.3"/></feComponentTransfer><feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs><g filter="url(#shadow)"><circle cx="20" cy="20" r="16" fill="#2196F3"/><circle cx="20" cy="20" r="13" fill="#fff" opacity="0.3"/><path d="M20 10 L20 18 M20 22 L20 30 M12 20 L18 20 M22 20 L28 20" stroke="#fff" stroke-width="3" stroke-linecap="round"/></g></svg>');
                    } else {
                      iconUrl = 'data:image/svg+xml;base64,' + btoa('<svg xmlns="http://www.w3.org/2000/svg" width="40" height="50" viewBox="0 0 40 50"><defs><filter id="shadow2" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur in="SourceAlpha" stdDeviation="2"/><feOffset dx="0" dy="2" result="offsetblur"/><feComponentTransfer><feFuncA type="linear" slope="0.3"/></feComponentTransfer><feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs><g filter="url(#shadow2)"><path d="M20 5 C13 5 8 10 8 17 C8 26 20 40 20 40 S32 26 32 17 C32 10 27 5 20 5 Z" fill="#f44336"/><circle cx="20" cy="17" r="6" fill="#fff"/></g></svg>');
                    }
                    
                    const marker = new google.maps.Marker({
                      position: { lat: parseFloat(markerData.lat), lng: parseFloat(markerData.lng) },
                      map: map,
                      title: markerData.title || 'Sin título',
                      icon: {
                        url: iconUrl,
                        scaledSize: new google.maps.Size(iconScale, iconScale * 1.25),
                        anchor: new google.maps.Point(iconScale / 2, iconScale * 1.25)
                      },
                      animation: google.maps.Animation.DROP
                    });
                    
                    const infoWindow = new google.maps.InfoWindow({
                      content: '<div class="info-window-content"><strong>' + (markerData.title || 'Sin título') + '</strong></div>'
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
                  map.fitBounds(bounds, { padding: 60 });
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
                if (loadingEl) {
                  setTimeout(() => {
                    loadingEl.style.opacity = '0';
                    loadingEl.style.transition = 'opacity 0.3s ease-out';
                    setTimeout(() => loadingEl.style.display = 'none', 300);
                  }, 500);
                }
                
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
                  fullscreenControl: false,
                  styles: [
                    {
                      featureType: 'water',
                      elementType: 'geometry',
                      stylers: [{ color: '#e3f2fd' }]
                    },
                    {
                      featureType: 'landscape',
                      elementType: 'geometry',
                      stylers: [{ color: '#f5f5f5' }]
                    },
                    {
                      featureType: 'road',
                      elementType: 'geometry',
                      stylers: [{ color: '#ffffff' }]
                    },
                    {
                      featureType: 'poi',
                      elementType: 'geometry',
                      stylers: [{ color: '#eeeeee' }]
                    }
                  ]
                };
                
                map = new google.maps.Map(document.getElementById('map'), mapOptions);
                
                console.log('Mapa inicializado correctamente');
                // Informa a Flutter que el mapa está listo para recibir marcadores.
                window.chrome.webview.postMessage('map_initialized');

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
          </script>
          
          <script async defer 
                  src="https://maps.googleapis.com/maps/api/js?key=$apiKey&callback=initMap&v=weekly"
                  onerror="handleMapError()">
          </script>
        </body>
        </html>
      """;

      await _controller!.loadStringContent(htmlContent);

      _updateDataHashes();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '';
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar el mapa: $e';
        });
      }
    }
  }

  Future<void> _updateMapMarkers(String markersJson) async {
    if (_controller == null || !_isInitialized || !mounted || !_controller!.value.isInitialized) return;

    try {
      final markersJsonEscaped = jsonEncode(jsonDecode(markersJson));
      await _controller!.executeScript('if (typeof updateMap === "function") { updateMap($markersJsonEscaped); }');
      _updateDataHashes();
    } catch (e) {
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

    await _controller?.dispose();
    _controller = null;

    await _initializeMap();
  }

  @override
  void didUpdateWidget(TechnicianMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_checkDataChanged()) {
      if (_isInitialized && _controller != null && !_isLoading && _controller!.value.isInitialized) {
        final markers = <Map<String, dynamic>>[];
        for (var order in widget.orders) {
          markers.add({
            'lat': order.ordenOriginal.direccion.latitud,
            'lng': order.ordenOriginal.direccion.longitud,
            'title': '${order.title} (${order.client})',
            'type': 'service'
          });
        }
        widget.technicianLocations.forEach((id, coords) {
          markers.add({
            'lat': coords[0],
            'lng': coords[1],
            'title': 'Técnico #${id.split('-').last}',
            'type': 'technician'
          });
        });
        _updateMapMarkers(jsonEncode(markers));
      } else if (!_isInitialized) {
        _initializeMap();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MapHeader(
                orders: widget.orders,
                technicianLocations: widget.technicianLocations,
                isExpanded: widget.isExpanded,
                onExpand: widget.onExpand,
              ),
              Expanded(
                child: _buildMapContent(),
              ),
            ],
          ),
        ),
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

    if (_controller != null && _controller!.value.isInitialized) {
      return Webview(_controller!);
    }

    return const _EmptyMapWidget();
  }
}

// Widget modernizado para el header
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
    final totalMarkers = orders.length + technicianLocations.length;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Icono principal
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor.withValues(alpha: 0.15),
                  AppColors.primaryColor.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Título y badges - Expanded para ocupar el espacio disponible
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Seguimiento en Tiempo Real',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    height: 1.2,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Badge de técnicos
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_pin_circle,
                            size: 13,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${technicianLocations.length}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Badge de órdenes
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.work_rounded,
                            size: 13,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${orders.length}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Badge de total (solo si hay marcadores)
          if (totalMarkers > 0) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                '$totalMarkers',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],

          const SizedBox(width: 12),

          // Botón de expandir/contraer
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onExpand,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isExpanded ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget modernizado para loading
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryColor.withValues(alpha: 0.1),
                            AppColors.primaryColor.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.map_rounded,
                      size: 28,
                      color: AppColors.primaryColor.withValues(alpha: 0.7),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Cargando mapa...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preparando la vista de seguimiento',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget modernizado para errores
class _ErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.red.shade50.withValues(alpha: 0.3),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.red.shade50,
                        Colors.red.shade100.withValues(alpha: 0.3),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.errorColor.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.errorColor,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '¡Ups! Algo salió mal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.errorColor.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
}

// Widget modernizado para estado vacío
class _EmptyMapWidget extends StatelessWidget {
  const _EmptyMapWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey.shade100,
                        Colors.grey.shade50,
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.map_outlined,
                    color: Colors.grey.shade400,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Inicializando mapa...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preparando el sistema de seguimiento',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
