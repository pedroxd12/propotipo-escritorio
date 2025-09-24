// lib/design/widgets/home/mini_calendar_widget.dart
import 'package:flutter/material.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:serviceflow/data/models/agenda_event.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class MiniCalendarWidget extends StatelessWidget {
  final VoidCallback onTap;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Map<DateTime, List<AgendaEvent>> eventsByDay;

  const MiniCalendarWidget({
    super.key,
    required this.onTap,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    required this.eventsByDay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.outline),
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calcular espacios fijos
            const headerHeight = 60.0; // Espacio para el título y icono
            const footerHeight = 40.0; // Espacio para el texto inferior
            const paddingTotal = 32.0; // Padding total vertical (16*2)
            const spacingTotal = 24.0; // SizedBox spacings

            // Calcular altura disponible para el calendario
            final fixedElements = headerHeight + footerHeight + paddingTotal + spacingTotal;
            final availableHeight = constraints.maxHeight - fixedElements;

            // Establecer límites mínimos y máximos para el calendario
            final calendarHeight = availableHeight.clamp(120.0, 300.0).toDouble();

            // Ajustar tamaños de fuente según el espacio disponible
            final isCompact = calendarHeight < 180;
            final headerFontSize = isCompact ? 8.0 : 10.0;
            final cellFontSize = isCompact ? 10.0 : 12.0;
            final daysFontSize = isCompact ? 8.0 : 9.0;
            final markerSize = isCompact ? 2.0 : 3.0;
            final cellMargin = isCompact ? 0.5 : 1.0;
            final headerPadding = isCompact ? 2.0 : 4.0;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header fijo
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, color: AppColors.primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        'Calendario',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Calendario con altura dinámica
                  SizedBox(
                    height: calendarHeight,
                    child: ClipRect( // Asegurar que no se salga del contenedor
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(), // Deshabilitar scroll manual
                        child: AbsorbPointer(
                          child: TableCalendar<AgendaEvent>(
                            locale: 'es_ES',
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: focusedDay,
                            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                            onDaySelected: onDaySelected,
                            onPageChanged: (focusedDay) {},
                            eventLoader: (day) {
                              final dayKey = DateTime.utc(day.year, day.month, day.day);
                              return eventsByDay[dayKey] ?? [];
                            },
                            calendarFormat: CalendarFormat.month,
                            availableCalendarFormats: const {
                              CalendarFormat.month: 'Month',
                            },
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              headerPadding: EdgeInsets.symmetric(vertical: headerPadding),
                              titleTextStyle: TextStyle(
                                fontSize: cellFontSize + 2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            calendarStyle: CalendarStyle(
                              defaultTextStyle: TextStyle(fontSize: cellFontSize),
                              weekendTextStyle: TextStyle(fontSize: cellFontSize),
                              selectedTextStyle: TextStyle(fontSize: cellFontSize, color: Colors.white),
                              todayTextStyle: TextStyle(fontSize: cellFontSize, color: Colors.white),
                              markerSize: markerSize,
                              cellMargin: EdgeInsets.all(cellMargin),
                              selectedDecoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              markersMaxCount: isCompact ? 1 : 3, // Limitar marcadores si es compacto
                            ),
                            daysOfWeekStyle: DaysOfWeekStyle(
                              weekdayStyle: TextStyle(fontSize: daysFontSize),
                              weekendStyle: TextStyle(fontSize: daysFontSize),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  // Footer fijo
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Toque para regresar al mapa',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryColor,
                        fontSize: isCompact ? 9.0 : 11.0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ALTERNATIVA 2: Si necesitas que sea más flexible, usa esta versión
class MiniCalendarWidgetFlexible extends StatelessWidget {
  final VoidCallback onTap;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Map<DateTime, List<AgendaEvent>> eventsByDay;

  const MiniCalendarWidgetFlexible({
    super.key,
    required this.onTap,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    required this.eventsByDay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.outline),
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calcular la altura disponible para el calendario
            final availableHeight = constraints.maxHeight - 120; // Restar espacio para header y footer
            final calendarHeight = availableHeight > 150 ? availableHeight : 150;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, color: AppColors.primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        'Calendario',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Usar la altura calculada
                  SizedBox(
                    height: calendarHeight.toDouble(),
                    child: SingleChildScrollView( // Añadir scroll por si acaso
                      child: AbsorbPointer(
                        child: TableCalendar<AgendaEvent>(
                          locale: 'es_ES',
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: focusedDay,
                          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                          onDaySelected: onDaySelected,
                          onPageChanged: (focusedDay) {},
                          eventLoader: (day) {
                            final dayKey = DateTime.utc(day.year, day.month, day.day);
                            return eventsByDay[dayKey] ?? [];
                          },
                          calendarFormat: CalendarFormat.month,
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Month',
                          },
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            headerPadding: EdgeInsets.symmetric(vertical: 4.0),
                          ),
                          calendarStyle: CalendarStyle(
                            defaultTextStyle: const TextStyle(fontSize: 11),
                            weekendTextStyle: const TextStyle(fontSize: 11),
                            selectedTextStyle: const TextStyle(fontSize: 11, color: Colors.white),
                            todayTextStyle: const TextStyle(fontSize: 11, color: Colors.white),
                            markerSize: 3.0,
                            cellMargin: const EdgeInsets.all(1.0),
                            selectedDecoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          daysOfWeekStyle: const DaysOfWeekStyle(
                            weekdayStyle: TextStyle(fontSize: 9),
                            weekendStyle: TextStyle(fontSize: 9),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Toque para regresar al mapa',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryColor,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}