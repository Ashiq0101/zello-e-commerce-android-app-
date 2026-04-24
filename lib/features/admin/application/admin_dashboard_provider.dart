import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStats {
  final int totalUsers;
  final int totalProducts;
  final int ordersToday;
  final double revenueToday;

  AdminStats({
    required this.totalUsers,
    required this.totalProducts,
    required this.ordersToday,
    required this.revenueToday,
  });
}

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final firestore = FirebaseFirestore.instance;
  
  // Fetch total users dynamically
  final usersSnapshot = await firestore.collection('users').count().get();
  final totalUsers = usersSnapshot.count ?? 0;
  
  // Fetch total products dynamically
  final productsSnapshot = await firestore.collection('products').count().get();
  final totalProducts = productsSnapshot.count ?? 0;
  
  // Fetch orders today dynamically
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final ordersSnapshot = await firestore.collection('orders')
      .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
      .count()
      .get();
  final ordersToday = ordersSnapshot.count ?? 0;
  
  // Keeping revenue hardcoded as requested
  return AdminStats(
    totalUsers: totalUsers,
    totalProducts: totalProducts,
    ordersToday: ordersToday,
    revenueToday: 1250.50,
  );
});
