import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello/features/admin/domain/order.dart' as order_domain;

class UserOrderNotifier extends Notifier<AsyncValue<List<order_domain.Order>>> {
  StreamSubscription? _subscription;

  @override
  AsyncValue<List<order_domain.Order>> build() {
    _subscribeToUserOrders();
    return const AsyncValue.loading();
  }

  void _subscribeToUserOrders() {
    _subscription?.cancel();
    
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      state = const AsyncValue.data([]);
      return;
    }

    _subscription = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .listen((snapshot) {
      final orders = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return order_domain.Order.fromJson(data);
      }).toList();
      
      // Sort locally to avoid requiring a composite index in Firestore
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      state = AsyncValue.data(orders);
    }, onError: (error) {
      state = AsyncValue.error(error, StackTrace.current);
    });
  }
}

final userOrderProvider = NotifierProvider<UserOrderNotifier, AsyncValue<List<order_domain.Order>>>(UserOrderNotifier.new);
