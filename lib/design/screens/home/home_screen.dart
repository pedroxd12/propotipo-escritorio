// lib/design/screens/home/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:serviceflow/data/models/agenda_event.dart';
import 'package:serviceflow/data/models/client_model.dart';
import 'package:serviceflow/data/models/orden_servicio_model.dart';
import 'package:serviceflow/data/models/usuario_model.dart';
import 'package:serviceflow/design/widgets/agenda/agenda_item_widget.dart';
import 'package:serviceflow/design/widgets/home/daily_agenda_panel.dart';
import 'package:serviceflow/design/widgets/map/technician_map_widget.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:serviceflow/design/widgets/agenda/event_layout_helper.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:serviceflow/design/state/service_order_provider.dart';
import 'package:serviceflow/design/state/technician_provider.dart';
import 'package:serviceflow/design/widgets/home/mini_calendar_widget.dart';
import 'package:serviceflow/design/widgets/order/order_detail_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isEditMode = false;
  final Map<String, AgendaEvent> _pendingChanges = {};
  List<AgendaEvent> _events = [];
  Map<DateTime, List<AgendaEvent>> _eventsByDay = {};
  List<AgendaEvent> _selectedDayEvents = [];
  DateTime _currentDate = DateTime.now();
  String _currentView = 'Semana';
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _isMapExpanded = false;
  bool _initialLoadComplete = false;

  final ScrollController _scrollController = ScrollController();
  final ScrollController _eventsScrollController = ScrollController();
  Timer? _scrollTimer;
  bool _isDragging = false;

  late AnimationController _calendarAnimationController;
  late AnimationController _eventListAnimationController;
  late AnimationController _pageTransitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final double _hourRowHeight = 90.0;
  final int _startHour = 7;
  final int _endHour = 21;
  final EventLayoutHelper _layoutHelper = EventLayoutHelper();
  final List<GlobalKey> _dayColumnKeys = List.generate(7, (_) => GlobalKey());

  late OrdenServicio _orden1, _orden2, _orden3, _orden4;

  final Map<String, List<double>> _technicianLocations = {
    'user-2': [17.9628, -102.2040],
    'user-3': [17.9735, -102.2000],
  };

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);

    _calendarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _eventListAnimationController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _eventListAnimationController,
      curve: Curves.easeInOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _eventListAnimationController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialLoadComplete && mounted) {
        _loadSampleEvents();
        _eventListAnimationController.forward();
        setState(() => _initialLoadComplete = true);
      }
    });
  }

  @override
  void dispose() {
    _calendarAnimationController.dispose();
    _eventListAnimationController.dispose();
    _pageTransitionController.dispose();
    _scrollController.dispose();
    _eventsScrollController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  void _createSampleOrders() {
    final technicianProvider = context.read<TechnicianProvider>();
    final tecnicos = technicianProvider.filteredTechnicians;

    final tecnico1 = tecnicos.isNotEmpty && tecnicos[0].id == 'user-2'
        ? tecnicos[0]
        : Usuario(
        id: 'user-2',
        empresaId: 'emp-1',
        nombres: 'Carlos',
        apellidoPaterno: 'Sánchez',
        email: 'carlos@ex.com',
        telefono: '1',
        rol: 'Tecnico');

    final tecnico2 = tecnicos.length > 1 && tecnicos[1].id == 'user-3'
        ? tecnicos[1]
        : Usuario(
        id: 'user-3',
        empresaId: 'emp-1',
        nombres: 'María',
        apellidoPaterno: 'Gómez',
        email: 'maria@ex.com',
        telefono: '2',
        rol: 'Tecnico');

    final today = DateTime.now();
    final mondayThisWeek = today.subtract(Duration(days: today.weekday - 1));

    final cliente1 = Cliente(
        id: 'cl-1',
        empresaId: 'emp-1',
        nombreCuenta: 'TechCorp S.A. de C.V.',
        telefonoPrincipal: '555-1111-2222',
        emailFacturacion: 'facturacion@techcorp.com',
        direcciones: [
          Direccion(
              id: 'dir-1',
              calleYNumero: 'Av. Melchor Ocampo 15',
              colonia: 'Centro',
              codigoPostal: '60950',
              municipio: 'Lázaro Cardenas',
              estado: 'Michoacán',
              referencias: 'Frente al malecón de la cultura y las artes.',
              latitud: 17.9625,
              longitud: -102.2033)
        ]);

    final cliente2 = Cliente(
        id: 'cl-2',
        empresaId: 'emp-1',
        nombreCuenta: 'Zeta Solutions',
        telefonoPrincipal: '555-3333-4444',
        emailFacturacion: 'compras@betamax.com',
        direcciones: [
          Direccion(
              id: 'dir-2',
              calleYNumero: 'Blvd. Industrial 100',
              colonia: 'Parque Industrial',
              codigoPostal: '12346',
              municipio: 'Springfield',
              estado: 'Oregon',
              latitud: 17.9740,
              longitud: -102.1995)
        ]);

    _orden1 = OrdenServicio(
      id: 'OS-12564',
      empresaId: 'emp-1',
      folio: 'OS-12564',
      cliente: cliente1,
      direccion: cliente1.direcciones.first,
      servicio: Servicio(id: 'ser-1', nombre: 'Reunión equipo Alfa', costoBase: 0),
      status: OrdenStatus.agendada,
      fechaSolicitud: DateTime.now(),
      fechaAgendadaInicio: DateTime(mondayThisWeek.year, mondayThisWeek.month,
          mondayThisWeek.day, 9, 0),
      fechaAgendadaFin: DateTime(mondayThisWeek.year, mondayThisWeek.month,
          mondayThisWeek.day, 10, 0),
      detallesSolicitud: 'Planificación semanal del sprint.',
      costoTotal: 0,
      tecnicosAsignados: [tecnico1],
    );

    _orden2 = OrdenServicio(
      id: 'OS-12565',
      empresaId: 'emp-1',
      folio: 'OS-12565',
      cliente: cliente1,
      direccion: cliente1.direcciones.first,
      servicio:
      Servicio(id: 'ser-2', nombre: 'Visita Cliente TechCorp', costoBase: 0),
      status: OrdenStatus.enProceso,
      fechaSolicitud: DateTime.now(),
      fechaAgendadaInicio: DateTime(mondayThisWeek.year, mondayThisWeek.month,
          mondayThisWeek.day, 11, 0),
      fechaAgendadaFin: DateTime(mondayThisWeek.year, mondayThisWeek.month,
          mondayThisWeek.day, 12, 30),
      detallesSolicitud: 'Mantenimiento preventivo del servidor principal.',
      costoTotal: 0,
      tecnicosAsignados: [tecnico2],
    );

    _orden3 = OrdenServicio(
      id: 'OS-12566',
      empresaId: 'emp-1',
      folio: 'OS-12566',
      cliente: cliente2,
      direccion: cliente2.direcciones.first,
      servicio:
      Servicio(id: 'ser-3', nombre: 'Soporte Remoto Zeta', costoBase: 0),
      status: OrdenStatus.agendada,
      fechaSolicitud: DateTime.now(),
      fechaAgendadaInicio: DateTime(mondayThisWeek.year, mondayThisWeek.month,
          mondayThisWeek.day, 11, 30),
      fechaAgendadaFin: DateTime(mondayThisWeek.year, mondayThisWeek.month,
          mondayThisWeek.day, 13, 30),
      detallesSolicitud: 'Soporte remoto para el sistema de facturación.',
      costoTotal: 0,
      tecnicosAsignados: [tecnico1],
    );

    _orden4 = OrdenServicio(
      id: 'OS-12567',
      empresaId: 'emp-1',
      folio: 'OS-12567',
      cliente: cliente2,
      direccion: cliente2.direcciones.first,
      servicio:
      Servicio(id: 'ser-4', nombre: 'Capacitación Interna', costoBase: 0),
      status: OrdenStatus.finalizada,
      fechaSolicitud: DateTime.now(),
      fechaAgendadaInicio: DateTime(mondayThisWeek.year, mondayThisWeek.month,
          mondayThisWeek.day + 2, 15, 0),
      fechaAgendadaFin: DateTime(mondayThisWeek.year, mondayThisWeek.month,
          mondayThisWeek.day + 2, 17, 0),
      detallesSolicitud: 'Capacitación sobre nuevo software.',
      costoTotal: 0,
      tecnicosAsignados: [tecnico2],
    );
  }

  void _loadSampleEvents() {
    if (!mounted) return;
    _createSampleOrders();

    _events = [
      AgendaEvent.fromOrdenServicio(_orden1),
      AgendaEvent.fromOrdenServicio(_orden2),
      AgendaEvent.fromOrdenServicio(_orden3),
      AgendaEvent.fromOrdenServicio(_orden4),
    ];

    _rebuildEventMapAndUpdateUI();
  }

  void _rebuildEventMapAndUpdateUI() {
    _eventsByDay = {};
    for (var event in _events) {
      final day = DateTime.utc(
          event.startTime.year, event.startTime.month, event.startTime.day);
      _eventsByDay[day] ??= [];
      _eventsByDay[day]!.add(event);
    }
    _updateSelectedDayEvents();
  }

  void _updateSelectedDayEvents() {
    final dayKey =
    DateTime.utc(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final eventsForDay = _eventsByDay[dayKey] ?? [];

    eventsForDay.sort((a, b) => a.startTime.compareTo(b.startTime));

    if (mounted) {
      setState(() {
        _selectedDayEvents = eventsForDay;
      });

      _eventListAnimationController.reset();
      _eventListAnimationController.forward();
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!mounted) return;
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _updateSelectedDayEvents();
  }

  void _navigateToOrderDetail(AgendaEvent event) {
    // Abre el modal flotante con animación
    OrderDetailModal.show(context, event);
  }

  DateTime get _startOfWeek {
    return _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
  }

  void _previous() {
    if (!mounted) return;
    setState(() {
      if (_currentView == 'Semana') {
        _currentDate = _currentDate.subtract(const Duration(days: 7));
        _focusedDay = _currentDate;
      } else {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
      }
      _updateSelectedDayEvents();
    });
  }

  void _next() {
    if (!mounted) return;
    setState(() {
      if (_currentView == 'Semana') {
        _currentDate = _currentDate.add(const Duration(days: 7));
        _focusedDay = _currentDate;
      } else {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
      }
      _updateSelectedDayEvents();
    });
  }

  void _goToToday() {
    if (!mounted) return;
    setState(() {
      _currentDate = DateTime.now();
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();
      _updateSelectedDayEvents();
    });
  }

  void _saveChanges() {
    if (!mounted) return;

    if (_pendingChanges.isEmpty) {
      setState(() => _isEditMode = false);
      return;
    }

    setState(() {
      for (var changedEvent in _pendingChanges.values) {
        final index = _events.indexWhere((e) => e.id == changedEvent.id);
        if (index != -1) {
          _events[index] = changedEvent;
        }
      }
      _rebuildEventMapAndUpdateUI();
      _pendingChanges.clear();
      _isEditMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Los cambios en la agenda han sido guardados.'),
        backgroundColor: AppColors.successColor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _cancelChanges() {
    if (!mounted) return;
    setState(() {
      _pendingChanges.clear();
      _isEditMode = false;
    });
    _rebuildEventMapAndUpdateUI();
  }

  void _toggleMapExpand() {
    if (!mounted) return;
    setState(() => _isMapExpanded = !_isMapExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final serviceOrderProvider = context.watch<ServiceOrderProvider>();

    final todayOrders = serviceOrderProvider.filteredOrders.where((order) {
      final now = DateTime.now();
      return order.fechaAgendadaInicio.day == now.day &&
          order.fechaAgendadaInicio.month == now.month &&
          order.fechaAgendadaInicio.year == now.year;
    }).toList();

    final todayEventsForMap =
    todayOrders.map((e) => AgendaEvent.fromOrdenServicio(e)).toList();

    if (!_initialLoadComplete) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildMainContent(todayEventsForMap),
      ),
    );
  }

  Widget _buildMainContent(List<AgendaEvent> todayEventsForMap) {
    return Row(
      children: [
        Container(
          width: 320,
          margin: const EdgeInsets.fromLTRB(16, 16, 0, 16),
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: DailyAgendaPanel(todayEvents: todayEventsForMap),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 4,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeInOutCubic,
                  switchOutCurve: Curves.easeInOutCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.0)
                            .animate(animation),
                        child: child,
                      ),
                    );
                  },
                  // --- CORRECCIÓN DE LÓGICA AQUÍ ---
                  // Si el mapa está expandido, muestra el mini calendario.
                  // Si no, muestra el mini mapa.
                  child: _isMapExpanded
                      ? MiniCalendarWidget(
                    key: const ValueKey('mini-calendar'),
                    onTap: _toggleMapExpand,
                    selectedDay: _selectedDay,
                    focusedDay: _focusedDay,
                    onDaySelected: _onDaySelected,
                    eventsByDay: _eventsByDay,
                  )
                      : TechnicianMapWidget(
                    key: const ValueKey('technician-map-small'),
                    orders: todayEventsForMap,
                    technicianLocations: _technicianLocations,
                    onExpand: _toggleMapExpand,
                    isExpanded: _isMapExpanded,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppColors.outline),
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.02, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _isMapExpanded
                    ? TechnicianMapWidget(
                  key: const ValueKey('technician-map-expanded'),
                  orders: _events,
                  technicianLocations: _technicianLocations,
                  onExpand: _toggleMapExpand,
                  isExpanded: _isMapExpanded,
                )
                    : _buildCurrentView(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentView() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final scaleAnimation = Tween<double>(
          begin: 0.92,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
      child: _currentView == 'Semana'
          ? _buildWeekView()
          : _buildMonthView(),
    );
  }

  Widget _buildMonthView() {
    return Column(
      key: const ValueKey('month-view'),
      children: [
        _buildViewHeader(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 800;
              if (isNarrow) {
                return Column(
                  children: [
                    Container(
                      height: constraints.maxHeight * 0.4,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildResponsiveCalendar(),
                    ),
                    const Divider(height: 1, color: AppColors.outline),
                    Expanded(
                      child: _buildDayAgendaPanel(),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildResponsiveCalendar(),
                    ),
                  ),
                  Container(
                    width: 1,
                    color: AppColors.outline,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildDayAgendaPanel(),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveCalendar() {
    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 2.0,
      panEnabled: true,
      scaleEnabled: true,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: TableCalendar<AgendaEvent>(
          locale: 'es_ES',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: _onDaySelected,
          onPageChanged: (focusedDay) {
            if (mounted) {
              setState(() => _focusedDay = focusedDay);
            }
          },
          eventLoader: (day) {
            final dayKey = DateTime.utc(day.year, day.month, day.day);
            return _eventsByDay[dayKey] ?? [];
          },
          pageJumpingEnabled: true,
          pageAnimationEnabled: true,
          pageAnimationCurve: Curves.easeInOutCubic,
          pageAnimationDuration: const Duration(milliseconds: 300),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(
                color: AppColors.errorColor.withValues(alpha: 0.8)),
            holidayTextStyle: TextStyle(
                color: AppColors.errorColor.withValues(alpha: 0.8)),
            todayDecoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primaryColor, width: 1.5),
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: AppColors.accentColor,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
            markerMargin: const EdgeInsets.symmetric(horizontal: 1.5),
            cellMargin: const EdgeInsets.all(4.0),
            defaultTextStyle: const TextStyle(fontSize: 16),
            selectedTextStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            todayTextStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
            canMarkersOverflow: false,
            markerSizeScale: 0.2,
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronVisible: false,
            rightChevronVisible: false,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            weekendStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.errorColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewHeader() {
    final DateFormat dayMonthFormat = DateFormat('d MMM', 'es_ES');
    final weekStart = _startOfWeek;
    final String headerText = _currentView == 'Mes'
        ? DateFormat('MMMM y', 'es_ES').format(_focusedDay)
        : '${dayMonthFormat.format(weekStart)} - ${dayMonthFormat.format(weekStart.add(const Duration(days: 6)))}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primaryColor.withValues(alpha: 0.03),
          ],
        ),
        border: const Border(
          bottom: BorderSide(color: AppColors.outline, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previous,
            tooltip: 'Anterior',
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _next,
            tooltip: 'Siguiente',
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: _goToToday,
            icon: const Icon(Icons.today, size: 18),
            label: const Text("Hoy"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              headerText,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_currentView == 'Semana') ..._buildEditModeButtons(),
          _buildViewSelector(),
        ],
      ),
    );
  }

  List<Widget> _buildEditModeButtons() {
    if (!_isEditMode) {
      return [
        IconButton(
          icon: const Icon(Icons.edit_calendar_outlined),
          tooltip: 'Editar Agenda',
          onPressed: () {
            if (mounted) setState(() => _isEditMode = true);
          },
        ),
      ];
    }

    return [
      TextButton.icon(
        onPressed: _cancelChanges,
        icon: const Icon(Icons.cancel_outlined,
            color: AppColors.errorColor, size: 20),
        label: const Text('Cancelar',
            style: TextStyle(color: AppColors.errorColor)),
      ),
      const SizedBox(width: 8),
      FilledButton.icon(
        onPressed: _saveChanges,
        icon: const Icon(Icons.check_circle_outline, size: 20),
        label: const Text('Guardar'),
        style: FilledButton.styleFrom(backgroundColor: AppColors.successColor),
      ),
      const SizedBox(width: 16),
    ];
  }

  Widget _buildViewSelector() {
    return _ViewSelectorWidget(
      currentView: _currentView,
      isEditMode: _isEditMode,
      onChanged: (newValue) {
        if (_isEditMode) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Guarde o cancele los cambios para cambiar de vista.'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        if (mounted && newValue != null) {
          setState(() => _currentView = newValue);
        }
      },
    );
  }

  Widget _buildDayAgendaPanel() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDayAgendaHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedDayEvents.isEmpty
                ? _buildEmptyEventsState()
                : _buildEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayAgendaHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            color: AppColors.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE', 'es_ES').format(_selectedDay),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                Text(
                  DateFormat('d MMMM y', 'es_ES').format(_selectedDay),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _selectedDayEvents.isEmpty
                  ? AppColors.backgroundColor
                  : AppColors.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_selectedDayEvents.length}',
              style: TextStyle(
                color: _selectedDayEvents.isEmpty
                    ? AppColors.textSecondaryColor
                    : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyEventsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 64,
            color: AppColors.textSecondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "Sin eventos",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No hay actividades programadas\npara este día",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification) {
          _eventListAnimationController.forward();
        }
        return false;
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Scrollbar(
            controller: _eventsScrollController,
            thumbVisibility: true,
            radius: const Radius.circular(8),
            thickness: 6,
            child: ListView.separated(
              controller: _eventsScrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.only(
                bottom: 16,
                right: 12,
              ),
              itemCount: _selectedDayEvents.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.95 + (0.05 * value),
                      child: Transform.translate(
                        offset: Offset(0, 10 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: _buildResponsiveEventCard(_selectedDayEvents[index]),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveEventCard(AgendaEvent event) {
    final timeFormat = DateFormat('HH:mm');
    final duration = event.endTime.difference(event.startTime);
    final durationText = '${duration.inHours}h ${duration.inMinutes % 60}m';
    final statusInfo = _getStatusInfo(event.ordenOriginal.status);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 300;
        final isVeryCompact = constraints.maxWidth < 250;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: event.color.withValues(alpha: 0.3), width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _navigateToOrderDetail(event),
              splashColor: event.color.withValues(alpha: 0.1),
              highlightColor: event.color.withValues(alpha: 0.05),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isVeryCompact ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: isVeryCompact ? 3 : 4,
                          height: isCompact ? 35 : 40,
                          decoration: BoxDecoration(
                            color: event.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: isVeryCompact ? 8 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: AppColors.textSecondaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimaryColor,
                                            fontSize: isVeryCompact ? 12 : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (!isVeryCompact)
                                    Text(
                                      '($durationText)',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                        color: AppColors.textSecondaryColor,
                                        fontSize: isCompact ? 11 : null,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    statusInfo['icon'] as IconData,
                                    size: isVeryCompact ? 12 : 14,
                                    color: statusInfo['color'] as Color,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      statusInfo['text'] as String,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                        color: statusInfo['color'] as Color,
                                        fontWeight: FontWeight.w600,
                                        fontSize: isVeryCompact ? 11 : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isVeryCompact ? 8 : 12),

                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                        fontSize: isVeryCompact ? 14 : isCompact ? 15 : null,
                      ),
                      maxLines: isVeryCompact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: isVeryCompact ? 6 : 8),

                    if (isVeryCompact) ...[
                      Text(
                        '${event.client} • ${event.technician}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryColor,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else ...[
                      _buildInfoRow(
                        icon: Icons.business_outlined,
                        label: 'Cliente',
                        value: event.client,
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        icon: Icons.person_outline,
                        label: 'Técnico',
                        value: event.technician,
                      ),
                    ],

                    if (!isVeryCompact && event.ordenOriginal.detallesSolicitud?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(isCompact ? 6 : 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.outline.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.note_outlined,
                              size: isCompact ? 14 : 16,
                              color: AppColors.textSecondaryColor,
                            ),
                            SizedBox(width: isCompact ? 6 : 8),
                            Expanded(
                              child: Text(
                                event.ordenOriginal.detallesSolicitud ?? '',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondaryColor,
                                  fontSize: isCompact ? 11 : null,
                                ),
                                maxLines: isCompact ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getStatusInfo(OrdenStatus status) {
    switch (status) {
      case OrdenStatus.enProceso:
        return {
          'color': AppColors.warningColor,
          'text': 'En Proceso',
          'icon': Icons.play_circle_outline,
        };
      case OrdenStatus.enCamino:
        return {
          'color': AppColors.infoColor,
          'text': 'En Camino',
          'icon': Icons.directions_car_outlined,
        };
      case OrdenStatus.finalizada:
        return {
          'color': AppColors.successColor,
          'text': 'Finalizada',
          'icon': Icons.check_circle_outline,
        };
      case OrdenStatus.cancelada:
        return {
          'color': AppColors.errorColor,
          'text': 'Cancelada',
          'icon': Icons.cancel_outlined,
        };
      case OrdenStatus.agendada:
      default:
        return {
          'color': AppColors.primaryColor,
          'text': 'Agendada',
          'icon': Icons.schedule,
        };
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekView() {
    const days = ["LUN", "MAR", "MIÉ", "JUE", "VIE", "SÁB", "DOM"];
    final weekStart = _startOfWeek;

    return Column(
      children: [
        _buildViewHeader(),
        _buildWeekDayHeaders(days, weekStart),
        Expanded(
          child: Builder(
            builder: (context) {
              return Listener(
                onPointerMove: (event) {
                  if (!_isEditMode || !_isDragging) return;

                  final RenderBox? scrollRenderBox = context.findRenderObject() as RenderBox?;
                  if (scrollRenderBox == null) return;

                  final localPosition = scrollRenderBox.globalToLocal(event.position);
                  const scrollZoneHeight = 60.0;
                  const scrollSpeed = 8.0;

                  if (localPosition.dy < scrollZoneHeight) {
                    _startAutoScroll(-scrollSpeed);
                  } else if (localPosition.dy > scrollRenderBox.size.height - scrollZoneHeight) {
                    _startAutoScroll(scrollSpeed);
                  } else {
                    _stopAutoScroll();
                  }
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimeColumn(),
                      ...List.generate(7, (dayIndex) {
                        return Expanded(
                          child: _buildDayColumn(
                              dayIndex, weekStart.add(Duration(days: dayIndex))),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekDayHeaders(List<String> days, DateTime weekStart) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outline)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 80),
          ...List.generate(7, (index) {
            final dayDate = weekStart.add(Duration(days: index));
            final isToday = DateUtils.isSameDay(DateTime.now(), dayDate);
            final isSelected = DateUtils.isSameDay(_selectedDay, dayDate);

            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
                  ),
                ),
                child: InkWell(
                  onTap: () => _onDaySelected(dayDate, dayDate),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          days[index],
                          style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.textSecondaryColor,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isToday
                                ? AppColors.primaryColor
                                : isSelected
                                ? AppColors.primaryColor.withValues(alpha: 0.2)
                                : Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              DateFormat('d').format(dayDate),
                              style: TextStyle(
                                fontSize: 12,
                                color: isToday
                                    ? Colors.white
                                    : isSelected
                                    ? AppColors.primaryColor
                                    : AppColors.textPrimaryColor,
                                fontWeight: isToday || isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeColumn() {
    return Container(
      width: 80,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.outline)),
      ),
      child: Column(
        children: List.generate(
          (_endHour - _startHour),
              (index) {
            final hour = _startHour + index;
            return Container(
              height: _hourRowHeight,
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${NumberFormat("00").format(hour)}:00',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _stopAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  void _startAutoScroll(double velocity) {
    if (_scrollTimer != null) return;

    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final newOffset = _scrollController.offset + velocity;
      if (newOffset < _scrollController.position.minScrollExtent ||
          newOffset > _scrollController.position.maxScrollExtent) {
        _stopAutoScroll();
      } else {
        _scrollController.jumpTo(newOffset);
      }
    });
  }

  Widget _buildDayColumn(int dayIndexInWeek, DateTime dateForColumn) {
    final dayKey = DateTime.utc(
        dateForColumn.year, dateForColumn.month, dateForColumn.day);

    final Map<String, AgendaEvent> eventsForDisplayMap = {};

    for (var event in _eventsByDay[dayKey] ?? []) {
      if (!_pendingChanges.containsKey(event.id)) {
        eventsForDisplayMap[event.id] = event;
      }
    }

    for (var pendingEvent in _pendingChanges.values) {
      final pendingDayKey = DateTime.utc(pendingEvent.startTime.year,
          pendingEvent.startTime.month, pendingEvent.startTime.day);
      if (isSameDay(pendingDayKey, dayKey)) {
        eventsForDisplayMap[pendingEvent.id] = pendingEvent;
      }
    }

    final eventsForDay = eventsForDisplayMap.values.toList();
    final eventLayoutParams = _layoutHelper.calculateLayout(eventsForDay);

    return DragTarget<AgendaEvent>(
      onWillAcceptWithDetails: (_) => _isEditMode,
      onAcceptWithDetails: (details) {
        _stopAutoScroll();
        if (!_isEditMode || !mounted) return;

        final renderBox = _dayColumnKeys[dayIndexInWeek]
            .currentContext
            ?.findRenderObject() as RenderBox?;
        if (renderBox == null) return;

        final localOffset = renderBox.globalToLocal(details.offset);
        final eventDurationMinutes = details.data.duration.inMinutes.toDouble();
        final itemHeight = (eventDurationMinutes / 60.0) * _hourRowHeight;

        double desiredTop = localOffset.dy;

        final columnHeight = (_endHour - _startHour) * _hourRowHeight;
        desiredTop = desiredTop.clamp(0.0, columnHeight - itemHeight);

        final minutesFromStart = (desiredTop / _hourRowHeight) * 60.0;
        int totalMinutes = (minutesFromStart / 15).round() * 15;

        final totalAvailableMinutes = (_endHour - _startHour) * 60;
        if (totalMinutes + eventDurationMinutes > totalAvailableMinutes) {
          totalMinutes = totalAvailableMinutes - eventDurationMinutes.toInt();
        }

        int newHour = _startHour + (totalMinutes / 60).floor();
        int newMinute = totalMinutes % 60;

        setState(() {
          final eventToUpdate = details.data;
          final duration = eventToUpdate.duration;

          final newStartTime = DateTime(
            dateForColumn.year,
            dateForColumn.month,
            dateForColumn.day,
            newHour,
            newMinute,
          );
          final newEndTime = newStartTime.add(duration);

          final updatedOrden = eventToUpdate.ordenOriginal.copyWith(
            fechaAgendadaInicio: newStartTime,
            fechaAgendadaFin: newEndTime,
          );
          final updatedEvent = AgendaEvent.fromOrdenServicio(updatedOrden);
          _pendingChanges[updatedEvent.id] = updatedEvent;
        });
      },
      builder: (context, candidateData, rejectedData) {
        final isSelected = DateUtils.isSameDay(dateForColumn, _selectedDay);
        final isHighlighted = candidateData.isNotEmpty;

        return AnimatedContainer(
          key: _dayColumnKeys[dayIndexInWeek],
          duration: const Duration(milliseconds: 200),
          height: (_endHour - _startHour) * _hourRowHeight,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
            ),
            color: isHighlighted
                ? AppColors.primaryColor.withValues(alpha: 0.15)
                : isSelected
                ? AppColors.primaryColor.withValues(alpha: 0.05)
                : Colors.transparent,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  ..._buildHourLines(),
                  ..._buildEventWidgets(
                      eventLayoutParams, constraints.maxWidth),
                ],
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildHourLines() {
    return List.generate(
      (_endHour - _startHour),
          (index) => Positioned(
        top: index * _hourRowHeight,
        left: 0,
        right: 0,
        child: Container(
          height: _hourRowHeight,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEventWidgets(
      List<EventLayoutParams> eventLayoutParams, double totalWidth) {
    return eventLayoutParams.map((params) {
      final event = params.event;
      final topPosition =
          (event.startHourOffset - _startHour) * _hourRowHeight;
      final itemHeight = (event.duration.inMinutes / 60.0) * _hourRowHeight;
      final itemWidth = totalWidth * params.width;
      final leftPosition = totalWidth * params.left;

      final baseEventWidget = AgendaItemWidget(
        event: event,
        onTap: () {
          if (!_isEditMode) _navigateToOrderDetail(event);
        },
        hourRowHeight: _hourRowHeight,
        startHourOfDay: _startHour,
      );

      final eventWidget = MouseRegion(
        cursor: _isEditMode ? SystemMouseCursors.move : SystemMouseCursors.click,
        child: baseEventWidget,
      );

      return Positioned(
        top: topPosition,
        left: leftPosition,
        height: itemHeight,
        width: itemWidth,
        child: _isEditMode
            ? Draggable<AgendaEvent>(
          data: event,
          maxSimultaneousDrags: 1,
          feedback: Opacity(
            opacity: 0.85,
            child: Transform.scale(
              scale: 1.05,
              child: SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: Material(
                  elevation: 12.0,
                  borderRadius: BorderRadius.circular(8),
                  clipBehavior: Clip.antiAlias,
                  shadowColor: event.color.withValues(alpha: 0.5),
                  child: baseEventWidget,
                ),
              ),
            ),
          ),
          childWhenDragging: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: event.color.withValues(alpha: 0.5),
                width: 2,
                style: BorderStyle.solid,
              ),
              color: event.color.withValues(alpha: 0.1),
            ),
            child: Center(
              child: Icon(
                Icons.drag_indicator,
                color: event.color.withValues(alpha: 0.3),
                size: 32,
              ),
            ),
          ),
          onDragStarted: () {
            if (mounted) setState(() => _isDragging = true);
          },
          onDragEnd: (details) {
            if (mounted) setState(() => _isDragging = false);
            _stopAutoScroll();
          },
          onDraggableCanceled: (velocity, offset) {
            if (mounted) setState(() => _isDragging = false);
            _stopAutoScroll();
          },
          child: eventWidget,
        )
            : eventWidget,
      );
    }).toList();
  }
}

class _ViewSelectorWidget extends StatefulWidget {
  final String currentView;
  final bool isEditMode;
  final ValueChanged<String?> onChanged;

  const _ViewSelectorWidget({
    required this.currentView,
    required this.isEditMode,
    required this.onChanged,
  });

  @override
  State<_ViewSelectorWidget> createState() => _ViewSelectorWidgetState();
}

class _ViewSelectorWidgetState extends State<_ViewSelectorWidget> {
  bool _isHovered = false;

  void _showViewMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.bottomLeft(Offset.zero), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 4,
      items: <String>['Semana', 'Mes'].map((String value) {
        return PopupMenuItem<String>(
          value: value,
          child: Row(
            children: [
              if (widget.currentView == value)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.check,
                    color: AppColors.primaryColor,
                    size: 18,
                  ),
                ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: widget.currentView == value
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: widget.currentView == value
                      ? AppColors.primaryColor
                      : AppColors.textPrimaryColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((String? value) {
      if (value != null) {
        widget.onChanged(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () => _showViewMenu(context),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minWidth: 120),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.primaryColor.withValues(alpha: 0.05)
                : Colors.transparent,
            border: Border.all(
              color: _isHovered
                  ? AppColors.primaryColor
                  : AppColors.outline,
              width: _isHovered ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  widget.currentView,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: _isHovered ? AppColors.primaryColor : AppColors.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

