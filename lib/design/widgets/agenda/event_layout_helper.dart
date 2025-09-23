// lib/design/widgets/agenda/event_layout_helper.dart
import 'package:serviceflow/data/models/agenda_event.dart';
import 'dart:math';

class EventLayoutParams {
  final double left; // Posición horizontal (0.0 a 1.0)
  final double width; // Ancho (0.0 a 1.0)
  final AgendaEvent event;

  EventLayoutParams({required this.left, required this.width, required this.event});
}

class EventLayoutHelper {
  /// Calcula la disposición de los eventos para evitar solapamientos.
  /// Devuelve una lista de parámetros de layout para cada evento.
  List<EventLayoutParams> calculateLayout(List<AgendaEvent> events) {
    if (events.isEmpty) {
      return [];
    }

    // Ordena los eventos por hora de inicio
    events.sort((a, b) => a.startTime.compareTo(b.startTime));

    final List<List<AgendaEvent>> columns = [];
    final Map<String, EventLayoutParams> layoutParams = {};

    for (final event in events) {
      bool placed = false;
      // Intenta colocar el evento en una columna existente
      for (final column in columns) {
        final lastEventInColumn = column.last;
        // Si el evento actual no se solapa con el último de la columna, lo añade
        if (!event.overlaps(lastEventInColumn)) {
          column.add(event);
          placed = true;
          break;
        }
      }

      // Si no pudo colocarlo, crea una nueva columna para él
      if (!placed) {
        columns.add([event]);
      }
    }

    // Calcula los parámetros de layout para cada evento
    for (int i = 0; i < columns.length; i++) {
      for (final event in columns[i]) {
        final collidingGroups = _findCollidingGroups(event, events);
        final maxColumns = _calculateMaxColumns(collidingGroups, events);
        final columnWidth = 1.0 / maxColumns;

        final currentColumnIndex = _determineColumnIndex(event, collidingGroups, events);

        layoutParams[event.id] = EventLayoutParams(
          left: currentColumnIndex * columnWidth,
          width: columnWidth,
          event: event,
        );
      }
    }

    return events.map((e) => layoutParams[e.id]!).toList();
  }

  // Encuentra todos los eventos que colisionan con el evento dado
  List<AgendaEvent> _findCollidingGroups(AgendaEvent event, List<AgendaEvent> allEvents) {
    final group = <AgendaEvent>{event};
    bool added;
    do {
      added = false;
      for (final otherEvent in allEvents) {
        if (!group.contains(otherEvent)) {
          if (group.any((e) => e.overlaps(otherEvent))) {
            if (group.add(otherEvent)) {
              added = true;
            }
          }
        }
      }
    } while (added);
    return group.toList()..sort((a,b) => a.startTime.compareTo(b.startTime));
  }

  // Calcula el número máximo de columnas necesarias en un grupo de colisión
  int _calculateMaxColumns(List<AgendaEvent> group, List<AgendaEvent> allEvents) {
    if (group.isEmpty) return 1;
    final columns = <List<AgendaEvent>>[];
    for(final event in group) {
      bool placed = false;
      for(final col in columns) {
        if(!event.overlaps(col.last)) {
          col.add(event);
          placed = true;
          break;
        }
      }
      if(!placed) {
        columns.add([event]);
      }
    }
    return max(1, columns.length);
  }

  // Determina el índice de la columna para un evento dentro de su grupo
  int _determineColumnIndex(AgendaEvent event, List<AgendaEvent> group, List<AgendaEvent> allEvents) {
    final occupiedColumns = <int>{};
    for(final otherEvent in group) {
      if(otherEvent.id != event.id && otherEvent.overlaps(event)) {
        final otherParams = _findCollidingGroups(otherEvent, group);
        final otherMaxCols = _calculateMaxColumns(otherParams, group);
        final otherIndex = _determineColumnIndexRecursive(otherEvent, otherParams, group);
        if(otherMaxCols > 1) {
          occupiedColumns.add(otherIndex);
        }
      }
    }
    int index = 0;
    while(occupiedColumns.contains(index)) {
      index++;
    }
    return index;
  }
  int _determineColumnIndexRecursive(AgendaEvent event, List<AgendaEvent> group, List<AgendaEvent> allEvents) {
    final columns = <List<AgendaEvent>>[];
    for(final e in group) {
      bool placed = false;
      for (int i = 0; i < columns.length; i++) {
        if(!e.overlaps(columns[i].last)) {
          columns[i].add(e);
          if(e.id == event.id) return i;
          placed = true;
          break;
        }
      }
      if(!placed) {
        columns.add([e]);
        if(e.id == event.id) return columns.length - 1;
      }
    }
    return 0;
  }

}

// Extensión para añadir la lógica de solapamiento al modelo de evento
extension EventOverlap on AgendaEvent {
  bool overlaps(AgendaEvent other) {
    return startTime.isBefore(other.endTime) && endTime.isAfter(other.startTime);
  }
}