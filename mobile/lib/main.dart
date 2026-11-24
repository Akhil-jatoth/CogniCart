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
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgDark,
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
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // Subtle background decorative ambient glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryPurple.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentCyan.withValues(alpha: 0.08),
              ),
            ),
          ),

          // Main Layout
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

                // Active Tab Content
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

      // Floating AI Assistant Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAiChat,
        backgroundColor: Colors.transparent,
        elevation: 6,
        highlightElevation: 10,
        label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryPurple, AppTheme.accentCyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentCyan.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'AI Deals',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
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
