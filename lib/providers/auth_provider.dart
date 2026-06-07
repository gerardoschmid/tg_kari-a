<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _userName;
  String? _email;
  int _level = 1;
  bool _isLoggedIn = false;
  bool _useFirebase = false;

  String? get userName => _userName;
  String? get email => _email;
  int get level => _level;
  bool get isLoggedIn => _isLoggedIn;
  bool get useFirebase => _useFirebase;

  AuthProvider() {
    _checkFirebaseState();
    _loadSession();
  }

  void _checkFirebaseState() {
    try {
      final auth = FirebaseAuth.instance;
      _useFirebase = true;
      debugPrint("Firebase Auth is active.");
      auth.authStateChanges().listen((User? user) {
        if (user != null) {
          _userName = user.displayName ?? user.email?.split('@')[0] ?? 'Usuario';
          _email = user.email;
          _isLoggedIn = true;
          _saveSession();
          notifyListeners();
        } else {
          if (!_isBypassUser()) {
            _isLoggedIn = false;
            _userName = null;
            _email = null;
            _saveSession();
            notifyListeners();
          }
        }
      });
    } catch (e) {
      debugPrint("Firebase Auth initialization skipped or failed: $e. Using local simulation.");
      _useFirebase = false;
    }
  }

  bool _isBypassUser() {
    return _email == 'bypass@karina.com' || _email == 'admin@karina.com';
  }

  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('auth_is_logged_in') ?? false;
      _userName = prefs.getString('auth_user_name');
      _email = prefs.getString('auth_email');
      _level = prefs.getInt('auth_level') ?? 1;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading auth session: $e");
    }
  }

  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auth_is_logged_in', _isLoggedIn);
      if (_userName != null) await prefs.setString('auth_user_name', _userName!);
      if (_email != null) await prefs.setString('auth_email', _email!);
      await prefs.setInt('auth_level', _level);
    } catch (e) {
      debugPrint("Error saving auth session: $e");
    }
  }

  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_is_logged_in');
      await prefs.remove('auth_user_name');
      await prefs.remove('auth_email');
      await prefs.remove('auth_level');
    } catch (e) {
      debugPrint("Error clearing auth session: $e");
    }
  }

  // ─── Registro con Firebase Auth + Firestore ───────────────────────────────

  /// Crea una cuenta nueva, actualiza el displayName, envía verificación de
  /// correo y crea el documento inicial en Firestore users/{uid}.
  Future<void> register(String username, String email, String password) async {
    final cleanEmail = email.trim();
    final cleanUsername = username.trim();

    if (!_useFirebase) {
      throw Exception('Servicio de Firebase no disponible. Usa el modo bypass para pruebas.');
    }

    try {
      // 1. Crear cuenta en Firebase Auth
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('No se pudo crear la cuenta.');

      // 2. Actualizar displayName con el nombre de usuario
      await user.updateDisplayName(cleanUsername);

      // 3. Enviar correo de verificación
      await user.sendEmailVerification();

      // 4. Crear documento inicial en Firestore
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': cleanUsername,
          'email': cleanEmail,
          'level': 1,
          'xp': 0,
          'lives': 5,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (firestoreError) {
        // Si Firestore falla, no bloqueamos el flujo — el usuario ya fue creado
        debugPrint('Firestore write failed (non-critical): $firestoreError');
      }

      // 5. Cerrar sesión para que el usuario deba verificar antes de entrar
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      String message = 'Ocurrió un error al registrarse.';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Este correo electrónico ya está registrado.';
          break;
        case 'invalid-email':
          message = 'El formato del correo electrónico es inválido.';
          break;
        case 'weak-password':
          message = 'La contraseña es demasiado débil. Usa al menos 8 caracteres con números.';
          break;
        case 'operation-not-allowed':
          message = 'El registro por correo/contraseña no está habilitado.';
          break;
        case 'network-request-failed':
          message = 'Error de conexión a internet.';
          break;
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Error inesperado: ${e.toString()}');
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<bool> login(String userEmail, String password) async {
    final cleanEmail = userEmail.trim();

    // Bypass credentials check
    if ((cleanEmail == 'bypass@karina.com' || cleanEmail == 'admin@karina.com') &&
        (password == 'bypass123' || password == 'admin123')) {
      _userName = cleanEmail == 'admin@karina.com' ? 'Administrador' : 'Usuario Bypass';
      _email = cleanEmail;
      _isLoggedIn = true;
      _level = 5; // Simular progreso de nivel 5 para pruebas
      await _saveSession();
      notifyListeners();
      return true;
    }

    if (!_useFirebase) {
      throw Exception("Servicio de Firebase no disponible. Usa las credenciales de bypass para ingresar: bypass@karina.com / bypass123");
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        // Verificar que el correo esté verificado
        if (!user.emailVerified) {
          await FirebaseAuth.instance.signOut();
          throw Exception('Debes verificar tu correo electrónico antes de iniciar sesión. Revisa tu bandeja de entrada.');
        }
        _userName = user.displayName ?? user.email?.split('@')[0] ?? 'Usuario';
        _email = user.email;
        _isLoggedIn = true;
        _level = 1;
        await _saveSession();
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      String message = 'Ocurrió un error al iniciar sesión.';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        message = 'El usuario o contraseña son incorrectos.';
      } else if (e.code == 'wrong-password') {
        message = 'La contraseña es incorrecta.';
      } else if (e.code == 'invalid-email') {
        message = 'El formato del correo electrónico es inválido.';
      } else if (e.code == 'user-disabled') {
        message = 'Esta cuenta ha sido deshabilitada.';
      } else if (e.code == 'network-request-failed') {
        message = 'Error de conexión a internet.';
      }
      throw Exception(message);
    } catch (e) {
      // Reenviar excepciones no-FirebaseAuthException (como la de email no verificado)
      rethrow;
    }
  }

  // ─── Recuperar contraseña ─────────────────────────────────────────────────

  Future<void> sendResetEmail(String emailText) async {
    final cleanEmail = emailText.trim();
    if (cleanEmail.isEmpty) {
      throw Exception("El correo electrónico no puede estar vacío.");
    }

    if (cleanEmail == 'bypass@karina.com' || cleanEmail == 'admin@karina.com' || !_useFirebase) {
      await Future.delayed(const Duration(seconds: 1));
      debugPrint("Simulación: Enlace de recuperación enviado a $cleanEmail");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: cleanEmail);
    } on FirebaseAuthException catch (e) {
      String message = 'Error al enviar enlace de recuperación.';
      if (e.code == 'user-not-found') {
        message = 'No existe un usuario con este correo electrónico.';
      } else if (e.code == 'invalid-email') {
        message = 'El formato del correo electrónico es inválido.';
      } else if (e.code == 'network-request-failed') {
        message = 'Error de conexión a internet.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    _isLoggedIn = false;
    _userName = null;
    _email = null;
    _level = 1;
    await _clearSession();
    if (_useFirebase) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        debugPrint("Error signing out from Firebase: $e");
      }
    }
    notifyListeners();
  }

  void setLevel(int newLevel) {
    _level = newLevel;
    _saveSession();
    notifyListeners();
  }
=======
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
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
}