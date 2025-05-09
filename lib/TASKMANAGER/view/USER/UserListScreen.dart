import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../model/User.dart' as model;
import '../../service/UserFirebaseService.dart';
import '../../view/USER/EditUserScreen.dart';
import '../../view/USER/UserDetailScreen.dart';
import '../../view/USER/ChangePasswordScreen.dart';
import '../../view/USER/UserListItem.dart';

class UserListScreen extends StatefulWidget {
  final bool isAdmin;
  const UserListScreen({Key? key, required this.isAdmin}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _service = UserFirebaseService();
  String _searchQuery = '';
  String _sortBy = 'createdAt';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👥 Danh sách người dùng'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'createdAt', child: Text('📅 Sắp xếp theo tạo mới')),
              PopupMenuItem(value: 'lastActive', child: Text('⏱️ Sắp xếp theo hoạt động')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Tìm theo tên hoặc email...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<model.User>>(
        stream: _service.usersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var users = snapshot.data ?? [];
          if (users.isEmpty) return const Center(child: Text('⚠️ Chưa có người dùng nào.'));

          final currentUser = fb.FirebaseAuth.instance.currentUser;

          // Lọc theo tìm kiếm
          users = users.where((u) {
            final name = u.username?.toLowerCase() ?? '';
            final email = u.email?.toLowerCase() ?? '';
            return name.contains(_searchQuery) || email.contains(_searchQuery);
          }).toList();

          // Tách bản thân và người khác
          model.User? myself;
          final others = <model.User>[];

          for (final u in users) {
            if (u.id == currentUser?.uid) {
              myself = u;
            } else {
              others.add(u);
            }
          }

          // Sắp xếp người khác
          others.sort((a, b) {
            final aField = _sortBy == 'createdAt' ? a.createdAt : a.lastActive;
            final bField = _sortBy == 'createdAt' ? b.createdAt : b.lastActive;
            return (bField ?? DateTime(2000)).compareTo(aField ?? DateTime(2000));
          });

          final displayUsers = [
            if (myself != null) myself,
            ...others,
          ];

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: displayUsers.length,
            itemBuilder: (_, index) {
              final user = displayUsers[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: UserListItem(
                  user: user,
                  isAdmin: widget.isAdmin,
                  onTap: () => _open(UserDetailScreen(user: user)),
                  onEdit: () => _open(EditUserScreen(user: user)),
                  onDelete: () => _confirmDelete(user),
                  onChangePassword: () => _open(const ChangePasswordScreen()),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _confirmDelete(model.User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🗑️ Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa người dùng này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteUserBackend(user);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Xóa thành công'), backgroundColor: Colors.green),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Xóa thất bại: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }
}
