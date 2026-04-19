import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello/core/theme/app_theme.dart';
import 'package:zello/features/admin/application/category_provider.dart';
import 'package:zello/features/admin/application/product_provider.dart';
import 'package:zello/features/dashboard/presentation/widgets/product_card.dart';

class HomeDashboardView extends ConsumerStatefulWidget {
  const HomeDashboardView({super.key});

  @override
  ConsumerState<HomeDashboardView> createState() => _HomeDashboardViewState();
}

class _HomeDashboardViewState extends ConsumerState<HomeDashboardView> {
  final PageController _pageController = PageController();
  int _currentBannerIndex = 0;
  Timer? _carouselTimer;

  final List<String> mockBanners = [
    'https://via.placeholder.com/800x300/6C63FF/ffffff?text=Summer+Sale+50%25+Off',
    'https://via.placeholder.com/800x300/FF6584/ffffff?text=New+Arrivals',
    'https://via.placeholder.com/800x300/3F3D56/ffffff?text=Free+Shipping',
  ];

  @override
  void initState() {
    super.initState();
    _startCarousel();
  }

  void _startCarousel() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextIndex = (_currentBannerIndex + 1) % mockBanners.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBannerCarousel(),
          _buildCategorySection(),
          _buildSectionHeader('New Arrivals', () {}),
          _buildNewArrivalsLane(),
          _buildSectionHeader('Popular Products', () {}),
          _buildPopularProductsLane(),
          const SizedBox(height: 100), // padding for bottom nav
        ],
      ),
    );
  }

  Widget _buildTopBannerCarousel() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16),
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: mockBanners.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    mockBanners[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40)),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            mockBanners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBannerIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index ? AppTheme.primaryColor : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    final categoriesAsync = ref.watch(categoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Categories', () {}),
        SizedBox(
          height: 100,
          child: categoriesAsync.when(
            data: (categories) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              cat.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Center(child: Text('Failed to load categories')),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          InkWell(
            onTap: onSeeAll,
            child: const Text('See All', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildNewArrivalsLane() {
    final productsAsync = ref.watch(productProvider);
    return SizedBox(
      height: 240,
      child: productsAsync.when(
        data: (products) {
          final activeProducts = products.where((p) => p.isActive).toList();
          return ListView.builder(
            padding: const EdgeInsets.only(left: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: activeProducts.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: activeProducts[index],
                onTap: () {
                  context.push('/product-detail', extra: activeProducts[index]);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text('Error loading products')),
      ),
    );
  }

  Widget _buildPopularProductsLane() {
    final productsAsync = ref.watch(productProvider);
    return SizedBox(
      height: 240,
      child: productsAsync.when(
        data: (products) {
          // Mock sorting for popularity
          final popProducts = products.where((p) => p.isActive).toList();
          popProducts.sort((a, b) => b.avgRating.compareTo(a.avgRating));
          
          return ListView.builder(
            padding: const EdgeInsets.only(left: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: popProducts.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: popProducts[index],
                onTap: () {
                  context.push('/product-detail', extra: popProducts[index]);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text('Error loading products')),
      ),
    );
  }
}
