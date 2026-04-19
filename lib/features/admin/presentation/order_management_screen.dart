import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello/core/theme/app_theme.dart';
import 'package:zello/features/admin/application/order_provider.dart';
import 'package:zello/features/admin/domain/order.dart';

class OrderManagementScreen extends ConsumerStatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  ConsumerState<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends ConsumerState<OrderManagementScreen> {
  OrderStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Orders'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(null, 'All'),
                const SizedBox(width: 8),
                _buildFilterChip(OrderStatus.pending, 'Pending'),
                const SizedBox(width: 8),
                _buildFilterChip(OrderStatus.confirmed, 'Confirmed'),
                const SizedBox(width: 8),
                _buildFilterChip(OrderStatus.shipped, 'Shipped'),
                const SizedBox(width: 8),
                _buildFilterChip(OrderStatus.delivered, 'Delivered'),
                const SizedBox(width: 8),
                _buildFilterChip(OrderStatus.cancelled, 'Cancelled'),
              ],
            ),
          ),
        ),
      ),
      body: ordersAsync.when(
        data: (orders) {
          final filteredOrders = _statusFilter == null
              ? orders
              : orders.where((o) => o.status == _statusFilter).toList();

          if (filteredOrders.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              return _buildOrderCard(context, ref, order);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildFilterChip(OrderStatus? status, String label) {
    final isSelected = _statusFilter == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _statusFilter = status);
        }
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, WidgetRef ref, Order order) {
    Color statusColor;
    switch (order.status) {
      case OrderStatus.pending:
        statusColor = Colors.orange;
        break;
      case OrderStatus.confirmed:
        statusColor = Colors.blue;
        break;
      case OrderStatus.shipped:
        statusColor = Colors.purple;
        break;
      case OrderStatus.delivered:
        statusColor = Colors.green;
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showStatusUpdateModal(context, ref, order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.id,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      order.status.name,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Customer: ${order.customerName}', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusUpdateModal(BuildContext context, WidgetRef ref, Order order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update Status for ${order.id}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...OrderStatus.values.map((status) {
                return RadioListTile<OrderStatus>(
                  title: Text(status.name),
                  value: status,
                  groupValue: order.status,
                  onChanged: (newStatus) {
                    if (newStatus != null) {
                      ref.read(orderProvider.notifier).updateOrderStatus(order.id, newStatus);
                    }
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
