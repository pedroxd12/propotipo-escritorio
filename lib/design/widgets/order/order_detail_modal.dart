// lib/design/widgets/order/order_detail_modal.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:serviceflow/data/models/agenda_event.dart';
import 'package:serviceflow/data/models/orden_servicio_model.dart';

/// Modal flotante animado para mostrar los detalles de una orden de servicio
class OrderDetailModal extends StatelessWidget {
  final AgendaEvent event;

  const OrderDetailModal({
    super.key,
    required this.event,
  });

  /// Muestra el modal con animación
  static Future<void> show(BuildContext context, AgendaEvent event) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return OrderDetailModal(event: event);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Animación de escala con efecto de rebote suave
        final scaleAnimation = Tween<double>(
          begin: 0.85,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ));

        // Animación de opacidad
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE d \'de\' MMMM, y', 'es_ES');
    final timeFormat = DateFormat('HH:mm', 'es_ES');
    final statusInfo = _getStatusInfo(event.ordenOriginal.status);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        constraints: const BoxConstraints(
          maxWidth: 900,
          maxHeight: 700,
        ),
        child: Material(
          elevation: 24,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          shadowColor: event.color.withValues(alpha: 0.3),
          child: Column(
            children: [
              // Header con color del evento
              _buildHeader(context, statusInfo),

              // Contenido con scroll
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(context, dateFormat, timeFormat),
                      const SizedBox(height: 32),
                      _buildClientSection(context),
                      const SizedBox(height: 32),
                      _buildTechnicianSection(context),
                      const SizedBox(height: 32),
                      _buildDescriptionSection(context),
                      const SizedBox(height: 32),
                      _buildLocationSection(context),
                    ],
                  ),
                ),
              ),

              // Footer con acciones
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> statusInfo) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            event.color,
            event.color.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusInfo['icon'] as IconData,
                            size: 16,
                            color: statusInfo['color'] as Color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusInfo['text'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusInfo['color'] as Color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Orden #${event.id}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, DateFormat dateFormat, DateFormat timeFormat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: event.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: event.color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  context,
                  Icons.calendar_today_rounded,
                  'Fecha',
                  dateFormat.format(event.startTime),
                  event.color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  context,
                  Icons.schedule_rounded,
                  'Horario',
                  '${timeFormat.format(event.startTime)} - ${timeFormat.format(event.endTime)}',
                  event.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            Icons.timer_outlined,
            'Duración',
            '${event.duration.inHours}h ${event.duration.inMinutes % 60}m',
            event.color,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientSection(BuildContext context) {
    return _buildSection(
      context,
      'Cliente',
      Icons.business_rounded,
      AppColors.primaryColor,
      [
        _buildDetailRow(Icons.account_circle_outlined, 'Nombre', event.client),
        _buildDetailRow(Icons.phone_outlined, 'Teléfono', event.ordenOriginal.cliente.telefonoPrincipal),
        _buildDetailRow(Icons.email_outlined, 'Email', event.ordenOriginal.cliente.emailFacturacion),
      ],
    );
  }

  Widget _buildTechnicianSection(BuildContext context) {
    return _buildSection(
      context,
      'Técnico Asignado',
      Icons.engineering_rounded,
      AppColors.accentColor,
      [
        _buildDetailRow(Icons.person_outline, 'Nombre', event.technician),
        if (event.ordenOriginal.tecnicosAsignados.isNotEmpty)
          _buildDetailRow(Icons.phone_outlined, 'Teléfono', event.ordenOriginal.tecnicosAsignados.first.telefono),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    if (event.ordenOriginal.detallesSolicitud?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return _buildSection(
      context,
      'Descripción del Servicio',
      Icons.description_outlined,
      AppColors.infoColor,
      [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            event.ordenOriginal.detallesSolicitud ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: AppColors.textPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    final direccion = event.ordenOriginal.direccion;
    return _buildSection(
      context,
      'Ubicación',
      Icons.location_on_rounded,
      AppColors.errorColor,
      [
        _buildDetailRow(Icons.map_outlined, 'Dirección', direccion.calleYNumero),
        _buildDetailRow(Icons.location_city_outlined, 'Colonia', direccion.colonia),
        _buildDetailRow(Icons.pin_drop_outlined, 'Ciudad', '${direccion.municipio}, ${direccion.estado}'),
        _buildDetailRow(Icons.markunread_mailbox_outlined, 'C.P.', direccion.codigoPostal),
        if (direccion.referencias?.isNotEmpty ?? false)
          _buildDetailRow(Icons.info_outline, 'Referencias', direccion.referencias!),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, Color color, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children.map((child) {
              final index = children.indexOf(child);
              return Column(
                children: [
                  child,
                  if (index < children.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondaryColor),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            label: const Text('Cerrar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // Aquí puedes agregar navegación a editar o más acciones
            },
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Editar Orden'),
            style: FilledButton.styleFrom(
              backgroundColor: event.color,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(OrdenStatus status) {
    switch (status) {
      case OrdenStatus.enProceso:
        return {
          'color': AppColors.warningColor,
          'text': 'En Proceso',
          'icon': Icons.play_circle_outline,
        };
      case OrdenStatus.enCamino:
        return {
          'color': AppColors.infoColor,
          'text': 'En Camino',
          'icon': Icons.directions_car_outlined,
        };
      case OrdenStatus.finalizada:
        return {
          'color': AppColors.successColor,
          'text': 'Finalizada',
          'icon': Icons.check_circle_outline,
        };
      case OrdenStatus.cancelada:
        return {
          'color': AppColors.errorColor,
          'text': 'Cancelada',
          'icon': Icons.cancel_outlined,
        };
      case OrdenStatus.agendada:
      default:
        return {
          'color': AppColors.primaryColor,
          'text': 'Agendada',
          'icon': Icons.schedule,
        };
    }
  }
}
