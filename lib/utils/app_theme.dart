import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary: #E67E22 (Naranja tierra)
  static const Color primary = Color(0xFFE67E22);
  // Secondary: #2D6A4F (Verde selva)
  static const Color secondary = Color(0xFF2D6A4F);
  // Background: #FFF8F0 (Blanco hueso/claro)
  static const Color background = Color(0xFFFFF8F0);
  // Surface/Cards: #FFFFFF
  static const Color surface = Color(0xFFFFFFFF);
  // Text Main: #4A3B32 (Marrón oscuro)
  static const Color textMain = Color(0xFF4A3B32);
  // Text Secondary: #7A6A5F
  static const Color textSecondary = Color(0xFF7A6A5F);
  // Success: #40916C
  static const Color success = Color(0xFF40916C);
  // Error: #BC4742
  static const Color error = Color(0xFFBC4742);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textMain,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
        ),
        displayMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
        ),
        displaySmall: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
        ),
        bodyLarge: GoogleFonts.nunito(
          color: AppColors.textMain,
        ),
        bodyMedium: GoogleFonts.nunito(
          color: AppColors.textMain,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  static TextStyle get karinaTextStyle => GoogleFonts.notoSerif(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
        color: AppColors.textMain,
      );

  static TextStyle get spanishTranslationStyle => GoogleFonts.nunito(
        fontSize: 16,
        color: AppColors.textSecondary,
      );
}

class TactileButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color bottomBorderColor;
  final double height;
  final double padding;

  const TactileButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.bottomBorderColor = const Color(0xFFB35E1A), // Darker version of E67E22
    this.height = 56,
    this.padding = 16,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(top: _isPressed ? 4 : 0),
        padding: EdgeInsets.symmetric(horizontal: widget.padding),
        height: widget.height - (_isPressed ? 4 : 0),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border(
            bottom: _isPressed
                ? BorderSide.none
                : BorderSide(color: widget.bottomBorderColor, width: 4),
          ),
        ),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
