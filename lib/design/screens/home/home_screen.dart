// lib/design/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:serviceflow/data/models/agenda_event.dart';
import 'package:serviceflow/design/widgets/agenda/agenda_item_widget.dart';
import 'package:serviceflow/design/widgets/notification/notification_panel_widget.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:serviceflow/design/widgets/agenda/event_layout_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AgendaEvent> _events = [];
  DateTime _currentDate = DateTime.now();
  String _currentView = 'Semana';
  DateTime? _selectedDay;

  final double _hourRowHeight = 90.0;
  final int _startHour = 7;
  final int _endHour = 21;

  final EventLayoutHelper _layoutHelper = EventLayoutHelper();
  final List<GlobalKey> _dayColumnKeys = List.generate(7, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    // Esta función ahora será reconocida gracias a la importación correcta
    initializeDateFormatting('es_ES', null);
    _selectedDay = DateTime.now();
    _loadSampleEvents();
  }

  void _loadSampleEvents() {
    final today = _currentDate;
    final mondayThisWeek = today.subtract(Duration(days: today.weekday - 1));

    setState(() {
      _events = [
        AgendaEvent(
            id: 'OS-12564',
            title: 'Reunión equipo Alfa',
            startTime: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day, 9, 0),
            endTime: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day, 10, 0),
            technician: 'Ana Pérez',
            client: 'Interno',
            description: 'Planificación semanal del sprint.',
            color: AppColors.eventBlue),
        AgendaEvent(
            id: 'OS-12565',
            title: 'Visita Cliente TechCorp',
            startTime: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day, 11, 0),
            endTime: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day, 12, 30),
            technician: 'Carlos Ruiz',
            client: 'TechCorp',
            description: 'Mantenimiento preventivo del servidor principal.',
            color: AppColors.eventGreen),
        AgendaEvent(
            id: 'OS-12566',
            title: 'Soporte Remoto Zeta',
            startTime: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day, 11, 30),
            endTime: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day, 13, 0),
            technician: 'Ana Pérez',
            client: 'Zeta Solutions',
            description: 'Soporte remoto para el sistema de facturación.',
            color: AppColors.eventOrange),
      ];
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
      } else if (_currentView == 'Día') {
        _selectedDay = _selectedDay?.subtract(const Duration(days: 1));
      } else {
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      }
      _loadSampleEvents();
    });
  }

  void _next() {
    setState(() {
      if (_currentView == 'Semana') {
        _currentDate = _currentDate.add(const Duration(days: 7));
      } else if (_currentView == 'Día') {
        _selectedDay = _selectedDay?.add(const Duration(days: 1));
      } else {
        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      }
      _loadSampleEvents();
    });
  }

  void _goToToday() {
    setState(() {
      _currentDate = DateTime.now();
      _selectedDay = DateTime.now();
      _loadSampleEvents();
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
        Expanded(child: _buildDayAgenda(_selectedDay ?? DateTime.now())),
      ],
    );
  }

  Widget _buildViewHeader() {
    final DateFormat dayMonthFormat = DateFormat('d MMM', 'es_ES');
    final weekStart = _startOfWeek;
    String headerText;

    switch (_currentView) {
      case 'Día':
        headerText = DateFormat('EEEE, d MMMM y', 'es_ES').format(_selectedDay ?? DateTime.now());
        break;
      case 'Mes':
        headerText = DateFormat('MMMM y', 'es_ES').format(_currentDate);
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
          DropdownButton<String>(
            value: _currentView,
            items: <String>['Día', 'Semana', 'Mes'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? newValue) => setState(() => _currentView = newValue!),
            underline: const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayAgenda(DateTime day) {
    return const Center(child: Text("Vista de Día no implementada"));
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

  Widget _buildMonthView() {
    return const Center(child: Text("Vista de Mes no implementada"));
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
    final eventsForDay = _events.where((e) => DateUtils.isSameDay(e.startTime, dateForColumn)).toList();
    final eventLayoutParams = _layoutHelper.calculateLayout(eventsForDay);

    return DragTarget<AgendaEvent>(
      onWillAccept: (data) => true,
      onAcceptWithDetails: (details) {
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
          final event = details.data;
          final duration = event.duration;
          final eventIndex = _events.indexWhere((e) => e.id == event.id);
          if (eventIndex != -1) {
            _events[eventIndex].startTime = DateTime(
              dateForColumn.year,
              dateForColumn.month,
              dateForColumn.day,
              newHour,
              newMinute,
            );
            _events[eventIndex].endTime = _events[eventIndex].startTime.add(duration);
          }
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

                    return Positioned(
                      top: topPosition,
                      left: leftPosition,
                      height: itemHeight,
                      width: itemWidth,
                      child: Draggable<AgendaEvent>(
                        data: event,
                        feedback: SizedBox(
                          width: itemWidth,
                          height: itemHeight,
                          child: Material(
                            elevation: 4.0,
                            child: AgendaItemWidget(event: event, onTap: () {}, hourRowHeight: _hourRowHeight, startHourOfDay: _startHour),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.4,
                          child: AgendaItemWidget(
                            event: event,
                            onTap: () => _navigateToOrderDetail(event),
                            hourRowHeight: _hourRowHeight,
                            startHourOfDay: _startHour,
                          ),
                        ),
                        child: AgendaItemWidget(
                          event: event,
                          onTap: () => _navigateToOrderDetail(event),
                          hourRowHeight: _hourRowHeight,
                          startHourOfDay: _startHour,
                        ),
                      ),
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