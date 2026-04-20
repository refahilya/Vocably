import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class AppTheme {
  AppTheme._();

  // ── Color Palette ──
  static const Color primary = Color(0xFF1A237E);       // Deep indigo
  static const Color primaryLight = Color(0xFF3949AB);   // Lighter indigo
  static const Color secondary = Color(0xFF00BFA5);      // Teal accent
  static const Color accent = Color(0xFFFFB300);         // Warm amber
  static const Color success = Color(0xFF2E7D32);        // Green
  static const Color error = Color(0xFFD32F2F);          // Red
  static const Color surface = Color(0xFFF8F9FE);        // Light surface
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color wordBubble = Color(0xFFE8EAF6);     // Light indigo bg
  static const Color wordBubbleSelected = Color(0xFF3F51B5);
  static const Color wordUsed = Color(0xFF42A5F5);       // Blue for used words
  static const Color wordUnused = Color(0xFFBDBDBD);     // Grey for unused

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF283593)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFE8EAF6), Color(0xFFC5CAE9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows ──
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.1),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  // ── Border Radius ──
  static BorderRadius get cardRadius => BorderRadius.circular(16);
  static BorderRadius get chipRadius => BorderRadius.circular(24);
  static BorderRadius get buttonRadius => BorderRadius.circular(14);

  // ── Theme Data ──
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          primary: primary,
          secondary: secondary,
          surface: surface,
        ),
        scaffoldBackgroundColor: surface,
        textTheme: GoogleFonts.nunitoTextTheme(),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: buttonRadius),
            elevation: 3,
            textStyle: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: buttonRadius),
            textStyle: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primary,
          unselectedItemColor: textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        cardTheme: CardThemeData(
          color: cardBg,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: cardRadius),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
      );
}
