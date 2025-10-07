// lib/design/widgets/notification/notification_panel_widget.dart
import 'package:flutter/material.dart';
import 'package:serviceflow/core/theme/app_colors.dart';

class NotificationPanel extends StatelessWidget {
  final List<NotificationItem> notifications;
  final VoidCallback? onViewAll;
  final Function(NotificationItem)? onNotificationTap;

  const NotificationPanel({
    super.key,
    this.notifications = const [],
    this.onViewAll,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayNotifications = notifications.isNotEmpty
        ? notifications.take(4).toList()
        : _getDefaultNotifications();

    return Container(
      width: 320,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildNotificationsList(context, displayNotifications),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: AppColors.primaryColor,
                size: 20,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.errorColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Notificaciones',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (notifications.length > 4)
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Ver todas',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, List<NotificationItem> items) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 48,
              color: AppColors.textTertiaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              'No hay notificaciones',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return _buildNotificationItem(context, items[index]);
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationItem notification) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onNotificationTap?.call(notification),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: notification.isRead
                ? Colors.transparent
                : AppColors.primaryColor.withValues(alpha: 0.02),
            border: notification.priority == NotificationPriority.critical
                ? Border.all(color: AppColors.errorColor.withValues(alpha: 0.2), width: 1)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: notification.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w500,
                        fontSize: 13,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.timeAgo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: notification.color,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Datos de ejemplo para cuando no se proporcionan notificaciones
  List<NotificationItem> _getDefaultNotifications() {
    return [
      NotificationItem(
        id: '1',
        icon: Icons.warning_amber_rounded,
        message: 'Servidor crítico requiere atención inmediata',
        timeAgo: 'Hace 2 min',
        color: AppColors.warningColor,
        priority: NotificationPriority.critical,
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        icon: Icons.person_add_rounded,
        message: 'Nuevo cliente registrado: Tech Solutions SA',
        timeAgo: 'Hace 15 min',
        color: AppColors.primaryColor,
        priority: NotificationPriority.info,
        isRead: false,
      ),
      NotificationItem(
        id: '3',
        icon: Icons.check_circle_rounded,
        message: 'Orden de servicio #12345 completada exitosamente',
        timeAgo: 'Hace 45 min',
        color: AppColors.successColor,
        priority: NotificationPriority.success,
        isRead: true,
      ),
    ];
  }
}

// Modelo de datos para las notificaciones
class NotificationItem {
  final String id;
  final IconData icon;
  final String message;
  final String timeAgo;
  final Color color;
  final NotificationPriority priority;
  final bool isRead;
  final DateTime? timestamp;

  const NotificationItem({
    required this.id,
    required this.icon,
    required this.message,
    required this.timeAgo,
    required this.color,
    required this.priority,
    this.isRead = false,
    this.timestamp,
  });

  NotificationItem copyWith({
    String? id,
    IconData? icon,
    String? message,
    String? timeAgo,
    Color? color,
    NotificationPriority? priority,
    bool? isRead,
    DateTime? timestamp,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      message: message ?? this.message,
      timeAgo: timeAgo ?? this.timeAgo,
      color: color ?? this.color,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

enum NotificationPriority {
  critical,
  warning,
  info,
  success,
}

// Ejemplo de uso:
/*
NotificationPanel(
  notifications: [
    NotificationItem(
      id: '1',
      icon: Icons.error_outline,
      message: 'Error en el sistema de pagos',
      timeAgo: 'Hace 5 min',
      color: Colors.red,
      priority: NotificationPriority.critical,
      isRead: false,
    ),
    // ... más notificaciones
  ],
  onViewAll: () {
    // Navegar a la pantalla completa de notificaciones
  },
  onNotificationTap: (notification) {
    // Manejar tap en notificación específica
  },
)
*/