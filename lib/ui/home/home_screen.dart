import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../notifications/in_app_notifications_screen.dart';

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
  late final List<Product> _carouselProducts;
  late final List<Product> _gridProducts;

  @override
  void initState() {
    super.initState();
    // Simulate fetching data -> 1.5 seconds loading
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });

    _carouselProducts = dummyProducts.take(5).toList();
    _gridProducts = dummyProducts.skip(5).toList();
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
                                  '$name 🥬',
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
                    Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  LucideIcons.bell,
                                  color: AppTheme.textPrimaryColor,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const InAppNotificationsScreen(),
                                    ),
                                  );
                                },
                              ),
                              Consumer<AppState>(
                                builder: (context, state, child) {
                                  if (state.unreadNotificationsCount > 0) {
                                    return Positioned(
                                      right: 12,
                                      top: 12,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          curve: Curves.easeOutBack,
                        ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: const SizedBox(height: 16)),

          // CAROUSEL
          SliverToBoxAdapter(
            child:
                CarouselSlider.builder(
                      itemCount: _carouselProducts.length,
                      options: CarouselOptions(
                        height: 180,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        viewportFraction: 0.85,
                        autoPlayCurve: Curves.easeInOutCubic,
                        autoPlayAnimationDuration: const Duration(
                          milliseconds: 800,
                        ),
                      ),
                      itemBuilder: (context, index, realIndex) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(
                                  product: _carouselProducts[index],
                                ),
                              ),
                            );
                          },
                          child: _buildHeroCard(_carouselProducts[index]),
                        );
                      },
                    )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fresh Deals',
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
            ).animate().fadeIn(delay: 400.ms),
          ),

          // BENTO GRID
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ).copyWith(bottom: 120), // bottom nav padding
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return _buildBentoRow(index)
                    .animate()
                    .fadeIn(delay: (500 + (index * 100)).ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
              }, childCount: (_gridProducts.length / 2).ceil()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(Product product) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Hero(
              tag: 'product_${product.id}',
              child: Image.asset(product.imagePath, width: 220, height: 220),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '20% OFF',
                    style: TextStyle(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 28,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fresh from farm',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoRow(int rowIndex) {
    // We create a pattern:
    // Row 0: 2 items (split)
    // Row 1: 1 item (wide)
    // Row 2: 2 items (split)
    // etc.

    int itemIndex = rowIndex * 2;
    // Adjust logic for bento
    bool isWideRow = rowIndex % 2 != 0;

    if (isWideRow) {
      if (itemIndex < _gridProducts.length) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildProductCard(_gridProducts[itemIndex], isWide: true),
        );
      }
    } else {
      if (itemIndex + 1 < _gridProducts.length) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Expanded(child: _buildProductCard(_gridProducts[itemIndex])),
              const SizedBox(width: 16),
              Expanded(child: _buildProductCard(_gridProducts[itemIndex + 1])),
            ],
          ),
        );
      } else if (itemIndex < _gridProducts.length) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildProductCard(_gridProducts[itemIndex]),
        );
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildProductCard(Product product, {bool isWide = false}) {
    return Container(
      height: isWide ? 160 : 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: isWide
              ? _buildWideCardContent(product)
              : _buildSquareCardContent(product),
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
                  CustomSnackbar.showSuccess(
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

  Widget _buildWideCardContent(Product product) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    product.category,
                    style: TextStyle(
                      color: AppTheme.secondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        context.read<AppState>().addToCart(product);

                        context.read<AppState>().addNotification(
                          title: 'Added to Cart',
                          body: '${product.name} was added to your cart.',
                        );
                        CustomSnackbar.showSuccess(
                          context: context,
                          message: '${product.name} added to cart',
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Hero(
              tag: 'product_${product.id}',
              child: Image.asset(product.imagePath)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(
                    begin: -5,
                    end: 5,
                    duration: 2.seconds,
                    curve: Curves.easeInOutSine,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
