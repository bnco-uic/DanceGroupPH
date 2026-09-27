import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The "Filipino fiesta" palette: flag colors plus festival accents.
class AppColors {
  static const Color sunYellow = Color(0xFFFCD116);
  static const Color royalBlue = Color(0xFF0038A8);
  static const Color festiveRed = Color(0xFFCE1126);
  static const Color mangoOrange = Color(0xFFFF8F00);
  static const Color banigMagenta = Color(0xFFC2185B);
  static const Color sampaguitaCream = Color(0xFFFFF8E7);
  static const Color ink = Color(0xFF1F1A2E);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color muted = Color(0xFF6B6478);
}

/// How one dance style looks: gradient, icon, and a readable text color.
class StyleInfo {
  const StyleInfo({
    required this.colors,
    required this.icon,
    required this.onColor,
  });

  final List<Color> colors;
  final IconData icon;

  /// Text/icon color with good contrast on top of the gradient.
  final Color onColor;

  Color get main => colors.first;

  LinearGradient get gradient => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

class AppTheme {
  /// Dashboard banner: blue -> magenta -> orange sunset.
  static const LinearGradient heroGradient = LinearGradient(
    colors: [AppColors.royalBlue, AppColors.banigMagenta, Color(0xFFE65100)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Each dance style gets its own gradient and icon.
  static const Map<String, StyleInfo> _styles = {
    'Folk': StyleInfo(
      colors: [AppColors.festiveRed, Color(0xFFBF360C)],
      icon: Icons.nature_people,
      onColor: Colors.white,
    ),
    'Festival': StyleInfo(
      colors: [AppColors.mangoOrange, AppColors.sunYellow],
      icon: Icons.celebration,
      onColor: AppColors.ink, // dark text: white on yellow is hard to read
    ),
    'Street': StyleInfo(
      colors: [Color(0xFF6A1B9A), AppColors.banigMagenta],
      icon: Icons.directions_run,
      onColor: Colors.white,
    ),
    'Contemporary': StyleInfo(
      colors: [AppColors.royalBlue, Color(0xFF00838F)],
      icon: Icons.auto_awesome,
      onColor: Colors.white,
    ),
    'Cultural': StyleInfo(
      colors: [Color(0xFF5D4037), Color(0xFFBF360C)],
      icon: Icons.diversity_3,
      onColor: Colors.white,
    ),
    'Ballroom': StyleInfo(
      colors: [Color(0xFF311B92), Color(0xFFAD1457)],
      icon: Icons.music_note,
      onColor: Colors.white,
    ),
  };

  /// Used for "All" and for any unknown style.
  static const StyleInfo _fallback = StyleInfo(
    colors: [AppColors.royalBlue, AppColors.banigMagenta],
    icon: Icons.apps,
    onColor: Colors.white,
  );

  static StyleInfo styleInfo(String style) => _styles[style] ?? _fallback;

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.royalBlue,
        primary: AppColors.royalBlue,
        secondary: AppColors.mangoOrange,
        tertiary: AppColors.banigMagenta,
        error: AppColors.festiveRed,
        surface: Colors.white,
      ),
    );

    // Nunito for body text, Poppins (bold) for headings.
    final body = GoogleFonts.nunitoTextTheme(base.textTheme).apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );
    TextStyle heading(TextStyle? style) =>
        GoogleFonts.poppins(textStyle: style, fontWeight: FontWeight.w700);

    final textTheme = body.copyWith(
      displaySmall: heading(body.displaySmall),
      headlineLarge: heading(body.headlineLarge),
      headlineMedium: heading(body.headlineMedium),
      headlineSmall: heading(body.headlineSmall),
      titleLarge: heading(body.titleLarge),
      titleMedium: heading(body.titleMedium),
    );

    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.sampaguitaCream,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.royalBlue,
        foregroundColor: Colors.white,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: AppColors.ink.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        errorMaxLines: 3,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: rounded,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: rounded,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: rounded,
      ),
    );
  }
}
