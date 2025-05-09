import 'package:flutter/material.dart';
import '../../model/User.dart';

/// Form dùng để thêm hoặc chỉnh sửa thông tin User (không đổi mật khẩu)
class UserForm extends StatefulWidget {
  final User? user;
  final Future<void> Function(User) onSave;

  const UserForm({Key? key, this.user, required this.onSave}) : super(key: key);

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _avatarCtrl;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _usernameCtrl = TextEditingController(text: user?.username ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _avatarCtrl = TextEditingController(text: user?.avatar ?? '');
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final user = widget.user!;
    final updatedUser = user.copyWith(
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      avatar: _avatarCtrl.text.trim().isEmpty ? null : _avatarCtrl.text.trim(),
    );

    await widget.onSave(updatedUser);
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _usernameCtrl,
              decoration: _inputDecoration('Username', Icons.person),
              validator: (v) => v == null || v.trim().isEmpty ? 'Nhập username' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              readOnly: isEdit,
              decoration: _inputDecoration('Email', Icons.email),
              validator: (v) => v == null || v.trim().isEmpty ? 'Nhập email' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _avatarCtrl,
              decoration: _inputDecoration('Avatar URL', Icons.image),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _handleSubmit,
              icon: Icon(isEdit ? Icons.edit : Icons.add),
              label: Text(isEdit ? 'CẬP NHẬT' : 'THÊM'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
