import 'package:flutter/material.dart';

class GameProvider with ChangeNotifier {
  int _lives = 5;
  final int maxLives = 5;

  int get lives => _lives;

  void subtractLife() {
    if (_lives > 0) {
      _lives--;
      notifyListeners();
    }
  }

  void resetLives() {
    _lives = maxLives;
    notifyListeners();
  }

  bool get isGameOver => _lives <= 0;
}
