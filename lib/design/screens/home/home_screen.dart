// lib/design/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:serviceflow/data/models/agenda_event.dart';
import 'package:serviceflow/data/models/client_model.dart';
import 'package:serviceflow/data/models/orden_servicio_model.dart';
import 'package:serviceflow/data/models/usuario_model.dart';
import 'package:serviceflow/design/widgets/agenda/agenda_item_widget.dart';
import 'package:serviceflow/design/widgets/notification/notification_panel_widget.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:serviceflow/design/widgets/agenda/event_layout_helper.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- ESTADO AÑADIDO PARA EL MODO EDICIÓN ---
  bool _isEditMode = false;
  Map<String, AgendaEvent> _pendingChanges = {};

  // Estado existente
  List<AgendaEvent> _events = [];
  Map<DateTime, List<AgendaEvent>> _eventsByDay = {};
  List<AgendaEvent> _selectedDayEvents = [];
  DateTime _currentDate = DateTime.now();
  String _currentView = 'Semana';
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  final double _hourRowHeight = 90.0;
  final int _startHour = 7;
  final int _endHour = 21;

  final EventLayoutHelper _layoutHelper = EventLayoutHelper();
  final List<GlobalKey> _dayColumnKeys = List.generate(7, (_) => GlobalKey());

  // Datos de ejemplo
  late OrdenServicio _orden1, _orden2, _orden3, _orden4;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _createSampleOrders();
    _loadSampleEvents();
  }

  void _createSampleOrders() {
    final today = DateTime.now();
    final mondayThisWeek = today.subtract(Duration(days: today.weekday - 1));

    final cliente1 = Cliente(id: 'cl-1', empresaId: 'emp-1', nombreCuenta: 'TechCorp', telefonoPrincipal: 'N/A', emailFacturacion: 'N/A');
    final cliente2 = Cliente(id: 'cl-2', empresaId: 'emp-1', nombreCuenta: 'Zeta Solutions', telefonoPrincipal: 'N/A', emailFacturacion: 'N/A');
    final tecnico1 = Usuario(id: 'user-2', empresaId: 'emp-1', nombres: 'Ana', apellidoPaterno: 'Pérez', email: 'N/A', telefono: 'N/A', rol: 'Tecnico');
    final tecnico2 = Usuario(id: 'user-3', empresaId: 'emp-1', nombres: 'Carlos', apellidoPaterno: 'Ruiz', email: 'N/A', telefono: 'N/A', rol: 'Tecnico');

    _orden1 = OrdenServicio(
      id: 'OS-12564',
      empresaId: 'emp-1',
      folio: 'OS-12564',
      cliente: cliente1,
      direccion: Direccion(id: 'dir-1', calleYNumero: 'N/A', colonia: 'N/A', codigoPostal: 'N/A', municipio: 'N/A', estado: 'N/A', latitud: 0, longitud: 0),
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
      direccion: Direccion(id: 'dir-1', calleYNumero: 'N/A', colonia: 'N/A', codigoPostal: 'N/A', municipio: 'N/A', estado: 'N/A', latitud: 0, longitud: 0),
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
      direccion: Direccion(id: 'dir-2', calleYNumero: 'N/A', colonia: 'N/A', codigoPostal: 'N/A', municipio: 'N/A', estado: 'N/A', latitud: 0, longitud: 0),
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
      direccion: Direccion(id: 'dir-2', calleYNumero: 'N/A', colonia: 'N/A', codigoPostal: 'N/A', municipio: 'N/A', estado: 'N/A', latitud: 0, longitud: 0),
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
    _onDaySelected(_selectedDay, _focusedDay);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      final dayKey = DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);
      _selectedDayEvents = _eventsByDay[dayKey] ?? [];
    });
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
      } else if (_currentView == 'Día') {
        _selectedDay = _selectedDay.subtract(const Duration(days: 1));
        _focusedDay = _selectedDay;
      } else { // Mes
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
      }
      _onDaySelected(_selectedDay, _focusedDay);
    });
  }

  void _next() {
    setState(() {
      if (_currentView == 'Semana') {
        _currentDate = _currentDate.add(const Duration(days: 7));
        _focusedDay = _currentDate;
      } else if (_currentView == 'Día') {
        _selectedDay = _selectedDay.add(const Duration(days: 1));
        _focusedDay = _selectedDay;
      } else { // Mes
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
      }
      _onDaySelected(_selectedDay, _focusedDay);
    });
  }

  void _goToToday() {
    setState(() {
      _currentDate = DateTime.now();
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();
      _onDaySelected(_selectedDay, _focusedDay);
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
      ),
    );
  }

  void _cancelChanges() {
    setState(() {
      _pendingChanges.clear();
      _isEditMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Row(
        children: [
          const NotificationPanel(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppColors.outline),
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildCurrentView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case 'Día': return _buildDayView();
      case 'Semana': return _buildWeekView();
      case 'Mes': return _buildMonthView();
      default: return _buildWeekView();
    }
  }

  Widget _buildDayView() {
    return Column(
      children: [
        _buildViewHeader(),
        const Divider(height: 1),
        Expanded(child: _buildDayAgenda(showDate: false)),
      ],
    );
  }

  Widget _buildMonthView() {
    return Column(
      children: [
        _buildViewHeader(),
        Padding(
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
              todayDecoration: BoxDecoration(
                color: AppColors.primaryColor.withAlpha(128),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.accentColor,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
        ),
        const Divider(height: 24, indent: 16, endIndent: 16,),
        Expanded(child: _buildDayAgenda(showDate: true)),
      ],
    );
  }

  Widget _buildViewHeader() {
    final DateFormat dayMonthFormat = DateFormat('d MMM', 'es_ES');
    final weekStart = _startOfWeek;
    String headerText;

    switch (_currentView) {
      case 'Día':
        headerText = DateFormat('EEEE, d MMMM y', 'es_ES').format(_selectedDay);
        break;
      case 'Mes':
        headerText = DateFormat('MMMM y', 'es_ES').format(_focusedDay);
        break;
      default:
        headerText = "${dayMonthFormat.format(weekStart)} - ${dayMonthFormat.format(weekStart.add(const Duration(days: 6)))}";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: _previous),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: _next),
          const SizedBox(width: 16),
          OutlinedButton(onPressed: _goToToday, child: const Text("Hoy")),
          const SizedBox(width: 24),
          Text(headerText, style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          if (_currentView == 'Semana')
            if (_isEditMode)
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _cancelChanges,
                    icon: const Icon(Icons.cancel_outlined, color: AppColors.errorColor),
                    label: const Text('Cancelar', style: TextStyle(color: AppColors.errorColor)),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Guardar Cambios'),
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
          DropdownButton<String>(
            value: _currentView,
            items: <String>['Día', 'Semana', 'Mes'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? newValue) {
              if (_isEditMode) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guarde o cancele los cambios para cambiar de vista.')));
                return;
              }
              setState(() => _currentView = newValue!);
            },
            underline: const SizedBox(),
          ),
        ],
      ),
    );
  }

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
              child: Center(child: Text("No hay eventos para este día."))
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
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(border: Border(left: BorderSide(color: AppColors.outline.withOpacity(0.5)))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(days[index], style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 4),
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: isToday ? AppColors.primaryColor : Colors.transparent,
                          child: Text(
                            DateFormat('d').format(dayDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: isToday ? Colors.white : AppColors.textPrimaryColor,
                            ),
                          ),
                        ),
                      ],
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryColor),
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

    // 1. Añadir eventos originales que no han sido movidos
    for (var event in _eventsByDay[dayKey] ?? []) {
      if (!_pendingChanges.containsKey(event.id)) {
        eventsForDisplayMap[event.id] = event;
      }
    }

    // 2. Añadir cambios pendientes que pertenecen a este día
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
        return Container(
          key: _dayColumnKeys[dayIndexInWeek],
          height: (_endHour - _startHour) * _hourRowHeight,
          decoration: BoxDecoration(border: Border(left: BorderSide(color: AppColors.outline.withOpacity(0.5)))),
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
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.outline.withOpacity(0.5)))),
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