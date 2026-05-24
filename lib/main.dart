import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/deck_provider.dart';
import 'providers/game_provider.dart';
import 'utils/app_theme.dart';
import 'utils/db_helper.dart';
import 'views/dashboard_screen.dart';

void main() async {
  // OPTIMIZADO [INI-001]: Asegura que los bindings se inicialicen antes de tareas asíncronas
  WidgetsFlutterBinding.ensureInitialized();

  // OPTIMIZADO [INI-001]: Inicialización de la base de datos antes de arrancar la UI
  // Esto evita pantallas en blanco por falta de datos en el primer renderizado.
  try {
    await DBHelper().db;
  } catch (e) {
    debugPrint('Error crítico al inicializar la base de datos: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DeckProvider()),
        ChangeNotifierProvider(create: (context) => GameProvider()),
      ],
      child: const KarinaApp(),
    ),
  );
}

class KarinaApp extends StatelessWidget {
  const KarinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kariña Learning',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // OPTIMIZADO [INI-002]: DashboardScreen centralizado como entrada definitiva
      home: const DashboardScreen(),
    );
  }
}
