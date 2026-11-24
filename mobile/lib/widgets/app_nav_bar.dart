import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class AppNavBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLoginTap;
  final VoidCallback onProfileTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onLogoTap;
  final VoidCallback? onThemeToggle;

  const AppNavBar({
    super.key,
    required this.onLoginTap,
    required this.onProfileTap,
    this.onLogoutTap,
    this.onLogoTap,
    this.onThemeToggle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final username = StorageService.getUser();
    final displayName = StorageService.getDisplayName();
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgDark.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: AppTheme.glassBorder, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo & Brand Name
              GestureDetector(
                onTap: onLogoTap ?? onThemeToggle,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 32,
                      width: 32,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.shopping_cart_rounded,
                        color: AppTheme.accentCyan,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Color(0xFFFFFFFF), AppTheme.accentCyan],
                      ).createShader(bounds),
                      child: Text(
                        'CogniCart',
                        style: GoogleFonts.syne(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Actions (Theme toggle + Login or User Circle)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onThemeToggle != null) ...[
                    IconButton(
                      icon: Icon(Icons.palette_outlined, size: 20, color: AppTheme.accentCyan),
                      tooltip: 'Change Background Theme',
                      onPressed: onThemeToggle,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                  ],
                  if (username != null && username.isNotEmpty)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onProfileTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.bgCardHover,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppTheme.primaryPurple,
                                  child: Text(
                                    initial,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (onLogoutTap != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.logout_rounded, size: 18, color: AppTheme.textMuted),
                            onPressed: onLogoutTap,
                            tooltip: 'Logout',
                          ),
                        ],
                      ],
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: onLoginTap,
                      icon: const Icon(Icons.login_rounded, size: 15, color: Colors.white),
                      label: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
