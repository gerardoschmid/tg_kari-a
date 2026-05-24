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

  // OPTIMIZADO [INI-001]: Inicialización de la base de datos
  try {
    await DBHelper().db;
  } catch (e) {
    debugPrint('Error crítico al inicializar la base de datos: $e');
  }

  // Pre-creamos los providers para inicializar datos críticos
  final deckProvider = DeckProvider();

  // SOLUCIÓN AL BUG DE CARGA: Aseguramos el volcado del JSON a la DB antes de runApp
  await deckProvider.initializeProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: deckProvider),
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
      home: const DashboardScreen(),
    );
  }
}
