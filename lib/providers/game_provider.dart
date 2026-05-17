import 'package:flutter/material.dart';

class GameProvider with ChangeNotifier {
  int _lives = 5;
  int _score = 0;
  int _coins = 125;
  int _currentLevel = 1;
  final int _maxLives = 5;

  // Simulation of unlocked levels
  final Set<int> _unlockedLevels = {1};

  int get lives => _lives;
  int get score => _score;
  int get coins => _coins;
  int get currentLevel => _currentLevel;
  int get maxLives => _maxLives;
  bool get isGameOver => _lives <= 0;

  bool isLevelUnlocked(int level) => _unlockedLevels.contains(level);

  void subtractLife() {
    if (_lives > 0) {
      _lives--;
      notifyListeners();
    }
  }

  void addScore(int points) {
    _score += points;
    notifyListeners();
  }

  void addCoins(int amount) {
    _coins += amount;
    notifyListeners();
  }

  void unlockLevel(int level) {
    _unlockedLevels.add(level);
    notifyListeners();
  }

  void resetGame() {
    _lives = _maxLives;
    _score = 0;
    notifyListeners();
  }
}
