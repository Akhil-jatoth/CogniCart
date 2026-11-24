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
          // ─── 1. FULLSCREEN SHOPPING DOODLE BACKGROUND PATTERN (EXACT SAME AS WEBSITE) ───
          Positioned.fill(
            child: Image.asset(
              'assets/bg/bg3.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF060912)),
            ),
          ),

          // ─── 2. DARK TINT OVERLAY: linear-gradient(rgba(6, 9, 18, 0.88), rgba(6, 9, 18, 0.90)) ───
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xE0060912), // 88% dark
                    Color(0xE8080E1C), // 91% dark
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
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryPurple.withValues(alpha: 0.16),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentCyan.withValues(alpha: 0.10),
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
