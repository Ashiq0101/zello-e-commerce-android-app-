import 'package:zello/features/admin/domain/product.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
