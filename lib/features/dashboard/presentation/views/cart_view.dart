import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello/core/theme/app_theme.dart';
import 'package:zello/features/dashboard/application/cart_provider.dart';
import 'package:zello/features/dashboard/application/wishlist_provider.dart';
import 'package:zello/features/admin/application/product_provider.dart';

class CartView extends ConsumerStatefulWidget {
  const CartView({super.key});

  @override
  ConsumerState<CartView> createState() => _CartViewState();
}

class _CartViewState extends ConsumerState<CartView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'My Cart'),
            Tab(text: 'Saved Items'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCartTab(),
              _buildSavedTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartTab() {
    final cartItems = ref.watch(cartProvider);
    final total = ref.read(cartProvider.notifier).cartTotal;

    if (cartItems.isEmpty) {
      return const Center(child: Text('Your cart is empty.'));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];

              return Dismissible(
                key: Key(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  // Capture item for undo
                  final removedItem = item;
                  
                  ref.read(cartProvider.notifier).removeFromCart(item.id);
                  
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${removedItem.product.name} removed from cart'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          ref.read(cartProvider.notifier).addToCart(removedItem.product, removedItem.quantity);
                        },
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: item.product.images.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.product.images.first,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey),
                                  ),
                                )
                              : const Icon(Icons.image, color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 8),
                              Text(
                                '\$${item.product.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () => ref.read(cartProvider.notifier).updateQuantity(item.id, item.quantity - 1),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                                      child: const Icon(Icons.remove, size: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 12),
                                  InkWell(
                                    onTap: item.product.stock > item.quantity 
                                      ? () => ref.read(cartProvider.notifier).updateQuantity(item.id, item.quantity + 1)
                                      : null,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: item.product.stock > item.quantity ? Colors.grey.shade200 : Colors.grey.shade100, 
                                        borderRadius: BorderRadius.circular(4)
                                      ),
                                      child: Icon(Icons.add, size: 16, color: item.product.stock > item.quantity ? Colors.black : Colors.grey),
                                    ),
                                  ),
                                ],
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
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Grand Total', style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to checkout
                    context.push('/checkout');
                  },
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSavedTab() {
    final wishlistedIds = ref.watch(wishlistProvider);
    final productsAsync = ref.watch(productProvider);

    return productsAsync.when(
      data: (products) {
        final savedProducts = products.where((p) => wishlistedIds.contains(p.id)).toList();

        if (savedProducts.isEmpty) {
          return const Center(child: Text('No saved items.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
          itemCount: savedProducts.length,
          itemBuilder: (context, index) {
            final product = savedProducts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: product.images.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        )
                      : const Icon(Icons.image, color: Colors.grey),
                ),
                title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.add_shopping_cart, color: AppTheme.primaryColor),
                  onPressed: () {
                    if (product.stock > 0) {
                      ref.read(cartProvider.notifier).addToCart(product, 1);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Moved to cart'), duration: Duration(seconds: 1)));
                    }
                  },
                ),
                onTap: () {
                   context.push('/product-detail', extra: product);
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const Center(child: Text('Failed to load saved items')),
    );
  }
}
