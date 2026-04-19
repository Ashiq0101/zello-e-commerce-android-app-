enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

extension OrderStatusExtension on OrderStatus {
  String get name {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class Order {
  final String id;
  final String customerName;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.customerName,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  Order copyWith({
    String? id,
    String? customerName,
    double? totalAmount,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
