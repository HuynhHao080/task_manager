import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cached_network_image/cached_network_image.dart';
import '../../model/User.dart';

class UserListItem extends StatelessWidget {
  final User user;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onChangePassword;
  final bool isAdmin;

  const UserListItem({
    Key? key,
    required this.user,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onChangePassword,
    required this.isAdmin,
  }) : super(key: key);

  bool _isGoogleLogin(fb.User? fbUser) =>
      fbUser?.providerData.any((p) => p.providerId == 'google.com') ?? false;

  @override
  Widget build(BuildContext context) {
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    final isMyself = fbUser?.uid == user.id;
    final userIsAdmin = user.role == 'admin';
    final canEdit = isAdmin || isMyself;
    final showChangePassword = isMyself && !_isGoogleLogin(fbUser) || isAdmin;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: userIsAdmin ? Colors.redAccent : Colors.green.shade400,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade300,
                child: user.avatar != null
                    ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: user.avatar!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.redAccent),
                  ),
                )
                    : const Icon(Icons.person, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              if (canEdit)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showChangePassword)
                      IconButton(
                        icon: const Icon(Icons.lock_reset),
                        tooltip: 'Đổi mật khẩu',
                        color: Colors.deepPurple,
                        onPressed: onChangePassword,
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Sửa thông tin',
                      color: Colors.blueAccent,
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Xóa người dùng',
                      color: Colors.redAccent,
                      onPressed: onDelete,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
