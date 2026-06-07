import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color surface = Color(0xFFF7FBF0);
  static const Color surfaceDim = Color(0xFFD7DBD2);
  static const Color surfaceContainer = Color(0xFFEBEFE5);
  static const Color onSurface = Color(0xFF181D17);
  static const Color onSurfaceVariant = Color(0xFF40493D);
  static const Color outline = Color(0xFF707A6C);
  static const Color outlineVariant = Color(0xFFBFCABA);

  static const Color primary = Color(0xFF0D631B);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF2E7D32);
  static const Color onPrimaryContainer = Color(0xFFCBFFC2);

  static const Color secondary = Color(0xFF705D00);
  static const Color secondaryContainer = Color(0xFFFCD400);
  static const Color onSecondaryContainer = Color(0xFF6E5C00);

  static const Color tertiary = Color(0xFFAC101F);
  static const Color error = Color(0xFFBA1A1A);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.64,
          color: AppColors.onSurface,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.primary,
        ),
      ),
    );
  }

  static TextStyle get karinaTextStyle => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  static TextStyle get spanishTranslationStyle => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        color: AppColors.onSurfaceVariant,
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
    this.bottomBorderColor = const Color(0xFF094513),
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
