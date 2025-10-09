// lib/design/widgets/home/daily_agenda_panel.dart
import 'package:flutter/material.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:serviceflow/data/models/agenda_event.dart';
import 'package:serviceflow/design/widgets/order/order_detail_modal.dart';

class DailyAgendaPanel extends StatelessWidget {
  final List<AgendaEvent> todayEvents;

  const DailyAgendaPanel({
    super.key,
    this.todayEvents = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.outline),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.today_rounded, color: AppColors.primaryColor),
                const SizedBox(width: 12),
                Text(
                  'Agenda de Hoy',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${todayEvents.length}',
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          Expanded(
            child: todayEvents.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: todayEvents.length,
                    itemBuilder: (context, index) {
                      return _buildTaskItem(context, todayEvents[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: AppColors.successColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Sin eventos para hoy',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '¡Día libre!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, AgendaEvent event) {
    final statusInfo = _getStatusInfo(event.ordenOriginal.status);
    final timeFormat = '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => OrderDetailModal.show(context, event),
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: event.color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: event.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    statusInfo['icon'] as IconData,
                    color: event.color,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.business_rounded,
                            size: 12,
                            color: AppColors.textTertiaryColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.client,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiaryColor,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: event.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        timeFormat,
                        style: TextStyle(
                          color: event.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (statusInfo['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusInfo['text'] as String,
                        style: TextStyle(
                          color: statusInfo['color'] as Color,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(status) {
    switch (status.toString()) {
      case 'OrdenStatus.enProceso':
        return {
          'color': AppColors.warningColor,
          'text': 'En Proceso',
          'icon': Icons.play_circle_outline,
        };
      case 'OrdenStatus.enCamino':
        return {
          'color': AppColors.infoColor,
          'text': 'En Camino',
          'icon': Icons.directions_car_outlined,
        };
      case 'OrdenStatus.finalizada':
        return {
          'color': AppColors.successColor,
          'text': 'Finalizada',
          'icon': Icons.check_circle_outline,
        };
      case 'OrdenStatus.cancelada':
        return {
          'color': AppColors.errorColor,
          'text': 'Cancelada',
          'icon': Icons.cancel_outlined,
        };
      case 'OrdenStatus.agendada':
      default:
        return {
          'color': AppColors.primaryColor,
          'text': 'Agendada',
          'icon': Icons.schedule,
        };
    }
  }
}