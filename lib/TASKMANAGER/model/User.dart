import 'package:cloud_firestore/cloud_firestore.dart';

/// Model đại diện cho người dùng hệ thống
class User {
  final String? id;
  final String username;
  final String password;
  final String email;
  final String? avatar;
  final String role;
  final DateTime createdAt;
  final DateTime lastActive;

  /// Constructor
  User({
    this.id,
    required this.username,
    required this.password,
    required this.email,
    this.avatar,
    this.role = 'user',
    required this.createdAt,
    required this.lastActive,
  });

  /// Chuyển User thành JSON để lưu vào Firestore
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'avatar': avatar,
      'role': role,
      'createdAt': createdAt,
      'lastActive': lastActive,
    };
  }

  /// Tạo User từ dữ liệu JSON lấy từ Firestore
  factory User.fromJson(Map<String, dynamic> json, {String? id}) {
    return User(
      id: id,
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'user',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      lastActive: (json['lastActive'] as Timestamp).toDate(),
    );
  }

  /// Tạo một bản sao mới với các trường được thay đổi
  User copyWith({
    String? id,
    String? username,
    String? password,
    String? email,
    String? avatar,
    String? role,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  /// Ghi đè để hiển thị đối tượng khi debug
  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, avatar: $avatar, '
        'role: $role, createdAt: $createdAt, lastActive: $lastActive)';
  }
}
