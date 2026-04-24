import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello/core/theme/app_theme.dart';
import 'package:zello/features/dashboard/application/cart_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zello/features/admin/domain/order.dart' as order_domain;
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPaymentMethod = 'Cash on Delivery'; // Manual fallback
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _placeOrder() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a delivery address')));
      return;
    }

    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) return;

    final total = ref.read(cartProvider.notifier).cartTotal;
    final currentUser = FirebaseAuth.instance.currentUser;
    
    // Create new order in Firestore
    try {
      final orderRef = FirebaseFirestore.instance.collection('orders').doc();
      
      final newOrder = order_domain.Order(
        id: orderRef.id,
        userId: currentUser?.uid ?? 'guest',
        customerName: currentUser?.displayName ?? 'User',
        totalAmount: total,
        status: order_domain.OrderStatus.pending,
        createdAt: DateTime.now(),
        items: cartItems.map((item) => {
          'productName': item.product.name,
          'quantity': item.quantity,
          'price': item.product.price,
        }).toList(),
      );

      await orderRef.set(newOrder.toJson());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
      }
      return;
    }

    ref.read(cartProvider.notifier).clearCart();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text('Order Placed Successfully!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const Text('Your order has been recorded. You will be notified when it ships.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/dashboard');
                  },
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.read(cartProvider.notifier).cartTotal;

    if (cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('Your cart is empty.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            ...cartItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('${item.quantity}x ${item.product.name}')),
                  Text('\$${(item.product.price * item.quantity).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppTheme.primaryColor)),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Shipping Address
            const Text('Shipping Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your full delivery address here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            const SizedBox(height: 40),

            // Payment Method
            const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RadioListTile<String>(
                value: 'Cash on Delivery',
                groupValue: _selectedPaymentMethod,
                activeColor: AppTheme.primaryColor,
                title: const Text('Cash on Delivery (Manual)'),
                subtitle: const Text('SSL Commerz is currently disabled.'),
                onChanged: (val) {
                  setState(() => _selectedPaymentMethod = val!);
                },
              ),
            ),
            
            const SizedBox(height: 60),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _placeOrder,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirm Order', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
