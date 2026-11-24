import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'widgets/app_nav_bar.dart';
import 'widgets/auth_modal.dart';
import 'widgets/ai_chat_modal.dart';
import 'screens/home_search_screen.dart';
import 'screens/watchlist_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';

class BackgroundThemeOption {
  final String asset;
  final Color overlayTop;
  final Color overlayBottom;
  final Color glow1;
  final Color glow2;
  final String name;

  const BackgroundThemeOption({
    required this.asset,
    required this.overlayTop,
    required this.overlayBottom,
    required this.glow1,
    required this.glow2,
    required this.name,
  });
}

const List<BackgroundThemeOption> kBackgroundThemes = [
  BackgroundThemeOption(
    asset: 'assets/bg/bg1.png',
    overlayTop: Color(0xDE090705), // rgba(9, 7, 5, 0.88)
    overlayBottom: Color(0xEB090705),
    glow1: Color(0xFFFACC15), // Yellow
    glow2: Color(0xFFEF4444), // Red
    name: 'Solar Flare',
  ),
  BackgroundThemeOption(
    asset: 'assets/bg/bg2.png',
    overlayTop: Color(0xDE0A0A0A), // rgba(10, 10, 10, 0.88)
    overlayBottom: Color(0xEB0A0A0A),
    glow1: Color(0xFFF59E0B), // Amber
    glow2: Color(0xFFD97706), // Gold
    name: 'Cyber Amber',
  ),
  BackgroundThemeOption(
    asset: 'assets/bg/bg3.png',
    overlayTop: Color(0xDE060912), // rgba(6, 9, 18, 0.88)
    overlayBottom: Color(0xE8080E1C),
    glow1: Color(0xFF10B981), // Emerald
    glow2: Color(0xFF8B5CF6), // Purple
    name: 'Neon Matrix',
  ),
  BackgroundThemeOption(
    asset: 'assets/bg/bg4.png',
    overlayTop: Color(0xEB060912), // rgba(6, 9, 18, 0.92)
    overlayBottom: Color(0xF2080E1C),
    glow1: Color(0xFF3B82F6), // Electric Blue
    glow2: Color(0xFF60A5FA), // Sky Blue
    name: 'Deep Oceanic',
  ),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF080E1C),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await StorageService.init();
  runApp(const CogniCartApp());
}

class CogniCartApp extends StatelessWidget {
  const CogniCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CogniCart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  late int _themeIndex;

  @override
  void initState() {
    super.initState();
    // Random theme selection on launch matching the web app (Math.random() * themes.length)
    _themeIndex = math.Random().nextInt(kBackgroundThemes.length);
  }

  void _cycleTheme() {
    setState(() {
      _themeIndex = (_themeIndex + 1) % kBackgroundThemes.length;
    });
    final theme = kBackgroundThemes[_themeIndex];
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.palette_rounded, color: AppTheme.accentCyan, size: 20),
            const SizedBox(width: 10),
            Text('Background: ${theme.name} (${_themeIndex + 1}/4)'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF161E31),
      ),
    );
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  void _openAuthModal() {
    AuthModal.show(context, () {
      setState(() {});
    });
  }

  void _openAiChat() {
    AiChatModal.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = kBackgroundThemes[_themeIndex];

    final screens = [
      HomeSearchScreen(onOpenAuth: _openAuthModal),
      WatchlistScreen(onOpenAuth: _openAuthModal),
      AlertsScreen(onOpenAuth: _openAuthModal),
      CartScreen(onOpenAuth: _openAuthModal),
      ProfileScreen(
        onOpenAuth: _openAuthModal,
        onReSearch: (query) {
          setState(() => _currentIndex = 0);
        },
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF060912),
      body: Stack(
        children: [
          // ─── 1. FULLSCREEN SHOPPING DOODLE BACKGROUND PATTERN (DYNAMIC 4 THEMES) ───
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: Image.asset(
                currentTheme.asset,
                key: ValueKey<String>(currentTheme.asset),
                fit: BoxFit.cover,
                alignment: Alignment.center,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF060912)),
              ),
            ),
          ),

          // ─── 2. DYNAMIC DARK TINT OVERLAY GRADIENT ───
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    currentTheme.overlayTop,
                    currentTheme.overlayBottom,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ─── 3. SUBTLE NEON AMBIENT GLOW ACCENTS ───
          Positioned(
            top: -60,
            right: -60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentTheme.glow1.withValues(alpha: 0.16),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentTheme.glow2.withValues(alpha: 0.10),
              ),
            ),
          ),

          // ─── 4. MAIN FOREGROUND APP CONTENT ───
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                AppNavBar(
                  onLoginTap: _openAuthModal,
                  onProfileTap: () => setState(() => _currentIndex = 4),
                  onThemeToggle: _cycleTheme,
                  onLogoTap: _cycleTheme,
                  onLogoutTap: () async {
                    await StorageService.logout();
                    setState(() {});
                  },
                ),

                // Active Tab Screen Content
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: screens,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Floating AI Assistant Button (Matches Web circular glowing bot button)
      floatingActionButton: FloatingActionButton(
        onPressed: _openAiChat,
        backgroundColor: Colors.transparent,
        elevation: 6,
        highlightElevation: 10,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF00E5FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentCyan.withValues(alpha: 0.45),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.smart_toy_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xF20B1120),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.accentCyan,
          unselectedItemColor: AppTheme.textMuted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              activeIcon: Icon(Icons.search_rounded, color: AppTheme.accentCyan),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline_rounded),
              activeIcon: Icon(Icons.bookmark_rounded, color: AppTheme.accentCyan),
              label: 'Watchlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none_rounded),
              activeIcon: Icon(Icons.notifications_active_rounded, color: AppTheme.accentCyan),
              label: 'Radar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart_rounded, color: AppTheme.accentCyan),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded, color: AppTheme.accentCyan),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
