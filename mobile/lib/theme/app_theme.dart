import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BackgroundThemeOption {
  final String asset;
  final String name;
  final Color primary;
  final Color primaryGlow;
  final Color secondary;
  final Color accent;
  final Color accentGlow;
  final Color bgVoid;
  final Color bgDeep;
  final Color bgSurface;
  final Color bgCard;
  final Color bgCardHover;
  final Color bgRaised;
  final Color overlayTop;
  final Color overlayBottom;
  final Color glow1;
  final Color glow2;

  const BackgroundThemeOption({
    required this.asset,
    required this.name,
    required this.primary,
    required this.primaryGlow,
    required this.secondary,
    required this.accent,
    required this.accentGlow,
    required this.bgVoid,
    required this.bgDeep,
    required this.bgSurface,
    required this.bgCard,
    required this.bgCardHover,
    required this.bgRaised,
    required this.overlayTop,
    required this.overlayBottom,
    required this.glow1,
    required this.glow2,
  });
}

// 4 Themes matching public/index.html (lines 687-748)
const List<BackgroundThemeOption> kBackgroundThemes = [
  // 1. Solar Flare (Gold / Red)
  BackgroundThemeOption(
    asset: 'assets/bg/bg1.png',
    name: 'Solar Flare',
    primary: Color(0xFFFACC15),      // #facc15 yellow
    primaryGlow: Color(0x59FACC15),
    secondary: Color(0xFFEF4444),    // #ef4444 red
    accent: Color(0xFFF87171),       // #f87171 coral
    accentGlow: Color(0x40F87171),
    bgVoid: Color(0xFF090705),
    bgDeep: Color(0xFF14100C),
    bgSurface: Color(0xD91C1611),
    bgCard: Color(0xCC1C1611),
    bgCardHover: Color(0xE6261E16),
    bgRaised: Color(0xD9261E16),
    overlayTop: Color(0xDE090705),   // rgba(9, 7, 5, 0.88)
    overlayBottom: Color(0xEB090705),
    glow1: Color(0xFFFACC15),
    glow2: Color(0xFFEF4444),
  ),
  // 2. Cyber Amber (Amber / Gold)
  BackgroundThemeOption(
    asset: 'assets/bg/bg2.png',
    name: 'Cyber Amber',
    primary: Color(0xFFF59E0B),      // #f59e0b amber
    primaryGlow: Color(0x59F59E0B),
    secondary: Color(0xFFD97706),    // #d97706 dark amber
    accent: Color(0xFFFBBF24),       // #fbbf24 bright amber
    accentGlow: Color(0x40FBBF24),
    bgVoid: Color(0xFF0A0A0A),
    bgDeep: Color(0xFF121212),
    bgSurface: Color(0xD91A1A1A),
    bgCard: Color(0xCC1A1A1A),
    bgCardHover: Color(0xE6242424),
    bgRaised: Color(0xD9242424),
    overlayTop: Color(0xDE0A0A0A),   // rgba(10, 10, 10, 0.88)
    overlayBottom: Color(0xEB0A0A0A),
    glow1: Color(0xFFF59E0B),
    glow2: Color(0xFFD97706),
  ),
  // 3. Neon Matrix (Emerald / Blue / Purple)
  BackgroundThemeOption(
    asset: 'assets/bg/bg3.png',
    name: 'Neon Matrix',
    primary: Color(0xFF10B981),      // #10b981 emerald
    primaryGlow: Color(0x5910B981),
    secondary: Color(0xFF3B82F6),    // #3b82f6 blue
    accent: Color(0xFF8B5CF6),       // #8b5cf6 purple
    accentGlow: Color(0x408B5CF6),
    bgVoid: Color(0xFF060912),
    bgDeep: Color(0xFF0B1120),
    bgSurface: Color(0xD9111827),
    bgCard: Color(0xCC111827),
    bgCardHover: Color(0xE61A2235),
    bgRaised: Color(0xD91A2235),
    overlayTop: Color(0xDE060912),   // rgba(6, 9, 18, 0.88)
    overlayBottom: Color(0xE8080E1C),
    glow1: Color(0xFF10B981),
    glow2: Color(0xFF8B5CF6),
  ),
  // 4. Deep Oceanic (Electric Blue / Sky Blue)
  BackgroundThemeOption(
    asset: 'assets/bg/bg4.png',
    name: 'Deep Oceanic',
    primary: Color(0xFF3B82F6),      // #3b82f6 electric blue
    primaryGlow: Color(0x593B82F6),
    secondary: Color(0xFF2563EB),    // #2563eb royal blue
    accent: Color(0xFF60A5FA),       // #60a5fa sky blue
    accentGlow: Color(0x4060A5FA),
    bgVoid: Color(0xFF060912),
    bgDeep: Color(0xFF0B1120),
    bgSurface: Color(0xD9111827),
    bgCard: Color(0xCC111827),
    bgCardHover: Color(0xE61A2235),
    bgRaised: Color(0xD91A2235),
    overlayTop: Color(0xEB060912),   // rgba(6, 9, 18, 0.92)
    overlayBottom: Color(0xF2080E1C),
    glow1: Color(0xFF3B82F6),
    glow2: Color(0xFF60A5FA),
  ),
];

class AppTheme {
  // Global reactive theme controller
  static final ValueNotifier<int> themeNotifier = ValueNotifier<int>(0);

  static int get activeIndex => themeNotifier.value;
  static BackgroundThemeOption get current => kBackgroundThemes[activeIndex];

  static void setTheme(int index) {
    themeNotifier.value = index % kBackgroundThemes.length;
  }

  static void cycleTheme() {
    setTheme(activeIndex + 1);
  }

  // Dynamic getters that match the chosen theme
  static Color get primary => current.primary;
  static Color get primaryPurple => current.primary;
  static Color get secondary => current.secondary;
  static Color get accent => current.accent;
  static Color get accentCyan => current.accent;
  static Color get bgDark => current.bgVoid;
  static Color get bgVoid => current.bgVoid;
  static Color get bgDeep => current.bgDeep;
  static Color get bgSurface => current.bgSurface;
  static Color get bgCard => current.bgCard;
  static Color get bgCardHover => current.bgCardHover;
  static Color get bgRaised => current.bgRaised;
  static Color get bgFloat => current.bgCardHover;
  static Color get bgInput => current.bgDeep;

  // Accents & status
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color accentEmerald = Color(0xFF10B981);

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

  static LinearGradient get primaryGradient => LinearGradient(
    colors: [current.primary, current.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get aiBadgeGradient => LinearGradient(
    colors: [current.accent, current.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.dmSans().fontFamily,
      scaffoldBackgroundColor: Colors.transparent,
      primaryColor: current.primary,
      colorScheme: ColorScheme.dark(
        primary: current.primary,
        secondary: current.accent,
        surface: current.bgCard,
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
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: current.bgDeep.withValues(alpha: 0.95),
        selectedItemColor: current.accent,
        unselectedItemColor: textMuted,
      ),
      cardTheme: CardThemeData(
        color: current.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: glassBorder),
        ),
      ),
    );
  }
}
