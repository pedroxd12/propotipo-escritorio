// lib/data/models/agenda_event.dart
import 'package:flutter/material.dart';
import 'package:serviceflow/data/models/orden_servicio_model.dart';

// Esta clase ahora actúa como un 'adaptador' para la vista de agenda.
// Convierte una OrdenServicio a un formato que el calendario puede mostrar.
class AgendaEvent {
  final String id; // Corresponde al ID de la OrdenServicio
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final String technician; // Nombre del técnico principal
  final String client; // Nombre del cliente
  final String description;
  final OrdenServicio ordenOriginal; // Referencia a la orden completa

  AgendaEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.technician,
    required this.client,
    required this.description,
    required this.ordenOriginal,
  });

  // Factory constructor para crear un AgendaEvent desde una OrdenServicio
  factory AgendaEvent.fromOrdenServicio(OrdenServicio orden) {
    return AgendaEvent(
      id: orden.id,
      title: orden.servicio.nombre,
      startTime: orden.fechaAgendadaInicio,
      endTime: orden.fechaAgendadaFin,
      color: _getStatusColor(orden.status),
      technician: orden.tecnicosAsignados.isNotEmpty
          ? orden.tecnicosAsignados.first.nombreCompleto
          : 'No asignado',
      client: orden.cliente.nombreCuenta,
      description: orden.detallesSolicitud ?? 'Sin detalles.',
      ordenOriginal: orden,
    );
  }

  Duration get duration => endTime.difference(startTime);
  double get startHourOffset => startTime.hour + startTime.minute / 60.0;
}

// Lógica para asignar un color basado en el estatus de la orden
Color _getStatusColor(OrdenStatus status) {
  switch (status) {
    case OrdenStatus.finalizada:
      return Colors.green.shade600;
    case OrdenStatus.enProceso:
    case OrdenStatus.enCamino:
      return Colors.blue.shade600;
    case OrdenStatus.cancelada:
      return Colors.red.shade400;
    case OrdenStatus.agendada:
      return Colors.orange.shade600;
    default:
      return Colors.grey.shade500;
  }
}