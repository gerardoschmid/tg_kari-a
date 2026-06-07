import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    // Falls back to Spanish if LocalProvider is not ready
    return AppLocalizations(Localizations.localeOf(context));
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'es': {
      // ── Login & Auth ──────────────────────────────────────────────────────
      'login_title': 'KARIÑA',
      'email': 'Correo Electrónico',
      'password': 'Contraseña',
      'login_button': 'INICIAR SESIÓN',
      'forgot_password': '¿Olvidaste tu contraseña?',
      'bypass_login': 'Modo Pruebas (Bypass)',
      'reset_title': 'Recuperar Contraseña',
      'reset_instructions': 'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
      'cancel': 'Cancelar',
      'send': 'Enviar',
      'email_val': 'Por favor ingresa un correo válido.',
      'pass_val': 'La contraseña no puede estar vacía.',
      'reset_success': 'Se ha enviado el enlace de restablecimiento. Revisa tu correo.',
      // ── Registro ─────────────────────────────────────────────────────────
      'register': 'Registrarse',
      'register_button': 'CREAR CUENTA',
      'username': 'Nombre de Usuario',
      'username_val': 'El nombre de usuario debe tener al menos 3 caracteres.',
      'confirm_password': 'Confirmar Contraseña',
      'confirm_pass_val': 'Las contraseñas no coinciden.',
      'pass_strength_val': 'La contraseña debe tener al menos 8 caracteres y un número.',
      'verify_email_title': '¡Revisa tu Correo!',
      'verify_email_desc': 'Te enviamos un enlace de verificación a tu correo. Confirma tu cuenta antes de iniciar sesión.',
      'already_have_account': '¿Ya tienes cuenta? Inicia Sesión',
      'no_account': '¿No tienes cuenta? Regístrate',
      // ── Juego & Mapa ─────────────────────────────────────────────────────
      'lives': 'Vidas',
      'level': 'Nivel',
      'xp': 'XP',
      'learning_path': 'Camino de Aprendizaje',
      'logout': 'Cerrar Sesión',
      'unlocked': 'Desbloqueado',
      'locked': 'Bloqueado',
      'completed': 'Completado',
      'tap_to_start': 'Toca para empezar',
      'start_lesson': 'EMPEZAR LECCIÓN',
      'words_in_lesson': 'Palabras en esta lección',
      // ── Quiz ─────────────────────────────────────────────────────────────
      'spelling_game': 'Deletrea la palabra',
      'check': 'COMPROBAR',
      'correct': '¡Correcto!',
      'incorrect': 'Incorrecto',
      'game_over': 'JUEGO TERMINADO',
      'game_over_desc': 'Te has quedado sin vidas. ¡Sigue practicando para mejorar tu Kariña!',
      'return_home': 'VOLVER AL INICIO',
      'quiz_results': 'Resultados del Quiz',
      'score': 'Tu Puntaje',
      'precision': 'Precisión',
      'time': 'Tiempo',
      'continue_btn': 'CONTINUAR',
      'spelling_tip': 'Toca las letras para escribir el nombre en Kariña de:',
      // ── Sistema ──────────────────────────────────────────────────────────
      'update_required': 'Actualización Obligatoria',
      'update_desc': 'Hay una nueva versión disponible con mejoras importantes. Por favor actualiza la aplicación para continuar.',
      'update_btn': 'ACTUALIZAR',
      'loading': 'Cargando...',
      'no_lives_warning': 'No tienes vidas suficientes. Espera a que se regeneren para jugar.',
    },
    'en': {
      // ── Login & Auth ──────────────────────────────────────────────────────
      'login_title': 'KARIÑA',
      'email': 'Email Address',
      'password': 'Password',
      'login_button': 'LOG IN',
      'forgot_password': 'Forgot password?',
      'bypass_login': 'Testing Mode (Bypass)',
      'reset_title': 'Reset Password',
      'reset_instructions': 'Enter your email and we will send you a password reset link.',
      'cancel': 'Cancel',
      'send': 'Send',
      'email_val': 'Please enter a valid email.',
      'pass_val': 'Password cannot be empty.',
      'reset_success': 'Password reset link sent. Check your email.',
      // ── Registro ─────────────────────────────────────────────────────────
      'register': 'Sign Up',
      'register_button': 'CREATE ACCOUNT',
      'username': 'Username',
      'username_val': 'Username must be at least 3 characters.',
      'confirm_password': 'Confirm Password',
      'confirm_pass_val': 'Passwords do not match.',
      'pass_strength_val': 'Password must be at least 8 characters and include a number.',
      'verify_email_title': 'Check Your Email!',
      'verify_email_desc': 'We sent a verification link to your email. Confirm your account before signing in.',
      'already_have_account': 'Already have an account? Log In',
      'no_account': "Don't have an account? Sign Up",
      // ── Juego & Mapa ─────────────────────────────────────────────────────
      'lives': 'Lives',
      'level': 'Level',
      'xp': 'XP',
      'learning_path': 'Learning Path',
      'logout': 'Log Out',
      'unlocked': 'Unlocked',
      'locked': 'Locked',
      'completed': 'Completed',
      'tap_to_start': 'Tap to start',
      'start_lesson': 'START LESSON',
      'words_in_lesson': 'Words in this lesson',
      // ── Quiz ─────────────────────────────────────────────────────────────
      'spelling_game': 'Spell the word',
      'check': 'CHECK',
      'correct': 'Correct!',
      'incorrect': 'Incorrect',
      'game_over': 'GAME OVER',
      'game_over_desc': 'You have run out of lives. Keep practicing to improve your Kariña!',
      'return_home': 'RETURN TO HOME',
      'quiz_results': 'Quiz Results',
      'score': 'Your Score',
      'precision': 'Precision',
      'time': 'Time',
      'continue_btn': 'CONTINUE',
      'spelling_tip': 'Tap the letters to spell the Kariña name for:',
      // ── Sistema ──────────────────────────────────────────────────────────
      'update_required': 'Update Required',
      'update_desc': 'A new version is available with important improvements. Please update the application to continue.',
      'update_btn': 'UPDATE',
      'loading': 'Loading...',
      'no_lives_warning': 'You do not have enough lives. Wait for them to regenerate to play.',
    }
  };

  String get(String key) {
    final langCode = locale.languageCode;
    return _localizedValues[langCode]?[key] ?? _localizedValues['es']?[key] ?? key;
  }
}
