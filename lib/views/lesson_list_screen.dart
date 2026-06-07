import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import 'vocabulary_screen.dart';

class LessonListScreen extends StatelessWidget {
  final String moduleTitle;

  const LessonListScreen({super.key, required this.moduleTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Módulo: $moduleTitle",
          style: GoogleFonts.poppins(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Progreso: 60%",
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const LinearProgressIndicator(
                value: 0.6,
                minHeight: 12,
                backgroundColor: Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Lecciones",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            _buildLessonCard(
              context,
              "Lección 1",
              "Buenos días",
              "3 flashcards, quiz",
              Icons.check_circle,
              AppColors.success,
              isActive: true,
            ),
            _buildLessonCard(
              context,
              "Lección 2",
              "¿Cómo estás?",
              "50% completado",
              Icons.watch_later,
              AppColors.primary,
            ),
            _buildLessonCard(
              context,
              "Lección 3",
              "(bloqueada)",
              "Completa la anterior",
              Icons.lock,
              Colors.grey,
              isLocked: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(
    BuildContext context,
    String title,
    String subtitle,
    String info,
    IconData icon,
    Color iconColor, {
    bool isActive = false,
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VocabularyScreen(),
                ),
              );
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? const Border(
                  left: BorderSide(color: AppColors.primary, width: 6),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(15),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: isLocked ? Colors.grey : AppColors.textMain,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isLocked ? Colors.grey : AppColors.textMain,
                ),
              ),
              Text(
                info,
                style: GoogleFonts.nunito(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          trailing: Icon(icon, color: iconColor),
        ),
      ),
    );
  }
}
