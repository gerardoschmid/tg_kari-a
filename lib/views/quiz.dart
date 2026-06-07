import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:karina_app/models/flashcard.dart';
import 'package:karina_app/utils/db_helper.dart';
import 'package:karina_app/providers/auth_provider.dart';
import 'package:karina_app/providers/deck_provider.dart';
import 'package:karina_app/providers/game_provider.dart';
import 'package:karina_app/views/karina_matching_view.dart';
import 'package:karina_app/views/word_builder_view.dart';
import 'package:karina_app/views/game_over_screen.dart';
import 'package:karina_app/views/quiz_results.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';

enum GameType { multipleChoice, matching, wordBuilder }

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

<<<<<<< HEAD
  // Lista de timers activos para cancelarlos en dispose
=======
  // BUG FIX: lista de timers activos para cancelarlos en dispose
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
  final List<Timer> _activeTimers = [];

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
<<<<<<< HEAD

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _audioPlayer = AudioPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GameProvider>().resetGame();
=======

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
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
      }
    });

    _flashcardsFuture = _loadFlashcards();
  }

<<<<<<< HEAD
  @override
  void dispose() {
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

    setState(() {
      _hasAnswered = false;
      _selectedOption = null;
      _showSuccessAnimation = false;

      final int remaining = _allFlashcards.length - _currentLevelIndex;

      if (remaining >= 4) {
        final double rand = Random().nextDouble();
        if (rand < 0.33) {
          _currentGameType = GameType.matching;
          final int setSize = min(4, remaining);
          _currentMatchingSet = _allFlashcards.sublist(
            _currentLevelIndex,
            _currentLevelIndex + setSize,
          );
        } else if (rand < 0.66) {
          _currentGameType = GameType.wordBuilder;
        } else {
          _currentGameType = GameType.multipleChoice;
          _generateOptions();
        }
      } else {
        _currentGameType =
            Random().nextBool() ? GameType.wordBuilder : GameType.multipleChoice;
        if (_currentGameType == GameType.multipleChoice) {
          _generateOptions();
=======
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
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
        }
      }
    });
  }

<<<<<<< HEAD
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
          _scheduleAction(const Duration(milliseconds: 300), _handleGameOver);
        }
      }
    });
  }
=======
  // ─── Emparejamiento ────────────────────────────────────────────────────────
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f

  // ─── Emparejamiento ────────────────────────────────────────────────────────

  void _onMatchingComplete() {
<<<<<<< HEAD
    if (!mounted) return;
=======
    if (!mounted) return; // BUG FIX: guard post-dispose
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
    final gameProvider = context.read<GameProvider>();
    final setSize = _currentMatchingSet.length;
    gameProvider.addScore(setSize);
    _playSound('sounds/ganar.m4a');
<<<<<<< HEAD
    setState(() {
      _currentLevelIndex += setSize;
    });
=======

    // BUG FIX: setState único que agrupa el incremento del índice
    setState(() {
      _currentLevelIndex += setSize;
    });

>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
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
<<<<<<< HEAD
      _scheduleAction(const Duration(milliseconds: 300), _handleGameOver);
=======
      _scheduleAction(
        const Duration(milliseconds: 300),
        _handleGameOver,
      );
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
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

<<<<<<< HEAD
=======
    // BUG FIX: leemos el provider ANTES de llamar pushReplacement
    // para no usar context después de la navegación
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
    final gameProvider = context.read<GameProvider>();
    final score = gameProvider.score;
    final lives = gameProvider.lives;

<<<<<<< HEAD
    final deckProvider = context.read<DeckProvider>();
    final authProvider = context.read<AuthProvider>();
    final deckIndex =
        deckProvider.decks.indexWhere((d) => d.id == widget.deckId);
    if (deckIndex != -1) {
      if (deckIndex + 1 == authProvider.level) {
        authProvider.setLevel(authProvider.level + 1);
      }
    }

=======
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
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

<<<<<<< HEAD
=======
  /// Programa una acción futura y registra el Timer para poder cancelarlo.
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
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

<<<<<<< HEAD
  Color _getColorFromName(String karina) {
    final flashcard = _allFlashcards.where((f) => f.karina == karina).firstOrNull;
    if (flashcard == null) return Colors.brown;
=======
  /// BUG FIX: firstWhere sin orElse crashea si el karina no existe en la lista.
  /// Ahora retorna un color por defecto en ese caso.
  Color _getColorFromName(String karina) {
    final flashcard = _allFlashcards
        .where((f) => f.karina == karina)
        .firstOrNull; // Dart 3 — no lanza excepción

    if (flashcard == null) return Colors.brown;

>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
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

<<<<<<< HEAD
  // ─── UI Principal ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isColorsUnit =
        widget.deckTitle.toLowerCase().contains('colores');

    // Colores del tema del quiz
    final bgColor = isDark
        ? const Color(0xFF1C110C)
        : const Color(0xFFF5E6D3);
    final cardColor = isDark
        ? const Color(0xFF2A1C15)
        : Colors.white;
    final accentColor = isDark
        ? const Color(0xFFFFD700)
        : const Color(0xFF4A7C44);
    final textColor = isDark ? Colors.white : const Color(0xFF5D4037);
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
=======
  // ─── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isColorsUnit = widget.deckTitle.toLowerCase().contains('colores');
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF2A1C15) : const Color(0xFF4A7C44),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.deckTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          Consumer<GameProvider>(
            builder: (context, gp, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Color(0xFFFF5252)),
                  const SizedBox(width: 4),
                  Text(
                    '${gp.lives}',
                    style: const TextStyle(
<<<<<<< HEAD
                        fontSize: 18, fontWeight: FontWeight.bold),
=======
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
<<<<<<< HEAD
=======
      backgroundColor: Colors.green[50],
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
      body: Stack(
        children: [
          FutureBuilder<List<Flashcard>>(
            future: _flashcardsFuture,
            builder: (context, snapshot) {
<<<<<<< HEAD
              // ── Cargando ──────────────────────────────────────────────────
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: accentColor),
                      const SizedBox(height: 16),
                      Text(
                        'Cargando lección...',
                        style: TextStyle(color: subTextColor, fontSize: 15),
=======
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
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
                      ),
                    ],
                  ),
                );
              }
<<<<<<< HEAD

              // ── Error ─────────────────────────────────────────────────────
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64,
                            color: isDark
                                ? Colors.redAccent
                                : Colors.red[700]),
                        const SizedBox(height: 16),
                        Text(
                          'Ocurrió un problema: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 15, color: textColor),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Volver'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
=======

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
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
                  ),
                );
              }

<<<<<<< HEAD
              // ── Sin datos ─────────────────────────────────────────────────
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No hay tarjetas disponibles.',
                    style: TextStyle(color: textColor),
                  ),
                );
              }

              // ── Emparejamiento ────────────────────────────────────────────
              if (_currentGameType == GameType.matching) {
                return _buildMatchingLayout(
                    isDark, accentColor, textColor, cardColor);
              }

              // ── Deletreo ──────────────────────────────────────────────────
              if (_currentGameType == GameType.wordBuilder) {
                return _buildWordBuilderLayout(isDark, cardColor);
              }

              // ── Selección Múltiple ────────────────────────────────────────
              return _buildMultipleChoiceLayout(
                  isDark, isColorsUnit, accentColor, textColor,
                  subTextColor, cardColor);
            },
          ),

          // ── Animación de éxito (overlay) ──────────────────────────────────
=======
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
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
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
<<<<<<< HEAD
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.check_circle_rounded,
                    size: 100,
                    color: const Color(0xFF4A7C44).withOpacity(0.9),
=======
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.check_circle,
                    size: 100,
                    color: Colors.green,
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  // ─── Layout: Emparejamiento ────────────────────────────────────────────────

  Widget _buildMatchingLayout(
    bool isDark,
    Color accentColor,
    Color textColor,
    Color cardColor,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        children: [
          // Tarjeta de instrucción
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.brown.withOpacity(0.08),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.compare_arrows_rounded,
                    color: accentColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Empareja las palabras',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildShakeAnimation(
              child: KarinaMatchingView(
                flashcards: _currentMatchingSet,
                onCorrect: () {},
                onIncorrect: _onMatchingIncorrect,
                onAllMatched: () {
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

  // ─── Layout: Deletreo ──────────────────────────────────────────────────────

  Widget _buildWordBuilderLayout(bool isDark, Color cardColor) {
    final currentFlashcard = _allFlashcards[_currentLevelIndex];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _buildShakeAnimation(
        child: WordBuilderView(
          flashcard: currentFlashcard,
          onCorrect: () {
            setState(() {
              _hasAnswered = true;
              _selectedOption = currentFlashcard.karina;
              _showSuccessAnimation = true;
            });
            context.read<GameProvider>().addScore(1);
            _playSound('sounds/ganar.m4a');
          },
          onIncorrect: () {
            setState(() {
              _hasAnswered = true;
              _selectedOption = '';
            });
            HapticFeedback.vibrate();
            _shakeController.forward(from: 0);
            final gameProvider = context.read<GameProvider>();
            gameProvider.subtractLife();
            _playSound('sounds/perder.m4a');
            if (gameProvider.isGameOver) {
              _scheduleAction(
                  const Duration(milliseconds: 1500), _handleGameOver);
            }
          },
          onNext: () {
            setState(() {
              _currentLevelIndex++;
            });
            _nextLevel();
          },
        ),
      ),
    );
  }

  // ─── Layout: Selección Múltiple ───────────────────────────────────────────

  Widget _buildMultipleChoiceLayout(
    bool isDark,
    bool isColorsUnit,
    Color accentColor,
    Color textColor,
    Color subTextColor,
    Color cardColor,
  ) {
    final currentFlashcard = _allFlashcards[_currentLevelIndex];
    final progress = (_currentLevelIndex + 1) / _allFlashcards.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Barra de progreso estilizada ─────────────────────────────────
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.brown.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FractionallySizedBox(
              widthFactor: progress,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF4A7C44), const Color(0xFFFFD700)]
                        : [const Color(0xFF4A7C44), const Color(0xFF6BB56A)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A7C44).withOpacity(0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Indicador numérico de progreso
          Text(
            'Pregunta ${_currentLevelIndex + 1} de ${_allFlashcards.length}',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: subTextColor, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 22),

          // ── Tarjeta de la pregunta (glassmorphism) ───────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.brown.withOpacity(0.10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.30 : 0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '¿Cómo se dice en Kariña?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: subTextColor,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '"${currentFlashcard.spanish}"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Opciones de respuesta ────────────────────────────────────────
          _buildShakeAnimation(
            child: Column(
              children: [
                if (isColorsUnit)
                  _buildColorOptions(currentFlashcard, isDark)
                else
                  ..._buildTextOptions(currentFlashcard, isDark, accentColor),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Botón Siguiente / Finalizar ──────────────────────────────────
          if (_hasAnswered)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 58),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                elevation: 4,
                shadowColor: accentColor.withOpacity(0.4),
              ),
              onPressed: () {
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Opciones de Color ─────────────────────────────────────────────────────

  Widget _buildColorOptions(Flashcard current, bool isDark) {
=======
  // ─── Constructores de opciones ─────────────────────────────────────────────

  Widget _buildColorOptions(Flashcard current) {
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: _currentOptions.map((option) {
        final isCorrect = option == current.karina;
        final isSelected = option == _selectedOption;
        final mainColor = _getColorFromName(option);

<<<<<<< HEAD
        Color borderColor = Colors.transparent;
        if (_hasAnswered && isCorrect) borderColor = const Color(0xFF4A7C44);
        if (_hasAnswered && isSelected && !isCorrect)
          borderColor = const Color(0xFFC62828);

        return GestureDetector(
          onTap: () => _checkAnswer(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
=======
        return GestureDetector(
          onTap: () => _checkAnswer(option),
          child: Container(
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: mainColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
<<<<<<< HEAD
                    ? (isCorrect
                        ? const Color(0xFF4A7C44)
                        : const Color(0xFFC62828))
                    : (isDark
                        ? Colors.white.withOpacity(0.15)
                        : Colors.grey[300]!),
                width: isSelected ? 4.5 : 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: mainColor.withOpacity(0.35),
                  blurRadius: 10,
=======
                    ? (isCorrect ? Colors.green : Colors.red)
                    : Colors.grey[300]!,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _hasAnswered && isCorrect
<<<<<<< HEAD
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 48)
                : (_hasAnswered && isSelected && !isCorrect
                    ? const Icon(Icons.close_rounded,
                        color: Colors.white, size: 48)
=======
                ? const Icon(Icons.check, color: Colors.white, size: 50)
                : (_hasAnswered && isSelected && !isCorrect
                    ? const Icon(Icons.close, color: Colors.white, size: 50)
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
                    : Center(
                        child: Text(
                          option,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: mainColor.computeLuminance() > 0.5
<<<<<<< HEAD
                                ? Colors.black87
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
=======
                                ? Colors.black
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
                          ),
                        ),
                      )),
          ),
        );
      }).toList(),
    );
  }

<<<<<<< HEAD
  // ─── Opciones de Texto (estilo Duolingo) ──────────────────────────────────

  List<Widget> _buildTextOptions(
    Flashcard current,
    bool isDark,
    Color accentColor,
  ) {
=======
  List<Widget> _buildTextOptions(Flashcard current) {
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
    return _currentOptions.map((option) {
      final isCorrect = option == current.karina;
      final isSelected = option == _selectedOption;

<<<<<<< HEAD
      // Determinar colores según estado
      Color bgColor;
      Color borderColor;
      Color textColor;

      if (_hasAnswered && isCorrect) {
        bgColor = isDark
            ? const Color(0xFF1B3A1E)
            : const Color(0xFFE8F5E9);
        borderColor = const Color(0xFF4A7C44);
        textColor = isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
      } else if (_hasAnswered && isSelected && !isCorrect) {
        bgColor = isDark
            ? const Color(0xFF3A1A1A)
            : const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFC62828);
        textColor = isDark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828);
      } else if (isSelected) {
        bgColor = isDark
            ? const Color(0xFF1E2D1E)
            : const Color(0xFFE8F5E9);
        borderColor = accentColor;
        textColor = accentColor;
      } else {
        bgColor = isDark ? const Color(0xFF2A1C15) : Colors.white;
        borderColor = isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.brown.withOpacity(0.15);
        textColor = isDark ? Colors.white : const Color(0xFF5D4037);
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _hasAnswered ? null : () => _checkAnswer(option),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (_hasAnswered && isCorrect)
                    Icon(Icons.check_circle_rounded,
                        color: const Color(0xFF4A7C44), size: 24)
                  else if (_hasAnswered && isSelected && !isCorrect)
                    Icon(Icons.cancel_rounded,
                        color: const Color(0xFFC62828), size: 24),
                ],
              ),
            ),
          ),
=======
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
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
        ),
      );
    }).toList();
  }
}
