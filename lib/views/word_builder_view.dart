import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karina_app/models/flashcard.dart';
import '../utils/app_localizations.dart';

class LetterChip {
  final String id;
  final String character;
  bool isUsed;

  LetterChip({
    required this.id,
    required this.character,
    this.isUsed = false,
  });
}

class WordBuilderView extends StatefulWidget {
  final Flashcard flashcard;
  final VoidCallback onCorrect;
  final VoidCallback onIncorrect;
  final VoidCallback onNext;

  const WordBuilderView({
    super.key,
    required this.flashcard,
    required this.onCorrect,
    required this.onIncorrect,
    required this.onNext,
  });

  @override
  State<WordBuilderView> createState() => _WordBuilderViewState();
}

class _WordBuilderViewState extends State<WordBuilderView> {
  late String targetWord;
  List<LetterChip> allChips = [];
  List<LetterChip> spelledChips = [];
  bool? isCorrectSpelled; // null = pendiente | true = correcto | false = incorrecto
  bool hasChecked = false;

  @override
  void initState() {
    super.initState();
    _setupSpelling();
  }

  @override
  void didUpdateWidget(covariant WordBuilderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flashcard.karina != widget.flashcard.karina) {
      _setupSpelling();
    }
  }

  void _setupSpelling() {
    targetWord = widget.flashcard.karina.trim();
    spelledChips = [];
    isCorrectSpelled = null;
    hasChecked = false;

    final chars = targetWord.split('');
    final List<LetterChip> chips = [];
    for (int i = 0; i < chars.length; i++) {
      final char = chars[i];
      if (char == ' ') continue;
      chips.add(LetterChip(id: '${char}_$i', character: char));
    }
    chips.shuffle();
    setState(() {
      allChips = chips;
    });
  }

  void _tapLetterPool(LetterChip chip) {
    if (hasChecked) return;
    setState(() {
      chip.isUsed = true;
      spelledChips.add(chip);
    });
    HapticFeedback.lightImpact();
  }

  void _tapSpelledLetter(LetterChip chip) {
    if (hasChecked) return;
    setState(() {
      chip.isUsed = false;
      spelledChips.remove(chip);
    });
    HapticFeedback.lightImpact();
  }

  void _checkSpelling(AppLocalizations local) {
    if (hasChecked) return;

    final buffer = StringBuffer();
    int chipIndex = 0;

    for (int i = 0; i < targetWord.length; i++) {
      if (targetWord[i] == ' ') {
        buffer.write(' ');
      } else {
        if (chipIndex < spelledChips.length) {
          buffer.write(spelledChips[chipIndex].character);
          chipIndex++;
        }
      }
    }

    final spelledStr = buffer.toString().trim().toLowerCase();
    final correctStr = targetWord.toLowerCase();

    setState(() {
      hasChecked = true;
      if (spelledStr == correctStr) {
        isCorrectSpelled = true;
        widget.onCorrect();
      } else {
        isCorrectSpelled = false;
        widget.onIncorrect();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final local = AppLocalizations.of(context);

    // ── Paleta dinámica ──────────────────────────────────────────────────────
    final cardBg = isDark ? const Color(0xFF2A1C15) : Colors.white;
    final accentColor =
        isDark ? const Color(0xFFFFD700) : const Color(0xFF4A7C44);
    final hintTextColor =
        isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final wordColor =
        isDark ? const Color(0xFFFFD700) : const Color(0xFF8B5E3C);

    // ── Slots de deletreo ────────────────────────────────────────────────────
    final List<Widget> slots = [];
    int chipIndex = 0;

    for (int i = 0; i < targetWord.length; i++) {
      if (targetWord[i] == ' ') {
        slots.add(const SizedBox(width: 14));
      } else {
        final currentChip =
            chipIndex < spelledChips.length ? spelledChips[chipIndex] : null;

        // Colores del slot según estado
        Color slotBg;
        Color slotBorder;
        Color slotText;

        if (currentChip != null) {
          if (hasChecked) {
            if (isCorrectSpelled == true) {
              slotBg = isDark
                  ? const Color(0xFF1B3A1E)
                  : const Color(0xFFE8F5E9);
              slotBorder = const Color(0xFF4A7C44);
              slotText = isDark
                  ? const Color(0xFF81C784)
                  : const Color(0xFF2E7D32);
            } else {
              slotBg = isDark
                  ? const Color(0xFF3A1A1A)
                  : const Color(0xFFFFEBEE);
              slotBorder = const Color(0xFFC62828);
              slotText = isDark
                  ? const Color(0xFFEF9A9A)
                  : const Color(0xFFC62828);
            }
          } else {
            slotBg = cardBg;
            slotBorder = accentColor.withOpacity(0.6);
            slotText = isDark ? Colors.white : const Color(0xFF5D4037);
          }
        } else {
          slotBg = Colors.transparent;
          slotBorder = isDark
              ? Colors.white.withOpacity(0.15)
              : Colors.brown.withOpacity(0.25);
          slotText = Colors.transparent;
        }

        slots.add(
          GestureDetector(
            onTap: currentChip != null
                ? () => _tapSpelledLetter(currentChip)
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: slotBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: slotBorder,
                  width: currentChip != null ? 2.0 : 1.5,
                ),
                boxShadow: currentChip != null
                    ? [
                        BoxShadow(
                          color: accentColor.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: currentChip != null
                  ? Text(
                      currentChip.character,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: slotText,
                      ),
                    )
                  : null,
            ),
          ),
        );
        chipIndex++;
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Cuerpo del juego ─────────────────────────────────────────────────
        Column(
          children: [
            // Tarjeta de pista / instrucción
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.07)
                      : Colors.brown.withOpacity(0.10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    local.get('spelling_tip'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: hintTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Palabra en español a traducir
                  Text(
                    widget.flashcard.spanish,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: wordColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Slots de escritura ───────────────────────────────────────────
            Wrap(
              alignment: WrapAlignment.center,
              runSpacing: 8,
              children: slots,
            ),
            const SizedBox(height: 30),

            // ── Banco de letras ──────────────────────────────────────────────
            Wrap(
              spacing: 10,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: allChips.map((chip) {
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: chip.isUsed ? 0.20 : 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: chip.isUsed
                          ? (isDark
                              ? const Color(0xFF1E140F)
                              : Colors.grey[100])
                          : cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: chip.isUsed
                            ? Colors.transparent
                            : (isDark
                                ? accentColor.withOpacity(0.35)
                                : Colors.brown.withOpacity(0.25)),
                        width: 2,
                      ),
                      boxShadow: chip.isUsed
                          ? []
                          : [
                              BoxShadow(
                                color:
                                    Colors.black.withOpacity(isDark ? 0.2 : 0.07),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: chip.isUsed || hasChecked
                          ? null
                          : () => _tapLetterPool(chip),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        child: Text(
                          chip.character,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: chip.isUsed
                                ? (isDark ? Colors.white24 : Colors.grey[400])
                                : (isDark ? Colors.white : const Color(0xFF5D4037)),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // ── Sección inferior: feedback + botón ───────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              // Feedback de error
              if (hasChecked && isCorrectSpelled == false)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3A1A1A)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFC62828).withOpacity(0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          color: isDark
                              ? const Color(0xFFEF9A9A)
                              : const Color(0xFFC62828)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFFEF9A9A)
                                  : const Color(0xFFC62828),
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                  text: "${local.get('incorrect')}. Respuesta: "),
                              TextSpan(
                                text: targetWord,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Botón principal
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasChecked
                      ? (isCorrectSpelled == true
                          ? const Color(0xFF4A7C44)
                          : const Color(0xFFC62828))
                      : const Color(0xFF4A7C44),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: isDark
                      ? Colors.white.withOpacity(0.12)
                      : Colors.grey[300],
                  disabledForegroundColor: isDark ? Colors.white30 : Colors.grey,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                ),
                onPressed: (spelledChips.length < allChips.length && !hasChecked)
                    ? null
                    : () {
                        if (!hasChecked) {
                          _checkSpelling(local);
                        } else {
                          widget.onNext();
                        }
                      },
                child: Text(
                  hasChecked
                      ? (isCorrectSpelled == true
                          ? local.get('correct').toUpperCase()
                          : local.get('continue_btn').toUpperCase())
                      : local.get('check').toUpperCase(),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
