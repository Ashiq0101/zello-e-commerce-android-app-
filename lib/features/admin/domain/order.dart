import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String userId;
  final String customerName;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final List<Map<String, dynamic>> items;

  Order({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  Order copyWith({
    String? id,
    String? userId,
    String? customerName,
    double? totalAmount,
    OrderStatus? status,
    DateTime? createdAt,
    List<Map<String, dynamic>>? items,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = DateTime.now();
    if (json['createdAt'] != null) {
      if (json['createdAt'] is Timestamp) {
        parsedDate = (json['createdAt'] as Timestamp).toDate();
      } else if (json['createdAt'] is String) {
        parsedDate = DateTime.tryParse(json['createdAt']) ?? DateTime.now();
      }
    }

    return Order(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      customerName: json['customerName'] ?? 'Unknown',
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == (json['status'] ?? 'pending').toString().toLowerCase(),
        orElse: () => OrderStatus.pending,
      ),
      createdAt: parsedDate,
      items: List<Map<String, dynamic>>.from(json['items'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'customerName': customerName,
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last.toLowerCase(),
      'createdAt': createdAt,
      'items': items,
    };
  }
}
