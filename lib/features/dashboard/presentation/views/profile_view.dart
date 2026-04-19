import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello/core/theme/app_theme.dart';
import 'package:zello/features/auth/application/auth_provider.dart';
import 'package:zello/features/admin/application/user_provider.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Header Profile Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.primaryDark,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              boxShadow: [
                BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // Mock rotating profile pictures
                    final avatars = [
                      'https://i.pravatar.cc/150?img=68',
                      'https://i.pravatar.cc/150?img=12',
                      'https://i.pravatar.cc/150?img=47',
                      'https://i.pravatar.cc/150?img=5'
                    ];
                    final currentIdx = avatars.indexOf(currentUser.profilePictureUrl);
                    final nextIdx = (currentIdx + 1) % avatars.length;
                    
                    ref.read(adminUserProvider.notifier).updateProfilePicture(currentUser.id, avatars[nextIdx]);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated!'), duration: Duration(seconds: 1)));
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: Colors.grey.shade200,
                        ),
                        child: ClipOval(
                          child: Image.network(
                            currentUser.profilePictureUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(Icons.person, size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  currentUser.name,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser.email,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildProfileOption(
                  icon: Icons.receipt_long,
                  title: 'Order History',
                  subtitle: 'View your recent purchases',
                  onTap: () {
                    context.push('/order-history');
                  },
                ),
                _buildProfileOption(
                  icon: Icons.location_on,
                  title: 'Saved Addresses',
                  subtitle: 'Manage your delivery locations',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Manage your alerts',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.dark_mode,
                  title: 'Dark Mode',
                  subtitle: 'Toggle application theme',
                  trailing: Switch(
                    value: false, // Defaulting to light mode for now
                    onChanged: (val) {},
                    activeColor: AppTheme.primaryColor,
                  ),
                  onTap: () {},
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      ref.read(authControllerProvider).logout();
                      context.go('/');
                    },
                  ),
                ),
                const SizedBox(height: 100), // Spacing for bottom nav
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
