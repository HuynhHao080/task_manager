import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/User.dart';
import 'UserFirebaseService.dart';

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserFirebaseService _userService = UserFirebaseService();

  /// Đăng ký bằng Email & Password
  Future<fb.UserCredential> registerWithEmail(
      String email, String password, String username) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = cred.user!;
    await user.updateDisplayName(username);
    await user.reload();

    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }

    return cred;
  }

  /// Đăng nhập bằng Email & Password
  Future<fb.UserCredential> signInWithEmail(
      String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    final user = cred.user!;

    if (!user.emailVerified) {
      await _auth.signOut();
      throw Exception('Email chưa xác thực. Vui lòng xác thực email trước.');
    }

    await ensureUserInFirestore(user);
    await updateLastActive(user.uid);
    return cred;
  }

  /// Đăng nhập bằng Google và ép chọn tài khoản mới
  Future<fb.UserCredential?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Ép chọn tài khoản mới

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      final user = cred.user;

      if (user != null) {
        await ensureUserInFirestore(user);
        await updateLastActive(user.uid);
      }

      return cred;
    } on fb.FirebaseAuthException catch (e) {
      throw Exception('Đăng nhập Google thất bại: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định khi đăng nhập Google: $e');
    }
  }

  /// Đăng xuất
  Future<void> signOut() async => _auth.signOut();

  /// Cập nhật thời gian hoạt động cuối
  Future<void> updateLastActive(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastActive': Timestamp.now(),
    });
  }

  /// Đảm bảo người dùng đã tồn tại trong Firestore
  Future<void> ensureUserInFirestore(fb.User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      final now = DateTime.now();
      final newUser = User(
        id: user.uid,
        username: (user.displayName?.trim().isNotEmpty ?? false)
            ? user.displayName!
            : (user.email ?? 'Unknown'),
        password: '',
        email: user.email ?? '',
        avatar: user.photoURL,
        createdAt: now,
        lastActive: now,
      );
      await _userService.addUser(newUser);
    }
  }
}
