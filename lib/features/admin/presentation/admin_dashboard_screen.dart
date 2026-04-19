import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello/core/theme/app_theme.dart';
import 'package:zello/features/auth/application/auth_provider.dart';
import 'package:zello/features/admin/application/admin_dashboard_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider).logout();
              context.go('/');
            },
          )
        ],
      ),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overview', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(context, 'Total Users', '${stats.totalUsers}', Icons.people, Colors.blue),
                  _buildStatCard(context, 'Total Products', '${stats.totalProducts}', Icons.inventory, Colors.orange),
                  _buildStatCard(context, 'Orders Today', '${stats.ordersToday}', Icons.shopping_bag, Colors.purple),
                  _buildStatCard(context, 'Revenue Today', '\$${stats.revenueToday.toStringAsFixed(2)}', Icons.attach_money, Colors.green),
                ],
              ),
              const SizedBox(height: 32),
              Text('Management', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.category, color: AppTheme.primaryColor),
                title: const Text('Categories'),
                trailing: const Icon(Icons.chevron_right),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () => context.push('/admin/categories'),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.inventory_2, color: AppTheme.primaryColor),
                title: const Text('Products'),
                trailing: const Icon(Icons.chevron_right),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () => context.push('/admin/products'),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.receipt_long, color: AppTheme.primaryColor),
                title: const Text('Orders'),
                trailing: const Icon(Icons.chevron_right),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () => context.push('/admin/orders'),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.manage_accounts, color: AppTheme.primaryColor),
                title: const Text('Users'),
                trailing: const Icon(Icons.chevron_right),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () => context.push('/admin/users'),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
