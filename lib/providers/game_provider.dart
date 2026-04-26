import 'package:flutter/material.dart';

class GameProvider with ChangeNotifier {
  int _lives = 5;
  int _score = 0;
  final int _maxLives = 5;

  int get lives => _lives;
  int get score => _score;
  int get maxLives => _maxLives;
  bool get isGameOver => _lives <= 0;

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

  void resetGame() {
    _lives = _maxLives;
    _score = 0;
    notifyListeners();
  }
}
