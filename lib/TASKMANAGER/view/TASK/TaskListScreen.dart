import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../model/Task.dart';
import 'AddTaskScreen.dart';
import 'EditTaskScreen.dart';
import 'TaskDetailScreen.dart';
import 'TaskListItem.dart';
import 'SelectUserScreen.dart';
import '../../service/TaskFirebaseService.dart';
import '../../service/TaskNotificationService.dart';

class TaskListScreen extends StatefulWidget {
  final bool isAdmin;
  const TaskListScreen({super.key, required this.isAdmin});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _service = TaskFirebaseService();
  final _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  bool _isKanban = false;
  final _columns = ['To do', 'In progress', 'Done', 'Cancelled'];
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _sortDesc = true;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final trimmed = value.toLowerCase().trim();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _searchQuery = trimmed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Quản lý công việc'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isKanban ? Icons.view_list : Icons.view_kanban),
            tooltip: _isKanban ? 'Dạng danh sách' : 'Dạng Kanban',
            onPressed: () => setState(() => _isKanban = !_isKanban),
          )
        ],
      ),
      body: StreamBuilder<List<Task>>(
        stream: _service.tasksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data ?? [];
          if (tasks.isEmpty) {
            return const Center(child: Text('🚫 Không có công việc nào.'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '🔍 Tìm công việc theo tiêu đề...',
                          border: const OutlineInputBorder(),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                              : null,
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<bool>(
                      value: _sortDesc,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: true, child: Text('📉 Mới nhất')),
                        DropdownMenuItem(value: false, child: Text('📈 Cũ nhất')),
                      ],
                      onChanged: (value) => setState(() => _sortDesc = value!),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isKanban
                    ? _buildKanban(_filterSortTasks(tasks), theme)
                    : _buildList(_filterSortTasks(tasks)),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(const AddTaskScreen()),
        label: const Text('Thêm'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  List<Task> _filterSortTasks(List<Task> tasks) {
    return tasks
        .where((t) => _searchQuery.isEmpty || t.title.toLowerCase().contains(_searchQuery))
        .toList()
      ..sort((a, b) => _sortDesc
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt));
  }

  Widget _buildList(List<Task> tasks) => ListView.separated(
    padding: const EdgeInsets.symmetric(vertical: 12),
    itemCount: tasks.length,
    separatorBuilder: (_, __) => const Divider(),
    itemBuilder: (_, i) => _buildTaskItem(tasks[i]),
  );

  Widget _buildKanban(List<Task> tasks, ThemeData theme) {
    return DefaultTabController(
      length: _columns.length,
      child: Column(
        children: [
          Material(
            color: theme.scaffoldBackgroundColor,
            child: TabBar(
              isScrollable: true,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: theme.colorScheme.primary,
              tabs: _columns.map((s) => Tab(text: s)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: _columns.map((status) {
                final filtered = tasks.where((t) => t.status == status).toList();
                return _buildList(filtered);
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return FutureBuilder<String?>(
      future: _service.getUserNameById(task.createdBy),
      builder: (_, snapshot) {
        final creatorName = snapshot.data ?? task.createdBy;
        return Hero(
          tag: task.id ?? task.title,
          child: TaskListItem(
            task: task,
            currentUserId: _userId,
            creatorName: creatorName,
            isAdmin: widget.isAdmin,
            onTap: () => _open(TaskDetailScreen(task: task)),
            onEdit: () => _open(EditTaskScreen(task: task)),
            onDelete: () => _confirmDelete(task),
            onAttachment: () => _attachFiles(task),
            onAssignUser: () => _assignUsers(task),
          ),
        );
      },
    );
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _confirmDelete(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn chắc chắn muốn xóa công việc này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Đồng ý')),
        ],
      ),
    );

    if (confirm == true) {
      await _service.deleteTask(task.id!);
    }
  }

  Future<void> _attachFiles(Task task) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'png', 'jpg'],
    );

    if (result != null) {
      final files = result.files.map((f) => f.path!).toList();
      final updated = task.copyWith(
        attachments: [...(task.attachments ?? []), ...files],
        updatedAt: DateTime.now(),
      );
      await _service.updateTask(updated);

      if (updated.dueDate != null && updated.id != null) {
        await TaskNotificationService.schedule(
          id: updated.id!.hashCode,
          title: '⏰ ${updated.title}',
          body: 'Đã đến hạn công việc!',
          scheduledTime: updated.dueDate!,
          taskId: updated.id!,
        );
      }
    }
  }

  Future<void> _assignUsers(Task task) async {
    final selected = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectUserScreen(assignedUserIds: task.assignedTo ?? []),
      ),
    );

    if (selected != null) {
      final updated = task.copyWith(
        assignedTo: selected,
        updatedAt: DateTime.now(),
      );
      await _service.updateTask(updated);
    }
  }
}
