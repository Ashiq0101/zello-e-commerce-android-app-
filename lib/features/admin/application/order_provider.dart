import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello/features/admin/domain/order.dart';

class OrderNotifier extends Notifier<AsyncValue<List<Order>>> {
  @override
  AsyncValue<List<Order>> build() {
    _fetchOrders();
    return const AsyncValue.loading();
  }

  Future<void> _fetchOrders() async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final mockOrders = [
      Order(
        id: 'ORD-1001',
        customerName: 'Alice Smith',
        totalAmount: 120.50,
        status: OrderStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Order(
        id: 'ORD-1002',
        customerName: 'Bob Jones',
        totalAmount: 89.99,
        status: OrderStatus.confirmed,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Order(
        id: 'ORD-1003',
        customerName: 'Charlie Brown',
        totalAmount: 250.00,
        status: OrderStatus.shipped,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Order(
        id: 'ORD-1004',
        customerName: 'Diana Prince',
        totalAmount: 45.00,
        status: OrderStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
    
    // Sort newest first
    mockOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = AsyncValue.data(mockOrders);
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final currentList = state.value ?? [];
    final updatedList = currentList.map((o) {
      if (o.id == orderId) {
        return o.copyWith(status: newStatus);
      }
      return o;
    }).toList();
    
    state = AsyncValue.data(updatedList);
  }
}

final orderProvider = NotifierProvider<OrderNotifier, AsyncValue<List<Order>>>(OrderNotifier.new);
