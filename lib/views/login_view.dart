import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Optimizamos memoria usando controladores reales
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos select en lugar de watch/Provider.of para evitar reconstrucciones innecesarias
    final auth = context.read<AuthProvider>(); 
    
    return Scaffold(
      body: Stack(
        children: [
          // OPTIMIZACIÓN: Usar Image.asset con errorBuilder para evitar ANR
          Image.asset(
            'assets/images/background_login.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
            // Si el asset no existe o falla, esto evita que la app se cuelgue
            errorBuilder: (context, error, stackTrace) {
              return Container(color: const Color(0xFF2E1A11)); // Color base de tu app
            },
          ),
          
          // Capa oscura
          Container(color: Colors.black.withOpacity(0.5)),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const Text(
                    "KARIÑA", 
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 50, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4
                    )
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _userController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      hintText: "Usuario",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      hintText: "Contraseña",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A7C44),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    onPressed: () => auth.login(_userController.text, _passwordController.text),
                    child: const Text("INICIAR SESIÓN", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  // ... resto de botones
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}