// lib/design/widgets/home/mini_calendar_widget.dart
import 'package:flutter/material.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:serviceflow/data/models/agenda_event.dart';
import 'package:table_calendar/table_calendar.dart';

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
        child: Container(
          color: AppColors.surfaceColor,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                final availableWidth = constraints.maxWidth;

                // Mejoras en responsive design
                final isCompact = availableHeight < 300 || availableWidth < 300;
                final isSmall = availableHeight < 250;

                // Ajustes de estilo adaptativos
                final titleFontSize = isSmall ? 12.0 : isCompact ? 13.0 : 14.0;
                final iconSize = isSmall ? 16.0 : isCompact ? 18.0 : 20.0;
                final cellFontSize = isSmall ? 7.0 : isCompact ? 8.0 : 9.0;
                final daysFontSize = isSmall ? 5.0 : isCompact ? 6.0 : 7.0;
                final rowHeight = isSmall ? 18.0 : isCompact ? 20.0 : 24.0;
                final daysOfWeekHeight = isSmall ? 10.0 : isCompact ? 12.0 : 14.0;
                final markerSize = isSmall ? 1.5 : 2.0;

                return Column(
                  children: [
                    // Header de estilo unificado
                    Container(
                      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            color: AppColors.primaryColor,
                            size: iconSize,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Calendario',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: titleFontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.outline),
                    const SizedBox(height: 8),

                    // Calendario con scroll mejorado y gestos habilitados
                    Expanded(
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
                        // Habilitar gestos para navegación
                        pageJumpingEnabled: true,
                        pageAnimationEnabled: true,
                        pageAnimationCurve: Curves.easeInOutCubic,
                        pageAnimationDuration: const Duration(milliseconds: 300),

                        // Estilos de calendario compactos y responsive
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          leftChevronVisible: false,
                          rightChevronVisible: false,
                          headerPadding: EdgeInsets.symmetric(vertical: 2),
                        ),
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: TextStyle(
                            fontSize: cellFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                          weekendTextStyle: TextStyle(
                            fontSize: cellFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                          selectedTextStyle: TextStyle(
                            fontSize: cellFontSize,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          todayTextStyle: TextStyle(
                            fontSize: cellFontSize,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          markerSize: markerSize,
                          markersMaxCount: 3,
                          cellMargin: EdgeInsets.all(isSmall ? 0.5 : 1.0),
                          selectedDecoration: const BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: AppColors.primaryColor.withAlpha(128),
                            shape: BoxShape.circle,
                          ),
                          outsideTextStyle: TextStyle(
                            fontSize: cellFontSize,
                            color: AppColors.textTertiaryColor,
                          ),
                          // Mejorar interactividad de las celdas
                          canMarkersOverflow: false,
                          markerDecoration: const BoxDecoration(
                            color: AppColors.accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontSize: daysFontSize,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryColor,
                          ),
                          weekendStyle: TextStyle(
                            fontSize: daysFontSize,
                            fontWeight: FontWeight.w600,
                            color: AppColors.errorColor,
                          ),
                        ),
                        rowHeight: rowHeight,
                        daysOfWeekHeight: daysOfWeekHeight,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Footer para indicar la acción
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 10,
                          color: AppColors.textSecondaryColor.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Toca para ver el mapa',
                          style: TextStyle(
                            color: AppColors.textSecondaryColor,
                            fontSize: isSmall ? 6 : 7,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}