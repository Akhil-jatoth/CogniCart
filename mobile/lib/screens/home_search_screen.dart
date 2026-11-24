import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_recommendation_card.dart';
import '../widgets/product_card.dart';
import '../widgets/target_price_modal.dart';
import '../widgets/action_confirm_modal.dart';
import '../widgets/auth_modal.dart';

class HomeSearchScreen extends StatefulWidget {
  final VoidCallback onOpenAuth;

  const HomeSearchScreen({super.key, required this.onOpenAuth});

  @override
  State<HomeSearchScreen> createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends State<HomeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String _selectedStore = 'All Stores';
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  Product? _aiTopPick;

  final List<String> _quickSearches = [
    'iPhone 15',
    'MacBook Air',
    'Sony WH-1000XM5',
    'Nike Running Shoes',
    'Samsung S24 Ultra',
    'Smart Watch',
  ];

  final List<String> _stores = ['All Stores', 'Amazon', 'Flipkart', 'Other Stores'];

  @override
  void initState() {
    super.initState();
    // Default initial search
    _searchProducts('iPhone 15');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchProducts(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchController.text = cleanQuery;
    });

    final username = StorageService.getUsername();
    // Record recent search
    await StorageService.addRecentSearch(cleanQuery);
    ApiService.recordSearch(username, cleanQuery);

    try {
      final storeResults = await ApiService.searchAllStores(cleanQuery);
      final List<Product> combined = [];
      storeResults.forEach((_, list) => combined.addAll(list));

      if (!mounted) return;

      setState(() {
        _allProducts = combined;
        _aiTopPick = _findBestDeal(combined);
        _filterByStore(_selectedStore);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Product? _findBestDeal(List<Product> items) {
    if (items.isEmpty) return null;
    Product best = items.first;
    for (final p in items) {
      if (p.numericPrice > 0 && (best.numericPrice == 0 || p.numericPrice < best.numericPrice)) {
        best = p;
      }
    }
    return best;
  }

  void _filterByStore(String store) {
    setState(() {
      _selectedStore = store;
      if (store == 'All Stores') {
        _filteredProducts = List.from(_allProducts);
      } else {
        _filteredProducts = _allProducts.where((p) {
          final pStore = p.store.toLowerCase();
          final target = store.toLowerCase().replaceAll(' ', '');
          if (target == 'otherstores') {
            return !pStore.contains('amazon') && !pStore.contains('flipkart');
          }
          return pStore.contains(target);
        }).toList();
      }
    });
  }

  void _requireAuthThen(VoidCallback action) {
    if (StorageService.isLoggedIn()) {
      action();
    } else {
      AuthModal.show(context, () {
        setState(() {});
        if (StorageService.isLoggedIn()) {
          action();
        }
      });
    }
  }

  Future<void> _handleWatchlist(Product product) async {
    _requireAuthThen(() async {
      final username = StorageService.getUsername();
      if (username == null) return;
      final success = await ApiService.addToWatchlist(username, product);
      if (mounted) {
        if (success) {
          ActionConfirmModal.showToast(context, 'Added "${product.title}" to Watchlist!');
        } else {
          ActionConfirmModal.showToast(context, 'Could not add to watchlist. Please retry.');
        }
      }
    });
  }

  Future<void> _handleAlert(Product product) async {
    _requireAuthThen(() {
      final username = StorageService.getUsername();
      if (username == null) return;
      TargetPriceModal.show(context, product, (targetPrice) async {
        final success = await ApiService.addAlert(username, product, targetPrice);
        if (mounted) {
          if (success) {
            ActionConfirmModal.showToast(
              context,
              'Price Alert set for ₹${targetPrice.toStringAsFixed(0)}! We will notify you on price drops.',
            );
          } else {
            ActionConfirmModal.showToast(context, 'Failed to set alert.');
          }
        }
      });
    });
  }

  Future<void> _handleAddToCart(Product product) async {
    _requireAuthThen(() async {
      final username = StorageService.getUsername();
      if (username == null) return;
      final success = await ApiService.addToCart(username, product);
      if (mounted) {
        if (success) {
          ActionConfirmModal.showToast(context, 'Added "${product.title}" to Cart!');
        } else {
          ActionConfirmModal.showToast(context, 'Failed to add item to Cart.');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return RefreshIndicator(
      color: AppTheme.accentCyan,
      backgroundColor: AppTheme.bgCard,
      onRefresh: () => _searchProducts(_searchController.text),
      child: CustomScrollView(
        slivers: [
          // Header / Search Bar area
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Title tagline
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded, color: AppTheme.accentCyan, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'AI-POWERED PRICE RADAR',
                              style: TextStyle(
                                color: AppTheme.accentCyan,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Smart Price Comparison',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Syne',
                    ),
                  ),
                  const Text(
                    'Compare live prices across Amazon, Flipkart & stores with AI',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // Pill Search Input
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.35)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: AppTheme.accentCyan, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                            decoration: const InputDecoration(
                              hintText: 'Search products (e.g. iPhone 15, Laptop)...',
                              hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                              border: InputBorder.none,
                            ),
                            onSubmitted: _searchProducts,
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppTheme.textMuted, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryPurple, AppTheme.accentCyan],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                            onPressed: () => _searchProducts(_searchController.text),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick search chips
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _quickSearches.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (ctx, i) {
                        return InkWell(
                          onTap: () => _searchProducts(_quickSearches[i]),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.bgCardHover,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: Text(
                              _quickSearches[i],
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Store Filter Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _stores.map((store) {
                        final isSelected = _selectedStore == store;
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            showCheckmark: false,
                            label: Text(
                              store,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textMuted,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                            backgroundColor: AppTheme.bgCard,
                            selectedColor: AppTheme.primaryPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? AppTheme.accentCyan : Colors.white12,
                              ),
                            ),
                            onSelected: (_) => _filterByStore(store),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // AI Recommendation Card if available
                  if (!_isLoading && _aiTopPick != null) ...[
                    AiRecommendationCard(
                      product: _aiTopPick!,
                      totalStores: _allProducts.map((p) => p.store).toSet().length,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Results header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Results for "${_searchController.text}"',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_filteredProducts.length} deals',
                        style: TextStyle(color: AppTheme.accentCyan, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.accentCyan),
                    SizedBox(height: 16),
                    Text(
                      'Comparing prices across all stores...',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else if (_filteredProducts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off_rounded, size: 64, color: AppTheme.textMuted),
                    const SizedBox(height: 12),
                    const Text('No products found', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('Try searching with a different term', style: TextStyle(color: AppTheme.textMuted)),
                  ],
                ),
              ),
            )
          else
            // Products List / Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: isTablet
                  ? SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (ctx, index) {
                          final product = _filteredProducts[index];
                          return ProductCard(
                            product: product,
                            onWatchlist: () => _handleWatchlist(product),
                            onAlert: () => _handleAlert(product),
                            onAddToCart: () => _handleAddToCart(product),
                          );
                        },
                        childCount: _filteredProducts.length,
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, index) {
                          final product = _filteredProducts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: ProductCard(
                              product: product,
                              onWatchlist: () => _handleWatchlist(product),
                              onAlert: () => _handleAlert(product),
                              onAddToCart: () => _handleAddToCart(product),
                            ),
                          );
                        },
                        childCount: _filteredProducts.length,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
