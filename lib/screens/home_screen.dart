import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';  //Importar flutter_svg
import 'package:intl/intl.dart';
import '../models/agenda_event.dart';
import '../widgets/agenda_item_widget.dart';
import '../widgets/notification_panel_widget.dart';
import '../theme/app_colors.dart';
import 'service_orders_screen.dart';
import 'clients_screen.dart';
import 'tecnicos_screen.dart';
import 'usuarios_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AgendaEvent> _events = [];
  DateTime _currentDate = DateTime.now();
  int _selectedWeekView = 0;
  String _currentView = 'Semana';
  DateTime? _selectedDay;

  final double _hourRowHeight = 60.0;
  final int _startHour = 8;
  final int _endHour = 20;

  @override
  void initState() {
    super.initState();
    _loadSampleEvents();
    _selectedDay = DateTime.now();
    initializeDateFormatting('es_ES', null);
  }

  Future<void> initializeDateFormatting(String locale, String? filePath) async {
    // Inicialización de formato de fecha
  }

  void _loadSampleEvents() {
    final today = DateTime.now().add(Duration(days: _selectedWeekView * 7));
    final mondayThisWeek = today.subtract(Duration(days: today.weekday - 1));

    setState(() {
      _events = [
        AgendaEvent(
            id: '1',
            title: 'Reunión equipo Alfa',
            startTime: DateTime(mondayThisWeek.year, mondayThisWeek.month,
                mondayThisWeek.day, 9, 0),
            endTime: DateTime(mondayThisWeek.year, mondayThisWeek.month,
                mondayThisWeek.day, 10, 0),
            technician: 'Ana Pérez',
            client: 'Interno',
            description: 'Planificación semanal del sprint.',
            color: AppColors.eventBlue),
        AgendaEvent(
            id: '2',
            title: 'Visita Cliente TechCorp',
            startTime: DateTime(mondayThisWeek.year, mondayThisWeek.month,
                mondayThisWeek.day, 11, 0),
            endTime: DateTime(mondayThisWeek.year, mondayThisWeek.month,
                mondayThisWeek.day, 12, 30),
            technician: 'Carlos Ruiz',
            client: 'TechCorp',
            description: 'Mantenimiento preventivo servidor principal.',
            color: AppColors.eventGreen),
        AgendaEvent(
            id: '3',
            title: 'Soporte Remoto Zeta',
            startTime: DateTime(mondayThisWeek.year, mondayThisWeek.month,
                mondayThisWeek.day + 1, 14, 0),
            endTime: DateTime(mondayThisWeek.year, mondayThisWeek.month,
                mondayThisWeek.day + 1, 15, 0),
            technician: 'Laura Gómez',
            client: 'Empresa Zeta',
            description: 'Resolución de incidencia #45B.',
            color: AppColors.eventOrange),
        AgendaEvent(
            id: '4',
            title: 'Instalación BetaMax',
            startTime: DateTime(mondayThisWeek.year, mondayThisWeek.month,
                mondayThisWeek.day + 2, 10, 0),
            endTime: DateTime(mondayThisWeek.year, mondayThisWeek.month,
                mondayThisWeek.day + 2, 13, 0),
            technician: 'Pedro Martín',
            client: 'Industrias BetaMax',
            description: 'Instalación y configuración de nuevo sistema.',
            color: AppColors.eventRed),
        AgendaEvent(
            id: '5',
            title: 'Capacitación Interna',
            startTime: DateTime(mondayThisWeek.year, mondayThisWeek.month,
                mondayThisWeek.day + 3, 9, 30),
            endTime: DateTime(mondayThisWeek.year, mondayThisWeek.month,
                mondayThisWeek.day + 3, 11, 0),
            technician: 'Varios',
            client: 'Interno',
            description: 'Nuevas funcionalidades ServiceFlow v2.',
            color: AppColors.eventBlue),
      ];
    });
  }

  void _navigateToOrderDetail(String orderId) {
    print("Navegar al detalle de la orden: $orderId");
  }

  DateTime get _startOfWeek {
    return _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
  }

  void _previousWeek() {
    setState(() {
      _selectedWeekView--;
      _currentDate = _currentDate.subtract(const Duration(days: 7));
      _loadSampleEvents();
    });
  }

  void _nextWeek() {
    setState(() {
      _selectedWeekView++;
      _currentDate = _currentDate.add(const Duration(days: 7));
      _loadSampleEvents();
    });
  }

  void _goToToday() {
    setState(() {
      _selectedWeekView = 0;
      _currentDate = DateTime.now();
      _selectedDay = DateTime.now();
      _loadSampleEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Row(
        children: [
          const NotificationPanel(),
          Expanded(
            child: _buildCurrentView(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case 'Día':
        return _buildDayView();
      case 'Semana':
        return _buildWeekView();
      case 'Mes':
        return _buildMonthView();
      default:
        return _buildWeekView();
    }
  }

  Widget _buildDayView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _selectedDay = _selectedDay?.subtract(Duration(days: 1)) ??
                            DateTime.now().subtract(Duration(days: 1));
                      });
                    },
                    tooltip: "Día anterior",
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _selectedDay = _selectedDay?.add(Duration(days: 1)) ??
                            DateTime.now().add(Duration(days: 1));
                      });
                    },
                    tooltip: "Día siguiente",
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: _goToToday,
                    child: const Text("Hoy"),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    DateFormat('EEEE, d MMMM y', 'es_ES').format(_selectedDay ?? DateTime.now()),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              // Dropdown para cambiar vista en pantalla de día
              DropdownButton<String>(
                value: _currentView,
                items: <String>['Día', 'Semana', 'Mes']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _currentView = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildDayAgenda(_selectedDay ?? DateTime.now()),
        ),
      ],
    );
  }

  Widget _buildDayAgenda(DateTime day) {
    final eventsForDay = _events.where((event) {
      return DateUtils.isSameDay(event.startTime, day);
    }).toList();

    return ListView.builder(
      itemCount: _endHour - _startHour + 1,
      itemBuilder: (context, index) {
        final hour = _startHour + index;
        final hourEvents = eventsForDay.where((event) {
          return event.startTime.hour == hour;
        }).toList();

        return Container(
          height: _hourRowHeight,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                padding: EdgeInsets.all(8),
                child: Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: hourEvents.isEmpty
                    ? Container()
                    : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: hourEvents.length,
                  itemBuilder: (context, eventIndex) {
                    final event = hourEvents[eventIndex];
                    return Container(
                      width: 200,
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: event.color.withOpacity(0.2),
                        border: Border.all(color: event.color),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: event.color,
                            ),
                          ),
                          Text(
                            '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    String userName = "Pedro Abdiel Villatoro";
    return AppBar(
      backgroundColor: AppColors.agendaHeaderBackground,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      elevation: 2.0,
      title: Container(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SvgPicture.asset(
                    'assets/images/service_flow_logo.svg',
                    height: 30,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
                const Text("ServiceFlow",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAppBarNavItem("Inicio", Icons.home_filled, true, () {}),
                    _buildAppBarNavItem("Órdenes", Icons.list_alt, false, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceOrdersScreen()));
                    }),
                    _buildAppBarNavItem("Seguimiento", Icons.location_on_outlined, false, () {}),
                    _buildAppBarNavItem("Clientes", Icons.people_outline, false, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ClientsScreen()));
                    }),
                    _buildAppBarNavItem("Técnicos", Icons.construction_outlined, false, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TechniciansScreen()));
                    }),
                    _buildAppBarNavItem("Usuarios", Icons.manage_accounts_outlined, false, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const userScreen()));
                    }),
                    _buildAppBarNavItem("Admin", Icons.admin_panel_settings_outlined, false, () {}),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 100),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 15),
          child: Center(
            child: Text(
              'Bienvenido, $userName',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 15),
          child: IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
            tooltip: "Ajustes",
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarNavItem(
      String title, IconData icon, bool isActive, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isActive ? AppColors.accentColor : Colors.white70,
                size: 20),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: isActive ? AppColors.accentColor : Colors.white70,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekView() {
    final days = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];
    final weekStart = _startOfWeek;
    final DateFormat dayMonthFormat = DateFormat('d MMM', 'es_ES');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _previousWeek,
                      tooltip: "Semana anterior"),
                  IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _nextWeek,
                      tooltip: "Semana siguiente"),
                  const SizedBox(width: 10),
                  OutlinedButton(
                      onPressed: _goToToday, child: const Text("Hoy")),
                  const SizedBox(width: 20),
                  Text(
                    "${dayMonthFormat.format(weekStart)} - ${dayMonthFormat.format(weekStart.add(const Duration(days: 6)))}",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: _currentView,
                items: <String>['Día', 'Semana', 'Mes']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _currentView = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
        Container(
          height: 50,
          color: Colors.grey[200],
          child: Row(
            children: [
              const SizedBox(width: 60),
              ...List.generate(7, (index) {
                final dayDate = weekStart.add(Duration(days: index));
                bool isToday = DateUtils.isSameDay(DateTime.now(), dayDate);
                return Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.grey[300]!),
                          right: index == 6
                              ? BorderSide(color: Colors.grey[300]!)
                              : BorderSide.none,
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(days[index],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isToday
                                    ? AppColors.primaryColor
                                    : AppColors.textPrimaryColor)),
                        Text(
                          DateFormat('d', 'es_ES').format(dayDate),
                          style: TextStyle(
                              fontSize: 12,
                              color: isToday
                                  ? AppColors.primaryColor
                                  : AppColors.textSecondaryColor),
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

  // VISTA MENSUAL MANUAL (sin table_calendar)
  Widget _buildMonthView() {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    // Calcular número de semanas en el mes
    final totalCells = daysInMonth + firstWeekday - 1;
    final weeksInMonth = (totalCells / 7).ceil();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
                      });
                    },
                    tooltip: "Mes anterior",
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
                      });
                    },
                    tooltip: "Mes siguiente",
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: _goToToday,
                    child: const Text("Hoy"),
                  ),
                ],
              ),
              Text(
                DateFormat('MMMM y', 'es_ES').format(_currentDate),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              DropdownButton<String>(
                value: _currentView,
                items: <String>['Día', 'Semana', 'Mes']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _currentView = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
        // Encabezado de días de la semana
        Container(
          height: 40,
          color: Colors.grey[200],
          child: Row(
            children: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']
                .map((day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
              ),
            ))
                .toList(),
          ),
        ),
        // Calendario
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemCount: weeksInMonth * 7,
            itemBuilder: (context, index) {
              final dayIndex = index - firstWeekday + 1;
              final isCurrentMonth = dayIndex > 0 && dayIndex <= daysInMonth;
              final day = isCurrentMonth
                  ? DateTime(_currentDate.year, _currentDate.month, dayIndex)
                  : null;

              final isToday = day != null && DateUtils.isSameDay(DateTime.now(), day);
              final hasEvents = day != null && _events.any((event) => DateUtils.isSameDay(event.startTime, day));
              final isSelected = day != null && DateUtils.isSameDay(_selectedDay, day);

              return GestureDetector(
                onTap: () {
                  if (day != null) {
                    setState(() {
                      _selectedDay = day;
                    });
                  }
                },
                child: Container(
                  margin: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor.withOpacity(0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: isToday ? AppColors.primaryColor : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isCurrentMonth ? dayIndex.toString() : '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isToday ? AppColors.primaryColor : AppColors.textPrimaryColor,
                        ),
                      ),
                      if (hasEvents)
                        Container(
                          width: 6,
                          height: 6,
                          margin: EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Lista de eventos del día seleccionado
        if (_selectedDay != null) ...[
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Eventos del ${DateFormat('EEEE, d MMMM', 'es_ES').format(_selectedDay!)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _buildEventList(_selectedDay!),
        ],
      ],
    );
  }

  Widget _buildEventList(DateTime day) {
    final eventsForDay = _events.where((event) {
      return DateUtils.isSameDay(event.startTime, day);
    }).toList();

    if (eventsForDay.isEmpty) {
      return Container(
        height: 100,
        child: Center(
          child: Text('No hay eventos para este día'),
        ),
      );
    }

    return Container(
      height: 150,
      child: ListView.builder(
        itemCount: eventsForDay.length,
        itemBuilder: (context, index) {
          final event = eventsForDay[index];
          return ListTile(
            leading: Container(
              width: 10,
              color: event.color,
            ),
            title: Text(event.title),
            subtitle: Text(
              '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
            ),
            onTap: () => _navigateToOrderDetail(event.id),
          );
        },
      ),
    );
  }

  Widget _buildTimeColumn() {
    return SizedBox(
      width: 60,
      child: Column(
        children: List.generate(_endHour - _startHour + 1, (index) {
          final hour = _startHour + index;
          return Container(
            height: _hourRowHeight,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                  right: BorderSide(color: Colors.grey[300]!),
                )),
            child: Text(
              "${NumberFormat("00").format(hour)}:00",
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondaryColor),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayColumn(int dayIndexInWeek, DateTime dateForColumn) {
    final eventsForDay = _events.where((event) {
      return DateUtils.isSameDay(event.startTime, dateForColumn);
    }).toList();

    return DragTarget<AgendaEvent>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        final event = details.data;
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;

        if (renderBox == null) return;

        final Offset localOffset = renderBox.globalToLocal(details.offset);
        double hoursFromAgendaStart = localOffset.dy / _hourRowHeight;
        int newHour = (_startHour + hoursFromAgendaStart).floor();
        int newMinute = ((hoursFromAgendaStart - (newHour - _startHour).toDouble()) * 60).round();

        newHour = newHour.clamp(_startHour, _endHour -1 );
        newMinute = newMinute.clamp(0, 59);

        DateTime newStartTime = DateTime(
            dateForColumn.year, dateForColumn.month, dateForColumn.day, newHour, newMinute);

        setState(() {
          final eventIndex = _events.indexWhere((e) => e.id == event.id);
          if (eventIndex != -1) {
            final oldEvent = _events[eventIndex];
            Duration duration = oldEvent.duration;

            _events[eventIndex] = AgendaEvent(
              id: oldEvent.id,
              title: oldEvent.title,
              startTime: newStartTime,
              endTime: newStartTime.add(duration),
              technician: oldEvent.technician,
              client: oldEvent.client,
              description: oldEvent.description,
              color: oldEvent.color,
            );
            _events.sort((a, b) => a.startTime.compareTo(b.startTime));
            print("Evento ${event.title} soltado en Día: ${DateFormat('EEE d', 'es_ES').format(dateForColumn)}, Hora: ${DateFormat('HH:mm').format(newStartTime)}");
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: (_endHour - _startHour + 1) * _hourRowHeight,
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Stack(
            children: [
              ...List.generate(_endHour - _startHour + 1, (index) {
                return Positioned(
                  top: index * _hourRowHeight,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: _hourRowHeight,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                    ),
                  ),
                );
              }),
              ...eventsForDay.map((event) {
                return Draggable<AgendaEvent>(
                  data: event,
                  feedback: Material(
                    elevation: 4.0,
                    child: Opacity(
                      opacity: 0.8,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 8,
                        height: (event.duration.inMinutes / 60.0) * _hourRowHeight < 30
                            ? 30
                            : (event.duration.inMinutes / 60.0) * _hourRowHeight,
                        color: event.color.withAlpha(200),
                        padding: const EdgeInsets.all(4),
                        child: Text(event.title,
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1),
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: AgendaItemWidget(
                      event: event,
                      onTap: () => _navigateToOrderDetail(event.id),
                      hourRowHeight: _hourRowHeight,
                      startHourOfDay: _startHour,
                    ),
                  ),
                  child: AgendaItemWidget(
                    event: event,
                    onTap: () => _navigateToOrderDetail(event.id),
                    hourRowHeight: _hourRowHeight,
                    startHourOfDay: _startHour,
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}