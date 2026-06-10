import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/app_state.dart';
import '../../core/app_theme.dart';

import '../../core/utils/snackbar_helper.dart';
import '../../data/dummy_data.dart';
import '../../models/product.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  late final List<Product> _allProducts;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Simulate fetching data -> 1.5 seconds loading
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });

    _allProducts = dummyProducts; // Use all products
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading ? _buildShimmerLoading() : _buildContent(),
    );
  }

  // ==== SHIMMER LOADING ====
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 150,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: 100,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }

  // ==== ACTUAL CONTENT ====
  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        await Future.delayed(const Duration(seconds: 1));
        setState(() => _isLoading = false);
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Consumer<AppState>(
                              builder: (context, state, child) {
                                final name = state.user?.displayName ?? 'Guest';
                                return Text(
                                  name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(fontSize: 28),
                                );
                              },
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: -0.1, end: 0),
                    // Removed notification button from here
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: const SizedBox(height: 16)),

          // Search Bar Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSearchBar()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: -0.1, end: 0),
            ),
          ),

          SliverToBoxAdapter(child: const SizedBox(height: 24)),

          // Products Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fresh Products',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontSize: 22),
                  ),
                  Text(
                    'See All',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),
          ),

          // BENTO GRID - Always show all products
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ).copyWith(bottom: 120), // bottom nav padding
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return _buildBentoRow(index)
                    .animate()
                    .fadeIn(delay: (400 + (index * 100)).ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
              }, childCount: (_allProducts.length / 2).ceil()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoRow(int rowIndex) {
    // Always create rows with 2 items (no wide cards)
    int itemIndex = rowIndex * 2;

    if (itemIndex + 1 < _allProducts.length) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            Expanded(child: _buildProductCard(_allProducts[itemIndex])),
            const SizedBox(width: 16),
            Expanded(child: _buildProductCard(_allProducts[itemIndex + 1])),
          ],
        ),
      );
    } else if (itemIndex < _allProducts.length) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            Expanded(child: _buildProductCard(_allProducts[itemIndex])),
            const Expanded(child: SizedBox()), // Empty space for last item
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildProductCard(Product product) {
    return Container(
      height: 220,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x21000000),
            blurRadius: 17,
            offset: Offset(0, 6),
            spreadRadius: 0,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: _buildSquareCardContent(product),
        ),
      ),
    );
  }

  Widget _buildSquareCardContent(Product product) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Hero(
                tag: 'product_${product.id}',
                child: Image.asset(product.imagePath, fit: BoxFit.contain)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(
                      begin: -5,
                      end: 5,
                      duration: 2.seconds,
                      curve: Curves.easeInOutSine,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              InkWell(
                onTap: () {
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
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    LucideIcons.plus,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: TypeAheadField<Product>(
        controller: _searchController,
        builder: (context, controller, focusNode) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: 'Search for food items...',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                LucideIcons.search,
                color: Colors.grey.shade600,
                size: 20,
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        LucideIcons.x,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: () {
                        controller.clear();
                        setState(() {}); // Update UI to hide the clear button
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              setState(() {}); // Update UI for clear button visibility
            },
          );
        },
        suggestionsCallback: (pattern) async {
          // Return empty list if pattern is empty
          if (pattern.isEmpty) return [];
          
          final searchTerm = pattern.toLowerCase().trim();
          
          final filteredProducts = _allProducts.where((product) {
            final productName = product.name.toLowerCase();
            final productCategory = product.category.toLowerCase();
            
            final matches = productName.contains(searchTerm) ||
                           productCategory.contains(searchTerm);
            
            return matches;
          }).toList();
          
          return filteredProducts.take(5).toList();
        },
        itemBuilder: (context, product) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade100,
                  width: 0.5,
                ),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    product.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        LucideIcons.utensils,
                        color: AppTheme.primaryColor,
                        size: 20,
                      );
                    },
                  ),
                ),
              ),
              title: Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                product.category,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              trailing: Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
        onSelected: (product) {
          // Clear the search field after selection
          _searchController.clear();
          setState(() {}); // Update UI
          
          // Navigate to product detail
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        hideOnEmpty: true,
        hideOnError: true,
        decorationBuilder: (context, child) {
          return Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            shadowColor: Colors.black.withValues(alpha: 0.1),
            color: Colors.white,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: child,
            ),
          );
        },
      ),
    );
  }

}
