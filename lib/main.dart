import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/deck_provider.dart';
import 'providers/local_provider.dart';
import 'providers/theme_provider.dart';
import 'package:karina_app/providers/game_provider.dart';
import 'views/login_view.dart';
import 'views/dashboard_screen.dart';
import 'views/splash_screen.dart';
import 'views/onboarding_screen.dart';
import 'utils/app_theme.dart';

void main() async {
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const InitialFlow(),
    );
  }
}

class InitialFlow extends StatefulWidget {
  const InitialFlow({super.key});

  @override
  State<InitialFlow> createState() => _InitialFlowState();
}

class _InitialFlowState extends State<InitialFlow> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _hideSplash();
  }

  void _hideSplash() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) return const SplashScreen();
    return const AuthGate();
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showOnboarding = true; // In production this would come from SharedPreferences

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (_showOnboarding) {
          return OnboardingScreen(
            onFinish: () {
              setState(() {
                _showOnboarding = false;
              });
            },
          );
        }
        return auth.isLoggedIn ? const DashboardScreen() : const LoginView();
      },
    );
  }
}
