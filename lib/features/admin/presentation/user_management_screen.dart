import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello/features/admin/application/user_provider.dart';
import 'package:zello/features/admin/domain/app_user.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUserProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Registered Users'),
      ),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserCard(context, ref, user);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, WidgetRef ref, AppUser user) {
    final isStrikethrough = user.isDisabled;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: user.isDisabled ? Colors.grey.shade100 : Colors.white,
      child: ExpansionTile(
        title: Text(
          user.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isStrikethrough ? TextDecoration.lineThrough : null,
            color: isStrikethrough ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(user.email, style: const TextStyle(fontSize: 13)),
        leading: CircleAvatar(
          backgroundColor: user.isDisabled ? Colors.grey.shade300 : Colors.blue.shade100,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: TextStyle(color: user.isDisabled ? Colors.grey.shade600 : Colors.blue.shade800),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Orders:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${user.totalOrders}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Join Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${user.joinDate.day}/${user.joinDate.month}/${user.joinDate.year}'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ref.read(adminUserProvider.notifier).toggleDisableUser(user.id, !user.isDisabled);
                      },
                      icon: Icon(user.isDisabled ? Icons.check_circle : Icons.block, 
                        color: user.isDisabled ? Colors.green : Colors.orange),
                      label: Text(user.isDisabled ? 'Enable User' : 'Disable User'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context, ref, user),
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Logic to see user orders
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order history coming soon!')));
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('View User Orders'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, AppUser user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete User Account'),
          content: Text('Are you sure you want to permanently delete "${user.email}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(adminUserProvider.notifier).deleteUser(user.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User deleted')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
