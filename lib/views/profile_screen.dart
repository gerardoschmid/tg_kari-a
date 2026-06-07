import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      "AG",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ana García",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      Row(
                        children: [
                          const Text("🔥", style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 5),
                          Text(
                            "Racha: 7 días",
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("✨", style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 5),
                          Text(
                            "Total XP: 1250",
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 20),
              Text(
                "Logros",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _buildSectionCard([
                _buildAchievementRow("🏅 Primeras palabras"),
                _buildAchievementRow("🏅 10 días seguidos"),
                _buildAchievementRow("🏅 Maestro Saludos"),
              ]),
              const SizedBox(height: 30),
              Text(
                "Estadísticas",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _buildSectionCard([
                _buildStatRow("Palabras:", "85"),
                _buildStatRow("Lecciones:", "12"),
                _buildStatRow("Tiempo:", "3h 40m"),
              ]),
              const SizedBox(height: 40),
              TactileButton(
                onPressed: () {},
                backgroundColor: Colors.grey[200]!,
                bottomBorderColor: Colors.grey[400]!,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.settings, color: AppColors.textMain),
                    const SizedBox(width: 10),
                    Text(
                      "Configuración",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              TactileButton(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                },
                backgroundColor: AppColors.error.withValues(alpha: 0.1),
                bottomBorderColor: AppColors.error.withValues(alpha: 0.3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.exit_to_app, color: AppColors.error),
                    const SizedBox(width: 10),
                    Text(
                      "Cerrar sesión",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildAchievementRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }
}
