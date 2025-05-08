import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importar flutter_svg
import 'package:intl/intl.dart';
import '../models/agenda_event.dart';
import '../widgets/agenda_item_widget.dart';
import '../widgets/notification_panel_widget.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AgendaEvent> _events = [];
  DateTime _currentDate = DateTime.now();
  int _selectedWeekView = 0;

  final double _hourRowHeight = 60.0;
  final int _startHour = 8;
  final int _endHour = 20;

  @override
  void initState() {
    super.initState();
    _loadSampleEvents();
  }

  void _loadSampleEvents() {
    final today = DateTime.now().add(Duration(days: _selectedWeekView * 7)); // Ajustar para la semana seleccionada
    final mondayThisWeek = today.subtract(Duration(days: today.weekday - 1));

    setState(() {
      _events = [
        AgendaEvent(
            id: '1',
            title: 'Reunión equipo Alfa',
            startTime: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day, 9, 0),
            endTime: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day, 10, 0),
            technician: 'Ana Pérez',
            client: 'Interno',
            description: 'Planificación semanal del sprint.',
            // dayOfWeek: 1, // Eliminado
            color: AppColors.eventBlue),
        AgendaEvent(
            id: '2',
            title: 'Visita Cliente TechCorp',
            startTime: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day, 11, 0),
            endTime: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day, 12, 30),
            technician: 'Carlos Ruiz',
            client: 'TechCorp',
            description: 'Mantenimiento preventivo servidor principal.',
            // dayOfWeek: 1, // Eliminado
            color: AppColors.eventGreen),
        AgendaEvent(
            id: '3',
            title: 'Soporte Remoto Zeta',
            startTime: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day + 1, 14, 0), // Martes
            endTime: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day + 1, 15, 0),
            technician: 'Laura Gómez',
            client: 'Empresa Zeta',
            description: 'Resolución de incidencia #45B.',
            // dayOfWeek: 2, // Eliminado
            color: AppColors.eventOrange),
        AgendaEvent(
            id: '4',
            title: 'Instalación BetaMax',
            startTime: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day + 2, 10, 0), // Miércoles
            endTime: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day + 2, 13, 0),
            technician: 'Pedro Martín',
            client: 'Industrias BetaMax',
            description: 'Instalación y configuración de nuevo sistema.',
            // dayOfWeek: 3, // Eliminado
            color: AppColors.eventRed),
        AgendaEvent(
            id: '5',
            title: 'Capacitación Interna',
            startTime: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day + 3, 9, 30), // Jueves
            endTime: DateTime(mondayThisWeek.year, mondayThisWeek.month, mondayThisWeek.day + 3, 11, 0),
            technician: 'Varios',
            client: 'Interno',
            description: 'Nuevas funcionalidades ServiceFlow v2.',
            // dayOfWeek: 4, // Eliminado
            color: AppColors.eventBlue),
      ];
    });
  }

  void _navigateToOrderDetail(String orderId) {
    Navigator.of(context).pushNamed('/order_detail', arguments: orderId);
  }

  DateTime get _startOfWeek {
    final now = DateTime.now().add(Duration(days: _selectedWeekView * 7));
    return now.subtract(Duration(days: now.weekday - 1));
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
            child: _buildAgendaView(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    String userName = "Pedro Abdiel Villatoro";
    return AppBar(
      backgroundColor: AppColors.agendaHeaderBackground,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      elevation: 2.0,
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SvgPicture.asset( // Cambiado a SvgPicture.asset
              'assets/images/service_flow_logo.svg', // Ruta al SVG
              height: 30,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn), // Para que el SVG sea blanco
            ),
          ),
          const Text("ServiceFlow", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 20),
          _buildAppBarNavItem("Inicio", Icons.home_filled, true, () {}),
          _buildAppBarNavItem("Órdenes de servicio", Icons.list_alt, false, () {}),
          _buildAppBarNavItem("Seguimiento", Icons.location_on_outlined, false, () {}),
          _buildAppBarNavItem("Clientes", Icons.people_outline, false, () {}),
          _buildAppBarNavItem("Técnicos", Icons.construction_outlined, false, () {}),
          _buildAppBarNavItem("Usuarios", Icons.manage_accounts_outlined, false, () {}),
          _buildAppBarNavItem("Administración", Icons.admin_panel_settings_outlined, false, () {}),
        ],
      ),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              'Bienvenido, $userName',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          tooltip: "Ajustes",
          onPressed: () {},
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildAppBarNavItem(String title, IconData icon, bool isActive, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? AppColors.accentColor : Colors.white70, size: 20),
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

  Widget _buildAgendaView() {
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
                  IconButton(icon: const Icon(Icons.chevron_left), onPressed: _previousWeek, tooltip: "Semana anterior"),
                  IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextWeek, tooltip: "Semana siguiente"),
                  const SizedBox(width: 10),
                  OutlinedButton(onPressed: _goToToday, child: const Text("Hoy")),
                  const SizedBox(width: 20),
                  Text(
                    "${dayMonthFormat.format(weekStart)} - ${dayMonthFormat.format(weekStart.add(const Duration(days: 6)))}",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              DropdownButton<String>(
                value: 'Semana',
                items: <String>['Día', 'Semana', 'Mes']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {},
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
                          right: index == 6 ? BorderSide(color: Colors.grey[300]!) : BorderSide.none,
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(days[index], style: TextStyle(fontWeight: FontWeight.bold, color: isToday ? AppColors.primaryColor : AppColors.textPrimaryColor)),
                        Text(
                          DateFormat('d', 'es_ES').format(dayDate),
                          style: TextStyle(fontSize: 12, color: isToday ? AppColors.primaryColor : AppColors.textSecondaryColor),
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
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryColor),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayColumn(int dayIndexInWeek, DateTime dateForColumn) { // dayIndexInWeek es 0 para Lunes, ..., 6 para Domingo
    final eventsForDay = _events.where((event) {
      return DateUtils.isSameDay(event.startTime, dateForColumn);
    }).toList();

    return DragTarget<AgendaEvent>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        final event = details.data;
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        // El offset es relativo al DragTarget. Si el DragTarget es el _buildDayColumn,
        // localOffset.dy es la posición Y desde la parte superior de esta columna de día.
        final Offset localOffset = renderBox.globalToLocal(details.offset);

        // Calcula la nueva hora y minutos basándose en la posición Y y la altura de la fila horaria
        double hoursFromAgendaStart = localOffset.dy / _hourRowHeight;
        int newHour = (_startHour + hoursFromAgendaStart).floor();
        int newMinute = ((hoursFromAgendaStart - newHour.toDouble() + _startHour.toDouble()) * 60).round();

        // Ajustar minutos a incrementos (ej. 0, 15, 30, 45) si se desea, o dejarlos precisos.
        // Para simplicidad, aquí se redondean al más cercano.
        // newMinute = (newMinute / 15).round() * 15; // Ejemplo de ajuste a incrementos de 15 min

        newHour = newHour.clamp(_startHour, _endHour -1); // Asegura que la hora de inicio esté en rango
        // (si un evento dura 1h, no puede empezar en _endHour)
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
              endTime: newStartTime.add(duration), // Mantiene la duración original
              technician: oldEvent.technician,
              client: oldEvent.client,
              description: oldEvent.description,
              color: oldEvent.color,
            );
            _events.sort((a, b) => a.startTime.compareTo(b.startTime));
            print("Evento ${event.title} soltado en ${DateFormat('EEE d, HH:mm').format(newStartTime)}");
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
                        width: 100, // Podrías hacerlo más dinámico basado en el ancho de la columna
                        height: (event.duration.inMinutes / 60.0) * _hourRowHeight < 30 ? 30 : (event.duration.inMinutes / 60.0) * _hourRowHeight,
                        color: event.color.withAlpha(200),
                        padding: const EdgeInsets.all(4),
                        child: Text(event.title, style: const TextStyle(color: Colors.white, fontSize: 10), overflow: TextOverflow.ellipsis),
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