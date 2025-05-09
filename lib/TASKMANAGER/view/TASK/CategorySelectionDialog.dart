import 'package:flutter/material.dart';

class CategorySelectionDialog extends StatefulWidget {
  final String? initialWorkplace;
  final String? initialDepartment;
  final Set<String> initialLevels;
  final List<String> workplaces;
  final List<String> departments;
  final List<String> levels;

  const CategorySelectionDialog({
    Key? key,
    required this.initialWorkplace,
    required this.initialDepartment,
    required this.initialLevels,
    required this.workplaces,
    required this.departments,
    required this.levels,
  }) : super(key: key);

  @override
  State<CategorySelectionDialog> createState() => _CategorySelectionDialogState();
}

class _CategorySelectionDialogState extends State<CategorySelectionDialog> {
  late String? _workplace = widget.initialWorkplace;
  late String? _department = widget.initialDepartment;
  late Set<String> _levels = Set.from(widget.initialLevels);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Phân loại công việc'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Nơi làm việc'),
            ...widget.workplaces.map((w) => _buildRadioTile(w, _workplace, (v) => setState(() => _workplace = v))),

            _buildDivider(),
            _buildSectionTitle('Ban ngành'),
            ...widget.departments.map((d) => _buildRadioTile(d, _department, (v) => setState(() => _department = v))),

            _buildDivider(),
            _buildSectionTitle('Trình độ yêu cầu'),
            ...widget.levels.map(
                  (level) => CheckboxListTile(
                title: Text(level),
                value: _levels.contains(level),
                onChanged: (checked) => setState(() =>
                checked == true ? _levels.add(level) : _levels.remove(level)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'workplace': _workplace,
              'department': _department,
              'levels': _levels,
            });
          },
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _buildRadioTile(String value, String? groupValue, ValueChanged<String?> onChanged) {
    return RadioListTile<String>(
      title: Text(value),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }

  Widget _buildDivider() => const Divider(height: 24);
}
