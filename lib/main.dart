// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Asegúrate que esta importación esté
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:serviceflow/core/routes/app_router.dart';
import 'package:serviceflow/core/theme/app_theme.dart';
import 'package:serviceflow/design/state/technician_provider.dart';
import 'package:serviceflow/design/state/client_provider.dart';
import 'package:serviceflow/design/state/service_order_provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);

  await dotenv.load(fileName: ".env");

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(1100, 600),
    center: true,
    title: 'ServiceFlow',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

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
        ChangeNotifierProvider(create: (_) => ServiceOrderProvider()),
      ],
      child: MaterialApp.router(
        title: 'ServiceFlow',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          // --- CORRECCIÓN AQUÍ ---
          GlobalMaterialLocalizations.delegate, // Nombre correcto
          GlobalWidgetsLocalizations.delegate,  // Nombre correcto
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