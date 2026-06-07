import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karina_app/models/flashcard.dart';

class KarinaMatchingView extends StatefulWidget {
  final List<Flashcard> flashcards;
  final VoidCallback onCorrect;
  final VoidCallback onIncorrect;
  final VoidCallback onAllMatched;

  const KarinaMatchingView({
    super.key,
    required this.flashcards,
    required this.onCorrect,
    required this.onIncorrect,
    required this.onAllMatched,
  });

  @override
  State<KarinaMatchingView> createState() => _KarinaMatchingViewState();
}

class _KarinaMatchingViewState extends State<KarinaMatchingView> {
  late List<String> spanishOptions;
  late List<String> karinaOptions;

  String? selectedSpanish;
  String? selectedKarina;

  Set<String> matchedSpanish = {};
  Set<String> matchedKarina = {};

  // null: default | true: correcto | false: incorrecto
  Map<String, bool?> spanishStatus = {};
  Map<String, bool?> karinaStatus = {};

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    spanishOptions = widget.flashcards.map((f) => f.spanish).toList()..shuffle();
    karinaOptions = widget.flashcards.map((f) => f.karina).toList()..shuffle();
  }

  void _onSpanishTap(String word) {
    if (matchedSpanish.contains(word)) return;
    setState(() {
      selectedSpanish = word;
      _checkMatch();
    });
  }

  void _onKarinaTap(String word) {
    if (matchedKarina.contains(word)) return;
    setState(() {
      selectedKarina = word;
      _checkMatch();
    });
  }

  void _checkMatch() {
    if (selectedSpanish != null && selectedKarina != null) {
      final flashcard = widget.flashcards
          .firstWhere((f) => f.spanish == selectedSpanish);

      if (flashcard.karina == selectedKarina) {
        setState(() {
          matchedSpanish.add(selectedSpanish!);
          matchedKarina.add(selectedKarina!);
          spanishStatus[selectedSpanish!] = true;
          karinaStatus[selectedKarina!] = true;
          selectedSpanish = null;
          selectedKarina = null;
        });
        widget.onCorrect();
        if (matchedSpanish.length == widget.flashcards.length) {
          widget.onAllMatched();
        }
      } else {
        final wrongSpanish = selectedSpanish!;
        final wrongKarina = selectedKarina!;
        setState(() {
          spanishStatus[wrongSpanish] = false;
          karinaStatus[wrongKarina] = false;
          selectedSpanish = null;
          selectedKarina = null;
        });
        HapticFeedback.vibrate();
        widget.onIncorrect();

        Timer(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              spanishStatus[wrongSpanish] = null;
              karinaStatus[wrongKarina] = null;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (spanishOptions.isEmpty || karinaOptions.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: isDark ? const Color(0xFFFFD700) : const Color(0xFF4A7C44),
        ),
=======
    if (spanishOptions.isEmpty || karinaOptions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Columna español ──────────────────────────────────────────────
        Expanded(
<<<<<<< HEAD
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Español',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ...spanishOptions.map(
                  (word) => _buildItem(word, true, isDark)),
            ],
=======
          child: SingleChildScrollView(
            child: Column(
              children: spanishOptions.map((word) => _buildItem(word, true)).toList(),
            ),
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
          ),
        ),
        const SizedBox(width: 12),
        // ── Columna Kariña ───────────────────────────────────────────────
        Expanded(
<<<<<<< HEAD
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Kariña',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFFFD700)
                        : const Color(0xFF4A7C44),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ...karinaOptions.map(
                  (word) => _buildItem(word, false, isDark)),
            ],
=======
          child: SingleChildScrollView(
            child: Column(
              children: karinaOptions.map((word) => _buildItem(word, false)).toList(),
            ),
>>>>>>> b4628f86043bc618fe2edcc17e759e2bb190964f
          ),
        ),
      ],
    );
  }

  Widget _buildItem(String word, bool isSpanish, bool isDark) {
    final bool isMatched = isSpanish
        ? matchedSpanish.contains(word)
        : matchedKarina.contains(word);
    final bool isSelected = isSpanish
        ? selectedSpanish == word
        : selectedKarina == word;
    final bool? status = isSpanish ? spanishStatus[word] : karinaStatus[word];

    // ── Determinar colores del estado ──────────────────────────────────────
    Color bgColor;
    Color borderColor;
    Color textColor;
    double borderWidth = 2.0;

    if (isMatched || status == true) {
      bgColor = isDark ? const Color(0xFF1B3A1E) : const Color(0xFFE8F5E9);
      borderColor = const Color(0xFF4A7C44);
      textColor = isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
      borderWidth = 2.5;
    } else if (status == false) {
      bgColor = isDark ? const Color(0xFF3A1A1A) : const Color(0xFFFFEBEE);
      borderColor = const Color(0xFFC62828);
      textColor = isDark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828);
      borderWidth = 2.5;
    } else if (isSelected) {
      bgColor = isDark ? const Color(0xFF1E2D20) : const Color(0xFFEEF8EE);
      borderColor = const Color(0xFF4A7C44);
      textColor = isDark ? Colors.white : const Color(0xFF2E7D32);
      borderWidth = 2.5;
    } else {
      bgColor = isDark ? const Color(0xFF2A1C15) : Colors.white;
      borderColor = isDark
          ? Colors.white.withOpacity(0.10)
          : Colors.brown.withOpacity(0.15);
      textColor = isDark ? Colors.white70 : const Color(0xFF5D4037);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: isMatched ? 0.0 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: isSelected || status != null
                ? [
                    BoxShadow(
                      color: borderColor.withOpacity(0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.20 : 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: InkWell(
            onTap: isMatched
                ? null
                : () => isSpanish
                    ? _onSpanishTap(word)
                    : _onKarinaTap(word),
            borderRadius: BorderRadius.circular(20),
            splashColor:
                const Color(0xFF4A7C44).withOpacity(0.15),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      word,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        decoration: isMatched
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: textColor,
                      ),
                    ),
                  ),
                  if (isMatched) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.check_circle_rounded,
                        size: 16, color: const Color(0xFF4A7C44)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
