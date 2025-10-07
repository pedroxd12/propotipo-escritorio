// lib/design/widgets/agenda/agenda_item_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serviceflow/data/models/agenda_event.dart';

class AgendaItemWidget extends StatefulWidget {
  final AgendaEvent event;
  final VoidCallback onTap;
  final double hourRowHeight;
  final int startHourOfDay;

  const AgendaItemWidget({
    super.key,
    required this.event,
    required this.onTap,
    this.hourRowHeight = 90.0,
    this.startHourOfDay = 7,
  });

  @override
  State<AgendaItemWidget> createState() => _AgendaItemWidgetState();
}

class _AgendaItemWidgetState extends State<AgendaItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final itemHeight = (widget.event.duration.inMinutes / 60.0) * widget.hourRowHeight;
    final finalHeight = itemHeight < 45.0 ? 45.0 : itemHeight;
    final eventColor = widget.event.color;
    final backgroundColor = eventColor.withValues(alpha: 0.9);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Tooltip(
          message: _buildTooltipMessage(),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Card(
              elevation: _isHovered ? 8 : 4,
              shadowColor: eventColor.withValues(alpha: 0.3),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Container(
                height: finalHeight,
                width: double.infinity, // Asegura que ocupe todo el ancho
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [backgroundColor, eventColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                // --- SOLUCIÓN A PRUEBA DE ERRORES CON SingleChildScrollView ---
                // Se envuelve el contenido en un SingleChildScrollView para
                // prevenir cualquier desbordamiento de píxeles vertical.
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(), // Evita que el usuario pueda hacer scroll
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuye el espacio
                    children: [
                      // Contenido superior
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.event.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${timeFormat.format(widget.event.startTime)} - ${timeFormat.format(widget.event.endTime)}',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9), fontSize: 11),
                          ),
                        ],
                      ),
                      // Contenido inferior (sólo si hay espacio)
                      if (finalHeight > 60)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0), // Añade un espacio si hay cliente
                          child: Text(
                            widget.event.client,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildTooltipMessage() {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('EEE, d MMM', 'es_ES');
    return '${widget.event.title}\n'
        '${dateFormat.format(widget.event.startTime)}\n'
        '${timeFormat.format(widget.event.startTime)} - ${timeFormat.format(widget.event.endTime)}\n'
        'Técnico: ${widget.event.technician}\n'
        'Cliente: ${widget.event.client}';
  }
}