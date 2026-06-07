import 'package:flutter/material.dart';

/// Resultado normalizado que cualquier minijuego puede emitir.
/// Preparado para la arquitectura Strategy (Pilar 3).
sealed class GameResult {
  const GameResult();
}

class GameCorrect extends GameResult {
  final int xpEarned;
  const GameCorrect({this.xpEarned = 1});
}

class GameIncorrect extends GameResult {
  final String? correctAnswer;
  const GameIncorrect({this.correctAnswer});
}

class GameSkipped extends GameResult {
  const GameSkipped();
}

// ---------------------------------------------------------------------------

class GameProvider with ChangeNotifier {
  int _lives = 5;
  int _score = 0;
  int _xp = 0;
  final int _maxLives = 5;

  // BUG FIX: flag para evitar notifyListeners() después de dispose
  bool _disposed = false;

  int get lives => _lives;
  int get score => _score;
  int get xp => _xp;
  int get maxLives => _maxLives;
  bool get isGameOver => _lives <= 0;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  void subtractLife() {
    if (_lives > 0) {
      _lives--;
      _safeNotify();
    }
  }

  void addScore(int points) {
    _score += points;
    _xp += points * 10; // 10 XP por punto — escalable
    _safeNotify();
  }

  void resetGame() {
    _lives = _maxLives;
    _score = 0;
    // Nota: _xp es acumulativo entre sesiones (no se resetea aquí).
    // Para resetear XP total, llamar resetXp() explícitamente.
    _safeNotify();
  }

  void resetXp() {
    _xp = 0;
    _safeNotify();
  }
}
