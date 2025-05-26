import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importar flutter_svg
import 'package:intl/intl.dart';
import '../models/agenda_event.dart';
import '../widgets/agenda_item_widget.dart';
import '../widgets/notification_panel_widget.dart';
import '../theme/app_colors.dart';
import 'service_orders_screen.dart';
import 'clients_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AgendaEvent> _events = [];
  DateTime _currentDate = DateTime.now();
  int _selectedWeekView = 0; // 0 para la semana actual, -1 para la anterior, 1 para la siguiente, etc.

  final double _hourRowHeight = 60.0;
  final int _startHour = 8; // Hora de inicio de la agenda (8 AM)
  final int _endHour = 20; // Hora de fin de la agenda (8 PM)

  @override
  void initState() {
    super.initState();
    _loadSampleEvents();
    // Inicializar Localización Española para intl
    initializeDateFormatting('es_ES', null);
  }

  // Necesario para que DateFormat funcione con localización.
  // Asegúrate de tener la dependencia intl y flutter_localizations en tu pubspec.yaml
  // y configurar la localización en tu MaterialApp.
  Future<void> initializeDateFormatting(
      String locale, String? filePath) async {
    // Esta función puede variar dependiendo de cómo cargues los datos de localización.
    // Para este ejemplo, asumimos que ya está configurado a nivel de MaterialApp.
    // Si usas `Intl.defaultLocale = 'es_ES';` directamente, a veces puede no ser suficiente
    // sin la inicialización completa.
  }

  void _loadSampleEvents() {
    // Ajustar la fecha base para cargar eventos según la semana seleccionada
    final today = DateTime.now().add(Duration(days: _selectedWeekView * 7));
    // Calcular el lunes de la semana correspondiente a 'today'
    final mondayThisWeek = today.subtract(Duration(days: today.weekday - 1));

    setState(() {
      _events = [
        AgendaEvent(
            id: '1',
            title: 'Reunión equipo Alfa',
            startTime: DateTime(mondayThisWeek.year, mondayThisWeek.month,
                mondayThisWeek.day, 9, 0), // Lunes 9:00 AM
            endTime: DateTime(mondayThisWeek.year, mondayThisWeek.month,
                mondayThisWeek.day, 10, 0), // Lunes 10:00 AM
            technician: 'Ana Pérez',
            client: 'Interno',
            description: 'Planificación semanal del sprint.',
            color: AppColors.eventBlue),
        AgendaEvent(
            id: '2',
            title: 'Visita Cliente TechCorp',
            startTime: DateTime(mondayThisWeek.year, mondayThisWeek.month,
                mondayThisWeek.day, 11, 0), // Lunes 11:00 AM
            endTime: DateTime(mondayThisWeek.year, mondayThisWeek.month,
                mondayThisWeek.day, 12, 30), // Lunes 12:30 PM
            technician: 'Carlos Ruiz',
            client: 'TechCorp',
            description: 'Mantenimiento preventivo servidor principal.',
            color: AppColors.eventGreen),
        AgendaEvent(
            id: '3',
            title: 'Soporte Remoto Zeta',
            startTime: DateTime(
                mondayThisWeek.year,
                mondayThisWeek.month,
                mondayThisWeek.day + 1,
                14,
                0), // Martes 2:00 PM
            endTime: DateTime(
                mondayThisWeek.year,
                mondayThisWeek.month,
                mondayThisWeek.day + 1,
                15,
                0), // Martes 3:00 PM
            technician: 'Laura Gómez',
            client: 'Empresa Zeta',
            description: 'Resolución de incidencia #45B.',
            color: AppColors.eventOrange),
        AgendaEvent(
            id: '4',
            title: 'Instalación BetaMax',
            startTime: DateTime(
                mondayThisWeek.year,
                mondayThisWeek.month,
                mondayThisWeek.day + 2,
                10,
                0), // Miércoles 10:00 AM
            endTime: DateTime(
                mondayThisWeek.year,
                mondayThisWeek.month,
                mondayThisWeek.day + 2,
                13,
                0), // Miércoles 1:00 PM
            technician: 'Pedro Martín',
            client: 'Industrias BetaMax',
            description: 'Instalación y configuración de nuevo sistema.',
            color: AppColors.eventRed),
        AgendaEvent(
            id: '5',
            title: 'Capacitación Interna',
            startTime: DateTime(
                mondayThisWeek.year,
                mondayThisWeek.month,
                mondayThisWeek.day + 3,
                9,
                30), // Jueves 9:30 AM
            endTime: DateTime(
                mondayThisWeek.year,
                mondayThisWeek.month,
                mondayThisWeek.day + 3,
                11,
                0), // Jueves 11:00 AM
            technician: 'Varios',
            client: 'Interno',
            description: 'Nuevas funcionalidades ServiceFlow v2.',
            color: AppColors.eventBlue),
      ];
    });
  }

  void _navigateToOrderDetail(String orderId) {
    // Esta función es para navegar al detalle de una orden específica desde la agenda.
    // Si tienes una pantalla de detalle de orden, puedes implementarla aquí.
    // Ejemplo: Navigator.of(context).pushNamed('/order_detail', arguments: orderId);
    print("Navegar al detalle de la orden: $orderId");
    // Por ahora, si no tienes la ruta '/order_detail', esto podría dar error.
    // Asegúrate de que la ruta exista o cambia la navegación.
  }

  DateTime get _startOfWeek {
    // Calcula el inicio de la semana (Lunes) basado en _currentDate
    // _currentDate se actualiza con _previousWeek, _nextWeek, _goToToday
    return _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
  }

  void _previousWeek() {
    setState(() {
      _selectedWeekView--; // Actualiza el contador de vista de semana
      _currentDate = _currentDate.subtract(
          const Duration(days: 7)); // Retrocede _currentDate una semana
      _loadSampleEvents(); // Recarga los eventos para la nueva semana
    });
  }

  void _nextWeek() {
    setState(() {
      _selectedWeekView++; // Actualiza el contador de vista de semana
      _currentDate = _currentDate
          .add(const Duration(days: 7)); // Avanza _currentDate una semana
      _loadSampleEvents(); // Recarga los eventos para la nueva semana
    });
  }

  void _goToToday() {
    setState(() {
      _selectedWeekView = 0; // Resetea el contador de vista de semana
      _currentDate = DateTime.now(); // Establece _currentDate a hoy
      _loadSampleEvents(); // Recarga los eventos para la semana actual
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
    String userName = "Pedro Abdiel Villatoro"; // Ejemplo de nombre de usuario
    return AppBar(
      backgroundColor: AppColors.agendaHeaderBackground,
      automaticallyImplyLeading: false, // No muestra el botón de retroceso automáticamente
      titleSpacing: 0,
      elevation: 2.0, // Sombra ligera debajo del AppBar
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SvgPicture.asset(
              'assets/images/service_flow_logo.svg', // Ruta a tu logo SVG
              height: 30,
              colorFilter:
              const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
          const Text("ServiceFlow",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 20),
          _buildAppBarNavItem("Inicio", Icons.home_filled, true, () {
            // Acción para Inicio (actualmente no hace nada si ya estás aquí)
          }),
          _buildAppBarNavItem(
              "Órdenes de servicio", Icons.list_alt, false, () {
            // Navegar a la pantalla de órdenes de servicio
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ServiceOrdersScreen()),
            );
          }),
          _buildAppBarNavItem("Seguimiento", Icons.location_on_outlined, false,
                  () {
                // Acción para Seguimiento
              }),
          _buildAppBarNavItem("Clientes", Icons.people_outline, false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ClientsScreen()),
            );
          }),
          _buildAppBarNavItem("Técnicos", Icons.construction_outlined, false,
                  () {
                // Acción para Técnicos
              }),
          _buildAppBarNavItem("Usuarios", Icons.manage_accounts_outlined, false,
                  () {
                // Acción para Usuarios
              }),
          _buildAppBarNavItem(
              "Administración", Icons.admin_panel_settings_outlined, false, () {
            // Acción para Administración
          }),
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
          onPressed: () {
            // Acción para Ajustes
          },
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildAppBarNavItem(
      String title, IconData icon, bool isActive, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4), // Para efecto visual en hover/tap
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

  Widget _buildAgendaView() {
    final days = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];
    final weekStart = _startOfWeek; // Lunes de la semana actual/seleccionada
    // Formato para mostrar día y mes (ej. "20 May")
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
                    // Muestra el rango de la semana, ej. "20 May - 26 May"
                    "${dayMonthFormat.format(weekStart)} - ${dayMonthFormat.format(weekStart.add(const Duration(days: 6)))}",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                ],
              ),
              // Dropdown para cambiar la vista (Día, Semana, Mes) - Funcionalidad no implementada
              DropdownButton<String>(
                value: 'Semana', // Valor actual (solo visual)
                items: <String>['Día', 'Semana', 'Mes']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  // Aquí implementarías la lógica para cambiar la vista
                },
              ),
            ],
          ),
        ),
        // Cabecera de los días de la semana
        Container(
          height: 50, // Altura de la cabecera de días
          color: Colors.grey[200],
          child: Row(
            children: [
              const SizedBox(width: 60), // Espacio para la columna de horas
              ...List.generate(7, (index) {
                final dayDate = weekStart.add(Duration(days: index));
                // Verifica si el día actual es hoy para resaltarlo
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
                          DateFormat('d', 'es_ES').format(dayDate), // Solo el número del día
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
        // Cuerpo de la agenda (horas y eventos)
        Expanded(
          child: SingleChildScrollView( // Permite scroll vertical si el contenido excede
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeColumn(), // Columna de las horas
                // Genera una columna para cada día de la semana
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
    // Construye la columna lateral que muestra las horas del día
    return SizedBox(
      width: 60, // Ancho de la columna de horas
      child: Column(
        children: List.generate(_endHour - _startHour + 1, (index) {
          final hour = _startHour + index;
          return Container(
            height: _hourRowHeight, // Altura de cada celda de hora
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!), // Línea divisoria horizontal
                  right: BorderSide(color: Colors.grey[300]!), // Línea divisoria vertical
                )),
            child: Text(
              "${NumberFormat("00").format(hour)}:00", // Formato "08:00"
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondaryColor),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayColumn(int dayIndexInWeek, DateTime dateForColumn) {
    // Construye una columna para un día específico, mostrando sus eventos
    // dayIndexInWeek: 0 para Lunes, ..., 6 para Domingo
    // dateForColumn: La fecha exacta para esta columna

    // Filtra los eventos que corresponden a `dateForColumn`
    final eventsForDay = _events.where((event) {
      return DateUtils.isSameDay(event.startTime, dateForColumn);
    }).toList();

    return DragTarget<AgendaEvent>(
      // Se activa cuando un Draggable está sobre este target y está a punto de ser soltado
      onWillAcceptWithDetails: (details) => true, // Siempre acepta el evento por ahora
      // Se activa cuando un Draggable es soltado sobre este target
      onAcceptWithDetails: (details) {
        final event = details.data; // El AgendaEvent que se está arrastrando
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;

        if (renderBox == null) return;

        // Convierte la posición global del puntero (donde se soltó) a una posición local
        // dentro de este widget _buildDayColumn.
        final Offset localOffset = renderBox.globalToLocal(details.offset);

        // Calcula la nueva hora y minutos basándose en la posición Y donde se soltó el evento.
        // localOffset.dy es la distancia vertical desde la parte superior de la columna del día.
        double hoursFromAgendaStart = localOffset.dy / _hourRowHeight;
        int newHour = (_startHour + hoursFromAgendaStart).floor();
        int newMinute = ((hoursFromAgendaStart - (newHour - _startHour).toDouble()) * 60).round();


        // Ajustar minutos a incrementos (ej. 0, 15, 30, 45)
        // newMinute = (newMinute / 15).round() * 15; // Redondea al múltiplo de 15 más cercano

        // Asegura que la nueva hora de inicio esté dentro de los límites de la agenda.
        // Si un evento dura 1 hora, no puede empezar en la _endHour.
        newHour = newHour.clamp(_startHour, _endHour -1 );
        newMinute = newMinute.clamp(0, 59);


        DateTime newStartTime = DateTime(
            dateForColumn.year, dateForColumn.month, dateForColumn.day, newHour, newMinute);

        setState(() {
          final eventIndex = _events.indexWhere((e) => e.id == event.id);
          if (eventIndex != -1) {
            final oldEvent = _events[eventIndex];
            Duration duration = oldEvent.duration; // Conserva la duración original del evento

            // Actualiza el evento en la lista _events con la nueva hora de inicio
            // y la nueva fecha (si se movió a otro día).
            _events[eventIndex] = AgendaEvent(
              id: oldEvent.id,
              title: oldEvent.title,
              startTime: newStartTime,
              endTime: newStartTime.add(duration), // La hora de fin se recalcula
              technician: oldEvent.technician,
              client: oldEvent.client,
              description: oldEvent.description,
              color: oldEvent.color,
            );
            // Opcional: Reordenar la lista si es necesario, aunque el pintado se basa en startTime.
            _events.sort((a, b) => a.startTime.compareTo(b.startTime));
            print("Evento ${event.title} soltado en Día: ${DateFormat('EEE d', 'es_ES').format(dateForColumn)}, Hora: ${DateFormat('HH:mm').format(newStartTime)}");
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        // El 'builder' define cómo se ve el DragTarget (la columna del día)
        return Container(
          // La altura total de la columna del día debe coincidir con la altura total de la columna de horas
          height: (_endHour - _startHour + 1) * _hourRowHeight,
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: Colors.grey[300]!)), // Línea divisoria a la izquierda
          ),
          child: Stack( // Stack permite superponer los eventos sobre las líneas horarias
            children: [
              // Dibuja las líneas horizontales para cada hora dentro de la columna del día
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
              // Mapea cada evento del día a un widget Draggable<AgendaEvent>
              ...eventsForDay.map((event) {
                return Draggable<AgendaEvent>(
                  data: event, // Los datos que se pasarán cuando se arrastre
                  // 'feedback' es el widget que se muestra mientras se arrastra
                  feedback: Material(
                    elevation: 4.0,
                    child: Opacity(
                      opacity: 0.8, // Un poco transparente durante el arrastre
                      child: Container(
                        // El ancho podría ser dinámico si las columnas de día varían de tamaño
                        width: MediaQuery.of(context).size.width / 8, // Aproximación del ancho
                        height: (event.duration.inMinutes / 60.0) * _hourRowHeight < 30
                            ? 30 // Altura mínima para eventos cortos
                            : (event.duration.inMinutes / 60.0) * _hourRowHeight,
                        color: event.color.withAlpha(200),
                        padding: const EdgeInsets.all(4),
                        child: Text(event.title,
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                            overflow: TextOverflow.ellipsis, // Corta el texto si es muy largo
                            maxLines: 1),
                      ),
                    ),
                  ),
                  // 'childWhenDragging' es cómo se ve el widget original mientras se está arrastrando su 'feedback'
                  childWhenDragging: Opacity(
                    opacity: 0.3, // Se ve más tenue
                    child: AgendaItemWidget(
                      event: event,
                      onTap: () => _navigateToOrderDetail(event.id),
                      hourRowHeight: _hourRowHeight,
                      startHourOfDay: _startHour,
                    ),
                  ),
                  // 'child' es el widget que se muestra normalmente
                  child: AgendaItemWidget(
                    event: event,
                    onTap: () => _navigateToOrderDetail(event.id), // Acción al tocar el evento
                    hourRowHeight: _hourRowHeight,
                    startHourOfDay: _startHour, // Necesario para calcular la posición del AgendaItem
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