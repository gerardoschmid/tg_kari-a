import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:karina_app/models/flashcard.dart';
import 'package:karina_app/utils/db_helper.dart';
import 'package:karina_app/providers/game_provider.dart';
import 'package:karina_app/views/karina_matching_view.dart';
import 'package:karina_app/views/game_over_screen.dart';
import 'package:karina_app/views/quiz_results.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';

enum GameType { multipleChoice, matching }

class QuizPage extends StatefulWidget {
  final String deckTitle;
  final int deckId;

  const QuizPage({
    super.key,
    required this.deckTitle,
    required this.deckId,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with SingleTickerProviderStateMixin {
  late Future<List<Flashcard>> _flashcardsFuture;
  List<Flashcard> _allFlashcards = [];
  int _currentLevelIndex = 0;

  // Estado del quiz
  List<String> _currentOptions = [];
  bool _hasAnswered = false;
  String? _selectedOption;
  bool _showSuccessAnimation = false;

  // Flujo del juego
  GameType? _currentGameType;
  late Stopwatch _stopwatch;
  late AnimationController _shakeController;
  late AudioPlayer _audioPlayer;

  // Para el juego de emparejamiento
  List<Flashcard> _currentMatchingSet = [];

  // BUG FIX: lista de timers activos para cancelarlos en dispose
  final List<Timer> _activeTimers = [];

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _audioPlayer = AudioPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GameProvider>().resetGame();
      }
    });

    _flashcardsFuture = _loadFlashcards();
  }

  @override
  void dispose() {
    // BUG FIX: cancelar todos los timers pendientes antes de desmontar
    for (final t in _activeTimers) {
      t.cancel();
    }
    _shakeController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ─── Carga de datos ────────────────────────────────────────────────────────

  Future<List<Flashcard>> _loadFlashcards() async {
    try {
      final maps = await DBHelper().query(
        'flashcard',
        where: 'deckId = ?',
        whereArgs: [widget.deckId],
      );

      final flashcards = maps.map(Flashcard.fromMap).toList();

      if (flashcards.isEmpty) {
        throw Exception('No se encontraron palabras en este mazo.');
      }

      _allFlashcards = List.from(flashcards)..shuffle();
      _nextLevel();
      return _allFlashcards;
    } catch (e) {
      debugPrint('Error cargando lección: $e');
      rethrow;
    }
  }

  // ─── Lógica de niveles ─────────────────────────────────────────────────────

  void _nextLevel() {
    if (_currentLevelIndex >= _allFlashcards.length) {
      _finishQuiz();
      return;
    }

    // BUG FIX: un único setState atómico en lugar de dos consecutivos
    setState(() {
      _hasAnswered = false;
      _selectedOption = null;
      _showSuccessAnimation = false;

      final int remaining = _allFlashcards.length - _currentLevelIndex;

      if (remaining >= 4 && Random().nextBool()) {
        _currentGameType = GameType.matching;
        final int setSize = min(4, remaining);
        _currentMatchingSet = _allFlashcards.sublist(
          _currentLevelIndex,
          _currentLevelIndex + setSize,
        );
      } else {
        _currentGameType = GameType.multipleChoice;
        _generateOptions();
      }
    });
  }

  void _generateOptions() {
    if (_allFlashcards.isEmpty || _currentLevelIndex >= _allFlashcards.length) {
      return;
    }

    final current = _allFlashcards[_currentLevelIndex];
    final Set<String> optionsSet = {current.karina};

    final List<String> others = _allFlashcards
        .where((f) => f.karina != current.karina)
        .map((f) => f.karina)
        .toList()
      ..shuffle();

    for (final word in others.take(2)) {
      optionsSet.add(word);
    }

    int placeholder = 1;
    while (optionsSet.length < 3) {
      optionsSet.add('Opción ${placeholder++}');
    }

    _currentOptions = optionsSet.toList()..shuffle();
  }

  // ─── Respuesta del usuario ─────────────────────────────────────────────────

  void _checkAnswer(String option) {
    if (_hasAnswered || !mounted) return;

    final gameProvider = context.read<GameProvider>();
    final isCorrect = option == _allFlashcards[_currentLevelIndex].karina;

    setState(() {
      _hasAnswered = true;
      _selectedOption = option;
      if (isCorrect) {
        _showSuccessAnimation = true;
        gameProvider.addScore(1);
        _playSound('sounds/ganar.m4a');
      } else {
        HapticFeedback.vibrate();
        _shakeController.forward(from: 0);
        gameProvider.subtractLife();
        _playSound('sounds/perder.m4a');
        if (gameProvider.isGameOver) {
          // BUG FIX: navegación dentro de un Timer gestionado para evitar
          // pushes después de dispose
          _scheduleAction(
            const Duration(milliseconds: 300),
            _handleGameOver,
          );
        }
      }
    });
  }

  // ─── Emparejamiento ────────────────────────────────────────────────────────

  void _onMatchingComplete() {
    if (!mounted) return; // BUG FIX: guard post-dispose
    final gameProvider = context.read<GameProvider>();
    final setSize = _currentMatchingSet.length;
    gameProvider.addScore(setSize);
    _playSound('sounds/ganar.m4a');

    // BUG FIX: setState único que agrupa el incremento del índice
    setState(() {
      _currentLevelIndex += setSize;
    });

    if (_currentLevelIndex >= _allFlashcards.length) {
      _finishQuiz();
    } else {
      _nextLevel();
    }
  }

  void _onMatchingIncorrect() {
    if (!mounted) return;
    final gameProvider = context.read<GameProvider>();
    gameProvider.subtractLife();
    _playSound('sounds/perder.m4a');
    _shakeController.forward(from: 0);
    if (gameProvider.isGameOver) {
      _scheduleAction(
        const Duration(milliseconds: 300),
        _handleGameOver,
      );
    }
  }

  // ─── Fin del juego ─────────────────────────────────────────────────────────

  void _handleGameOver() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GameOverScreen()),
    );
  }

  void _finishQuiz() {
    if (!mounted) return;
    _stopwatch.stop();
    final duration = _stopwatch.elapsed;
    final timeStr =
        '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

    // BUG FIX: leemos el provider ANTES de llamar pushReplacement
    // para no usar context después de la navegación
    final gameProvider = context.read<GameProvider>();
    final score = gameProvider.score;
    final lives = gameProvider.lives;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizResults(
          score: score,
          totalQuestions: _allFlashcards.length,
          timeSpent: timeStr,
          livesRemaining: lives,
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Programa una acción futura y registra el Timer para poder cancelarlo.
  void _scheduleAction(Duration delay, VoidCallback action) {
    final timer = Timer(delay, action);
    _activeTimers.add(timer);
  }

  Future<void> _playSound(String path) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(path));
    } catch (e) {
      debugPrint('Error al reproducir sonido: $e');
    }
  }

  /// BUG FIX: firstWhere sin orElse crashea si el karina no existe en la lista.
  /// Ahora retorna un color por defecto en ese caso.
  Color _getColorFromName(String karina) {
    final flashcard = _allFlashcards
        .where((f) => f.karina == karina)
        .firstOrNull; // Dart 3 — no lanza excepción

    if (flashcard == null) return Colors.brown;

    final s = flashcard.spanish.toLowerCase();
    if (s.contains('rojo')) return Colors.red;
    if (s.contains('amarillo') || s.contains('dorado')) return Colors.yellow;
    if (s.contains('negro') || s.contains('negra')) return Colors.black;
    if (s.contains('verde')) return Colors.green;
    if (s.contains('azul')) return Colors.blue;
    if (s.contains('blanco')) return Colors.white;
    if (s.contains('oscuro')) return Colors.grey[800]!;
    if (s.contains('multicolor')) return Colors.orange;
    return Colors.brown;
  }

  Widget _buildShakeAnimation({required Widget child}) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final double offset = sin(_shakeController.value * pi * 4) * 10;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: child,
    );
  }

  // ─── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isColorsUnit = widget.deckTitle.toLowerCase().contains('colores');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckTitle),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          Consumer<GameProvider>(
            builder: (context, gp, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    '${gp.lives}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green[50],
      body: Stack(
        children: [
          FutureBuilder<List<Flashcard>>(
            future: _flashcardsFuture,
            builder: (context, snapshot) {
              // ── Cargando ──
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Cargando lección...',
                        style: TextStyle(color: Colors.brown),
                      ),
                    ],
                  ),
                );
              }

              // ── Error ──
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Ocurrió un problema: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.brown),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Volver'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // ── Sin datos ──
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No hay tarjetas disponibles.'),
                );
              }

              // ── Juego de emparejamiento ──
              if (_currentGameType == GameType.matching) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Empareja las palabras',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: _buildShakeAnimation(
                          child: KarinaMatchingView(
                            flashcards: _currentMatchingSet,
                            onCorrect: () {},
                            onIncorrect: _onMatchingIncorrect,
                            onAllMatched: () {
                              // BUG FIX: Timer registrado para cancelación en dispose
                              _scheduleAction(
                                const Duration(milliseconds: 800),
                                _onMatchingComplete,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // ── Selección múltiple ──
              final currentFlashcard = _allFlashcards[_currentLevelIndex];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LinearProgressIndicator(
                      value: (_currentLevelIndex + 1) / _allFlashcards.length,
                      backgroundColor: Colors.green[100],
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Pregunta ${_currentLevelIndex + 1} de ${_allFlashcards.length}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '¿Cómo se dice "${currentFlashcard.spanish}" en Kariña?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildShakeAnimation(
                      child: Column(
                        children: [
                          if (isColorsUnit)
                            _buildColorOptions(currentFlashcard)
                          else
                            ..._buildTextOptions(currentFlashcard),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (_hasAnswered)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          // BUG FIX: setState único, sin doble setState
                          setState(() {
                            _currentLevelIndex++;
                          });
                          _nextLevel();
                        },
                        child: Text(
                          _currentLevelIndex < _allFlashcards.length - 1
                              ? 'Siguiente'
                              : 'Finalizar',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          // ── Animación de éxito (overlay) ──
          if (_showSuccessAnimation)
            IgnorePointer(
              child: Center(
                child: Lottie.asset(
                  'assets/animations/success.json',
                  width: 300,
                  height: 300,
                  repeat: false,
                  renderCache: RenderCache.drawingCommands,
                  frameRate: FrameRate(30),
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.check_circle,
                    size: 100,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Constructores de opciones ─────────────────────────────────────────────

  Widget _buildColorOptions(Flashcard current) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: _currentOptions.map((option) {
        final isCorrect = option == current.karina;
        final isSelected = option == _selectedOption;
        final mainColor = _getColorFromName(option);

        return GestureDetector(
          onTap: () => _checkAnswer(option),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: mainColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? (isCorrect ? Colors.green : Colors.red)
                    : Colors.grey[300]!,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _hasAnswered && isCorrect
                ? const Icon(Icons.check, color: Colors.white, size: 50)
                : (_hasAnswered && isSelected && !isCorrect
                    ? const Icon(Icons.close, color: Colors.white, size: 50)
                    : Center(
                        child: Text(
                          option,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: mainColor.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildTextOptions(Flashcard current) {
    return _currentOptions.map((option) {
      final isCorrect = option == current.karina;
      final isSelected = option == _selectedOption;

      Color? btnColor = Colors.white;
      if (_hasAnswered) {
        if (isCorrect) {
          btnColor = Colors.green[100];
        } else if (isSelected) {
          btnColor = Colors.red[100];
        }
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            foregroundColor: Colors.brown,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: isSelected ? Colors.brown : Colors.grey[300]!,
                width: 2,
              ),
            ),
          ),
          onPressed: _hasAnswered ? null : () => _checkAnswer(option),
          child: Text(option, style: const TextStyle(fontSize: 18)),
        ),
      );
    }).toList();
  }
}
