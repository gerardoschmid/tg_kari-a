import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karina_app/models/deck.dart';
import 'package:karina_app/providers/auth_provider.dart';
import 'package:karina_app/providers/deck_provider.dart';
import 'package:karina_app/providers/game_provider.dart';
import 'package:karina_app/providers/local_provider.dart';
import 'package:karina_app/providers/theme_provider.dart';
import 'package:karina_app/utils/app_localizations.dart';
import 'package:karina_app/views/quiz.dart';
import 'package:karina_app/utils/update_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Conector de ruta punteado estilo camino de tierra premium
// ─────────────────────────────────────────────────────────────────────────────
class PathConnector extends StatelessWidget {
  final double startAlignment;
  final double endAlignment;

  const PathConnector({
    super.key,
    required this.startAlignment,
    required this.endAlignment,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 72,
      width: double.infinity,
      child: CustomPaint(
        painter: _PathPainter(
          startAlignment: startAlignment,
          endAlignment: endAlignment,
          pathColor: isDark
              ? const Color(0xFF8B6914).withOpacity(0.75)
              : const Color(0xFF8B5E3C).withOpacity(0.60),
          glowColor: isDark
              ? const Color(0xFFFFD700).withOpacity(0.12)
              : const Color(0xFF4A7C44).withOpacity(0.10),
        ),
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  final double startAlignment;
  final double endAlignment;
  final Color pathColor;
  final Color glowColor;

  const _PathPainter({
    required this.startAlignment,
    required this.endAlignment,
    required this.pathColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double startX =
        size.width / 2 + (startAlignment * size.width * 0.68);
    final double endX =
        size.width / 2 + (endAlignment * size.width * 0.68);

    final path = Path();
    path.moveTo(startX, 0);

    final double cy1 = size.height * 0.33;
    final double cy2 = size.height * 0.67;
    path.cubicTo(startX, cy1, endX, cy2, endX, size.height);

    // ── Capa de brillo/glow ───────────────────────────────────────────────
    final glowPaint = Paint()
      ..color = glowColor
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, glowPaint);

    // ── Trazo punteado principal ──────────────────────────────────────────
    final dashPaint = Paint()
      ..color = pathColor
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      const dashLength = 10.0;
      const spaceLength = 7.0;
      while (distance < metric.length) {
        final extractPath =
            metric.extractPath(distance, distance + dashLength);
        canvas.drawPath(extractPath, dashPaint);
        distance += dashLength + spaceLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter old) =>
      old.startAlignment != startAlignment ||
      old.endAlignment != endAlignment ||
      old.pathColor != pathColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// Decoraciones de Sabana/Pradera — CustomPainter con semilla determinística
// Se calcula una sola vez por índice, sin jitter durante el scroll.
// ─────────────────────────────────────────────────────────────────────────────
class _SavannaDecorationPainter extends CustomPainter {
  final int seed;
  final bool isDark;
  final double nodeAlignmentX; // alignment del nodo en [-1, 1]

  _SavannaDecorationPainter({
    required this.seed,
    required this.isDark,
    required this.nodeAlignmentX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed * 137 + 42); // semilla estable

    // Colores de paleta sabana adaptados al modo
    final List<Color> bushColors = isDark
        ? [
            const Color(0xFF2D4A1E),
            const Color(0xFF3A5C28),
            const Color(0xFF4A6B30),
          ]
        : [
            const Color(0xFF6B9B47),
            const Color(0xFF5A8C3A),
            const Color(0xFF7BAA55),
          ];
    final Color stoneColor =
        isDark ? const Color(0xFF4A3728) : const Color(0xFFB8956A);
    final Color flowerColor =
        isDark ? const Color(0xFFD4AC0D) : const Color(0xFFFFD700);

    // Zona segura donde NO dibujar: en torno al centro del nodo
    final double nodeCenterX =
        size.width / 2 + nodeAlignmentX * size.width * 0.68;
    final double safeLeft = nodeCenterX - 55;
    final double safeRight = nodeCenterX + 55;

    // ── Dibuja 4-6 elementos decorativos ───────────────────────────────────
    final int elemCount = 4 + rng.nextInt(3);
    for (int i = 0; i < elemCount; i++) {
      // Posición: preferir los lados, evitar el centro del nodo
      double x;
      double y;
      int attempts = 0;
      do {
        x = rng.nextDouble() * size.width;
        y = 4 + rng.nextDouble() * (size.height - 8);
        attempts++;
      } while (x > safeLeft && x < safeRight && attempts < 10);

      if (attempts >= 10) continue; // no se pudo colocar sin superponerlo

      final int type = rng.nextInt(3); // 0 = arbusto, 1 = piedra, 2 = flor

      switch (type) {
        case 0: // Arbusto redondeado
          _drawBush(
            canvas,
            Offset(x, y),
            bushColors[rng.nextInt(bushColors.length)],
            6.0 + rng.nextDouble() * 8,
          );
          break;
        case 1: // Piedra
          _drawStone(canvas, Offset(x, y), stoneColor,
              5.0 + rng.nextDouble() * 6);
          break;
        case 2: // Flor pequeña
          _drawFlower(canvas, Offset(x, y), flowerColor,
              3.0 + rng.nextDouble() * 3);
          break;
      }
    }
  }

  void _drawBush(Canvas canvas, Offset center, Color color, double r) {
    final paint = Paint()..color = color.withOpacity(0.65);
    // Tres círculos superpuestos que forman un arbusto
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(center.translate(-r * 0.7, r * 0.3), r * 0.75, paint);
    canvas.drawCircle(center.translate(r * 0.7, r * 0.3), r * 0.75, paint);
    // Sombra inferior leve
    final shadow = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(0, r), width: r * 2, height: r * 0.6),
      shadow,
    );
  }

  void _drawStone(Canvas canvas, Offset center, Color color, double r) {
    final paint = Paint()..color = color.withOpacity(0.55);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: r * 2.2, height: r * 1.4),
      paint,
    );
    // Reflejo leve
    final shine = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawOval(
      Rect.fromCenter(
          center: center.translate(-r * 0.3, -r * 0.2),
          width: r * 0.8,
          height: r * 0.4),
      shine,
    );
  }

  void _drawFlower(Canvas canvas, Offset center, Color color, double r) {
    final petalPaint = Paint()..color = color.withOpacity(0.70);
    final centerPaint = Paint()..color = Colors.white.withOpacity(0.9);
    // 5 pétalos
    for (int p = 0; p < 5; p++) {
      final angle = p * 2 * pi / 5;
      final petalCenter =
          center + Offset(cos(angle) * r * 1.2, sin(angle) * r * 1.2);
      canvas.drawCircle(petalCenter, r, petalPaint);
    }
    canvas.drawCircle(center, r * 0.6, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _SavannaDecorationPainter old) =>
      old.seed != seed || old.isDark != isDark;
}

/// Widget liviano que envuelve el painter de decoraciones para un nivel dado.
class _LevelDecorations extends StatelessWidget {
  final int levelIndex;
  final double nodeAlignmentX;

  const _LevelDecorations({
    required this.levelIndex,
    required this.nodeAlignmentX,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: CustomPaint(
        painter: _SavannaDecorationPainter(
          seed: levelIndex,
          isDark: isDark,
          nodeAlignmentX: nodeAlignmentX,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget eficiente para el reloj de regeneración de vidas
// ─────────────────────────────────────────────────────────────────────────────
class LivesCountdown extends StatefulWidget {
  const LivesCountdown({super.key});

  @override
  State<LivesCountdown> createState() => _LivesCountdownState();
}

class _LivesCountdownState extends State<LivesCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gp = Provider.of<GameProvider>(context);

    if (gp.lives >= gp.maxLives) {
      return _livesRow('${gp.lives}', null);
    }
    if (gp.lastLifeLostTime == null) {
      return _livesRow('${gp.lives}', null);
    }

    final now = DateTime.now();
    final diff = now.difference(gp.lastLifeLostTime!);
    const minutesPerLife = 30;
    const totalSeconds = minutesPerLife * 60;
    final elapsedSeconds = diff.inSeconds % totalSeconds;
    final remainingSeconds = totalSeconds - elapsedSeconds;
    final displayMin = remainingSeconds ~/ 60;
    final displaySec = remainingSeconds % 60;
    final timeStr =
        '${displayMin.toString().padLeft(2, "0")}:${displaySec.toString().padLeft(2, "0")}';

    return _livesRow('${gp.lives}', timeStr);
  }

  Widget _livesRow(String count, String? timer) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.favorite, color: Colors.red, size: 20),
        const SizedBox(width: 4),
        Text(count,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
        if (timer != null) ...[
          const SizedBox(width: 4),
          Text('($timer)',
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pantalla principal del mapa — Estilo Sabana/Pradera
// ─────────────────────────────────────────────────────────────────────────────
class MainHomeView extends StatefulWidget {
  const MainHomeView({super.key});

  @override
  State<MainHomeView> createState() => _MainHomeViewState();
}

class _MainHomeViewState extends State<MainHomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<DeckProvider>(context, listen: false).loadDecks(context);
        UpdateService().checkForUpdates(context);
      }
    });
  }

  double _getAlignmentForIndex(int index) {
    final mod = index % 4;
    if (mod == 0) return 0.0;
    if (mod == 1) return -0.40;
    if (mod == 2) return 0.0;
    return 0.40;
  }

  void _showLessonBottomSheet(
    BuildContext context,
    Deck deck,
    bool isUnlocked,
    int index,
    AppLocalizations local,
  ) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A1C15) : const Color(0xFFF5E6D3),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: isDark ? const Color(0xFF5D3A1A) : const Color(0xFFD7B896),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Indicador de arrastre
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF8B6914)
                        : const Color(0xFF8B5E3C),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Ícono del estado del nivel
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked
                        ? const Color(0xFF4A7C44).withOpacity(0.15)
                        : Colors.grey.withOpacity(0.12),
                    border: Border.all(
                      color: isUnlocked
                          ? const Color(0xFF4A7C44)
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isUnlocked ? Icons.play_arrow_rounded : Icons.lock_rounded,
                    size: 34,
                    color: isUnlocked
                        ? const Color(0xFF4A7C44)
                        : Colors.grey[500],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Título de la lección
              Text(
                deck.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color:
                      isDark ? Colors.white : const Color(0xFF5D4037),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${deck.flashcards.length} ${local.get('words_in_lesson').toLowerCase()}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 18),

              Divider(color: isDark ? Colors.brown[800] : Colors.brown[100]),
              const SizedBox(height: 10),

              // Etiqueta de palabras
              Text(
                "${local.get('words_in_lesson')}:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFFFFD700)
                      : const Color(0xFF8B5E3C),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),

              // Vista previa de palabras (scroll horizontal)
              SizedBox(
                height: 62,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: deck.flashcards.length,
                  itemBuilder: (context, idx) {
                    final fc = deck.flashcards[idx];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E140F)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF5D3A1A)
                              : const Color(0xFFD7B896),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            fc.karina,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            fc.spanish,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // Botón de empezar lección
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUnlocked
                      ? const Color(0xFF4A7C44)
                      : Colors.grey[500],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  elevation: isUnlocked ? 5 : 0,
                  shadowColor: const Color(0xFF4A7C44).withOpacity(0.4),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (!isUnlocked) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(local.get('locked')),
                      backgroundColor: const Color(0xFFC62828),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ));
                    return;
                  }
                  if (gameProvider.lives <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(local.get('no_lives_warning')),
                      backgroundColor: const Color(0xFFC62828),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ));
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizPage(
                        deckTitle: deck.title,
                        deckId: deck.id ?? 0,
                      ),
                    ),
                  ).then((_) {
                    if (context.mounted) {
                      Provider.of<DeckProvider>(context, listen: false)
                          .loadDecks(context);
                    }
                  });
                },
                child: Text(
                  local.get('start_lesson'),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final locale = Provider.of<LocalProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);
    final local = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // ── Fondo de Sabana/Pradera multi-stop ──────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF1A0F08), // café noche profundo
                        const Color(0xFF1E1408),
                        const Color(0xFF120C06),
                      ]
                    : [
                        const Color(0xFFEDD9A3), // dorado sabana
                        const Color(0xFFD4E8A0), // verde hierba suave
                        const Color(0xFFE8D4A0), // tierra cálida
                        const Color(0xFFD6C48A), // arena
                      ],
                stops: isDark
                    ? [0.0, 0.5, 1.0]
                    : [0.0, 0.30, 0.70, 1.0],
              ),
            ),
          ),

          // ── Textura sutil de puntos en el fondo ─────────────────────────
          Opacity(
            opacity: isDark ? 0.04 : 0.06,
            child: CustomPaint(
              size: Size(
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height,
              ),
              painter: _DotPatternPainter(
                  color: isDark ? Colors.white : Colors.brown),
            ),
          ),

          // ── Contenido ───────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Cabecera Glassmorphism ─────────────────────────────────
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2A1C15).withOpacity(0.88)
                        : Colors.white.withOpacity(0.80),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.brown.withOpacity(0.12),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFF4A7C44),
                        child: Text(
                          auth.userName?.isNotEmpty == true
                              ? auth.userName!
                                  .substring(0, 1)
                                  .toUpperCase()
                              : 'U',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.userName ?? 'Kariña Learner',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "${local.get('level')}: ${auth.level}",
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 14),
                                const SizedBox(width: 2),
                                Text(
                                  "${gameProvider.xp} ${local.get('xp')}",
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const LivesCountdown(),
                    ],
                  ),
                ),

                // ── Barra de herramientas ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        local.get('learning_path'),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? const Color(0xFFFFD700)
                              : const Color(0xFF5D4037),
                          shadows: isDark
                              ? [
                                  const Shadow(
                                      blurRadius: 6,
                                      color: Colors.black45,
                                      offset: Offset(0, 2))
                                ]
                              : [],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.wb_sunny
                                  : Icons.nights_stay,
                              color: isDark
                                  ? Colors.amber
                                  : const Color(0xFF8B5E3C),
                            ),
                            onPressed: () => themeProvider
                                .toggleTheme(!themeProvider.isDarkMode),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.language,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF8B5E3C)),
                            onSelected: (val) =>
                                locale.setLocale(Locale(val)),
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                  value: 'es', child: Text("Español")),
                              const PopupMenuItem(
                                  value: 'en', child: Text("English")),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.logout,
                                color: isDark
                                    ? Colors.redAccent
                                    : Colors.red[800]),
                            onPressed: () => auth.logout(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Mapa de niveles (scrollable) ──────────────────────────
                Expanded(
                  child: Consumer<DeckProvider>(
                    builder: (context, dp, _) {
                      if (dp.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: isDark
                                ? const Color(0xFFFFD700)
                                : const Color(0xFF4A7C44),
                          ),
                        );
                      }
                      if (dp.error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wifi_off,
                                  size: 48, color: Colors.brown),
                              const SizedBox(height: 12),
                              Text(dp.error!,
                                  style:
                                      const TextStyle(color: Colors.brown)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => dp.loadDecks(context),
                                child: const Text("Reintentar"),
                              ),
                            ],
                          ),
                        );
                      }
                      if (dp.decks.isEmpty) {
                        return const Center(
                          child: Text("No hay lecciones cargadas.",
                              style: TextStyle(color: Colors.brown)),
                        );
                      }

                      // Construir ítems del mapa:
                      // por cada nivel: decoraciones + nodo + conector
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                        // ítems: [decor0, nodo0, conector01, decor1, nodo1, ...]
                        // = 3 ítems por nivel, menos 1 conector al final
                        itemCount: dp.decks.length * 3 - 1,
                        itemBuilder: (context, index) {
                          // Cada grupo de 3: decoraciones, nodo, conector
                          // Posición dentro del grupo
                          final group = index ~/ 3;
                          final pos = index % 3;

                          if (pos == 2) {
                            // Conector entre group y group+1
                            final startAlign =
                                _getAlignmentForIndex(group);
                            final endAlign =
                                _getAlignmentForIndex(group + 1);
                            return PathConnector(
                              startAlignment: startAlign,
                              endAlignment: endAlign,
                            );
                          }

                          final deckIdx = group;
                          if (deckIdx >= dp.decks.length) {
                            return const SizedBox.shrink();
                          }

                          final deck = dp.decks[deckIdx];
                          final alignX = _getAlignmentForIndex(deckIdx);

                          if (pos == 0) {
                            // Decoraciones de sabana para este nivel
                            return _LevelDecorations(
                              levelIndex: deckIdx,
                              nodeAlignmentX: alignX,
                            );
                          }

                          // pos == 1: Nodo del nivel
                          final isUnlocked = deckIdx < auth.level;
                          final isCompleted = deckIdx < auth.level - 1;

                          Color nodeColor = Colors.grey[400]!;
                          Color shadowColor = Colors.grey.withOpacity(0.3);
                          IconData nodeIcon = Icons.lock_rounded;

                          if (isCompleted) {
                            nodeColor = const Color(0xFFFFD700);
                            shadowColor =
                                const Color(0xFFFFD700).withOpacity(0.4);
                            nodeIcon = Icons.emoji_events_rounded;
                          } else if (isUnlocked) {
                            nodeColor = const Color(0xFF4A7C44);
                            shadowColor =
                                const Color(0xFF4A7C44).withOpacity(0.4);
                            nodeIcon = Icons.play_arrow_rounded;
                          }

                          return Align(
                            alignment: Alignment(alignX, 0),
                            child: Column(
                              children: [
                                // Nodo circular
                                GestureDetector(
                                  onTap: () => _showLessonBottomSheet(
                                      context, deck, isUnlocked, deckIdx,
                                      local),
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.7, end: 1.0),
                                    duration: Duration(
                                        milliseconds:
                                            300 + deckIdx * 40),
                                    curve: Curves.elasticOut,
                                    builder: (_, scale, child) =>
                                        Transform.scale(
                                            scale: scale, child: child),
                                    child: Container(
                                      width: 82,
                                      height: 82,
                                      decoration: BoxDecoration(
                                        color: nodeColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: shadowColor,
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.15),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white.withOpacity(0.15)
                                              : Colors.white,
                                          width: 4,
                                        ),
                                      ),
                                      child: Icon(nodeIcon,
                                          color: Colors.white, size: 38),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Etiqueta del nivel
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  constraints: const BoxConstraints(maxWidth: 130),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF2A1C15)
                                        : Colors.white.withOpacity(0.88),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF5D3A1A)
                                          : const Color(0xFFD7B896),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    deck.title,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isUnlocked
                                          ? (isDark
                                              ? Colors.white
                                              : const Color(0xFF5D4037))
                                          : Colors.grey[500],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Patrón de puntos de fondo ────────────────────────────────────────────────
class _DotPatternPainter extends CustomPainter {
  final Color color;
  const _DotPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 28.0;
    const radius = 1.5;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPatternPainter old) =>
      old.color != color;
}