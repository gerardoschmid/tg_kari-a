import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
<<<<<<< HEAD
  DateTime? _lastLifeLostTime;
  Timer? _regenerationTimer;

  bool _disposed = false;

  int get lives {
    checkAndRegenerateLives();
    return _lives;
  }
  int get score => _score;
  int get xp => _xp;
  int get maxLives => _maxLives;
  bool get isGameOver => _lives <= 0;
  DateTime? get lastLifeLostTime => _lastLifeLostTime;

  GameProvider() {
    _loadFromPrefs().then((_) {
      checkAndRegenerateLives();
      _startRegenerationTimer();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _regenerationTimer?.cancel();
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  void _startRegenerationTimer() {
    _regenerationTimer?.cancel();
    _regenerationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      checkAndRegenerateLives();
    });
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lives = prefs.getInt('lives_count') ?? _maxLives;
      _xp = prefs.getInt('user_xp') ?? 0;
      final lostTimeStr = prefs.getString('last_life_lost_time');
      if (lostTimeStr != null) {
        _lastLifeLostTime = DateTime.tryParse(lostTimeStr);
      }
      _safeNotify();
    } catch (e) {
      debugPrint("Error loading game stats: $e");
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lives_count', _lives);
      await prefs.setInt('user_xp', _xp);
      if (_lastLifeLostTime != null) {
        await prefs.setString('last_life_lost_time', _lastLifeLostTime!.toIso8601String());
      } else {
        await prefs.remove('last_life_lost_time');
      }
    } catch (e) {
      debugPrint("Error saving game stats: $e");
    }
  }

  Future<void> checkAndRegenerateLives() async {
    if (_lives >= _maxLives) {
      if (_lastLifeLostTime != null) {
        _lastLifeLostTime = null;
        await _saveToPrefs();
      }
      return;
    }

    if (_lastLifeLostTime == null) {
      _lastLifeLostTime = DateTime.now();
      await _saveToPrefs();
      return;
    }

    final now = DateTime.now();
    final difference = now.difference(_lastLifeLostTime!);
    const minutesPerLife = 30; // 1 vida cada 30 minutos
    final regenerated = difference.inMinutes ~/ minutesPerLife;

    if (regenerated > 0) {
      _lives = _lives + regenerated;
      if (_lives >= _maxLives) {
        _lives = _maxLives;
        _lastLifeLostTime = null;
      } else {
        _lastLifeLostTime = _lastLifeLostTime!.add(Duration(minutes: regenerated * minutesPerLife));
      }
      await _saveToPrefs();
      _safeNotify();
    }
  }

  Future<void> subtractLife() async {
    if (_lives > 0) {
      _lives--;
      if (_lives < _maxLives && _lastLifeLostTime == null) {
        _lastLifeLostTime = DateTime.now();
      }
      await _saveToPrefs();
      _safeNotify();
    }
  }

  Future<void> addScore(int points) async {
    _score += points;
    _xp += points * 10; // 10 XP por punto
    await _saveToPrefs();
    _safeNotify();
  }

  Future<void> addLifeDirectly() async {
    if (_lives < _maxLives) {
      _lives++;
      if (_lives >= _maxLives) {
        _lastLifeLostTime = null;
      }
      await _saveToPrefs();
      _safeNotify();
    }
  }

  Future<void> resetGame() async {
    _score = 0;
    _safeNotify();
  }

  Future<void> resetLives() async {
    _lives = _maxLives;
    _lastLifeLostTime = null;
    await _saveToPrefs();
    _safeNotify();
  }

  Future<void> resetXp() async {
    _xp = 0;
    await _saveToPrefs();
=======

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
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
    _safeNotify();
  }
}
