import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_state.dart';
import '../../core/app_theme.dart';
import '../../core/utils/snackbar_helper.dart';

import '../../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 350.0,
                  pinned: true,
                  backgroundColor: AppTheme.backgroundColor,
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          LucideIcons.arrowLeft,
                          color: Colors.black,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: const EdgeInsets.all(40.0),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(40),
                        ),
                      ),
                      child: Hero(
                        tag: 'product_${product.id}',
                        child:
                            Image.asset(product.imagePath, fit: BoxFit.contain)
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .moveY(
                                  begin: -10,
                                  end: 10,
                                  duration: 3.seconds,
                                  curve: Curves.easeInOutSine,
                                ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.secondaryColor
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          product.category,
                                          style: TextStyle(
                                            color: AppTheme.secondaryColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(delay: 200.ms)
                                      .slideY(begin: 0.2),
                                  const SizedBox(height: 12),
                                  Text(
                                        product.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge
                                            ?.copyWith(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              height: 1.2,
                                            ),
                                      )
                                      .animate()
                                      .fadeIn(delay: 300.ms)
                                      .slideX(begin: -0.1),
                                ],
                              ),
                            ),
                            Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .scale(curve: Curves.easeOutBack),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.star,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(320 Reviews)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 500.ms),
                        const SizedBox(height: 32),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(delay: 600.ms),
                        const SizedBox(height: 12),
                        Text(
                          product.description.isNotEmpty
                              ? product.description
                              : 'Fresh and organic ${product.name.toLowerCase()} sourced directly from local farms. Perfect for a healthy diet and packed with essential nutrients.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            height: 1.6,
                          ),
                        ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Add To Cart Sheet
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
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
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<AppState>().addToCart(product);

                        context.read<AppState>().addNotification(
                          title: 'Added to Cart',
                          body: '${product.name} was added to your cart.',
                        );
                        CustomSnackbar.showTopNotification(
                          context: context,
                          message: '${product.name} added to cart',
                        );
                      },
                      icon: const Icon(
                        LucideIcons.shoppingCart,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }
}
