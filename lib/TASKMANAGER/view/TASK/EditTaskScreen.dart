import 'package:flutter/material.dart';
import '../../model/Task.dart';
import '../../service/TaskFirebaseService.dart';
import 'TaskForm.dart';

class EditTaskScreen extends StatelessWidget {
  const EditTaskScreen({Key? key, required this.task}) : super(key: key);

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa công việc')),
      body: TaskForm(
        task: task,
        onSave: (updatedTask) async {
          await TaskFirebaseService().updateTask(updatedTask);
          if (context.mounted) Navigator.pop(context, true);
        },
      ),
    );
  }
}
