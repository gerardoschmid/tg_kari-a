import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import 'vocabulary_screen.dart';
import '../widgets/learning_path/path_painter.dart';
import '../widgets/learning_path/level_node.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // OPTIMIZADO [DEB-001]: Separación de responsabilidades de las páginas
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
    // OPTIMIZADO: Definición de niveles desacoplada de la lógica de pintado
    final List<LevelData> levels = [
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
