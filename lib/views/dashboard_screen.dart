import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import 'vocabulary_screen.dart';
import 'quiz_multiple_choice_view.dart';
import 'matching_game_view.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const LearningPathView(),
    const VocabularyScreen(),
    const Center(child: Text('Perfil (Próximamente)')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _selectedIndex == 0 ? _buildFAB() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final gameProvider = context.watch<GameProvider>();
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        'Kariña Learning',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.primary,
            ),
      ),
      actions: [
        Row(
          children: [
            const Icon(Icons.stars, color: Color(0xFFFFD700)),
            const SizedBox(width: 4),
            Text(
              '${gameProvider.coins}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.favorite, color: AppColors.tertiary),
            const SizedBox(width: 4),
            Text(
              '${gameProvider.lives}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDUpnVVW-IzwNNMqpyVtGhZUlnot1DXc8EY1Meu0Emgfsq5_uFnSXE1XATVyyC2ISddxkAUfweYwf25dLBO3HevqzIEQO83yokuYgJbVLMUfRA64VA_q8Qi0XKGlz0PbE9qIaJfSlIO3nAQNwj-igyG8VA4NkP-CXgLrZ9nz9YHW2Wap2OtAWsRqjVT7sICDMCwG6ODs_0FxvZR1sGJbKk5kEGnSik90g6rQ2DtjAKntwry1V8Wm86_D9ibFIuNFnbgSZmyCw3jppFz'),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.map, 'Ruta'),
          _buildNavItem(1, Icons.menu_book, 'Vocabulario'),
          _buildNavItem(2, Icons.person, 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  bottom: BorderSide(color: AppColors.primary, width: 4),
                ),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return TactileButton(
      backgroundColor: AppColors.secondary,
      bottomBorderColor: const Color(0xFF544600),
      onPressed: () {},
      height: 56,
      padding: 0,
      child: const SizedBox(
        width: 56,
        child: Icon(Icons.auto_awesome, color: Colors.white),
      ),
    );
  }
}

class LearningPathView extends StatelessWidget {
  const LearningPathView({super.key});

  @override
  Widget build(BuildContext context) {
    final levels = [
      LevelData(
          id: 1,
          title: 'Pronombres y Palabras Básicas',
          type: LevelType.quiz),
      LevelData(id: 2, title: 'Colores y Tamaños', type: LevelType.matching),
      LevelData(id: 3, title: 'La Familia', type: LevelType.quiz),
      LevelData(id: 4, title: 'Naturaleza', type: LevelType.matching),
    ];

    return Stack(
      children: [
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 1200),
          painter: PathPainter(),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: levels.map((level) {
              double xOffset = 0;
              if (level.id == 2) xOffset = 80;
              if (level.id == 3) xOffset = -80;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Transform.translate(
                    offset: Offset(xOffset, 0),
                    child: LevelNode(level: level),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => level.type == LevelType.quiz
                          ? const QuizMultipleChoiceView()
                          : const MatchingGameView(),
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

class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = 80
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = AppColors.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width / 2, 0);

    // Use consistent spacing that matches LevelNodes
    const double verticalSpacing = 220; // verticalPadding + NodeHeight approx
    final offsets = [0.0, 80.0, -80.0, 0.0];

    for (int i = 0; i < offsets.length; i++) {
      double targetY = 140 + i * verticalSpacing;
      double targetX = size.width / 2 + offsets[i];
      if (i == 0) {
        path.lineTo(targetX, targetY);
      } else {
        double prevY = 140 + (i - 1) * verticalSpacing;
        double prevX = size.width / 2 + offsets[i - 1];
        path.cubicTo(
          prevX,
          prevY + verticalSpacing / 2,
          targetX,
          targetY - verticalSpacing / 2,
          targetX,
          targetY,
        );
      }
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, dashPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
