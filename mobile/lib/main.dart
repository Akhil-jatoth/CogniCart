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

  // Random theme selection on initial launch matching website (Math.random() * themes.length)
  AppTheme.setTheme(math.Random().nextInt(kBackgroundThemes.length));

  runApp(const CogniCartApp());
}

class CogniCartApp extends StatelessWidget {
  const CogniCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, themeIndex, child) {
        return MaterialApp(
          title: 'CogniCart',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const MainNavigationShell(),
        );
      },
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

  void _cycleTheme() {
    AppTheme.cycleTheme();
    final theme = AppTheme.current;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.palette_rounded, color: theme.accent, size: 20),
            const SizedBox(width: 10),
            Text(
              'Theme: ${theme.name} (${AppTheme.activeIndex + 1}/4)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.bgSurface,
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
    final currentTheme = AppTheme.current;

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
      backgroundColor: currentTheme.bgVoid,
      body: Stack(
        children: [
          // ─── 1. FULLSCREEN SHOPPING DOODLE BACKGROUND PATTERN (DYNAMIC 4 THEMES) ───
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Image.asset(
                currentTheme.asset,
                key: ValueKey<String>(currentTheme.asset),
                fit: BoxFit.cover,
                alignment: Alignment.center,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(color: currentTheme.bgVoid),
              ),
            ),
          ),

          // ─── 2. DYNAMIC DARK TINT OVERLAY GRADIENT ───
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
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

          // ─── 3. SUBTLE NEON AMBIENT GLOW ACCENTS MATCHING THEME ───
          Positioned(
            top: -60,
            right: -60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
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
              duration: const Duration(milliseconds: 500),
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

      // Floating AI Assistant Button (Colors dynamically match active theme)
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
            gradient: LinearGradient(
              colors: [currentTheme.primary, currentTheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: currentTheme.accent.withValues(alpha: 0.45),
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

      // Bottom Navigation Bar (Highlights dynamically match active theme)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: currentTheme.bgDeep.withValues(alpha: 0.95),
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
          selectedItemColor: currentTheme.accent,
          unselectedItemColor: AppTheme.textMuted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.search_rounded),
              activeIcon: Icon(Icons.search_rounded, color: currentTheme.accent),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bookmark_outline_rounded),
              activeIcon: Icon(Icons.bookmark_rounded, color: currentTheme.accent),
              label: 'Watchlist',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.notifications_none_rounded),
              activeIcon: Icon(Icons.notifications_active_rounded, color: currentTheme.accent),
              label: 'Radar',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart_rounded, color: currentTheme.accent),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded, color: currentTheme.accent),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
