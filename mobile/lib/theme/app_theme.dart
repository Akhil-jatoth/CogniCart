import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Backgrounds matching web
  static const Color bgDark = Color(0xFF080E1C);
  static const Color bgVoid = Color(0xFF060912);
  static const Color bgDeep = Color(0xFF0B1120);
  static const Color bgSurface = Color(0xD9111827); // 85% opacity glass
  static const Color bgCard = Color(0xCC111827);    // 80% opacity glass so background shines through
  static const Color bgCardHover = Color(0xE01E293B);// 88% opacity glass
  static const Color bgRaised = Color(0xD91A2235);
  static const Color bgFloat = Color(0xD91E293B);
  static const Color bgInput = Color(0xE60F172A);

  // Brand Accents
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryPurple = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color accent = Color(0xFF00E5FF);
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color accentEmerald = Color(0xFF10B981);

  // Status & Feedback
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Text Colors
  static const Color textMain = Color(0xFFF8FAFC);
  static const Color textBody = Color(0xFFCBD5E1);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textMuted = Color(0xFF94A3B8);

  // Glassmorphism borders and fills
  static const Color glassBg = Color(0x0AFFFFFF);
  static const Color glassBgMedium = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x1FFFFFFF);
  static const Color glassBorderAccent = Color(0x406366F1);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiBadgeGradient = LinearGradient(
    colors: [accentCyan, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.dmSans().fontFamily,
      scaffoldBackgroundColor: Colors.transparent, // Allow full-screen background image
      primaryColor: primaryPurple,
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: accentCyan,
        surface: bgCard,
        error: error,
      ),
      textTheme: TextTheme(
        titleLarge: GoogleFonts.syne(color: textMain, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.syne(color: textMain, fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.syne(color: textMain, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.dmSans(color: textBody),
        bodyMedium: GoogleFonts.dmSans(color: textBody),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xF20B1120),
        selectedItemColor: accentCyan,
        unselectedItemColor: textMuted,
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: glassBorder),
        ),
      ),
    );
  }
}
