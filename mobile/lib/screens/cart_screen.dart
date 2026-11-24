import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/action_confirm_modal.dart';
import '../widgets/auth_modal.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback onOpenAuth;

  const CartScreen({super.key, required this.onOpenAuth});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Product> _cartItems = [];
  List<OrderItem> _orders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final username = StorageService.getUsername();
    if (username == null) {
      setState(() {
        _cartItems = [];
        _orders = [];
      });
      return;
    }

    setState(() => _isLoading = true);
    final results = await Future.wait([
      ApiService.getCart(username),
      ApiService.getOrders(username),
    ]);

    if (!mounted) return;
    setState(() {
      _cartItems = results[0] as List<Product>;
      _orders = results[1] as List<OrderItem>;
      _isLoading = false;
    });
  }

  double get _cartTotal {
    double total = 0;
    for (final item in _cartItems) {
      total += item.numericPrice;
    }
    return total;
  }

  Future<void> _removeFromCart(Product item) async {
    final username = StorageService.getUsername();
    if (username == null) return;

    final success = await ApiService.removeFromCart(username, item.title);
    if (!mounted) return;

    if (success) {
      ActionConfirmModal.showToast(context, 'Removed from cart');
      _loadData();
    } else {
      ActionConfirmModal.showToast(context, 'Could not remove item');
    }
  }

  Future<void> _handleCheckout() async {
    final username = StorageService.getUsername();
    if (username == null) return;

    ActionConfirmModal.show(
      context: context,
      title: 'Confirm Checkout',
      message: 'Place simulated order for ${_cartItems.length} items totaling ₹${_cartTotal.toStringAsFixed(0)}?',
      confirmText: 'Place Order',
      confirmColor: AppTheme.accentEmerald,
      onConfirm: () async {
        final success = await ApiService.checkout(username);
        if (!mounted) return;

        if (success) {
          ActionConfirmModal.showToast(context, '🎉 Order Placed Successfully!');
          _loadData();
          _tabController.animateTo(1); // Switch to orders tab
        } else {
          ActionConfirmModal.showToast(context, 'Failed to complete checkout');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = StorageService.isLoggedIn();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cart & Orders',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Syne',
                  ),
                ),
                const SizedBox(height: 8),
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.accentCyan,
                  labelColor: AppTheme.accentCyan,
                  unselectedLabelColor: AppTheme.textMuted,
                  tabs: [
                    Tab(text: 'Cart (${_cartItems.length})'),
                    Tab(text: 'Order History (${_orders.length})'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: !isLoggedIn
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 54, color: AppTheme.accentCyan),
                    const SizedBox(height: 16),
                    const Text('Sign In Required', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to manage your shopping cart and view past orders.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => AuthModal.show(context, _loadData),
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
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.accentCyan))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Cart Tab
                    _buildCartTab(),
                    // Orders Tab
                    _buildOrdersTab(),
                  ],
                ),
    );
  }

  Widget _buildCartTab() {
    if (_cartItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.accentCyan,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Column(
                children: [
                  Icon(Icons.remove_shopping_cart_rounded, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                  const SizedBox(height: 12),
                  const Text('Your Cart is Empty', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Add items from price comparisons to get started', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.accentCyan,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cartItems.length,
              itemBuilder: (ctx, i) {
                final item = _cartItems[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
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
                            Row(
                              children: [
                                Text(item.price, style: const TextStyle(color: AppTheme.accentCyan, fontSize: 15, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppTheme.bgCardHover, borderRadius: BorderRadius.circular(6)),
                                  child: Text(item.store, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                        onPressed: () => _removeFromCart(item),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Total Bar & Checkout
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.3)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount:', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                      Text(
                        '₹${_cartTotal.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _handleCheckout,
                      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                      label: const Text('Checkout Now', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentEmerald,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    if (_orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.accentCyan,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Column(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                  const SizedBox(height: 12),
                  const Text('No Orders Placed Yet', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Completed orders will show up here', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.accentCyan,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (ctx, i) {
          final order = _orders[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id.substring(order.id.length > 8 ? order.id.length - 8 : 0)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentEmerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: const TextStyle(color: AppTheme.accentEmerald, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Date: ${order.createdAt}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                const Divider(color: Colors.white12, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${order.items.length} items', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    Text(
                      '₹${order.total.toStringAsFixed(0)}',
                      style: const TextStyle(color: AppTheme.accentCyan, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
