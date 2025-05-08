import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo
    final today = DateTime.now();
    final formattedDate = "${_getWeekday(today.weekday)}, ${today.day} ${_getMonth(today.month)}";

    final List<Map<String, String>> todaysTasks = [
      {"time": "09:00 AM", "task": "Reunión equipo", "client": "Interno"},
      {"time": "11:30 AM", "task": "Mantenimiento Servidor A", "client": "Cliente X"},
      {"time": "02:00 PM", "task": "Instalación Software", "client": "Cliente Y"},
    ];

    return Container(
      width: 280, // Ancho del panel
      padding: const EdgeInsets.all(16.0),
      color: AppColors.surfaceColor, // Un color ligeramente diferente o el mismo que el fondo
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formattedDate,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            _getGreeting(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text(
            'Tareas de Hoy',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18),
          ),
          const Divider(thickness: 1, height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: todaysTasks.length,
              itemBuilder: (context, index) {
                final task = todaysTasks[index];
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      child: Text(
                        task["time"]!.substring(0,2), // Hora
                        style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    title: Text(task["task"]!, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    subtitle: Text(task["client"]!, style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor)),
                    dense: true,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Notificaciones',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18),
          ),
          const Divider(thickness: 1, height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildNotificationItem(context, Icons.warning_amber_rounded, "Alerta: Servidor Z necesita atención.", "Hace 5 min", Colors.orange),
                _buildNotificationItem(context, Icons.info_outline, "Nuevo cliente registrado: Tech Solutions.", "Hace 30 min", AppColors.primaryColor),
                _buildNotificationItem(context, Icons.check_circle_outline, "Orden #12345 completada.", "Hace 1 hora", AppColors.successColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días!';
    if (hour < 18) return 'Buenas tardes!';
    return 'Buenas noches!';
  }

  String _getWeekday(int day) {
    const days = ["", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"];
    return days[day];
  }

  String _getMonth(int month) {
    const months = ["", "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"];
    return months[month];
  }

  Widget _buildNotificationItem(BuildContext context, IconData icon, String message, String time, Color iconColor) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 28),
      title: Text(message, style: const TextStyle(fontSize: 13)),
      subtitle: Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryColor)),
      dense: true,
      onTap: () {},
    );
  }
}