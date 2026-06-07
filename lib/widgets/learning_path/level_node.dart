import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../utils/app_theme.dart';
import '../../views/quiz.dart';

enum LevelType { quiz, matching }

class LevelData {
  final int id;
  final String title;
  final LevelType type;

  LevelData({required this.id, required this.title, required this.type});
}

class LevelNode extends StatelessWidget {
  final LevelData level;

  const LevelNode({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    bool isUnlocked = gameProvider.isLevelUnlocked(level.id);

    return Column(
      children: [
        if (level.id == 1 && isUnlocked) ...[
          const FloatingCharacter(),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: isUnlocked
              ? () {
                  // OPTIMIZADO: Redirección a la vista dinámica QuizPage
                  int targetDeckId = level.id;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPage(
                        deckTitle: level.title,
                        deckId: targetDeckId,
                      ),
                    ),
                  );
                }
              : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: isUnlocked ? AppColors.primaryContainer : AppColors.outlineVariant,
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
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked ? AppColors.primary : AppColors.surfaceDim,
                  border: Border(
                    bottom: isUnlocked
                        ? const BorderSide(color: Color(0xFF094513), width: 8)
                        : const BorderSide(color: AppColors.outline, width: 8),
                  ),
                ),
                child: Icon(
                  isUnlocked ? Icons.play_arrow : Icons.lock,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 160,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUnlocked ? Colors.white : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              bottom: BorderSide(
                color: isUnlocked ? AppColors.outlineVariant : AppColors.outlineVariant.withOpacity(0.5),
                width: 4,
              ),
            ),
            boxShadow: [
              if (isUnlocked)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'NIVEL ${level.id}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isUnlocked ? AppColors.primary : AppColors.outline,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                level.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FloatingCharacter extends StatefulWidget {
  const FloatingCharacter({super.key});

  @override
  State<FloatingCharacter> createState() => _FloatingCharacterState();
}

class _FloatingCharacterState extends State<FloatingCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -10 * _controller.value),
          child: child,
        );
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuB_8gLPnDtq8ibEVL4FRKt7vgFdD_2l4MfUcTHOv0K19HHSRVs_jFdiWyfSx8ff0KzI6YzLMV1MLDG7l8rTkTrdscOgwP_L69fzudDpyfn7IdoN4c2WauMVlQZRwwx6rwcvBOwHPD-BK59KVaVAEAtV0GtXEINjSwfaaX_tyGIoNtkJUheLvXb9NvR2uciCCrWK9YHDj4-CGyFPUYfSAWpDpyoiM1iHV-P9QqRs70NEITjlB5QJeNwA1u242u5aDnlBhBDqdUMKnDBn'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
