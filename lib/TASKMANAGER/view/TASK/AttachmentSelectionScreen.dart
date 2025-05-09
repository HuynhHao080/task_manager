import 'package:flutter/material.dart';

class AttachmentSelectionScreen extends StatefulWidget {
  final List<String> initialAttachments;

  const AttachmentSelectionScreen({Key? key, required this.initialAttachments}) : super(key: key);

  @override
  State<AttachmentSelectionScreen> createState() => _AttachmentSelectionScreenState();
}

class _AttachmentSelectionScreenState extends State<AttachmentSelectionScreen> {
  late List<String> _attachments;

  @override
  void initState() {
    super.initState();
    _attachments = List.from(widget.initialAttachments);
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  void _saveAndExit() {
    Navigator.pop(context, _attachments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📎 Tài liệu đính kèm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Lưu thay đổi',
            onPressed: _saveAndExit,
          ),
        ],
      ),
      body: _attachments.isEmpty
          ? const Center(child: Text('Chưa có tài liệu nào.'))
          : ListView.separated(
        itemCount: _attachments.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final link = _attachments[index];
          return ListTile(
            leading: const Icon(Icons.link, color: Colors.blueAccent),
            title: Text(link, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _removeAttachment(index),
            ),
          );
        },
      ),
    );
  }
}
