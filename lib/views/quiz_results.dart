import 'package:flutter/material.dart';

class QuizResults extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final String timeSpent;

  const QuizResults({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.timeSpent,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (score / totalQuestions) * 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3), // Light cream/parchment
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '¡Excelente Esfuerzo!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037), // Deep brown
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Aure (Gracias) por practicar Kariña',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF795548),
                ),
              ),
              const SizedBox(height: 40),
              _buildResultCard(
                title: 'Tu Puntaje',
                value: '$score / $totalQuestions',
                icon: Icons.emoji_events,
                color: const Color(0xFFC62828), // Earthy red
              ),
              const SizedBox(height: 16),
              _buildResultCard(
                title: 'Precisión',
                value: '${percentage.toStringAsFixed(0)}%',
                icon: Icons.track_changes,
                color: const Color(0xFF2E7D32), // Earthy green
              ),
              const SizedBox(height: 16),
              _buildResultCard(
                title: 'Tiempo',
                value: timeSpent,
                icon: Icons.timer,
                color: const Color(0xFFEF6C00), // Earthy orange
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D4037),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'CONTINUAR',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
