import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:dio/dio.dart';
import '../model/User.dart' as model;

/// Service CRUD cho User trên Firestore
class UserFirebaseService {
  final _usersRef = FirebaseFirestore.instance.collection('users');

  /// Stream realtime theo thứ tự tạo
  Stream<List<model.User>> usersStream({
    String sortField = 'createdAt',
    bool descending = true,
  }) {
    return _usersRef
        .orderBy(sortField, descending: descending)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => model.User.fromJson(doc.data(), id: doc.id))
        .toList());
  }

  /// Thêm user mới (yêu cầu có `id`)
  Future<void> addUser(model.User user) {
    if (user.id == null) throw ArgumentError('❌ Thiếu ID người dùng.');
    return _usersRef.doc(user.id).set(user.toJson());
  }

  /// Cập nhật user (yêu cầu có `id`)
  Future<void> updateUser(model.User user) {
    if (user.id == null) throw ArgumentError('❌ Thiếu ID để cập nhật.');
    return _usersRef.doc(user.id).update(user.toJson());
  }

  /// Xóa user (chỉ admin hoặc chính mình), gọi backend xác thực qua token
  Future<void> deleteUserBackend(model.User userToDelete) async {
    final currentUser = fb.FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('⚠️ Bạn chưa đăng nhập.');

    final doc = await _usersRef.doc(currentUser.uid).get();
    if (!doc.exists) throw Exception('⚠️ Không tìm thấy thông tin người dùng.');

    final currentRole = doc.data()?['role'] ?? 'user';
    final isOwner = currentUser.uid == userToDelete.id;

    if (currentRole != 'admin' && !isOwner) {
      throw Exception('⛔ Bạn không có quyền xóa người dùng khác.');
    }

    try {
      final idToken = await currentUser.getIdToken();
      final response = await Dio().post(
        'https://firebase-backend-q43h.onrender.com/deleteUser',
        data: {'uid': userToDelete.id},
        options: Options(headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Đã xóa user: ${response.data}');
      } else {
        throw Exception('❌ Lỗi xóa: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception('❌ Lỗi khi gọi API xóa user: ${e.message}');
    }
  }
}
