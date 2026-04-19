import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello/core/theme/app_theme.dart';
import 'package:zello/features/admin/domain/product.dart';
import 'package:zello/features/dashboard/application/cart_provider.dart';
import 'package:zello/features/dashboard/application/wishlist_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  int _quantity = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.8),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: Icon(
                  ref.watch(wishlistProvider).contains(widget.product.id) ? Icons.favorite : Icons.favorite_border,
                  color: ref.watch(wishlistProvider).contains(widget.product.id) ? Colors.red : Colors.black,
                ),
                onPressed: () {
                  ref.read(wishlistProvider.notifier).toggleWishlist(widget.product.id);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wishlist Updated!'), duration: Duration(seconds: 1)));
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            SizedBox(
              height: 400,
              width: double.infinity,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemCount: widget.product.images.isEmpty ? 1 : widget.product.images.length,
                    itemBuilder: (context, index) {
                      if (widget.product.images.isEmpty) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.image, size: 80, color: Colors.grey)),
                        );
                      }
                      return Image.network(
                        widget.product.images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.broken_image, size: 80, color: Colors.grey)),
                        ),
                      );
                    },
                  ),
                  if (widget.product.images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.product.images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentImageIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index ? AppTheme.primaryColor : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Product Info
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '\$${widget.product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              widget.product.avgRating.toStringAsFixed(1),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (widget.product.stock > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('In Stock', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Out of Stock', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        )
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: const TextStyle(color: Colors.black54, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    ),
                    Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: widget.product.stock > _quantity ? () => setState(() => _quantity++) : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Add to Cart Button
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.product.stock > 0
                      ? () {
                          ref.read(cartProvider.notifier).addToCart(widget.product, _quantity);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Cart!'), duration: Duration(seconds: 1)));
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(widget.product.stock > 0 ? 'Add to Cart' : 'Out of Stock'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
