import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  String? _userName;
  int _level = 1;
  bool _isLoggedIn = false;

  String? get userName => _userName;
  int get level => _level;
  bool get isLoggedIn => _isLoggedIn;

  // Simulación de Login
  Future<bool> login(String user, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // Simular red
    _userName = user;
    _isLoggedIn = true;
    _level = 5; // Ejemplo: el usuario ya va por el nivel 5
    notifyListeners();
    return true;
  }

  // API para "Olvidé mi contraseña"
  Future<void> sendResetEmail(String email) async {
    final url = Uri.parse('https://tu-api.com/reset-password');
    try {
      await http.post(url, body: {'email': email});
    } catch (e) {
      debugPrint("Error enviando correo: $e");
    }
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}