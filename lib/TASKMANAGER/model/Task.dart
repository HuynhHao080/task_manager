import 'package:cloud_firestore/cloud_firestore.dart';

/// Model đại diện cho một công việc (Task)
class Task {
  final String? id;
  final String title;
  final String description;
  final String status;
  final int priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? assignedTo;
  final String createdBy;
  final List<String>? category;
  final List<String>? attachments;
  final bool completed;

  /// Constructor
  Task({
    this.id,
    required this.title,
    required this.description,
    String? status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.assignedTo,
    required this.createdBy,
    this.category,
    this.attachments,
    required this.completed,
  }) : status = status ?? 'To do';

  /// Chuyển task thành JSON để lưu lên Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'dueDate': dueDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'category': category,
      'attachments': attachments,
      'completed': completed,
    };
  }

  /// Tạo task từ JSON Firestore
  factory Task.fromJson(Map<String, dynamic> json, {String? id}) {
    return Task(
      id: id,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'To do',
      priority: json['priority'] as int? ?? 1,
      dueDate: (json['dueDate'] as Timestamp?)?.toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      assignedTo: (json['assignedTo'] as List?)?.map((e) => e.toString()).toList(),
      createdBy: json['createdBy'] as String? ?? '',
      category: (json['category'] as List?)?.map((e) => e.toString()).toList(),
      attachments: (json['attachments'] as List?)?.map((e) => e.toString()).toList(),
      completed: json['completed'] as bool? ?? false,
    );
  }

  /// Tạo bản sao mới với các trường được thay đổi
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    int? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? assignedTo,
    String? createdBy,
    List<String>? category,
    List<String>? attachments,
    bool? completed,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      category: category ?? this.category,
      attachments: attachments ?? this.attachments,
      completed: completed ?? this.completed,
    );
  }

  /// Ghi đè toString để dễ debug
  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status, priority: $priority, '
        'dueDate: $dueDate, createdAt: $createdAt, updatedAt: $updatedAt, '
        'assignedTo: $assignedTo, createdBy: $createdBy, category: $category, '
        'attachments: $attachments, completed: $completed)';
  }
}
