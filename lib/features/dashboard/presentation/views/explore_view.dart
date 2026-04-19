import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello/core/theme/app_theme.dart';
import 'package:zello/features/admin/application/product_provider.dart';
import 'package:zello/features/admin/domain/product.dart';
import 'package:zello/features/dashboard/presentation/widgets/product_card.dart';

class ExploreView extends ConsumerStatefulWidget {
  const ExploreView({super.key});

  @override
  ConsumerState<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends ConsumerState<ExploreView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;
  String _searchQuery = '';
  
  // Filter states
  bool _inStockOnly = false;
  double _minRating = 0.0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productProvider);

    return Column(
      children: [
        // Search & Toolbar Container
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune, color: AppTheme.primaryColor),
                      onPressed: _showFilterBottomSheet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _searchQuery.isEmpty ? 'All Products' : 'Search Results',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                    onPressed: () => setState(() => _isGridView = !_isGridView),
                    color: Colors.grey.shade700,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Products List/Grid
        Expanded(
          child: productsAsync.when(
            data: (products) {
              // Apply filters
              var filtered = products.where((p) => p.isActive).toList();
              
              if (_searchQuery.isNotEmpty) {
                filtered = filtered.where((p) => 
                  p.name.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();
              }
              
              if (_inStockOnly) {
                filtered = filtered.where((p) => p.stock > 0).toList();
              }
              
              if (_minRating > 0) {
                filtered = filtered.where((p) => p.avgRating >= _minRating).toList();
              }

              if (filtered.isEmpty) {
                return const Center(child: Text('No products found matching your criteria.'));
              }

              return _isGridView 
                ? _buildGridView(filtered)
                : _buildListView(filtered);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Center(child: Text('Failed to load catalog')),
          ),
        ),
      ],
    );
  }

  Widget _buildGridView(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100, top: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        // Wrap with unconstrained so the card fills the grid cell properly
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: ProductCard(
            product: products[index],
            onTap: () {
              context.push('/product-detail', extra: products[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildListView(List<Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100, top: 8),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () {
               context.push('/product-detail', extra: product);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: product.images.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              product.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (c,e,s) => const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          )
                        : const Icon(Icons.image, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              product.avgRating.toStringAsFixed(1),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filter & Sort', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 24),
                  
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('In-Stock Only', style: TextStyle(fontWeight: FontWeight.bold)),
                    value: _inStockOnly,
                    onChanged: (val) {
                      setModalState(() => _inStockOnly = val);
                      setState(() => _inStockOnly = val);
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  
                  const SizedBox(height: 16),
                  const Text('Minimum Rating', style: TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: _minRating,
                    min: 0.0,
                    max: 5.0,
                    divisions: 5,
                    label: '${_minRating.toStringAsFixed(1)} Stars',
                    activeColor: AppTheme.primaryColor,
                    onChanged: (val) {
                      setModalState(() => _minRating = val);
                      setState(() => _minRating = val);
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply Filters'),
                    ),
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }
}
