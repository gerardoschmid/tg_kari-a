import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../providers/game_provider.dart';

class MatchingGameView extends StatefulWidget {
  const MatchingGameView({super.key});

  @override
  State<MatchingGameView> createState() => _MatchingGameViewState();
}

class _MatchingGameViewState extends State<MatchingGameView> {
  late List<String> _spanishWords;
  late List<String> _karinaWords;

  @override
  void initState() {
    super.initState();
    _spanishWords = ['Ustedes', 'Lugar', 'Tú', 'Él/Ella'];
    _karinaWords = ['Mojko', 'Po', 'Amooro', 'Amoññaro'];
    _spanishWords.shuffle();
    _karinaWords.shuffle();
  }

  String? _selectedSpanish;
  String? _selectedKarina;
  final Set<String> _matchedPairs = {};

  void _handleCheck() {
    if (_matchedPairs.length == _spanishWords.length * 2) {
      final gameProvider = context.read<GameProvider>();
      gameProvider.addScore(20);
      gameProvider.addCoins(5);
      gameProvider.unlockLevel(3); // Unlock next level
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Empareja las palabras',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona el significado correcto en Kariña',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildColumn(_spanishWords, true)),
                const SizedBox(width: 16),
                Expanded(child: _buildColumn(_karinaWords, false)),
              ],
            ),
            const SizedBox(height: 32),
            _buildFeedbackSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooter(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final gameProvider = context.watch<GameProvider>();
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context),
      ),
      title: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: _matchedPairs.length / (_spanishWords.length * 2),
          minHeight: 12,
          backgroundColor: AppColors.primary.withOpacity(0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
      actions: [
        const Icon(Icons.favorite, color: AppColors.tertiary),
        const SizedBox(width: 4),
        Text('${gameProvider.lives}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildColumn(List<String> words, bool isSpanish) {
    return Column(
      children: words.map((word) {
        bool isMatched = _matchedPairs.contains(word);
        bool isSelected = (isSpanish ? _selectedSpanish : _selectedKarina) == word;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: isMatched ? null : () => _handleTap(word, isSpanish),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isMatched
                    ? AppColors.primaryContainer.withOpacity(0.1)
                    : isSelected
                        ? AppColors.primaryContainer
                        : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isMatched
                      ? AppColors.primary.withOpacity(0.3)
                      : isSelected
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8)]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      word,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isMatched
                            ? AppColors.primary.withOpacity(0.5)
                            : isSelected
                                ? Colors.white
                                : AppColors.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    isMatched
                        ? Icons.check_circle
                        : isSpanish
                            ? Icons.translate
                            : Icons.volume_up,
                    size: 20,
                    color: isMatched
                        ? AppColors.primary.withOpacity(0.5)
                        : isSelected
                            ? Colors.white
                            : AppColors.outlineVariant,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleTap(String word, bool isSpanish) {
    setState(() {
      if (isSpanish) {
        _selectedSpanish = word;
      } else {
        _selectedKarina = word;
      }

      if (_selectedSpanish != null && _selectedKarina != null) {
        bool isMatch = false;
        final map = {
          'Tú': 'Amooro',
          'Lugar': 'Po',
          'Ustedes': 'Amoññaro',
          'Él/Ella': 'Mojko',
        };

        if (map[_selectedSpanish] == _selectedKarina) {
          isMatch = true;
        }

        if (isMatch) {
          _matchedPairs.add(_selectedSpanish!);
          _matchedPairs.add(_selectedKarina!);
        } else {
          context.read<GameProvider>().subtractLife();
        }

        _selectedSpanish = null;
        _selectedKarina = null;
      }
    });
  }

  Widget _buildFeedbackSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCXyTGwuMrjZ1Tvct0-TtjnHnWIjUIUmHMnAIM8h9NT4li5jGKCmFEyPzJJvyGIQOFkyb40mDmj9V7xEBIKyYLLpAH5JA54MqC8gh7_h4YrkaqZfdOYPOsbDQUELr6M2avaB1a80RO4aeqsN7NGzfOeILWuX2odvtrs44mBXrF-SMbA50CbaEUrLzaHifrLMsQaCloxbx2_jvSxYvaBUxdKpMowv5Bb2DtMI62bfgvHEm7LFAq8k-Tg239QY7ArCdSmSZqOEJlNsEU0'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '¡Excelente progreso!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Estás dominando los pronombres y conectores básicos del Kariña.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    bool allMatched = _matchedPairs.length == _spanishWords.length * 2;
    return Container(
      padding: const EdgeInsets.all(24),
      child: TactileButton(
        onPressed: allMatched ? _handleCheck : () {},
        backgroundColor: allMatched ? AppColors.primary : AppColors.surfaceDim,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              allMatched ? 'CONTINUAR' : 'COMPROBAR',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.trending_flat, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
