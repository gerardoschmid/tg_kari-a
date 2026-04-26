import 'package:flutter/material.dart';
import 'package:karina_app/models/flashcard.dart';

class KarinaCard extends StatelessWidget {
  final Flashcard flashcard;
  final VoidCallback? onPlayAudio;
  final VoidCallback? onTap;

  const KarinaCard({
    super.key,
    required this.flashcard,
    this.onPlayAudio,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.green[50],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(flashcard.difficultyLevel),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      flashcard.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (flashcard.audioPath != null && flashcard.audioPath!.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.green),
                      onPressed: () {
                        if (onPlayAudio != null) {
                          onPlayAudio!();
                        } else {
                          _showAudioPlaceholder(context);
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                flashcard.karina,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                flashcard.spanish,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (flashcard.exampleSentence != null && flashcard.exampleSentence!.isNotEmpty) ...[
                const Divider(height: 24),
                const Text(
                  'Ejemplo:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  flashcard.exampleSentence!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.brown,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(int? level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _showAudioPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reproduciendo audio (MP3)...'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
