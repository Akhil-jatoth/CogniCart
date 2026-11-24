import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/action_confirm_modal.dart';
import '../widgets/target_price_modal.dart';
import '../widgets/auth_modal.dart';

class AlertsScreen extends StatefulWidget {
  final VoidCallback onOpenAuth;

  const AlertsScreen({super.key, required this.onOpenAuth});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  bool _isLoading = false;
  List<AlertItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    final username = StorageService.getUsername();
    if (username == null) {
      setState(() => _items = []);
      return;
    }

    setState(() => _isLoading = true);
    final list = await ApiService.getAlerts(username);
    if (!mounted) return;
    setState(() {
      _items = list;
      _isLoading = false;
    });
  }

  Future<void> _deleteAlert(AlertItem item) async {
    ActionConfirmModal.show(
      context: context,
      title: 'Stop Tracking Price?',
      message: 'Are you sure you want to delete the price drop alert for "${item.title}"?',
      confirmText: 'Delete Alert',
      confirmColor: Colors.redAccent,
      onConfirm: () async {
        final username = StorageService.getUsername();
        if (username == null) return;

        final success = await ApiService.deleteAlert(item.id, username, item.title);
        if (!mounted) return;

        if (success) {
          ActionConfirmModal.showToast(context, 'Alert removed');
          _loadAlerts();
        } else {
          ActionConfirmModal.showToast(context, 'Could not remove alert');
        }
      },
    );
  }

  Future<void> _updateTargetPrice(AlertItem item) async {
    TargetPriceModal.show(context, item.product, (newTarget) async {
      final success = await ApiService.updateTargetPrice(item.id, newTarget);
      if (!mounted) return;

      if (success) {
        ActionConfirmModal.showToast(context, 'Target price updated to ₹${newTarget.toStringAsFixed(0)}');
        _loadAlerts();
      } else {
        ActionConfirmModal.showToast(context, 'Failed to update target price');
      }
    });
  }

  Future<void> _openStore(String link) async {
    if (link.isEmpty) return;
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = StorageService.isLoggedIn();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: AppTheme.accentCyan,
        backgroundColor: AppTheme.bgCard,
        onRefresh: _loadAlerts,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentCyan.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_active_rounded, color: AppTheme.accentCyan, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Price Drop Radar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Syne',
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCardHover,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_items.length} active',
                            style: const TextStyle(color: AppTheme.accentCyan, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Live 24/7 background price tracker. Alerts trigger the instant prices drop below target.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            if (!isLoggedIn)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_alert_rounded, size: 54, color: AppTheme.accentCyan),
                        const SizedBox(height: 16),
                        const Text('Sign In to Track Prices', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text(
                          'Get notified instantly when your favorite gadgets drop to your target budget.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => AuthModal.show(context, _loadAlerts),
                          icon: const Icon(Icons.login_rounded, color: Colors.white),
                          label: const Text('Sign In to CogniCart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              )
            else if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppTheme.accentCyan)),
              )
            else if (_items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none_rounded, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 12),
                      const Text('No Active Price Alerts', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text('Tap "Set Alert" on any search result to start monitoring drops', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final item = _items[i];
                      final isTargetMet = item.numericCurrentPrice <= item.targetPrice && item.numericCurrentPrice > 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isTargetMet ? AppTheme.accentEmerald : AppTheme.primaryPurple.withValues(alpha: 0.3),
                            width: isTargetMet ? 1.5 : 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      color: Colors.white,
                                      child: Image.network(
                                        item.image,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported_rounded, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.bgCardHover,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item.store,
                                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                    onPressed: () => _deleteAlert(item),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Price Status banner
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isTargetMet
                                      ? AppTheme.accentEmerald.withValues(alpha: 0.12)
                                      : AppTheme.bgCardHover,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isTargetMet ? AppTheme.accentEmerald.withValues(alpha: 0.3) : Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Current Price', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                        Text(
                                          item.currentPriceFormatted,
                                          style: TextStyle(
                                            color: isTargetMet ? AppTheme.accentEmerald : Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(Icons.arrow_forward_rounded, color: AppTheme.textMuted, size: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text('Target Alert', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                        Text(
                                          '₹${item.targetPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            color: AppTheme.accentCyan,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Action Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _updateTargetPrice(item),
                                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.accentCyan),
                                    label: const Text('Edit Target', style: TextStyle(color: AppTheme.accentCyan, fontSize: 12)),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _openStore(item.link),
                                    icon: const Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.white),
                                    label: const Text('View Deal', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryPurple,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _items.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
