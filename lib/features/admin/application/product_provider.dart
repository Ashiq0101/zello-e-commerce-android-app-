import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello/features/admin/domain/product.dart';

class ProductNotifier extends Notifier<AsyncValue<List<Product>>> {
  final _firestore = FirebaseFirestore.instance;

  @override
  AsyncValue<List<Product>> build() {
    _fetchProducts();
    return const AsyncValue.loading();
  }

  Future<void> _fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      final products = snapshot.docs.map((doc) => Product.fromJson({...doc.data(), 'id': doc.id})).toList();
      state = AsyncValue.data(products);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final docRef = await _firestore.collection('products').add(product.toJson());
      final newProduct = product.copyWith(id: docRef.id);
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newProduct]);
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).update(product.toJson());
      final currentList = state.value ?? [];
      final updatedList = currentList.map((p) => p.id == product.id ? product : p).toList();
      state = AsyncValue.data(updatedList);
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  Future<void> updateStock(String productId, int newStock) async {
    try {
      await _firestore.collection('products').doc(productId).update({'stock': newStock});
      final currentList = state.value ?? [];
      final updatedList = currentList.map((p) => p.id == productId ? p.copyWith(stock: newStock) : p).toList();
      state = AsyncValue.data(updatedList);
    } catch (e) {
      print('Error updating stock: $e');
    }
  }

  Future<void> toggleActive(String productId, bool isActive) async {
    try {
      await _firestore.collection('products').doc(productId).update({'isActive': isActive});
      final currentList = state.value ?? [];
      final updatedList = currentList.map((p) => p.id == productId ? p.copyWith(isActive: isActive) : p).toList();
      state = AsyncValue.data(updatedList);
    } catch (e) {
       print('Error toggling active: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      final currentList = state.value ?? [];
      final updatedList = currentList.where((p) => p.id != productId).toList();
      state = AsyncValue.data(updatedList);
    } catch (e) {
      print('Error deleting product: $e');
    }
  }
}

final productProvider = NotifierProvider<ProductNotifier, AsyncValue<List<Product>>>(ProductNotifier.new);
