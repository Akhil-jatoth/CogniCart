import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onWatchlist;
  final VoidCallback onAlert;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onWatchlist,
    required this.onAlert,
  });

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Color _getStoreColor(String store) {
    final lower = store.toLowerCase();
    if (lower.contains('amazon')) return const Color(0xFFFF9900);
    if (lower.contains('flipkart')) return const Color(0xFF2874F0);
    return AppTheme.accentEmerald;
  }

  @override
  Widget build(BuildContext context) {
    final formattedPrice = product.numericPrice > 0
        ? '₹${product.numericPrice.toStringAsFixed(0)}'
        : (product.price.startsWith('₹') ? product.price : '₹${product.price}');

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: product.isAiTopPick ? AppTheme.accentCyan : Colors.white.withValues(alpha: 0.08),
          width: product.isAiTopPick ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: product.isAiTopPick
                ? AppTheme.accentCyan.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.25),
            blurRadius: product.isAiTopPick ? 16 : 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Image area
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Image.network(
                    product.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),

              // Store badge on top left
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStoreColor(product.store),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    product.store.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // AI Pick badge on top right
              if (product.isAiTopPick)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryPurple, AppTheme.accentCyan],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, color: Colors.white, size: 13),
                        SizedBox(width: 3),
                        Text(
                          'AI CHOICE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Details area
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Rating & Reviews
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: AppTheme.accentGold),
                          const SizedBox(width: 3),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppTheme.accentGold,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${product.reviewsCount} reviews',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Price display
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formattedPrice,
                      style: GoogleFonts.syne(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    if (product.originalPrice != null && product.originalPrice!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        product.originalPrice!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),

                // Action buttons row
                Row(
                  children: [
                    // View Store button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchUrl(product.link),
                        icon: const Icon(Icons.open_in_new_rounded, size: 15, color: Colors.white),
                        label: const Text(
                          'View Store',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Add to Cart button
                    IconButton(
                      icon: Icon(Icons.add_shopping_cart_rounded, color: AppTheme.accentCyan, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.bgCardHover,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
                        ),
                      ),
                      onPressed: onAddToCart,
                      tooltip: 'Add to Cart',
                    ),
                    const SizedBox(width: 6),

                    // Set Alert button
                    IconButton(
                      icon: const Icon(Icons.notifications_active_outlined, color: AppTheme.accentGold, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.bgCardHover,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: AppTheme.accentGold.withValues(alpha: 0.3)),
                        ),
                      ),
                      onPressed: onAlert,
                      tooltip: 'Set Price Alert',
                    ),
                    const SizedBox(width: 6),

                    // Watchlist button
                    IconButton(
                      icon: const Icon(Icons.bookmark_add_outlined, color: AppTheme.accentPink, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.bgCardHover,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: AppTheme.accentPink.withValues(alpha: 0.3)),
                        ),
                      ),
                      onPressed: onWatchlist,
                      tooltip: 'Add to Watchlist',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
