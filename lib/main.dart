// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:serviceflow/core/routes/app_router.dart';
import 'package:serviceflow/core/theme/app_theme.dart';
import 'package:serviceflow/design/state/technician_provider.dart';
import 'package:serviceflow/design/state/client_provider.dart';
import 'package:window_manager/window_manager.dart'; // Importa el paquete

void main() async {
  // Asegura que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);

  // --- CONFIGURACIÓN DEL TAMAÑO DE LA VENTANA ---
  // Espera a que el gestor de la ventana esté listo
  await windowManager.ensureInitialized();

  // Define las opciones de la ventana
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),      // Tamaño inicial de la ventana
    minimumSize: Size(1100, 600), // Tamaño mínimo permitido
    center: true,               // Centra la ventana al iniciar
    title: 'ServiceFlow',       // Título de la ventana
  );

  // Espera a que las opciones se apliquen y luego muestra la ventana
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  // --- FIN DE LA CONFIGURACIÓN ---

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TechnicianProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        // Aquí puedes añadir más providers globales si los necesitas
      ],
      child: MaterialApp.router(
        title: 'ServiceFlow',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
        ],
        routerConfig: AppRouter.router,
      ),
    );
  }
}