import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
    );
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final fbUser = fb.FirebaseAuth.instance.currentUser;
      if (fbUser == null) throw Exception('Không tìm thấy người dùng.');

      final oldPass = _oldPassCtrl.text.trim();
      final newPass = _newPassCtrl.text.trim();

      final cred = fb.EmailAuthProvider.credential(email: fbUser.email!, password: oldPass);
      await fbUser.reauthenticateWithCredential(cred);
      await fbUser.updatePassword(newPass);

      if (!mounted) return;
      Navigator.pop(context, true);
      _showSnack('✅ Đổi mật khẩu thành công!');
    } on fb.FirebaseAuthException catch (e) {
      String msg = switch (e.code) {
        'wrong-password' => '❌ Mật khẩu cũ không đúng.',
        'weak-password' => '❗ Mật khẩu mới quá yếu.',
        _ => 'Lỗi đổi mật khẩu: ${e.message}',
      };
      if (mounted) _showSnack(msg);
    } catch (e) {
      if (mounted) _showSnack('⚠️ Lỗi: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔐 Đổi mật khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _oldPassCtrl,
                obscureText: true,
                decoration: _inputDecoration('Mật khẩu cũ', Icons.lock_outline),
                validator: (v) => v == null || v.isEmpty ? 'Nhập mật khẩu cũ' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPassCtrl,
                obscureText: true,
                decoration: _inputDecoration('Mật khẩu mới', Icons.lock),
                validator: (v) => v == null || v.length < 6 ? 'Mật khẩu mới ≥ 6 ký tự' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPassCtrl,
                obscureText: true,
                decoration: _inputDecoration('Xác nhận mật khẩu mới', Icons.lock),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Xác nhận mật khẩu';
                  if (v != _newPassCtrl.text) return 'Mật khẩu không khớp';
                  return null;
                },
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _loading ? null : _handleChangePassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _loading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.lock_open_rounded),
                label: const Text('Cập nhật mật khẩu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
