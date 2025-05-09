import 'package:flutter/material.dart';
import '../../model/User.dart';
import '../../service/UserFirebaseService.dart';
import 'UserForm.dart';

class EditUserScreen extends StatelessWidget {
  final User user;
  const EditUserScreen({Key? key, required this.user}) : super(key: key);

  Future<void> _handleSave(BuildContext context, User updatedUser) async {
    await UserFirebaseService().updateUser(updatedUser);

    if (!context.mounted) return;
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Cập nhật thành công'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật người dùng'),
      ),
      body: UserForm(
        user: user,
        onSave: (updatedUser) => _handleSave(context, updatedUser),
      ),
    );
  }
}
