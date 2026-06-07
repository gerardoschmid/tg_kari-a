import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String? _selectedOption;
  bool _isChecked = false;
  final String _correctAnswer = "B";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Quiz – Pregunta 2/5",
          style: GoogleFonts.poppins(
            color: AppColors.textMain,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              "¿Cómo se dice \"Gracias\" en kariña?",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 40),
            _buildOption("A", "Kareko"),
            _buildOption("B", "Anükü"),
            _buildOption("C", "Wapoto"),
            const Spacer(),
            if (_isChecked)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 10),
                    Text(
                      "Feedback: ¡Correcto! +10 XP",
                      style: GoogleFonts.nunito(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            TactileButton(
              onPressed: () {
                if (_isChecked) {
                  Navigator.pop(context); // Go back after quiz
                } else {
                  setState(() {
                    _isChecked = true;
                  });
                }
              },
              child: Text(
                _isChecked ? "Finalizar" : "Comprobar",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String key, String text) {
    bool isSelected = _selectedOption == key;
    bool isCorrect = _isChecked && key == _correctAnswer;

    return GestureDetector(
      onTap: () {
        if (!_isChecked) {
          setState(() => _selectedOption = key);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isCorrect ? AppColors.success.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCorrect
                ? AppColors.success
                : (isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3)),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected || isCorrect
                      ? (isCorrect ? AppColors.success : AppColors.primary)
                      : Colors.grey,
                  width: 2,
                ),
                color: isSelected || isCorrect
                    ? (isCorrect ? AppColors.success : AppColors.primary)
                    : Colors.transparent,
              ),
              child: isSelected || isCorrect
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 15),
            Text(
              "$key) $text",
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: isSelected || isCorrect
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: AppColors.textMain,
              ),
            ),
            const Spacer(),
            if (isCorrect)
              const Icon(Icons.check_circle, color: AppColors.success),
          ],
        ),
      ),
    );
  }
}
