import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/deck_provider.dart';
import 'providers/local_provider.dart';
import 'providers/theme_provider.dart';
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localProvider = Provider.of<LocalProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: localProvider.locale,
      themeMode: themeProvider.themeMode,
      
      // Tema Claro (Earthy Light Theme)
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: const Color(0xFF4A7C44),
        scaffoldBackgroundColor: const Color(0xFFF5E6D3), // Parchement/cream
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A7C44),
          brightness: Brightness.light,
          primary: const Color(0xFF4A7C44),
          secondary: const Color(0xFF8B5E3C),
          surface: Colors.white,
          background: const Color(0xFFF5E6D3),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A7C44),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),

      // Tema Oscuro (Earthy Dark Theme)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF4A7C44),
        scaffoldBackgroundColor: const Color(0xFF1C110C), // Café oscuro indígena
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A7C44),
          brightness: Brightness.dark,
          primary: const Color(0xFF4A7C44),
          secondary: const Color(0xFFD2B48C),
          surface: const Color(0xFF2A1C15),
          background: const Color(0xFF1C110C),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2A1C15),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF2A1C15),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return auth.isLoggedIn ? const MainHomeView() : const LoginView();
      },
    );
  }
}