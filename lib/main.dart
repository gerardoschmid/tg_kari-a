import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/deck_provider.dart';
import 'providers/local_provider.dart';
import 'package:karina_app/providers/game_provider.dart';
import 'views/login_view.dart';
import 'views/main_home_view.dart';

void main() async {
  // Asegura que los canales nativos de Android estén listos antes de cargar assets/DB
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DeckProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => LocalProvider()),
      ],
      child: const MaterialApp( // Agregado const para optimizar el árbol de widgets
        debugShowCheckedModeBanner: false,
        home: AuthGate(),
      ),
    ),
  );
}

// Extraemos la lógica de decisión a un widget separado para limpiar el main
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Esta redirección es atómica y eficiente
        return auth.isLoggedIn ? const MainHomeView() : const LoginView();
      },
    );
  }
}