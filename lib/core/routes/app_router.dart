// lib/core/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serviceflow/data/models/agenda_event.dart'; // Importar el modelo
import 'package:serviceflow/design/screens/auth/login_screen.dart';
import 'package:serviceflow/design/screens/clients/clients_screen.dart';
import 'package:serviceflow/design/screens/home/home_screen.dart';
import 'package:serviceflow/design/screens/orden_detail/order_detail_screen.dart';
import 'package:serviceflow/design/screens/service_orders/service_orders_screen.dart';
import 'package:serviceflow/design/screens/splash/splash_screen.dart';
import 'package:serviceflow/design/screens/tecnicos/tecnicos_screen.dart';
import 'package:serviceflow/design/screens/usuarios/usuarios_screen.dart';
import 'package:serviceflow/design/shared/widgets/app_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppShell(currentRoute: state.matchedLocation, child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/service-orders',
            builder: (context, state) => const ServiceOrdersScreen(),
          ),
          GoRoute(
            path: '/clients',
            builder: (context, state) => const ClientsScreen(),
          ),
          GoRoute(
            path: '/technicians',
            builder: (context, state) => const TechniciansScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersScreen(),
          ),
        ],
      ),
      // --- CORRECCIÓN CLAVE 4: MODIFICAR LA RUTA DE DETALLE ---
      GoRoute(
        path: '/order-detail/:orderId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          // Recibimos el objeto 'AgendaEvent' que pasamos como 'extra'
          final event = state.extra as AgendaEvent?;

          // Pasamos ambos datos a la pantalla de detalle
          return OrderDetailScreen(orderId: orderId, event: event);
        },
      ),
    ],
  );
}