import 'package:flutter_riverpod/flutter_riverpod.dart';

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

// Mock provider until Firebase is fully connected for Admin
final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  await Future.delayed(const Duration(milliseconds: 800));
  return AdminStats(
    totalUsers: 1420,
    totalProducts: 450,
    ordersToday: 24,
    revenueToday: 1250.50,
  );
});
