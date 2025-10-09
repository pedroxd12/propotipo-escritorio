// lib/design/screens/settings/settings_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:serviceflow/data/models/service_model.dart';
import 'package:uuid/uuid.dart';
// ignore: depend_on_referenced_packages
import 'package:webview_windows/webview_windows.dart' as ww;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _companyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _addressFocusNode = FocusNode();

  // Flag para prevenir que onChanged se dispare cuando actualizamos programáticamente
  bool _isUpdatingAddressProgrammatically = false;

  // Horarios
  TimeOfDay _workStartTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _workEndTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay? _lunchStartTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay? _lunchEndTime = const TimeOfDay(hour: 14, minute: 0);
  bool _hasLunchBreak = true;

  // Ubicación / Mapa - Iniciar centrado en México sin ubicación específica
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  bool _isMapReady = false;

  // Controlador para el WebView en Windows
  final _webviewController = ww.WebviewController();
  bool _isWebviewReady = false;
  bool _hasLoadedInitialMap = false;

  // Lista de servicios
  final List<ServiceModel> _services = [];

  // Logo
  String? _companyLogoPath;

  // API Key
  String get _googleApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  // Autocompletado
  final Dio _dio = Dio();
  Timer? _addressDebounce;
  bool _isFetchingSuggestions = false;
  bool _isReverseGeocoding = false;
  bool _isForwardGeocoding = false;
  List<PlaceSuggestion> _addressSuggestions = [];
  CancelToken? _cancelSuggestionsToken;
  CancelToken? _cancelDetailsToken;
  CancelToken? _cancelGeocodeToken;
  String? _sessionToken;
  final _uuid = const Uuid();

  // Validación de dirección
  bool _addressGeocodedSuccessfully = false;

  // Overlay
  final LayerLink _addressLayerLink = LayerLink();
  OverlayEntry? _addressOverlay;
  final GlobalKey _addressFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _addressFocusNode.addListener(_onAddressFocusChange);
    if (!kIsWeb && Platform.isWindows) {
      _initWebView();
    }
  }

  Future<void> _initWebView() async {
    try {
      await _webviewController.initialize();

      // Agregar listener para recibir mensajes del mapa de Windows
      _webviewController.webMessage.listen((message) {
        if (message['type'] == 'location') {
          final lat = message['lat'] as num?;
          final lng = message['lng'] as num?;
          if (lat != null && lng != null) {
            final newLocation = LatLng(lat.toDouble(), lng.toDouble());
            _updateAddressFromLatLng(newLocation);
          }
        }
      });

      if (mounted) {
        setState(() {
          _isWebviewReady = true;
        });
      }
    } catch (_) {
      // Manejar error de inicialización si es necesario
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _addressDebounce?.cancel();
    _mapController?.dispose();
    _hideAddressOverlay();
    _addressFocusNode.removeListener(_onAddressFocusChange);
    _addressFocusNode.dispose();
    _cancelSuggestionsToken?.cancel('dispose');
    _cancelDetailsToken?.cancel('dispose');
    _cancelGeocodeToken?.cancel('dispose');
    _webviewController.dispose();
    super.dispose();
  }

  void _onAddressFocusChange() {
    if (_addressFocusNode.hasFocus && _sessionToken == null) {
      _sessionToken = _uuid.v4();
    }
    if (!_addressFocusNode.hasFocus) {
      _hideAddressOverlay();
    } else {
      if (_addressController.text.trim().length >= 3) {
        _onAddressChanged(_addressController.text);
      }
    }
  }

  void _syncAddressOverlay() {
    _hideAddressOverlay();
    if (_addressFocusNode.hasFocus && _addressSuggestions.isNotEmpty) {
      _showAddressOverlay();
    }
  }

  void _showAddressOverlay() {
    if (_addressOverlay != null) return;
    _addressOverlay = _buildAddressOverlayEntry();
    Overlay.of(context).insert(_addressOverlay!);
  }

  void _hideAddressOverlay() {
    _addressOverlay?.remove();
    _addressOverlay = null;
  }

  OverlayEntry _buildAddressOverlayEntry() {
    final renderBox = _addressFieldKey.currentContext?.findRenderObject() as RenderBox?;
    final width = renderBox?.size.width ?? 500.0;
    return OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                _hideAddressOverlay();
                _addressFocusNode.unfocus();
              },
              child: Container(color: Colors.transparent),
            ),
            CompositedTransformFollower(
              link: _addressLayerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 60),
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: width,
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _addressSuggestions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final suggestion = _addressSuggestions[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on, color: AppColors.primaryColor),
                        title: Text(suggestion.mainText, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(suggestion.secondaryText),
                        onTap: () => _selectSuggestion(suggestion),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onAddressChanged(String value) {
    if (_isUpdatingAddressProgrammatically) {
      return;
    }

    // Limpiar validación cuando el usuario empieza a escribir
    if (_addressGeocodedSuccessfully) {
      setState(() {
        _addressGeocodedSuccessfully = false;
      });
    }

    _addressDebounce?.cancel();
    _addressDebounce = Timer(const Duration(milliseconds: 300), () async {
      final trimmed = value.trim();
      if (!mounted) return;
      if (trimmed.length < 3) {
        setState(() => _addressSuggestions = []);
        _syncAddressOverlay();
        return;
      }

      _sessionToken ??= _uuid.v4();
      setState(() => _isFetchingSuggestions = true);
      _cancelSuggestionsToken?.cancel('new input');
      _cancelSuggestionsToken = CancelToken();

      try {
        final resp = await _dio.get(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json',
          queryParameters: {
            'input': trimmed,
            'key': _googleApiKey,
            'components': 'country:mx',
            'types': 'address',
            'language': 'es',
            'sessiontoken': _sessionToken,
          },
          cancelToken: _cancelSuggestionsToken,
        );
        final predictions = (resp.data['predictions'] as List?) ?? [];
        if (mounted) {
          setState(() {
            _addressSuggestions = predictions.map((p) {
              final structured = p['structured_formatting'];
              return PlaceSuggestion(
                placeId: p['place_id'] ?? '',
                description: p['description'] ?? '',
                mainText: structured?['main_text'] ?? (p['description'] ?? ''),
                secondaryText: structured?['secondary_text'] ?? '',
              );
            }).toList();
            _isFetchingSuggestions = false;
          });
          _syncAddressOverlay();
        }
      } on DioException {
        if (mounted) {
          setState(() {
            _addressSuggestions = [];
            _isFetchingSuggestions = false;
          });
        }
      }
    });
  }

  // CÓDIGO CORREGIDO Y MÁS ROBUSTO
  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    _hideAddressOverlay();
    _addressFocusNode.unfocus();
    _isUpdatingAddressProgrammatically = true;

    setState(() {
      _addressSuggestions = [];
    });

    _sessionToken ??= _uuid.v4();
    _cancelDetailsToken?.cancel('new details request');
    _cancelDetailsToken = CancelToken();

    try {
      final resp = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': suggestion.placeId,
          'fields': 'geometry/location,formatted_address,address_components',
          'key': _googleApiKey,
          'language': 'es',
          'sessiontoken': _sessionToken,
        },
        cancelToken: _cancelDetailsToken,
      );

      _sessionToken = null;

      if (resp.data?['result'] == null || !mounted) {
        setState(() => _addressGeocodedSuccessfully = false);
        return;
      }

      final result = resp.data['result'];
      final loc = result['geometry']?['location'];
      final LatLng? target = (loc != null && loc['lat'] != null && loc['lng'] != null)
          ? LatLng((loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble())
          : null;

      final components = (result['address_components'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final normalized = _formatAddressFromComponents(components) ?? result['formatted_address'];

      if (mounted && normalized != null) {
        setState(() {
          _addressController.value = TextEditingValue(
            text: normalized,
            selection: TextSelection.collapsed(offset: normalized.length),
          );
          if (target != null) {
            _selectedLocation = target;
            _addressGeocodedSuccessfully = true;
          } else {
            _addressGeocodedSuccessfully = false;
          }
        });
      }

      if (target != null) {
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 17));
        if (!kIsWeb && Platform.isWindows && _isWebviewReady) {
          _loadWindowsMapLocation(target);
        }
      }
    } on DioException catch (_) {
      if (mounted) {
        setState(() {
          _addressGeocodedSuccessfully = false;
          _sessionToken = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al obtener detalles de la dirección'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _isUpdatingAddressProgrammatically = false;
        }
      });
    }
  }

  Future<void> _forwardGeocodeFromText(String value) async {
    if (_googleApiKey.isEmpty) return;

    setState(() => _isForwardGeocoding = true);
    _isUpdatingAddressProgrammatically = true;

    _cancelGeocodeToken?.cancel('new geocode');
    _cancelGeocodeToken = CancelToken();

    try {
      final resp = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'address': value,
          'key': _googleApiKey,
          'language': 'es',
          'region': 'mx',
          'components': 'country:MX',
        },
        cancelToken: _cancelGeocodeToken,
      );

      final results = (resp.data['results'] as List?) ?? [];
      if (!mounted || results.isEmpty) {
        if (mounted) setState(() => _addressGeocodedSuccessfully = false);
        return;
      }

      final best = results.first;
      final loc = best['geometry']?['location'];
      if (loc != null && loc['lat'] != null && loc['lng'] != null) {
        final target = LatLng((loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble());
        final formattedAddress = best['formatted_address'] as String?;

        setState(() {
          if (formattedAddress != null) {
            _addressController.value = TextEditingValue(
              text: formattedAddress,
              selection: TextSelection.collapsed(offset: formattedAddress.length),
            );
          }
          _selectedLocation = target;
          _addressGeocodedSuccessfully = true;
        });

        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 17));
        if (!kIsWeb && Platform.isWindows && _isWebviewReady) {
          await _loadWindowsMapLocation(target);
        }
      } else {
        if (mounted) setState(() => _addressGeocodedSuccessfully = false);
      }
    } on DioException catch (_) {
      if (mounted) setState(() => _addressGeocodedSuccessfully = false);
    } finally {
      if (mounted) setState(() => _isForwardGeocoding = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted) {
          _isUpdatingAddressProgrammatically = false;
        }
      });
    }
  }

  Future<void> _updateAddressFromLatLng(LatLng location) async {
    setState(() {
      _selectedLocation = location;
      _isReverseGeocoding = true;
    });

    _isUpdatingAddressProgrammatically = true;
    _cancelGeocodeToken?.cancel('reverse geocode');
    _cancelGeocodeToken = CancelToken();

    try {
      final resp = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '${location.latitude},${location.longitude}',
          'key': _googleApiKey,
          'language': 'es',
          'region': 'mx',
        },
        cancelToken: _cancelGeocodeToken,
      );
      final results = (resp.data['results'] as List?) ?? [];
      if (results.isNotEmpty && mounted) {
        final best = results.first;
        final comps = (best['address_components'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final normalized = _formatAddressFromComponents(comps) ?? best['formatted_address'];

        setState(() {
          final text = normalized ?? 'Ubicación seleccionada';
          _addressController.value = TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
          _addressGeocodedSuccessfully = true;
        });
      }
    } on DioException catch (_) {
      // Silenciar error de geocoding reverso
    } finally {
      if (mounted) setState(() => _isReverseGeocoding = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted) {
          _isUpdatingAddressProgrammatically = false;
        }
      });
    }
  }

  Future<void> _loadWindowsMapLocation(LatLng location) async {
    if (!_isWebviewReady) return;

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body, html { margin: 0; padding: 0; height: 100%; overflow: hidden; }
        #map { width: 100%; height: 100%; }
    </style>
</head>
<body>
    <div id="map"></div>
    <script>
        let marker;
        function initMap() {
            const location = { lat: ${location.latitude}, lng: ${location.longitude} };
            const map = new google.maps.Map(document.getElementById("map"), {
                zoom: 17,
                center: location,
                mapTypeControl: true,
                fullscreenControl: false,
                streetViewControl: true,
            });
            marker = new google.maps.Marker({
                position: location,
                map: map,
                draggable: true,
                title: "Ubicación de la empresa",
                animation: google.maps.Animation.DROP
            });

            marker.addListener('dragend', (event) => {
                window.chrome.webview.postMessage({ type: 'location', lat: event.latLng.lat(), lng: event.latLng.lng() });
            });

            map.addListener('click', (event) => {
                marker.setPosition(event.latLng);
                window.chrome.webview.postMessage({ type: 'location', lat: event.latLng.lat(), lng: event.latLng.lng() });
            });
        }
    </script>
    <script async defer
        src="https://maps.googleapis.com/maps/api/js?key=$_googleApiKey&callback=initMap&language=es&region=MX">
    </script>
</body>
</html>
''';

    await _webviewController.loadStringContent(htmlContent);
  }

  Future<void> _selectTime(BuildContext context, {required bool isStartTime, required bool isWorkTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isWorkTime
          ? (isStartTime ? _workStartTime : _workEndTime)
          : (isStartTime ? (_lunchStartTime ?? TimeOfDay.now()) : (_lunchEndTime ?? TimeOfDay.now())),
    );
    if (picked != null) {
      setState(() {
        if (isWorkTime) {
          isStartTime ? _workStartTime = picked : _workEndTime = picked;
        } else {
          isStartTime ? _lunchStartTime = picked : _lunchEndTime = picked;
        }
      });
    }
  }

  Future<void> _pickCompanyLogo() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        setState(() => _companyLogoPath = result.files.single.path);
      }
    } catch (_) {
      // Manejar excepción
    }
  }

  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    List<String> servicePaths = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar Servicio'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Servicio *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Precio',
                            prefixText: '\$',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Duración (min)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text('Imágenes del Servicio', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (servicePaths.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: servicePaths.map((path) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(path),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    servicePaths.remove(path);
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: true,
                        );
                        if (result != null) {
                          setDialogState(() {
                            servicePaths.addAll(
                              result.files.where((f) => f.path != null).map((f) => f.path!).toList(),
                            );
                          });
                        }
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Agregar Imágenes'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El nombre del servicio es requerido')),
                  );
                  return;
                }

                final newService = ServiceModel(
                  id: _uuid.v4(),
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                  price: double.tryParse(priceController.text) ?? 0.0,
                  duration: int.tryParse(durationController.text) ?? 0,
                  imagePaths: servicePaths,
                );

                setState(() {
                  _services.add(newService);
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Servicio agregado correctamente'),
                    backgroundColor: AppColors.successColor,
                  ),
                );
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _editService(int index) {
    final service = _services[index];
    final nameController = TextEditingController(text: service.name);
    final descController = TextEditingController(text: service.description);
    final priceController = TextEditingController(text: service.price.toString());
    final durationController = TextEditingController(text: service.duration.toString());
    List<String> servicePaths = List.from(service.imagePaths);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Servicio'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Servicio *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Precio',
                            prefixText: '\$',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Duración (min)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text('Imágenes del Servicio', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (servicePaths.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: servicePaths.map((path) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(path),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    servicePaths.remove(path);
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: true,
                        );
                        if (result != null) {
                          setDialogState(() {
                            servicePaths.addAll(
                              result.files.where((f) => f.path != null).map((f) => f.path!).toList(),
                            );
                          });
                        }
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Agregar Imágenes'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El nombre del servicio es requerido')),
                  );
                  return;
                }

                setState(() {
                  _services[index] = ServiceModel(
                    id: service.id,
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    price: double.tryParse(priceController.text) ?? 0.0,
                    duration: int.tryParse(durationController.text) ?? 0,
                    imagePaths: servicePaths,
                  );
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Servicio actualizado correctamente'),
                    backgroundColor: AppColors.successColor,
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteService(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Servicio'),
        content: Text('¿Estás seguro de eliminar "${_services[index].name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _services.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Servicio eliminado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajustes guardados correctamente.'),
          backgroundColor: AppColors.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Column(children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.settings, color: AppColors.primaryColor, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Configuración',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ajusta la información y preferencias de tu empresa',
                    style: TextStyle(color: AppColors.textSecondaryColor, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ]),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildCardSizedSection(
                          child: _buildSection(
                              title: 'Información de la Empresa',
                              icon: Icons.business_rounded,
                              child: _buildCompanyInfoContent())),
                      _buildCardSizedSection(
                          child: _buildSection(
                              title: 'Horario Laboral',
                              icon: Icons.schedule_rounded,
                              child: _buildWorkScheduleContent())),
                      _buildCardSizedSection(
                          minWidth: 500,
                          child: _buildSection(
                              title: 'Ubicación de la Empresa',
                              icon: Icons.location_on_rounded,
                              child: _buildLocationContent())),
                      _buildCardSizedSection(
                          minWidth: 500,
                          child: _buildSection(
                              title: 'Catálogo de Servicios',
                              icon: Icons.miscellaneous_services_rounded,
                              child: _buildServicesContent())),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar Cambios'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSizedSection({required Widget child, double minWidth = 400}) {
    return LayoutBuilder(builder: (context, constraints) {
      final cardWidth = constraints.maxWidth < minWidth ? constraints.maxWidth : minWidth;
      return SizedBox(
        width: cardWidth,
        child: child,
      );
    });
  }

  Widget _buildCompanyInfoContent() {
    return Column(children: [
      GestureDetector(
        onTap: _pickCompanyLogo,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline, width: 2),
          ),
          child: _companyLogoPath != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(File(_companyLogoPath!), fit: BoxFit.cover),
          )
              : const Icon(Icons.add_a_photo_outlined, size: 48, color: AppColors.textTertiaryColor),
        ),
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: _pickCompanyLogo,
        icon: const Icon(Icons.upload_file_rounded),
        label: Text(_companyLogoPath != null ? 'Cambiar Logo' : 'Subir Logo'),
      ),
      const SizedBox(height: 32),
      TextFormField(
        controller: _companyNameController,
        decoration: const InputDecoration(labelText: 'Nombre de la Empresa *'),
        validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _phoneController,
        decoration: const InputDecoration(labelText: 'Teléfono *'),
        keyboardType: TextInputType.phone,
        validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _emailController,
        decoration: const InputDecoration(labelText: 'Correo Electrónico *'),
        keyboardType: TextInputType.emailAddress,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Campo requerido';
          if (!v.contains('@') || !v.contains('.')) return 'Email inválido';
          return null;
        },
      ),
    ]);
  }

  Widget _buildWorkScheduleContent() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
            child: _buildTimePickerField('Inicio de Jornada', _workStartTime, Icons.wb_sunny_outlined,
                    () => _selectTime(context, isStartTime: true, isWorkTime: true))),
        const SizedBox(width: 16),
        Expanded(
            child: _buildTimePickerField('Fin de Jornada', _workEndTime, Icons.nights_stay_outlined,
                    () => _selectTime(context, isStartTime: false, isWorkTime: true))),
      ]),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Checkbox(
          value: _hasLunchBreak,
          onChanged: (v) => setState(() => _hasLunchBreak = v ?? false),
        ),
        const Text('Incluir horario de comida'),
      ]),
      if (_hasLunchBreak) ...[
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: _buildTimePickerField('Inicio de Comida', _lunchStartTime!, Icons.restaurant_outlined,
                      () => _selectTime(context, isStartTime: true, isWorkTime: false))),
          const SizedBox(width: 16),
          Expanded(
              child: _buildTimePickerField('Fin de Comida', _lunchEndTime!, Icons.restaurant_outlined,
                      () => _selectTime(context, isStartTime: false, isWorkTime: false))),
        ]),
      ],
    ]);
  }

  Widget _buildLocationContent() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CompositedTransformTarget(
        link: _addressLayerLink,
        child: Container(
          key: _addressFieldKey,
          child: TextFormField(
            controller: _addressController,
            focusNode: _addressFocusNode,
            onChanged: _onAddressChanged,
            validator: _validateMexicanAddress,
            onFieldSubmitted: (value) {
              if (_addressSuggestions.isNotEmpty) {
                _selectSuggestion(_addressSuggestions.first);
              } else if (value.trim().isNotEmpty) {
                _forwardGeocodeFromText(value.trim());
              }
            },
            decoration: InputDecoration(
              labelText: 'Dirección de la Empresa *',
              hintText: 'Ej: Av. Reforma 123, Col. Centro, CDMX...',
              helperText: 'Busca y selecciona tu dirección de la lista',
              prefixIcon: const Icon(Icons.place_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: (_isFetchingSuggestions || _isReverseGeocoding || _isForwardGeocoding)
                  ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5)),
              )
                  : (_addressController.text.isNotEmpty
                  ? IconButton(
                tooltip: 'Limpiar',
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _isUpdatingAddressProgrammatically = true;
                  setState(() {
                    _addressController.clear();
                    _addressSuggestions = [];
                    _addressGeocodedSuccessfully = false;
                    _selectedLocation = null;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _isUpdatingAddressProgrammatically = false;
                  });
                  _addressFocusNode.requestFocus();
                  _syncAddressOverlay();

                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      const LatLng(23.6345, -102.5528), // Centro de México
                      5,
                    ),
                  );
                },
              )
                  : null),
            ),
          ),
        ),
      ),
      if (_selectedLocation != null && _addressGeocodedSuccessfully)
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.successColor.withOpacity(0.3)),
            ),
            child: Row(
              children: const [
                Icon(Icons.check_circle, color: AppColors.successColor, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dirección validada. Puedes ajustar el marcador en el mapa.',
                    style: TextStyle(color: AppColors.successColor, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      const SizedBox(height: 20),
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 500,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.outline, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: _googleApiKey.isEmpty
              ? _buildApiWarning()
              : (kIsWeb || !Platform.isWindows)
              ? Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(23.6345, -102.5528),
                  zoom: 5,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  _isMapReady = true;

                  if (_selectedLocation != null) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(_selectedLocation!, 17),
                      );
                    });
                  }
                },
                markers: _selectedLocation != null
                    ? {
                  Marker(
                    markerId: const MarkerId('company_location'),
                    position: _selectedLocation!,
                    draggable: true,
                    onDragEnd: (newPosition) {
                      _updateAddressFromLatLng(newPosition);
                    },
                    infoWindow: const InfoWindow(
                      title: 'Ubicación de tu empresa',
                      snippet: 'Arrastra para ajustar',
                    ),
                  ),
                }
                    : {},
                onTap: (position) {
                  _updateAddressFromLatLng(position);
                },
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
                compassEnabled: true,
                mapType: MapType.normal,
              ),
              if (_selectedLocation == null)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.location_searching, size: 48, color: AppColors.primaryColor),
                        SizedBox(height: 12),
                        Text(
                          'Busca tu dirección arriba',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'O toca en el mapa para seleccionar',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          )
              : _buildWindowsMap(),
        ),
      ),
    ]);
  }

  Widget _buildWindowsMap() {
    if (!_isWebviewReady) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasLoadedInitialMap && _selectedLocation != null) {
      _hasLoadedInitialMap = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadWindowsMapLocation(_selectedLocation!);
      });
    }

    return ww.Webview(_webviewController);
  }

  Widget _buildServicesContent() {
    return Column(children: [
      ElevatedButton.icon(
        onPressed: _showAddServiceDialog,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Servicio'),
      ),
      const SizedBox(height: 24),
      if (_services.isEmpty)
        const Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No hay servicios registrados.',
            style: TextStyle(color: AppColors.textSecondaryColor, fontSize: 16),
          ),
        )
      else
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _services.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final service = _services[i];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            service.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.primaryColor),
                          onPressed: () => _editService(i),
                          tooltip: 'Editar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteService(i),
                          tooltip: 'Eliminar',
                        ),
                      ],
                    ),
                    if (service.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        service.description,
                        style: const TextStyle(color: AppColors.textSecondaryColor),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (service.price > 0) ...[
                          const Icon(Icons.attach_money, size: 16, color: AppColors.primaryColor),
                          Text(
                            '\$${service.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 16),
                        ],
                        if (service.duration > 0) ...[
                          const Icon(Icons.access_time, size: 16, color: AppColors.primaryColor),
                          Text(
                            '${service.duration} min',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                    if (service.imagePaths.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: service.imagePaths.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, imgIndex) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(service.imagePaths[imgIndex]),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
    ]);
  }

  Widget _buildApiWarning() => const Center(child: Text('API Key de Google Maps no configurada.'));

  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: AppColors.primaryColor),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
          const Divider(height: 32),
          child,
        ]),
      ),
    );
  }

  Widget _buildTimePickerField(String label, TimeOfDay time, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        child: Text(time.format(context)),
      ),
    );
  }

  String? _formatAddressFromComponents(List<Map<String, dynamic>> components) {
    if (components.isEmpty) return null;
    final byType = <String, String>{};
    for (final c in components) {
      final types = (c['types'] as List?)?.cast<String>() ?? const [];
      for (final t in types) {
        byType[t] = c['long_name'];
      }
    }
    final parts = [
      if (byType['route'] != null) '${byType['route']} ${byType['street_number'] ?? ''}'.trim(),
      byType['neighborhood'] ?? byType['sublocality_level_1'] ?? byType['sublocality'],
      byType['locality'],
      byType['administrative_area_level_1'],
      byType['postal_code'],
    ].where((p) => p != null && p.isNotEmpty).toSet().toList();
    return parts.join(', ');
  }

  String? _validateMexicanAddress(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Campo requerido';
    if (!_addressGeocodedSuccessfully) return 'Selecciona una dirección válida de la lista.';
    if (trimmed.length < 10) return 'Dirección demasiado corta.';
    if (!RegExp(r'\d').hasMatch(trimmed)) return 'Incluye el número exterior.';
    return null;
  }
}

class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  const PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });
}

