import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/app_state.dart';
import '../../models/product.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _navigateToCheckout() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CheckoutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Cart'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            onPressed: () {
              context.read<AppState>().clearCart();
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          final cartItems = state.cartItems;
          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.shoppingBag,
                      size: 50,
                      color: AppTheme.primaryColor,
                    ),
                  ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 24),
                  Text(
                    'Your Cart is Empty',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Looks like you haven\'t added\nanything to your cart yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }

          final double subtotal = state.cartSubtotal;
          const double delivery = 5.00;
          final double total = subtotal + delivery;

          // Group items by ID to show quantity
          final Map<String, int> quantityMap = {};
          final List<Product> uniqueItems = [];

          for (var item in cartItems) {
            if (quantityMap.containsKey(item.id)) {
              quantityMap[item.id] = quantityMap[item.id]! + 1;
            } else {
              quantityMap[item.id] = 1;
              uniqueItems.add(item);
            }
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: uniqueItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = uniqueItems[index];
                    final qty = quantityMap[item.id]!;
                    return _buildCartItem(context, item, qty)
                        .animate()
                        .fadeIn(delay: (100 * index).ms)
                        .slideX(begin: 0.2, end: 0);
                  },
                ),
              ),

              // Bottom Checkout Section
              Container(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  120,
                ), // Padding for bottom nav
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSummaryRow(context, 'Subtotal', subtotal),
                    const SizedBox(height: 12),
                    _buildSummaryRow(context, 'Delivery', delivery),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildSummaryRow(context, 'Total', total, isTotal: true),
                    const SizedBox(height: 24),
                    SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _navigateToCheckout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Checkout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, Product product, int quantity) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset(product.imagePath),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.category,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${(product.price * quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.minus, size: 16),
                  onPressed: () {
                    context.read<AppState>().removeFromCart(product);
                  },
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                Text(
                  '$quantity',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.plus, size: 16),
                  onPressed: () {
                    context.read<AppState>().addToCart(product);
                  },
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String title,
    double amount, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: isTotal
              ? Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 18)
              : Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: isTotal
              ? const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )
              : const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}
