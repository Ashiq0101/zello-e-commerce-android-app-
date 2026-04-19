import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello/features/admin/domain/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserNotifier extends Notifier<AsyncValue<List<AppUser>>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  AsyncValue<List<AppUser>> build() {
    _fetchUsers();
    return const AsyncValue.loading();
  }

  void _fetchUsers() {
    _firestore.collection('users').snapshots().listen((snapshot) {
      final users = snapshot.docs.map((doc) {
        return AppUser.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
      state = AsyncValue.data(users);
    }, onError: (error) {
      state = AsyncValue.error(error, StackTrace.current);
    });
  }

  Future<void> registerNewUser(String name, String email) async {
    try {
      final query = await _firestore.collection('users').where('email', isEqualTo: email).get();
      if (query.docs.isEmpty) {
        final newUser = AppUser(
          id: '',
          name: name,
          email: email,
          joinDate: DateTime.now(),
          totalOrders: 0,
          isDisabled: false,
        );
        final docRef = await _firestore.collection('users').add(newUser.toJson());
        await docRef.update({'id': docRef.id});
      }
    } catch (e) {
      print('Error registering user: $e');
    }
  }

  Future<void> updateProfilePicture(String userId, String newUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({'profilePictureUrl': newUrl});
    } catch (e) {
      print('Error updating profile picture: $e');
    }
  }

  Future<void> toggleDisableUser(String userId, bool isDisabled) async {
    try {
      await _firestore.collection('users').doc(userId).update({'isDisabled': isDisabled});
    } catch (e) {
      print('Error parsing user status: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}

final adminUserProvider = NotifierProvider<UserNotifier, AsyncValue<List<AppUser>>>(UserNotifier.new);

final currentUserProvider = Provider<AppUser?>((ref) {
  final users = ref.watch(adminUserProvider).value;
  if (users == null || users.isEmpty) return null;
  // Currently active user based on most recent join date (as a placeholder for actual logged-in user auth ID)
  final activeList = users.where((u) => !u.isDisabled).toList();
  activeList.sort((a,b) => b.joinDate.compareTo(a.joinDate));
  return activeList.isNotEmpty ? activeList.first : null;
});
