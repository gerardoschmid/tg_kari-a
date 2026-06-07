import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import 'quiz.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  int _currentIndex = 0;
  final List<WordData> _words = [
    WordData(karina: "Wei", spanish: "Sol", illustration: "☀️"),
    WordData(karina: "Nuna", spanish: "Luna", illustration: "🌙"),
    WordData(karina: "Shirichu", spanish: "Estrella", illustration: "⭐"),
  ];

  @override
  Widget build(BuildContext context) {
    final word = _words[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Lección 1 – tarjeta ${_currentIndex + 1}/${_words.length}",
          style: GoogleFonts.poppins(
            color: AppColors.textMain,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  word.illustration,
                  style: const TextStyle(fontSize: 80),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              word.karina,
              style: GoogleFonts.notoSerif(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            Text(
              "(${word.spanish})",
              style: GoogleFonts.nunito(
                fontSize: 24,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 30),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.volume_up, color: AppColors.primary),
              label: Text(
                "Reproducir audio",
                style: GoogleFonts.nunito(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton("Anterior", Icons.arrow_back, () {
                  if (_currentIndex > 0) {
                    setState(() => _currentIndex--);
                  }
                }),
                _buildNavButton("Siguiente", Icons.arrow_forward, () {
                  if (_currentIndex < _words.length - 1) {
                    setState(() => _currentIndex++);
                  }
                }, isForward: true),
              ],
            ),
            const SizedBox(height: 30),
            TactileButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizPage(),
                  ),
                );
              },
              backgroundColor: AppColors.secondary,
              bottomBorderColor: const Color(0xFF1B4332),
              child: const Text(
                "Marcar como aprendida",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(String label, IconData icon, VoidCallback onPressed,
      {bool isForward = false}) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        children: [
          if (!isForward) Icon(icon, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 5),
          if (isForward) Icon(icon, color: AppColors.primary),
        ],
      ),
    );
  }
}

class WordData {
  final String karina;
  final String spanish;
  final String illustration;

  WordData({
    required this.karina,
    required this.spanish,
    required this.illustration,
  });
}
