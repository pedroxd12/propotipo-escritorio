// lib/services/agenda_service.dart

import 'package:flutter/material.dart';
import '../models/agenda_event.dart';
import '../theme/app_colors.dart';

/// Un servicio para gestionar los datos de los eventos de la agenda.
///
/// En una aplicación real, este servicio se conectaría a una API,
/// una base de datos local o cualquier otra fuente de datos.
class AgendaService {
  /// Obtiene una lista de eventos de ejemplo para una semana específica.
  Future<List<AgendaEvent>> getEventsForWeek(DateTime weekDate) async {
    // Simulamos una llamada a red con un pequeño retraso.
    await Future.delayed(const Duration(milliseconds: 300));

    final mondayThisWeek = weekDate.subtract(Duration(days: weekDate.weekday - 1));

    // Los datos de ejemplo ahora se generan aquí, basados en la semana solicitada.
    return [
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
  }
}