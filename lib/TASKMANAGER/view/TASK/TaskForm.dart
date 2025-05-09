import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/Task.dart';
import '../../service/TaskNotificationService.dart';
import 'AttachmentSelectionScreen.dart';
import 'CategorySelectionDialog.dart';

class TaskForm extends StatefulWidget {
  final Task? task;
  final Future<void> Function(Task) onSave;

  const TaskForm({Key? key, this.task, required this.onSave}) : super(key: key);

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;

  String _status = 'To do';
  int _priority = 1;
  DateTime? _dueDate;
  List<String> _attachments = [];
  bool _completed = false;

  final List<String> _workplaces = ['Office', 'Remote', 'ALL'];
  final List<String> _departments = ['IT', 'HR', 'Marketing'];
  final List<String> _levels = ['Junior', 'Middle', 'Senior'];

  String? _selectedWorkplace;
  String? _selectedDepartment;
  Set<String> _selectedLevels = {};

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _status = t?.status ?? 'To do';
    _priority = t?.priority ?? 1;
    _dueDate = t?.dueDate;
    _attachments = t?.attachments ?? [];
    _completed = t?.completed ?? false;

    final category = t?.category ?? [];
    for (var cat in category) {
      if (_workplaces.contains(cat)) {
        _selectedWorkplace = cat;
      } else if (_departments.contains(cat)) {
        _selectedDepartment = cat;
      } else if (_levels.contains(cat)) {
        _selectedLevels.add(cat);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final now = DateTime.now();
    final initial = _dueDate != null && _dueDate!.isAfter(now) ? _dueDate! : now;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() => _dueDate = selected);

    if (widget.task?.id != null) {
      await TaskNotificationService.schedule(
        id: widget.task!.id.hashCode,
        title: '⏰ ${_titleCtrl.text.trim()}',
        body: 'Đã đến hạn công việc!',
        scheduledTime: selected,
        taskId: widget.task!.id!,
      );
    }
  }

  Future<void> _openAttachmentScreen() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => AttachmentSelectionScreen(initialAttachments: _attachments),
      ),
    );
    if (result != null) {
      setState(() => _attachments = result);
    }
  }

  Future<void> _openCategoryDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => CategorySelectionDialog(
        initialWorkplace: _selectedWorkplace,
        initialDepartment: _selectedDepartment,
        initialLevels: _selectedLevels,
        workplaces: _workplaces,
        departments: _departments,
        levels: _levels,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedWorkplace = result['workplace'];
        _selectedDepartment = result['department'];
        _selectedLevels = Set<String>.from(result['levels'] ?? {});
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final List<String> category = [
      if (_selectedWorkplace != null) _selectedWorkplace!,
      if (_selectedDepartment != null) _selectedDepartment!,
      ..._selectedLevels,
    ];

    final task = Task(
      id: widget.task?.id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      status: widget.task == null ? 'To do' : _status,
      priority: _priority,
      dueDate: _dueDate,
      createdAt: widget.task?.createdAt ?? now,
      updatedAt: now,
      assignedTo: widget.task?.assignedTo,
      createdBy: widget.task?.createdBy ?? 'user1',
      category: category.isEmpty ? null : category,
      attachments: _attachments,
      completed: _completed,
    );

    await widget.onSave(task);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    final selectedCategoryText = [
      if (_selectedWorkplace != null) _selectedWorkplace,
      if (_selectedDepartment != null) _selectedDepartment,
      ..._selectedLevels,
    ].whereType<String>().join(', ');

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Tiêu đề công việc'),
              validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Mô tả chi tiết'),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            if (isEditing)
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Trạng thái'),
                items: const [
                  DropdownMenuItem(value: 'To do', child: Text('To do')),
                  DropdownMenuItem(value: 'In progress', child: Text('In progress')),
                  DropdownMenuItem(value: 'Done', child: Text('Done')),
                  DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                ],
                onChanged: (v) => setState(() => _status = v!),
              ),
            if (isEditing) const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _priority,
              decoration: const InputDecoration(labelText: 'Mức ưu tiên'),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Thấp')),
                DropdownMenuItem(value: 2, child: Text('Trung bình')),
                DropdownMenuItem(value: 3, child: Text('Cao')),
              ],
              onChanged: (v) => setState(() => _priority = v!),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Hạn hoàn thành'),
              subtitle: Text(
                _dueDate != null
                    ? DateFormat('dd/MM/yyyy HH:mm').format(_dueDate!)
                    : 'Chưa chọn',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDue,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Phân loại công việc'),
              subtitle: Text(selectedCategoryText.isEmpty ? 'Chưa chọn' : selectedCategoryText),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openCategoryDialog,
            ),
            if (isEditing) const SizedBox(height: 16),
            if (isEditing)
              ListTile(
                title: const Text('Tài liệu đính kèm'),
                subtitle: Text(
                  _attachments.isEmpty
                      ? 'Không có tài liệu'
                      : '${_attachments.length} tài liệu',
                ),
                trailing: const Icon(Icons.attach_file),
                onTap: _openAttachmentScreen,
              ),
            if (isEditing) const SizedBox(height: 16),
            if (isEditing)
              CheckboxListTile(
                title: const Text('Hoàn thành công việc'),
                value: _completed,
                onChanged: (v) => setState(() => _completed = v ?? false),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              child: Text(widget.task == null ? 'Thêm công việc' : 'Cập nhật công việc'),
            ),
          ],
        ),
      ),
    );
  }
}
