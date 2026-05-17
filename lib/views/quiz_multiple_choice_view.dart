import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../providers/game_provider.dart';

class QuizMultipleChoiceView extends StatefulWidget {
  const QuizMultipleChoiceView({super.key});

  @override
  State<QuizMultipleChoiceView> createState() => _QuizMultipleChoiceViewState();
}

class _QuizMultipleChoiceViewState extends State<QuizMultipleChoiceView>
    with SingleTickerProviderStateMixin {
  final int _currentQuestion = 1;
  final int _totalQuestions = 11;
  int? _selectedOption;
  bool? _isCorrect;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    if (_selectedOption == null) return;

    final gameProvider = context.read<GameProvider>();
    // Correct answer is 'na'nakon' (index 2)
    setState(() {
      if (_selectedOption == 2) {
        _isCorrect = true;
        gameProvider.addScore(10);
        gameProvider.addCoins(2);
      } else {
        _isCorrect = false;
        gameProvider.subtractLife();
        _shakeController.forward(from: 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final double offset = 10 *
                (1 - (0.5 - (_shakeController.value - 0.5).abs()) * 2) *
                (0.5 - _shakeController.value).sign;
            return Transform.translate(
              offset: Offset(_isCorrect == false ? offset : 0, 0),
              child: child,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PREGUNTA $_currentQuestion DE $_totalQuestions',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),
              _buildCharacterQuestion(),
              const SizedBox(height: 48),
              _buildOptions(),
            ],
          ),
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
          value: _currentQuestion / _totalQuestions,
          minHeight: 12,
          backgroundColor: AppColors.primary.withOpacity(0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
      actions: [
        const Icon(Icons.favorite, color: AppColors.tertiary),
        const SizedBox(width: 4),
        Text(
          '${gameProvider.lives}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildCharacterQuestion() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const CircleAvatar(
          radius: 48,
          backgroundColor: AppColors.secondaryContainer,
          backgroundImage: NetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBjZBj1bYkiu3XKFJRdV7b0mSkFYVyXrfPwfS-fGavz_JtVGfk6C5plRh7_hhjIbqh0YmKJ_eNfDrZ8vIoQUx3sm5u4P-mljgTBW4hgM1xq3V28bzMSDzHOKf1pb_hJZXPBZ4cZ_J-I-g_l8TjL77e1AvJL88MIUtC1d9I1fBo0N52ycAJv30EDVPu8UoaNjhwG2fpg1Xg1KUA8Z1cTtBhSlwYpu-2VUETmC02Vo1HIOLb8ivGGF7ljDacpmvrMqOAu_aN9P4uvNX-x'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.volume_up, color: AppColors.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '¿Cómo se dice "Vosotros" en Kariña?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 20,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    final options = ['Amoññaro', 'Po', "na'nakon"];
    return Column(
      children: List.generate(options.length, (index) {
        bool isSelected = _selectedOption == index;
        Color bgColor = Colors.white;
        Color borderColor = AppColors.outlineVariant;
        Color shadowColor = AppColors.outlineVariant;

        if (isSelected) {
          bgColor = AppColors.secondaryContainer.withOpacity(0.2);
          borderColor = AppColors.secondaryContainer;
          shadowColor = AppColors.secondary;
        }

        if (_isCorrect != null && isSelected) {
          if (_isCorrect!) {
            bgColor = Colors.green.shade100;
            borderColor = Colors.green;
            shadowColor = Colors.green.shade900;
          } else {
            bgColor = Colors.red.shade100;
            borderColor = Colors.red;
            shadowColor = Colors.red.shade900;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TactileButton(
            onPressed: _isCorrect == null ? () => setState(() => _selectedOption = index) : () {},
            backgroundColor: bgColor,
            bottomBorderColor: shadowColor,
            height: 72,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? borderColor : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? borderColor : AppColors.outlineVariant,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  options[index],
                  style: AppTheme.karinaTextStyle.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Icon(
                    _isCorrect == null
                        ? Icons.check_circle
                        : (_isCorrect! ? Icons.check_circle : Icons.error),
                    color: borderColor,
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      child: TactileButton(
        onPressed: _isCorrect == true
            ? () => Navigator.pop(context)
            : (_isCorrect == false
                ? () => setState(() {
                      _isCorrect = null;
                      _selectedOption = null;
                    })
                : _checkAnswer),
        backgroundColor: _selectedOption != null
            ? (_isCorrect == null
                ? AppColors.primary
                : (_isCorrect! ? Colors.green : Colors.red))
            : AppColors.surfaceDim,
        bottomBorderColor: _selectedOption != null
            ? (_isCorrect == null
                ? const Color(0xFF094513)
                : (_isCorrect! ? Colors.green.shade900 : Colors.red.shade900))
            : AppColors.outline,
        child: Text(
          _isCorrect == true
              ? 'CONTINUAR'
              : (_isCorrect == false ? 'REINTENTAR' : 'COMPROBAR'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
