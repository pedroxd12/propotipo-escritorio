import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // <-- IMPORTANTE: Añade esta línea
import 'package:intl/date_symbol_data_local.dart'; // Importante para localización de fechas
import 'package:serviceflow/screens/home_screen.dart';
import 'package:serviceflow/screens/login_screen.dart';
import 'package:serviceflow/screens/order_detail_screen.dart';
import 'package:serviceflow/screens/splash_screen.dart';
import 'package:serviceflow/theme/app_theme.dart';
import 'package:serviceflow/screens/service_orders_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null); // Correcto para intl
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServiceFlow',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,

      // Configuración de Localización para Material Widgets:
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español de España
        // Locale('en', 'US'), // Si necesitas soportar inglés también
      ],
      // Opcional: define el idioma por defecto si quieres forzarlo
      // locale: const Locale('es', 'ES'),

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/service_orders': (context) => const ServiceOrdersScreen(),
        '/order_detail': (context) {
          final String? orderId = ModalRoute.of(context)?.settings.arguments as String?;
          if (orderId == null) {
            return const Scaffold(body: Center(child: Text("Error: Order ID no proporcionado.")));
          }
          return OrderDetailScreen(orderId: orderId);
        },
      },
    );
  }
}