// lib/design/screens/orden_detail/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:serviceflow/data/models/agenda_event.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  final AgendaEvent? event; // Acepta un objeto AgendaEvent opcional

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.event, // Añadido al constructor
  });

  @override
  Widget build(BuildContext context) {
    // Formateadores para fecha y hora
    final dateFormat = DateFormat('EEEE d \'de\' MMMM, y', 'es_ES');
    final timeFormat = DateFormat('HH:mm', 'es_ES');

    return Scaffold(
      appBar: AppBar(
        // El título ahora es más dinámico
        title: Text(event?.title ?? 'Detalle Orden #$orderId'),
        // El botón de volver usará context.pop() y funcionará correctamente
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: "Volver",
          onPressed: () => context.pop(),
        ),
        backgroundColor: AppColors.headerPrimary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            // Si no hay evento, muestra un mensaje de error
            child: event == null
                ? const Center(
              child: Text(
                'No se pudo cargar la información del evento.',
                style: TextStyle(fontSize: 18, color: AppColors.errorColor),
              ),
            )
            // Si hay evento, muestra una tarjeta con sus detalles
                : Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado
                      Row(
                        children: [
                          Icon(Icons.receipt_long_rounded, color: event!.color, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event!.title,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                Text(
                                  'Orden de Servicio #$orderId',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondaryColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 40),

                      // Detalles del evento
                      _buildDetailRow(context, Icons.person_outline_rounded, 'Cliente:', event!.client),
                      _buildDetailRow(context, Icons.engineering_outlined, 'Técnico Asignado:', event!.technician),
                      _buildDetailRow(context, Icons.calendar_today_outlined, 'Fecha:', dateFormat.format(event!.startTime)),
                      _buildDetailRow(
                        context,
                        Icons.schedule_outlined,
                        'Horario:',
                        '${timeFormat.format(event!.startTime)} - ${timeFormat.format(event!.endTime)} (${event!.duration.inMinutes} min)',
                      ),
                      const Divider(height: 40),

                      // Descripción del servicio
                      Text(
                        'Descripción del Servicio',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event!.description.isNotEmpty ? event!.description : 'No hay descripción disponible.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 40),

                      // Botones de acción
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              // Lógica para modificar la orden
                            },
                            icon: const Icon(Icons.edit_note_rounded),
                            label: const Text('Modificar Orden'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Lógica para marcar como completada
                            },
                            icon: const Icon(Icons.check_circle_outline_rounded),
                            label: const Text('Marcar como Completada'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.successColor,
                            ),
                          ),
                        ],
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

  // Widget de ayuda para mostrar las filas de detalles de forma consistente
  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondaryColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}