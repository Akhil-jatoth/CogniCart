import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

class TargetPriceModal extends StatefulWidget {
  final Product product;
  final Function(double targetPrice) onConfirm;

  const TargetPriceModal({
    super.key,
    required this.product,
    required this.onConfirm,
  });

  static void show(BuildContext context, Product product, Function(double targetPrice) onConfirm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TargetPriceModal(product: product, onConfirm: onConfirm),
    );
  }

  @override
  State<TargetPriceModal> createState() => _TargetPriceModalState();
}

class _TargetPriceModalState extends State<TargetPriceModal> {
  late TextEditingController _controller;
  double? _selectedTarget;

  @override
  void initState() {
    super.initState();
    // Default target 10% below current price
    final defaultTarget = (widget.product.numericPrice * 0.9).roundToDouble();
    _selectedTarget = defaultTarget > 0 ? defaultTarget : widget.product.numericPrice;
    _controller = TextEditingController(text: _selectedTarget!.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyDiscount(double percent) {
    final newPrice = (widget.product.numericPrice * (1.0 - percent)).roundToDouble();
    setState(() {
      _selectedTarget = newPrice;
      _controller.text = newPrice.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_rounded, color: AppTheme.accentCyan, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Set Price Drop Alert',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Syne',
                      ),
                    ),
                    Text(
                      widget.product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Current Price Display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.bgCardHover,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Current Best Price:', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                Text(
                  widget.product.price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Discount presets
          const Text('Quick Targets:', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildPresetChip('5% Off', 0.05),
              const SizedBox(width: 8),
              _buildPresetChip('10% Off', 0.10),
              const SizedBox(width: 8),
              _buildPresetChip('15% Off', 0.15),
              const SizedBox(width: 8),
              _buildPresetChip('20% Off', 0.20),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Input
          const Text('Notify me when price drops to (₹):', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: const TextStyle(color: AppTheme.accentCyan, fontSize: 18, fontWeight: FontWeight.bold),
              filled: true,
              fillColor: AppTheme.bgInput,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryPurple.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.accentCyan, width: 2),
              ),
            ),
            onChanged: (val) {
              setState(() {
                _selectedTarget = double.tryParse(val) ?? widget.product.numericPrice;
              });
            },
          ),
          const SizedBox(height: 20),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                final target = double.tryParse(_controller.text) ?? widget.product.numericPrice;
                Navigator.pop(context);
                widget.onConfirm(target);
              },
              icon: const Icon(Icons.add_alert_rounded, color: Colors.white),
              label: const Text(
                'Track Price Drop',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, double percent) {
    return Expanded(
      child: InkWell(
        onTap: () => _applyDiscount(percent),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.3)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.accentCyan,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
