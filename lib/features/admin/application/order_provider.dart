import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello/features/admin/domain/order.dart';

class OrderNotifier extends Notifier<AsyncValue<List<Order>>> {
  StreamSubscription? _subscription;

  @override
  AsyncValue<List<Order>> build() {
    _subscribeToOrders();
    return const AsyncValue.loading();
  }

  void _subscribeToOrders() {
    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final orders = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Order.fromJson(data);
      }).toList();
      state = AsyncValue.data(orders);
    }, onError: (error) {
      state = AsyncValue.error(error, StackTrace.current);
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': newStatus.toString().split('.').last.toLowerCase(),
      });
    } catch (e) {
      print('Error updating order status: $e');
    }
  }
}

final orderProvider = NotifierProvider<OrderNotifier, AsyncValue<List<Order>>>(OrderNotifier.new);
