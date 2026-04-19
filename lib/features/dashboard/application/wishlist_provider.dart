import 'package:flutter_riverpod/flutter_riverpod.dart';

// Stores a list of product IDs that are bookmarked
class WishlistNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return [];
  }

  void toggleWishlist(String productId) {
    if (state.contains(productId)) {
      state = state.where((id) => id != productId).toList();
    } else {
      state = [...state, productId];
    }
  }

  bool isWishlisted(String productId) {
    return state.contains(productId);
  }
}

final wishlistProvider = NotifierProvider<WishlistNotifier, List<String>>(WishlistNotifier.new);
