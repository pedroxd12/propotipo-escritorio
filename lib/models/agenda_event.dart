import 'package:flutter/material.dart';

class AgendaEvent {
  final String id;
  String title;
  DateTime startTime;
  DateTime endTime;
  Color color;
  String technician;
  String client;
  String description;
  // int dayOfWeek; // Eliminado: Se puede obtener de startTime.weekday

  AgendaEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.color = Colors.blue,
    required this.technician,
    required this.client,
    required this.description,
    // required this.dayOfWeek, // Eliminado
  });

  // Helper para obtener la duración
  Duration get duration => endTime.difference(startTime);

  // Helper para obtener la posición en el grid horario (ej. 0 para 00:00, 9.0 para 09:00, 9.5 para 09:30)
  double get startHourOffset => startTime.hour + startTime.minute / 60.0;
}