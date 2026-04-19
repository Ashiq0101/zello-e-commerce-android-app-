import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello/features/admin/domain/category.dart';

class CategoryNotifier extends Notifier<AsyncValue<List<Category>>> {
  @override
  AsyncValue<List<Category>> build() {
    _fetchCategories();
    return const AsyncValue.loading();
  }

  Future<void> _fetchCategories() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    final mockCategories = [
      Category(id: '1', name: 'Electronics', imageUrl: 'https://via.placeholder.com/150'),
      Category(id: '2', name: 'Clothing', imageUrl: 'https://via.placeholder.com/150'),
      Category(id: '3', name: 'Food', imageUrl: 'https://via.placeholder.com/150'),
    ];
    
    state = AsyncValue.data(mockCategories);
  }

  Future<void> addCategory(String name, String imageUrl) async {
    final currentList = state.value ?? [];
    final newCategory = Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      imageUrl: imageUrl,
    );
    state = AsyncValue.data([...currentList, newCategory]);
  }

  Future<void> updateCategory(String id, String newName, String newImageUrl) async {
    final currentList = state.value ?? [];
    final updatedList = currentList.map((c) {
      if (c.id == id) {
        return c.copyWith(name: newName, imageUrl: newImageUrl);
      }
      return c;
    }).toList();
    state = AsyncValue.data(updatedList);
  }

  Future<void> deleteCategory(String id) async {
    final currentList = state.value ?? [];
    final updatedList = currentList.where((c) => c.id != id).toList();
    state = AsyncValue.data(updatedList);
  }
}

final categoryProvider = NotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>(CategoryNotifier.new);
