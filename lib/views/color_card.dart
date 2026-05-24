import 'package:flutter/material.dart';
import 'package:karina_app/models/flashcard.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class ColorCard extends StatefulWidget {
  final Flashcard flashcard;
  final VoidCallback? onTap;

  const ColorCard({
    super.key,
    required this.flashcard,
    this.onTap,
  });

  @override
  State<ColorCard> createState() => _ColorCardState();
}

class _ColorCardState extends State<ColorCard> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    // OPTIMIZADO [MEM-001]: Asegura liberación de recursos
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    final audioPath = widget.flashcard.audioPath;
    if (audioPath == null || audioPath.isEmpty) return;

    try {
      // OPTIMIZADO [ERR-001]: Manejo defensivo mejorado para recursos de audio
      // Se verifica la existencia del asset antes de intentar reproducirlo
      await rootBundle.load(audioPath);

      final assetPath = audioPath.replaceFirst('assets/', '');
      await _audioPlayer.stop(); // Detiene cualquier audio previo
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error al reproducir audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo cargar el audio: ${widget.flashcard.karina}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Color _getColorFromName(String spanish) {
    final s = spanish.toLowerCase();
    if (s.contains('rojo')) return Colors.red;
    if (s.contains('amarillo') || s.contains('dorado')) return Colors.yellow;
    if (s.contains('negro') || s.contains('negra')) return Colors.black;
    if (s.contains('verde')) return Colors.green;
    if (s.contains('azul')) return Colors.blue;
    if (s.contains('blanco')) return Colors.white;
    if (s.contains('oscuro')) return Colors.grey[800] ?? Colors.grey;
    if (s.contains('multicolor')) return Colors.orange;
    return Colors.brown;
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = _getColorFromName(widget.flashcard.spanish);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: BorderSide(color: mainColor.withOpacity(0.5), width: 2),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                mainColor.withOpacity(0.1),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Area
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                  child: _buildImage(mainColor),
                ),
              ),
              // Content Area
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.flashcard.karina,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.flashcard.spanish,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (widget.flashcard.audioPath != null && widget.flashcard.audioPath!.isNotEmpty)
                        CircleAvatar(
                          backgroundColor: Colors.green[700],
                          child: IconButton(
                            icon: const Icon(Icons.volume_up, color: Colors.white),
                            onPressed: _playAudio,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(Color fallbackColor) {
    final imagePath = widget.flashcard.imagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(fallbackColor);
        },
      );
    }
    return _buildPlaceholder(fallbackColor);
  }

  Widget _buildPlaceholder(Color color) {
    return Container(
      color: color.withOpacity(0.3),
      child: Center(
        child: Icon(Icons.palette, size: 80, color: color),
      ),
    );
  }
}
