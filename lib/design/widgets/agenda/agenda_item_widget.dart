import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/agenda_event.dart'; // Asegúrate que la ruta sea correcta
import '../theme/app_colors.dart'; // No parece usarse directamente aquí

class AgendaItemWidget extends StatelessWidget {
  final AgendaEvent event;
  final VoidCallback onTap;
  final double hourRowHeight;
  final int startHourOfDay;

  const AgendaItemWidget({
    super.key,
    required this.event,
    required this.onTap,
    this.hourRowHeight = 60.0,
    this.startHourOfDay = 8,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    // event.startHourOffset ya se calcula en el modelo AgendaEvent usando startTime
    final topPosition = (event.startHourOffset - startHourOfDay) * hourRowHeight;
    final itemHeight = (event.duration.inMinutes / 60.0) * hourRowHeight;

    return Positioned(
      top: topPosition,
      left: 0,
      right: 0,
      height: itemHeight < 30 ? 30 : itemHeight,
      child: Tooltip(
        message: 'Técnico: ${event.technician}\n'
            'Cliente: ${event.client}\n'
            'Hora: ${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}\n'
            'Descripción: ${event.description}',
        preferBelow: false,
        child: InkWell(
          onTap: onTap,
          child: Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            color: event.color.withOpacity(0.9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (itemHeight > 40)
                    Text(
                      timeFormat.format(event.startTime),
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  if (itemHeight > 60)
                    Text(
                      'Cliente: ${event.client}',
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}