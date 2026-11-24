import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/action_confirm_modal.dart';
import '../widgets/auth_modal.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onOpenAuth;
  final Function(String query)? onReSearch;

  const ProfileScreen({
    super.key,
    required this.onOpenAuth,
    this.onReSearch,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Timer? _timer;
  String _currentTimeString = '';
  bool _isLoading = false;

  // Stats
  int _totalSearches = 0;
  int _watchlistCount = 0;
  final double _savingsAmount = 0.0;
  double _watchlistValue = 0.0;
  int _ordersCount = 0;
  String _lastSearch = 'None';
  String _lastOrderDate = 'None';
  List<dynamic> _recentSearches = [];
  Map<String, int> _last7DaysActivity = {};

  @override
  void initState() {
    super.initState();
    _updateClock();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
    _loadProfileData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateClock() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    final format = DateFormat('hh:mm a');
    setState(() {
      _currentTimeString = '${format.format(now).toLowerCase()} IST (Asia/Kolkata)';
    });
  }

  Future<void> _loadProfileData() async {
    final username = StorageService.getUsername();
    if (username == null) return;

    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        ApiService.getUserHistory(username),
        ApiService.getWatchlist(username),
        ApiService.getOrders(username),
      ]);

      final historyData = results[0] as Map<String, dynamic>;
      final watchlist = results[1] as List;
      final orders = results[2] as List;

      final historyList = (historyData['history'] as List? ?? []);

      // Calculate watchlist value
      double wlValue = 0;
      for (final item in watchlist) {
        wlValue += item.numericPrice;
      }

      // Group last 7 days searches
      final Map<String, int> daysMap = {};
      final now = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        final dayName = DateFormat('E').format(d);
        daysMap[dayName] = 0;
      }

      for (final h in historyList) {
        if (h['timestamp'] != null) {
          try {
            final t = DateTime.parse(h['timestamp'].toString());
            final dayName = DateFormat('E').format(t);
            if (daysMap.containsKey(dayName)) {
              daysMap[dayName] = (daysMap[dayName] ?? 0) + 1;
            }
          } catch (_) {}
        }
      }

      if (!mounted) return;

      setState(() {
        _totalSearches = historyData['totalSearches'] ?? historyList.length;
        _watchlistCount = watchlist.length;
        _watchlistValue = wlValue;
        _ordersCount = orders.length;
        if (historyList.isNotEmpty) {
          _lastSearch = historyList.first['query'] ?? 'iPhone 12';
        }
        if (orders.isNotEmpty) {
          _lastOrderDate = orders.first.createdAt.toString().split(' ').first;
        }
        _recentSearches = historyList.take(6).toList();
        _last7DaysActivity = daysMap;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editDisplayName() async {
    final controller = TextEditingController(text: StorageService.getDisplayName());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Edit Display Name', style: TextStyle(color: Colors.white, fontFamily: 'Syne')),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter new name',
            filled: true,
            fillColor: AppTheme.bgInput,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await StorageService.setDisplayName(newName);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!mounted) return;
                setState(() {});
                ActionConfirmModal.showToast(context, 'Name updated successfully');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    ActionConfirmModal.show(
      context: context,
      title: 'Sign Out?',
      message: 'Are you sure you want to log out of CogniCart on this device?',
      confirmText: 'Sign Out',
      confirmColor: Colors.redAccent,
      onConfirm: () async {
        await StorageService.logout();
        if (mounted) {
          setState(() {});
          ActionConfirmModal.showToast(context, 'Signed out successfully');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = StorageService.isLoggedIn();
    final username = StorageService.getUsername() ?? 'Guest';
    final displayName = StorageService.getDisplayName();
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'G';

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator(color: AppTheme.accentCyan)),
      );
    }

    if (!isLoggedIn) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle_outlined, size: 64, color: AppTheme.accentCyan),
                const SizedBox(height: 16),
                const Text('Sign In to CogniCart Profile', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Access your real-time analytics, 5-metric dashboard, price drop statistics, and search history.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => AuthModal.show(context, _loadProfileData),
                  icon: const Icon(Icons.login_rounded, color: Colors.white),
                  label: const Text('Sign In with Email / OTP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: AppTheme.accentCyan,
        backgroundColor: AppTheme.bgCard,
        onRefresh: _loadProfileData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Profile Card (Hey, user!)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryPurple.withValues(alpha: 0.35),
                      AppTheme.bgCard,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Avatar Circle
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFF6C5CE7),
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Syne',
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Name & Email
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Hey, $displayName!',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Syne',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: _editDisplayName,
                                    child: const Icon(Icons.edit_outlined, color: AppTheme.accentPink, size: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(username, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                            ],
                          ),
                        ),
                        // Clock
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _currentTimeString.split(' ').first,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const Text('IST (Asia/Kolkata)', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Quick Badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildProfileBadge('$_totalSearches Searches', AppTheme.accentCyan, Icons.search_rounded),
                        _buildProfileBadge(
                          _savingsAmount > 0 ? '₹${_savingsAmount.toStringAsFixed(0)} Saved' : '🔥 No Savings Yet',
                          AppTheme.accentGold,
                          Icons.local_offer_rounded,
                        ),
                        _buildProfileBadge('$_watchlistCount Watching', AppTheme.accentPink, Icons.remove_red_eye_rounded),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 5 STAT CARDS IN SINGLE HORIZONTAL ROW (Matches Web Profile Dashboard Layout)
              const Row(
                children: [
                  Icon(Icons.dashboard_rounded, color: AppTheme.accentCyan, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Profile Statistics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Syne',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Single horizontal scrollable row with all 5 cards
              SizedBox(
                height: 128,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildStatCard(
                      icon: Icons.search_rounded,
                      iconColor: AppTheme.accentCyan,
                      value: '$_totalSearches',
                      label: 'TOTAL SEARCHES',
                      subtext: "Last: '$_lastSearch'",
                      borderColor: AppTheme.accentCyan,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      icon: Icons.visibility_rounded,
                      iconColor: AppTheme.accentPink,
                      value: '$_watchlistCount',
                      label: 'WATCHING',
                      subtext: '0 price drops detected',
                      borderColor: AppTheme.accentPink,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      icon: Icons.monetization_on_rounded,
                      iconColor: AppTheme.accentGold,
                      value: '₹${_savingsAmount.toStringAsFixed(0)}',
                      label: 'SAVINGS',
                      subtext: 'from price drops',
                      borderColor: AppTheme.accentGold,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      icon: Icons.shopping_bag_rounded,
                      iconColor: const Color(0xFF38EF7D),
                      value: '₹${_watchlistValue.toStringAsFixed(0)}',
                      label: 'WATCHLIST VALUE',
                      subtext: 'current prices',
                      borderColor: const Color(0xFF38EF7D),
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      icon: Icons.inventory_2_rounded,
                      iconColor: const Color(0xFFFF9F43),
                      value: '$_ordersCount',
                      label: 'ORDERS PLACED',
                      subtext: 'Latest: $_lastOrderDate',
                      borderColor: const Color(0xFFFF9F43),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Search Activity - Last 7 Days (fl_chart Bar Chart)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bar_chart_rounded, color: AppTheme.primaryPurple, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Search Activity — Last 7 Days',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Syne',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 160,
                      child: _buildBarChart(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recent Searches
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.history_rounded, color: AppTheme.accentCyan, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Recent Searches',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Syne',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_recentSearches.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('No search history recorded yet', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                      )
                    else
                      ..._recentSearches.map((s) {
                        final query = s['query']?.toString() ?? '';
                        final time = s['timestamp'] != null ? s['timestamp'].toString().split('T').first : '';
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: const Icon(Icons.circle, size: 8, color: AppTheme.accentCyan),
                          title: Text(query, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(time, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.arrow_outward_rounded, size: 16, color: AppTheme.accentCyan),
                                onPressed: () {
                                  if (widget.onReSearch != null) {
                                    widget.onReSearch!(query);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                  label: const Text('Log Out of CogniCart', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String subtext,
    required Color borderColor,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Syne',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtext,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final keys = _last7DaysActivity.keys.toList();
    if (keys.isEmpty) {
      return const Center(child: Text('No activity data', style: TextStyle(color: AppTheme.textMuted)));
    }

    int maxCount = 1;
    for (final v in _last7DaysActivity.values) {
      if (v > maxCount) maxCount = v;
    }

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < keys.length; i++) {
      final day = keys[i];
      final count = _last7DaysActivity[day] ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              gradient: const LinearGradient(
                colors: [AppTheme.primaryPurple, AppTheme.accentCyan],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 14,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (maxCount + 2).toDouble(),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx >= 0 && idx < keys.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      keys[idx],
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }
}
