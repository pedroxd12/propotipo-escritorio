import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importante para localización de fechas
import 'package:serviceflow/screens/home_screen.dart'; // Corregido
import 'package:serviceflow/screens/login_screen.dart'; // Corregido
import 'package:serviceflow/screens/order_detail_screen.dart'; // Corregido
import 'package:serviceflow/screens/splash_screen.dart'; // Corregido
import 'package:serviceflow/theme/app_theme.dart'; // Corregido


void main() async {
  // Asegura que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa datos de localización para formateo de fechas (ej. español)
  await initializeDateFormatting('es_ES', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServiceFlow',
      theme: AppTheme.lightTheme, // Usaremos un tema personalizado
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/order_detail': (context) => const OrderDetailScreen(orderId: 'dummy_id'), // Asegúrate de pasar un ID o manejarlo desde argumentos
      },
    );
  }
}