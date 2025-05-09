import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/User.dart';

class UserDetailScreen extends StatelessWidget {
  final User user;
  const UserDetailScreen({Key? key, required this.user}) : super(key: key);

  Widget _infoTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final created = DateFormat.yMMMMd().add_Hm().format(user.createdAt);
    final lastActive = DateFormat.yMMMMd().add_Hm().format(user.lastActive);

    return Scaffold(
      appBar: AppBar(title: Text('👤 ${user.username}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
                backgroundColor: Colors.grey.shade200,
                child: user.avatar == null
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            _infoTile(context: context, icon: Icons.email, label: 'Email', value: user.email),
            _infoTile(context: context, icon: Icons.calendar_today, label: 'Ngày tạo', value: created),
            _infoTile(context: context, icon: Icons.schedule, label: 'Hoạt động cuối', value: lastActive),
            _infoTile(
              context: context,
              icon: Icons.security,
              label: 'Vai trò',
              value: user.role == 'admin' ? 'Quản trị viên' : 'Người dùng',
            ),
          ],
        ),
      ),
    );
  }
}
