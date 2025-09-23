// lib/data/models/agenda_event.dart
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

  AgendaEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.color = Colors.blue,
    required this.technician,
    required this.client,
    required this.description,
  });

  Duration get duration => endTime.difference(startTime);
  double get startHourOffset => startTime.hour + startTime.minute / 60.0;
}