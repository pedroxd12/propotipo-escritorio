// lib/design/widgets/home/daily_agenda_panel.dart
import 'package:flutter/material.dart';
import 'package:serviceflow/core/theme/app_colors.dart';

class DailyAgendaPanel extends StatelessWidget {
  const DailyAgendaPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo para las tareas de hoy
    final List<Map<String, dynamic>> todaysTasks = [
      {
        "time": "09:00",
        "task": "Reunión equipo Alfa",
        "client": "Interno",
        "priority": "high",
        "icon": Icons.groups_rounded,
      },
      {
        "time": "11:30",
        "task": "Mantenimiento Servidor",
        "client": "TechCorp",
        "priority": "medium",
        "icon": Icons.storage_rounded,
      },
      {
        "time": "14:00",
        "task": "Instalación Software",
        "client": "BetaMax Corp",
        "priority": "low",
        "icon": Icons.install_desktop_rounded,
      },
      {
        "time": "16:30",
        "task": "Soporte Remoto",
        "client": "Zeta Solutions",
        "priority": "high",
        "icon": Icons.support_agent_rounded,
      },
    ];

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
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${todaysTasks.length}',
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: todaysTasks.length,
              itemBuilder: (context, index) {
                final task = todaysTasks[index];
                return _buildTaskItem(context, task);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Map<String, dynamic> task) {
    Color priorityColor;
    switch (task['priority']) {
      case 'high':
        priorityColor = AppColors.errorColor;
        break;
      case 'medium':
        priorityColor = AppColors.warningColor;
        break;
      default:
        priorityColor = AppColors.successColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              task['icon'],
              color: priorityColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['task'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
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
                        task['client'],
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task['time'],
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}