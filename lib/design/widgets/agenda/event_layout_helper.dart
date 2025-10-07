// lib/design/widgets/agenda/event_layout_helper.dart
import 'package:serviceflow/data/models/agenda_event.dart';

class EventLayoutParams {
  final double left;
  final double width;
  final AgendaEvent event;

  EventLayoutParams({required this.left, required this.width, required this.event});
}

class EventLayoutHelper {
  List<EventLayoutParams> calculateLayout(List<AgendaEvent> events) {
    if (events.isEmpty) return [];

    // Ordenar eventos por hora de inicio, luego por duración (más largos primero)
    events.sort((a, b) {
      if (a.startTime.isAtSameMomentAs(b.startTime)) {
        return b.endTime.compareTo(a.endTime);
      }
      return a.startTime.compareTo(b.startTime);
    });

    final List<EventLayoutParams> layoutParams = [];
    final List<AgendaEvent> processedEvents = [];

    for (final event in events) {
      if (processedEvents.contains(event)) continue;

      // 1. Encontrar el grupo de colisión completo para el evento actual
      final collisionGroup = _getCollisionGroup(event, events);
      processedEvents.addAll(collisionGroup);

      // 2. Organizar el grupo en columnas para evitar solapamientos
      final columns = _packEventsIntoColumns(collisionGroup);
      final totalColumns = columns.length;

      // 3. Asignar la posición y el ancho a cada evento del grupo
      for (int i = 0; i < totalColumns; i++) {
        for (final groupEvent in columns[i]) {
          layoutParams.add(EventLayoutParams(
            left: i / totalColumns,
            width: 1.0 / totalColumns,
            event: groupEvent,
          ));
        }
      }
    }

    return layoutParams;
  }

  // Encuentra todos los eventos que se solapan con un evento dado, directa o indirectamente.
  List<AgendaEvent> _getCollisionGroup(AgendaEvent event, List<AgendaEvent> allEvents) {
    final colliding = <AgendaEvent>{};
    final toCheck = [event];

    while (toCheck.isNotEmpty) {
      final current = toCheck.removeAt(0);
      colliding.add(current);

      for (final other in allEvents) {
        if (!colliding.contains(other) && current.overlaps(other)) {
          toCheck.add(other);
        }
      }
    }
    return colliding.toList();
  }

  // Organiza un grupo de eventos en el menor número de columnas posible.
  List<List<AgendaEvent>> _packEventsIntoColumns(List<AgendaEvent> group) {
    final columns = <List<AgendaEvent>>[];
    group.sort((a, b) => a.startTime.compareTo(b.startTime));

    for (final event in group) {
      bool placed = false;
      for (final column in columns) {
        if (!column.last.overlaps(event)) {
          column.add(event);
          placed = true;
          break;
        }
      }
      if (!placed) {
        columns.add([event]);
      }
    }
    return columns;
  }
}

// Extensión para verificar si dos eventos se solapan en el tiempo.
extension EventOverlap on AgendaEvent {
  bool overlaps(AgendaEvent other) {
    // Se añade un `.subtract` de 1 microsegundo para que eventos que terminan justo cuando empieza el otro no se consideren solapados.
    return startTime.isBefore(other.endTime) && endTime.subtract(const Duration(microseconds: 1)).isAfter(other.startTime);
  }
}