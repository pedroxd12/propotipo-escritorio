// lib/design/screens/home/home_screen.dart
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

// Importa el nuevo widget para el calendario pequeño
import 'package:serviceflow/design/widgets/home/mini_calendar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isEditMode = false;
  Map<String, AgendaEvent> _pendingChanges = {};
  List<AgendaEvent> _events = [];
  Map<DateTime, List<AgendaEvent>> _eventsByDay = {};
  List<AgendaEvent> _selectedDayEvents = [];
  DateTime _currentDate = DateTime.now();
  String _currentView = 'Semana';
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _isMapExpanded = false;

  // Controladores de animación para mejorar la UX
  late AnimationController _calendarAnimationController;
  late AnimationController _eventListAnimationController;
  late Animation<double> _fadeAnimation;

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

    // Inicializar controladores de animación
    _calendarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _eventListAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _eventListAnimationController,
      curve: Curves.easeInOut,
    ));

    _createSampleOrders();
    _loadSampleEvents();

    // Iniciar animación
    _eventListAnimationController.forward();
  }

  @override
  void dispose() {
    _calendarAnimationController.dispose();
    _eventListAnimationController.dispose();
    super.dispose();
  }

  void _createSampleOrders() {
    final today = DateTime.now();
    final mondayThisWeek = today.subtract(Duration(days: today.weekday - 1));

    final cliente1 = Cliente(
        id: 'cl-1',
        empresaId: 'emp-1',
        nombreCuenta: 'TechCorp',
        telefonoPrincipal: 'N/A',
        emailFacturacion: 'N/A',
        direcciones: [
          Direccion(
              id: 'dir-1',
              calleYNumero: 'N/A',
              colonia: 'N/A',
              codigoPostal: 'N/A',
              municipio: 'N/A',
              estado: 'N/A',
              latitud: 17.9625,
              longitud: -102.2033
          )
        ]
    );

    final cliente2 = Cliente(
        id: 'cl-2',
        empresaId: 'emp-1',
        nombreCuenta: 'Zeta Solutions',
        telefonoPrincipal: 'N/A',
        emailFacturacion: 'N/A',
        direcciones: [
          Direccion(
              id: 'dir-2',
              calleYNumero: 'N/A',
              colonia: 'N/A',
              codigoPostal: 'N/A',
              municipio: 'N/A',
              estado: 'N/A',
              latitud: 17.9740,
              longitud: -102.1995
          )
        ]
    );

    final tecnico1 = Usuario(
        id: 'user-2',
        empresaId: 'emp-1',
        nombres: 'Ana',
        apellidoPaterno: 'Pérez',
        email: 'N/A',
        telefono: 'N/A',
        rol: 'Tecnico'
    );

    final tecnico2 = Usuario(
        id: 'user-3',
        empresaId: 'emp-1',
        nombres: 'Carlos',
        apellidoPaterno: 'Ruiz',
        email: 'N/A',
        telefono: 'N/A',
        rol: 'Tecnico'
    );

    _orden1 = OrdenServicio(
      id: 'OS-12564',
      empresaId: 'emp-1',
      folio: 'OS-12564',
      cliente: cliente1,
      direccion: cliente1.direcciones.first,
      servicio: Servicio(id: 'ser-1', nombre: 'Reunión equipo Alfa', costoBase: 0),
      status: OrdenStatus.agendada,
      fechaSolicitud: DateTime.now(),
      fechaAgendadaInicio: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day, 9, 0),
      fechaAgendadaFin: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day, 10, 0),
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
      servicio: Servicio(id: 'ser-2', nombre: 'Visita Cliente TechCorp', costoBase: 0),
      status: OrdenStatus.en_proceso,
      fechaSolicitud: DateTime.now(),
      fechaAgendadaInicio: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day, 11, 0),
      fechaAgendadaFin: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day, 12, 30),
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
      servicio: Servicio(id: 'ser-3', nombre: 'Soporte Remoto Zeta', costoBase: 0),
      status: OrdenStatus.agendada,
      fechaSolicitud: DateTime.now(),
      fechaAgendadaInicio: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day, 11, 0),
      fechaAgendadaFin: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day, 13, 0),
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
      servicio: Servicio(id: 'ser-4', nombre: 'Capacitación Interna', costoBase: 0),
      status: OrdenStatus.finalizada,
      fechaSolicitud: DateTime.now(),
      fechaAgendadaInicio: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day + 2, 15, 0),
      fechaAgendadaFin: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day + 2, 17, 0),
      detallesSolicitud: 'Capacitación sobre nuevo software.',
      costoTotal: 0,
      tecnicosAsignados: [tecnico2],
    );
  }

  void _loadSampleEvents() {
    _events = [
      AgendaEvent.fromOrdenServicio(_orden1),
      AgendaEvent.fromOrdenServicio(_orden2),
      AgendaEvent.fromOrdenServicio(_orden3),
      AgendaEvent.fromOrdenServicio(_orden4),
    ];

    _eventsByDay = {};
    for (var event in _events) {
      final day = DateTime.utc(event.startTime.year, event.startTime.month, event.startTime.day);
      if (_eventsByDay[day] == null) {
        _eventsByDay[day] = [];
      }
      _eventsByDay[day]!.add(event);
    }

    // Actualizar eventos del día seleccionado
    _updateSelectedDayEvents();
  }

  void _updateSelectedDayEvents() {
    final dayKey = DateTime.utc(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final eventsForDay = _eventsByDay[dayKey] ?? [];

    // Ordenar eventos por hora de inicio
    eventsForDay.sort((a, b) => a.startTime.compareTo(b.startTime));

    setState(() {
      _selectedDayEvents = eventsForDay;
    });

    // Animar la actualización de la lista
    _eventListAnimationController.reset();
    _eventListAnimationController.forward();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _updateSelectedDayEvents();
  }

  void _navigateToOrderDetail(AgendaEvent event) {
    context.push('/order-detail/${event.id}', extra: event);
  }

  DateTime get _startOfWeek {
    DateTime date = _currentDate;
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _previous() {
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
    setState(() {
      _currentDate = DateTime.now();
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();
      _updateSelectedDayEvents();
    });
  }

  void _saveChanges() {
    if (_pendingChanges.isEmpty) {
      setState(() {
        _isEditMode = false;
      });
      return;
    }

    setState(() {
      for (var changedEvent in _pendingChanges.values) {
        if (changedEvent.id == _orden1.id) _orden1 = changedEvent.ordenOriginal;
        if (changedEvent.id == _orden2.id) _orden2 = changedEvent.ordenOriginal;
        if (changedEvent.id == _orden3.id) _orden3 = changedEvent.ordenOriginal;
        if (changedEvent.id == _orden4.id) _orden4 = changedEvent.ordenOriginal;
      }
      _loadSampleEvents();
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
    setState(() {
      _pendingChanges.clear();
      _isEditMode = false;
    });
  }

  void _toggleMapExpand() {
    setState(() {
      _isMapExpanded = !_isMapExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    final technicianProvider = context.watch<TechnicianProvider>();
    final serviceOrderProvider = context.watch<ServiceOrderProvider>();

    final todayEvents = serviceOrderProvider.filteredOrders.where((order) =>
    order.fechaAgendadaInicio.day == DateTime.now().day &&
        order.fechaAgendadaInicio.month == DateTime.now().month &&
        order.fechaAgendadaInicio.year == DateTime.now().year
    ).toList();

    return Row(
      children: [
        Container(
          width: 320,
          margin: const EdgeInsets.fromLTRB(16, 16, 0, 16),
          child: Column(
            children: [
              const Expanded(
                flex: 5,
                child: DailyAgendaPanel(),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 4,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
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
                    orders: todayEvents.map((e) => AgendaEvent.fromOrdenServicio(e)).toList(),
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
                duration: const Duration(milliseconds: 300),
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
    switch (_currentView) {
      case 'Semana':
        return _buildWeekView();
      case 'Mes':
        return _buildMonthView();
      default:
        return _buildWeekView();
    }
  }

  Widget _buildMonthView() {
    return Column(
      children: [
        _buildViewHeader(),
        Expanded(
          child: Row(
            children: [
              // Calendario del mes
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TableCalendar<AgendaEvent>(
                    locale: 'es_ES',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: _onDaySelected,
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: (day) {
                      final dayKey = DateTime.utc(day.year, day.month, day.day);
                      return _eventsByDay[dayKey] ?? [];
                    },
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(color: AppColors.errorColor.withOpacity(0.8)),
                      holidayTextStyle: TextStyle(color: AppColors.errorColor.withOpacity(0.8)),
                      todayDecoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryColor, width: 1.5),
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
                      todayTextStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
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
              ),
              // Separador vertical
              Container(
                width: 1,
                color: AppColors.outline,
                margin: const EdgeInsets.symmetric(vertical: 16),
              ),
              // Panel de eventos del día seleccionado
              Expanded(
                flex: 2,
                child: _buildDayAgendaImproved(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewHeader() {
    final DateFormat dayMonthFormat = DateFormat('d MMM', 'es_ES');
    final weekStart = _startOfWeek;
    String headerText;

    switch (_currentView) {
      case 'Mes':
        headerText = DateFormat('MMMM y', 'es_ES').format(_focusedDay);
        break;
      default:
        headerText = "${dayMonthFormat.format(weekStart)} - ${dayMonthFormat.format(weekStart.add(const Duration(days: 6)))}";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outline, width: 0.5)),
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
            ),
          ),
          if (_currentView == 'Semana')
            if (_isEditMode)
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _cancelChanges,
                    icon: const Icon(Icons.cancel_outlined, color: AppColors.errorColor, size: 20),
                    label: const Text('Cancelar', style: TextStyle(color: AppColors.errorColor)),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text('Guardar'),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.successColor),
                  ),
                  const SizedBox(width: 16),
                ],
              )
            else
              IconButton(
                icon: const Icon(Icons.edit_calendar_outlined),
                tooltip: 'Editar Agenda',
                onPressed: () => setState(() => _isEditMode = true),
              ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _currentView,
              items: <String>['Semana', 'Mes'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (_isEditMode) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Guarde o cancele los cambios para cambiar de vista.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                setState(() => _currentView = newValue!);
              },
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayAgendaImproved() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del día seleccionado
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
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
          ),
          const SizedBox(height: 16),

          // Lista de eventos
          Expanded(
            child: _selectedDayEvents.isEmpty
                ? _buildEmptyEventsState()
                : _buildEventsList(),
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
            color: AppColors.textSecondaryColor.withOpacity(0.5),
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
              color: AppColors.textSecondaryColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.separated(
        itemCount: _selectedDayEvents.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final event = _selectedDayEvents[index];
          return _buildEnhancedEventCard(event, index);
        },
      ),
    );
  }

  Widget _buildEnhancedEventCard(AgendaEvent event, int index) {
    final timeFormat = DateFormat('HH:mm');
    final duration = event.endTime.difference(event.startTime);
    final durationText = '${duration.inHours}h ${duration.inMinutes % 60}m';

    // Determinar el color del status
    Color statusColor = AppColors.primaryColor;
    String statusText = 'Agendada';
    IconData statusIcon = Icons.schedule;

    switch (event.ordenOriginal.status) {
      case OrdenStatus.en_proceso:
        statusColor = AppColors.warningColor;
        statusText = 'En Proceso';
        statusIcon = Icons.play_circle_outline;
        break;
      case OrdenStatus.finalizada:
        statusColor = AppColors.successColor;
        statusText = 'Finalizada';
        statusIcon = Icons.check_circle_outline;
        break;
      case OrdenStatus.cancelada:
        statusColor = AppColors.errorColor;
        statusText = 'Cancelada';
        statusIcon = Icons.cancel_outlined;
        break;
      case OrdenStatus.agendada:
      default:
        statusColor = AppColors.primaryColor;
        statusText = 'Agendada';
        statusIcon = Icons.schedule;
        break;
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 200 + (index * 50)),
      curve: Curves.easeOutBack,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: event.color.withOpacity(0.3), width: 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToOrderDetail(event),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con tiempo y status
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: event.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: AppColors.textSecondaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '($durationText)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                statusIcon,
                                size: 14,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Título del evento
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Información del cliente y técnico
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

                // Detalles adicionales si existen
                if (event.ordenOriginal.detallesSolicitud?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 16,
                          color: AppColors.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.ordenOriginal.detallesSolicitud ?? '',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryColor,
                            ),
                            maxLines: 2,
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

  // Método legacy mantenido para compatibilidad con vista semanal
  Widget _buildDayAgenda({bool showDate = false}) {
    if (_selectedDayEvents.isEmpty) {
      return Column(
        crossAxisAlignment: showDate ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (showDate)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Text(
                DateFormat('EEEE, d MMMM y', 'es_ES').format(_selectedDay),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          const Expanded(
            child: Center(child: Text("No hay eventos para este día.")),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDate)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Text(
              DateFormat('EEEE, d MMMM y', 'es_ES').format(_selectedDay),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _selectedDayEvents.length,
            itemBuilder: (context, index) {
              final event = _selectedDayEvents[index];
              return _buildEventCard(event);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(AgendaEvent event) {
    final timeFormat = DateFormat('HH:mm');
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: Container(
          width: 6,
          decoration: BoxDecoration(
            color: event.color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Cliente: ${event.client}\nTécnico: ${event.technician}'),
        trailing: Text('${timeFormat.format(event.startTime)}\n${timeFormat.format(event.endTime)}'),
        onTap: () => _navigateToOrderDetail(event),
      ),
    );
  }

  Widget _buildWeekView() {
    final days = ["LUN", "MAR", "MIÉ", "JUE", "VIE", "SÁB", "DOM"];
    final weekStart = _startOfWeek;

    return Column(
      children: [
        _buildViewHeader(),
        Container(
          height: 70,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.outline)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 80),
              ...List.generate(7, (index) {
                final dayDate = weekStart.add(Duration(days: index));
                bool isToday = DateUtils.isSameDay(DateTime.now(), dayDate);
                bool isSelected = DateUtils.isSameDay(_selectedDay, dayDate);

                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: AppColors.outline.withOpacity(0.5)),
                      ),
                    ),
                    child: InkWell(
                      onTap: () => _onDaySelected(dayDate, dayDate),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              days[index],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : AppColors.textSecondaryColor,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: isToday
                                  ? AppColors.primaryColor
                                  : isSelected
                                  ? AppColors.primaryColor.withOpacity(0.2)
                                  : Colors.transparent,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeColumn(),
                ...List.generate(7, (dayIndex) {
                  return Expanded(
                    child: _buildDayColumn(dayIndex, weekStart.add(Duration(days: dayIndex))),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
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
                "${NumberFormat("00").format(hour)}:00",
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

  Widget _buildDayColumn(int dayIndexInWeek, DateTime dateForColumn) {
    final dayKey = DateTime.utc(dateForColumn.year, dateForColumn.month, dateForColumn.day);

    final Map<String, AgendaEvent> eventsForDisplayMap = {};

    for (var event in _eventsByDay[dayKey] ?? []) {
      if (!_pendingChanges.containsKey(event.id)) {
        eventsForDisplayMap[event.id] = event;
      }
    }

    for (var pendingEvent in _pendingChanges.values) {
      final pendingDayKey = DateTime.utc(pendingEvent.startTime.year, pendingEvent.startTime.month, pendingEvent.startTime.day);
      if (isSameDay(pendingDayKey, dayKey)) {
        eventsForDisplayMap[pendingEvent.id] = pendingEvent;
      }
    }

    final eventsForDay = eventsForDisplayMap.values.toList();
    final eventLayoutParams = _layoutHelper.calculateLayout(eventsForDay);

    return DragTarget<AgendaEvent>(
      onWillAccept: (data) => _isEditMode,
      onAcceptWithDetails: (details) {
        if (!_isEditMode) return;
        final RenderBox? renderBox = _dayColumnKeys[dayIndexInWeek].currentContext?.findRenderObject() as RenderBox?;
        if (renderBox == null) return;

        final localOffset = renderBox.globalToLocal(details.offset);
        final minutesFromTop = (localOffset.dy / _hourRowHeight) * 60;
        final clampedMinutes = minutesFromTop.clamp(0.0, (_endHour - _startHour) * 60.0);

        int newHour = _startHour + (clampedMinutes / 60).floor();
        int newMinute = (clampedMinutes % 60).round();
        newMinute = (newMinute / 15).round() * 15;
        if (newMinute >= 60) {
          newHour++;
          newMinute = 0;
        }

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
        bool isSelected = DateUtils.isSameDay(dateForColumn, _selectedDay);

        return Container(
          key: _dayColumnKeys[dayIndexInWeek],
          height: (_endHour - _startHour) * _hourRowHeight,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.outline.withOpacity(0.5)),
            ),
            color: isSelected
                ? AppColors.primaryColor.withOpacity(0.05)
                : Colors.transparent,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  ...List.generate(
                    (_endHour - _startHour),
                        (index) => Positioned(
                      top: index * _hourRowHeight,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: _hourRowHeight,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.outline.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...eventLayoutParams.map((params) {
                    final event = params.event;
                    final topPosition = (event.startHourOffset - _startHour) * _hourRowHeight;
                    final itemHeight = (event.duration.inMinutes / 60.0) * _hourRowHeight;
                    final totalWidth = constraints.maxWidth;
                    final itemWidth = totalWidth * params.width;
                    final leftPosition = totalWidth * params.left;

                    Widget eventWidget = AgendaItemWidget(
                      event: event,
                      onTap: () {
                        if (!_isEditMode) _navigateToOrderDetail(event);
                      },
                      hourRowHeight: _hourRowHeight,
                      startHourOfDay: _startHour,
                    );

                    return Positioned(
                      top: topPosition,
                      left: leftPosition,
                      height: itemHeight,
                      width: itemWidth,
                      child: _isEditMode
                          ? Draggable<AgendaEvent>(
                        data: event,
                        feedback: SizedBox(
                          width: itemWidth,
                          height: itemHeight,
                          child: Material(
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(8),
                            child: eventWidget,
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.4,
                          child: eventWidget,
                        ),
                        child: eventWidget,
                      )
                          : eventWidget,
                    );
                  }).toList(),
                ],
              );
            },
          ),
        );
      },
    );
  }
}