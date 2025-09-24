// lib/design/shared/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:serviceflow/design/widgets/notification/notification_panel_widget.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;
  const CustomAppBar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    String userName = "Admin";

    return AppBar(
      backgroundColor: AppColors.headerPrimary,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.headerPrimary, AppColors.headerSecondary],
          ),
        ),
      ),
      title: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            // Logo y Nombre
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      'assets/images/service_flow_logo.svg',
                      height: 28,
                      width: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "ServiceFlow",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 30,
              width: 1,
              color: Colors.white.withOpacity(0.2),
              margin: const EdgeInsets.symmetric(horizontal: 20),
            ),

            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildNavItem(context, "Inicio", Icons.home_rounded, '/home'),
                    const SizedBox(width: 4),
                    _buildNavItem(context, "Órdenes", Icons.receipt_long_rounded, '/service-orders'),
                    const SizedBox(width: 4),
                    _buildNavItem(context, "Clientes", Icons.people_rounded, '/clients'),
                    const SizedBox(width: 4),
                    _buildNavItem(context, "Técnicos", Icons.engineering_rounded, '/technicians'),
                    const SizedBox(width: 4),
                    _buildNavItem(context, "Usuarios", Icons.manage_accounts_rounded, '/users'),
                  ],
                ),
              ),
            ),

            // Perfil de Usuario y Notificaciones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
                    tooltip: "Notificaciones",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const Dialog(
                          alignment: Alignment.topRight,
                          child: SizedBox(
                            width: 400,
                            height: 600,
                            child: NotificationPanel(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.accentColor,
                          child: Text(
                            userName.isNotEmpty ? userName[0] : 'U',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Hola, $userName',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                    tooltip: "Cerrar Sesión",
                    onPressed: () => context.go('/login'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, String route) {
    final bool isActive = currentRoute == route;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(8),
        hoverColor: Colors.white.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryColor.withOpacity(0.5) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: isActive ? Colors.white : Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}