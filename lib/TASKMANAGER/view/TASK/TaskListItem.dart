import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/Task.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final String currentUserId;
  final String creatorName;
  final bool isAdmin;

  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAttachment;
  final VoidCallback onAssignUser;

  const TaskListItem({
    Key? key,
    required this.task,
    required this.currentUserId,
    required this.creatorName,
    required this.isAdmin,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onAttachment,
    required this.onAssignUser,
  }) : super(key: key);

  // ==== [ Permission Logic ] ====

  bool get isCreator => task.createdBy == currentUserId;
  bool get isAssigned => task.assignedTo?.contains(currentUserId) ?? false;
  bool get canSee => isAdmin || isCreator || isAssigned;
  bool get canShowMenu => isAdmin || isCreator;

  String get assignedToText =>
      task.assignedTo?.isNotEmpty == true ? '${task.assignedTo!.length} người' : 'Chưa giao';

  // ==== [ UI Logic Helpers ] ====

  Color get _statusBorderColor => {
    'to do': Colors.grey,
    'in progress': Colors.orange,
    'done': Colors.green,
    'cancelled': Colors.red,
  }[task.status.toLowerCase()] ?? Colors.black38;

  IconData get _statusIcon => {
    'to do': Icons.pending_actions,
    'in progress': Icons.timelapse,
    'done': Icons.check_circle,
    'cancelled': Icons.cancel,
  }[task.status.toLowerCase()] ?? Icons.help_outline;

  Color get _priorityColor =>
      [Colors.green, Colors.orange, Colors.red][task.priority.clamp(1, 3) - 1];

  String get _dueDate =>
      task.dueDate == null ? 'Không có hạn' : DateFormat('dd/MM/yyyy HH:mm').format(task.dueDate!);

  // ==== [ Build ] ====

  @override
  Widget build(BuildContext context) {
    if (!canSee) return const SizedBox(); // Hide if not allowed

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: _statusBorderColor, width: 1.5),
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==== Left Icon ====
                CircleAvatar(
                  backgroundColor: _priorityColor.withOpacity(0.1),
                  radius: 24,
                  child: Icon(_statusIcon, color: _priorityColor, size: 20),
                ),
                const SizedBox(width: 16),

                // ==== Main Content ====
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==== Title + Menu ====
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (canShowMenu) _buildPopupMenu(),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ==== Tags ====
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildChip(Icons.flag, task.status, Colors.grey.shade100),
                          _buildChip(Icons.priority_high, 'Ưu tiên ${task.priority}', Colors.grey.shade100,
                              iconColor: _priorityColor),
                          if (task.dueDate != null)
                            _buildChip(Icons.calendar_today, _dueDate, Colors.grey.shade100),
                          _buildChip(
                            null,
                            task.completed ? '✅ Hoàn thành' : '⏳ Chưa xong',
                            task.completed ? Colors.green.shade50 : Colors.orange.shade50,
                            textColor: task.completed
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ==== Metadata ====
                      Row(
                        children: [
                          _buildIconLabel(Icons.person, 'Người tạo: $creatorName', Colors.teal),
                          const SizedBox(width: 12),
                          _buildIconLabel(Icons.group, 'Giao cho: $assignedToText', Colors.deepPurple),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==== [ Widget Builders ] ====

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'attachment':
            onAttachment();
            break;
          case 'assign':
            onAssignUser();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      icon: const Icon(Icons.more_vert),
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(leading: Icon(Icons.edit), title: Text('Chỉnh sửa')),
        ),
        const PopupMenuItem(
          value: 'attachment',
          child: ListTile(leading: Icon(Icons.attach_file), title: Text('Đính kèm')),
        ),
        const PopupMenuItem(
          value: 'assign',
          child: ListTile(leading: Icon(Icons.person_add_alt_1), title: Text('Giao việc')),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.redAccent),
            title: Text('Xóa', style: TextStyle(color: Colors.redAccent)),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(
      IconData? icon,
      String label,
      Color backgroundColor, {
        Color? iconColor,
        Color? textColor,
      }) {
    return Chip(
      label: Text(label, style: TextStyle(fontSize: 12, color: textColor ?? Colors.black87)),
      avatar: icon != null ? Icon(icon, size: 16, color: iconColor ?? Colors.black54) : null,
      backgroundColor: backgroundColor,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildIconLabel(IconData icon, String text, Color color) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
