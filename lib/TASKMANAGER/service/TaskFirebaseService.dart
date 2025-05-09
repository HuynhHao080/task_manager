import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/Task.dart';

/// Service xử lý CRUD cho Task trong Firestore
class TaskFirebaseService {
  final _tasksRef = FirebaseFirestore.instance.collection('tasks').withConverter<Task>(
    fromFirestore: (snap, _) => Task.fromJson(snap.data()!, id: snap.id),
    toFirestore: (task, _) => task.toJson(),
  );

  /// Stream realtime danh sách Task (sắp xếp theo trường tùy chọn)
  Stream<List<Task>> tasksStream({
    String sortField = 'createdAt',
    bool descending = true,
  }) {
    return _tasksRef
        .orderBy(sortField, descending: descending)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Thêm Task mới
  Future<void> addTask(Task task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Người dùng chưa đăng nhập.');
    }

    final now = DateTime.now();
    final newTask = task.copyWith(
      createdBy: user.uid,
      createdAt: now,
      updatedAt: now,
      status: 'To do',
    );

    await _tasksRef.add(newTask);
  }

  /// Cập nhật Task (bắt buộc có id)
  Future<void> updateTask(Task task) async {
    if (task.id == null) {
      throw StateError('Thiếu ID của task khi cập nhật.');
    }

    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    await _tasksRef.doc(task.id).set(updatedTask);
  }

  /// Xóa Task
  Future<void> deleteTask(String id) async {
    await _tasksRef.doc(id).delete();
  }

  /// Lấy Task theo ID
  Future<Task?> getTaskById(String id) async {
    final doc = await _tasksRef.doc(id).get();
    return doc.exists ? doc.data() : null;
  }

  /// Lấy tên người dùng từ Firestore theo userId
  Future<String> getUserNameById(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return doc.data()?['username'] ?? userId;
    } catch (e) {
      print('❌ Lỗi khi lấy username cho $userId: $e');
      return userId;
    }
  }
}
