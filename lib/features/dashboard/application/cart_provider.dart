import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello/features/dashboard/domain/cart_item.dart';
import 'package:zello/features/admin/domain/product.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return [];
  }

  void addToCart(Product product, int quantity) {
    // Check if exists
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      final updatedCart = List<CartItem>.from(state);
      final currentItem = updatedCart[existingIndex];
      updatedCart[existingIndex] = currentItem.copyWith(quantity: currentItem.quantity + quantity);
      state = updatedCart;
    } else {
      final newItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
        quantity: quantity,
      );
      state = [...state, newItem];
    }
  }

  void removeFromCart(String cartItemId) {
    state = state.where((item) => item.id != cartItemId).toList();
  }

  void updateQuantity(String cartItemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(cartItemId);
      return;
    }

    state = state.map((item) {
      if (item.id == cartItemId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();
  }
  
  void clearCart() {
    state = [];
  }

  int get cartCount => state.fold(0, (total, item) => total + item.quantity);
  
  double get cartTotal => state.fold(0.0, (total, item) => total + (item.product.price * item.quantity));
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);
