import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karina_app/models/flashcard.dart';
import 'dart:async';

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

  Map<String, bool?> spanishStatus = {}; // null: default, true: correct, false: incorrect
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
      final flashcard = widget.flashcards.firstWhere((f) => f.spanish == selectedSpanish);

      if (flashcard.karina == selectedKarina) {
        // Correct match
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
        // Incorrect match
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

        Timer(const Duration(milliseconds: 500), () {
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
    if (spanishOptions.isEmpty || karinaOptions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: spanishOptions.map((word) => _buildItem(word, true)).toList(),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: karinaOptions.map((word) => _buildItem(word, false)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(String word, bool isSpanish) {
    bool isMatched = isSpanish ? matchedSpanish.contains(word) : matchedKarina.contains(word);
    bool isSelected = isSpanish ? selectedSpanish == word : selectedKarina == word;
    bool? status = isSpanish ? spanishStatus[word] : karinaStatus[word];

    Color bgColor = Colors.white;
    if (isMatched || status == true) {
      bgColor = Colors.green[100]!;
    } else if (status == false) {
      bgColor = Colors.red[100]!;
    } else if (isSelected) {
      bgColor = Colors.blue[50]!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: isMatched ? 0.0 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: InkWell(
            onTap: isMatched ? null : () => isSpanish ? _onSpanishTap(word) : _onKarinaTap(word),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(
                  color: isSelected ? Colors.blue : (isMatched ? Colors.green : Colors.grey[300]!),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  word,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isMatched ? Colors.green[700] : Colors.brown[700],
                    decoration: isMatched ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
