import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager_01/TASKMANAGER/service/AuthService.dart';
import 'package:task_manager_01/TASKMANAGER/view/ForgotPasswordScreen.dart';
import 'HomeScreen.dart';
import 'RegisterScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(Future<UserCredential?> Function() loginMethod) async {
    setState(() => _loading = true);

    try {
      final cred = await loginMethod();
      final user = cred?.user;

      if (user != null) {
        final isEmailLogin = user.providerData.any((p) => p.providerId == 'password');
        if (isEmailLogin && !user.emailVerified) {
          await FirebaseAuth.instance.signOut();
          return _showSnack('Vui lòng xác thực email trước khi đăng nhập.', Colors.orange);
        }

        await _authService.ensureUserInFirestore(user);
        await _authService.updateLastActive(user.uid);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'user-not-found' => 'Tài khoản không tồn tại.',
        'wrong-password' => 'Sai mật khẩu.',
        _ => 'Đăng nhập thất bại.',
      };
      _showSnack(msg, Colors.redAccent);
    } catch (e) {
      _showSnack('Đăng nhập thất bại: $e', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔐 Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailCtrl,
                decoration: _inputDecoration('Email'),
                validator: (v) => v == null || !v.contains('@') ? 'Email không hợp lệ' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                decoration: _inputDecoration('Mật khẩu'),
                obscureText: true,
                validator: (v) => v == null || v.length < 6 ? 'Mật khẩu ≥ 6 ký tự' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.login),
                label: const Text('Đăng nhập', style: TextStyle(fontSize: 16)),
                onPressed: _loading
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    _handleLogin(() => _authService.signInWithEmail(
                      _emailCtrl.text.trim(),
                      _passCtrl.text.trim(),
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loading
                    ? null
                    : () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                ),
                child: const Text('Quên mật khẩu?'),
              ),
              const Divider(height: 32),
              ElevatedButton.icon(
                icon: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.g_mobiledata, size: 28),
                label: const Text('Đăng nhập bằng Google'),
                onPressed: _loading ? null : () => _handleLogin(() => _authService.signInWithGoogle()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _loading
                    ? null
                    : () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text('Tạo tài khoản mới'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
