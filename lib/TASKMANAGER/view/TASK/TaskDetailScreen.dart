// Optimized and Cleaned TaskDetailScreen
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/Task.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final _userMap = <String, String>{};
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final current = snapshot.docs.firstWhere(
          (doc) => doc.id == _userId,
      orElse: () => throw Exception('User not found'),
    );

    setState(() {
      _userMap.addAll({
        for (var doc in snapshot.docs)
          doc.id: doc.data()['username'] ?? doc.data()['email'] ?? 'Không rõ'
      });
      _isAdmin = current.data()['role'] == 'admin';
    });
  }

  Future<void> _handleAttachment(String filePath) async {
    final task = widget.task;
    final isAllowed = _isAdmin ||
        _userId == task.createdBy ||
        (task.assignedTo?.contains(_userId) ?? false);

    if (!isAllowed) {
      _showSnack('🚫 Bạn không có quyền truy cập tài liệu này.');
      return;
    }

    try {
      if (filePath.startsWith('http')) {
        final uri = Uri.parse(filePath);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw 'Không thể mở liên kết: $filePath';
        }
      } else {
        final file = File(filePath);
        if (!await file.exists()) throw 'File không tồn tại';

        final dir = await getExternalStorageDirectory();
        if (dir == null) throw 'Không thể truy cập bộ nhớ';

        final dest = path.join(dir.path, path.basename(filePath));
        final copied = await file.copy(dest);
        final result = await OpenFilex.open(copied.path);

        if (result.type != ResultType.done) {
          throw 'Không có ứng dụng đọc file này!';
        }
      }
    } catch (_) {
      _showSnack('⚠ Không mở được file. Cài WPS Office nếu cần.');
      final uri = Uri.parse('https://play.google.com/store/apps/details?id=cn.wps.moffice_eng');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final creator = _userMap[task.createdBy] ?? task.createdBy;
    final assigned = (task.assignedTo ?? []).map((id) => _userMap[id] ?? id).join(', ');
    final canAccessFiles = _isAdmin || _userId == task.createdBy || (task.assignedTo?.contains(_userId) ?? false);

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết công việc')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(task.title),
            const SizedBox(height: 12),
            Text(task.description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            _buildInfo(context, task, creator, assigned),
            if ((task.attachments ?? []).isNotEmpty) _buildAttachments(task.attachments!, canAccessFiles),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) => Row(
    children: [
      const Icon(Icons.task, size: 30),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          maxLines: 2,
        ),
      ),
    ],
  );

  Widget _buildInfo(BuildContext context, Task task, String creator, String assigned) => Column(
    children: [
      _infoTile(Icons.flag, 'Trạng thái', task.status),
      _infoTile(Icons.priority_high, 'Ưu tiên', task.priority.toString()),
      if (task.dueDate != null)
        _infoTile(Icons.calendar_today, 'Hạn hoàn thành', DateFormat('dd/MM/yyyy HH:mm').format(task.dueDate!)),
      _infoTile(Icons.schedule, 'Ngày tạo', DateFormat('dd/MM/yyyy').format(task.createdAt)),
      _infoTile(Icons.update, 'Cập nhật', DateFormat('dd/MM/yyyy').format(task.updatedAt)),
      _infoTile(Icons.person, 'Người tạo', creator),
      _infoTile(Icons.group, 'Người nhận', assigned.isNotEmpty ? assigned : 'Chưa giao'),
      _infoTile(Icons.label, 'Phân loại', (task.category ?? []).join(', ')),
      _infoTile(Icons.check_circle_outline, 'Hoàn thành', task.completed ? '✔ Đã hoàn thành' : '⏳ Chưa hoàn thành'),
    ],
  );

  Widget _buildAttachments(List<String> files, bool canAccess) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Divider(),
      const Text('📎 Tài liệu đính kèm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 12),
      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: files.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final filePath = files[index];
          final fileName = path.basename(filePath);
          return ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            tileColor: Colors.grey.shade100,
            leading: const Icon(Icons.insert_drive_file),
            title: Text(fileName, overflow: TextOverflow.ellipsis),
            trailing: canAccess ? const Icon(Icons.download_rounded) : const Icon(Icons.lock_outline, color: Colors.grey),
            onTap: canAccess ? () => _handleAttachment(filePath) : null,
          );
        },
      ),
    ],
  );

  Widget _infoTile(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
