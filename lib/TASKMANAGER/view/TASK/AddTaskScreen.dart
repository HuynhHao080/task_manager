import 'package:flutter/material.dart';
import '../../service/TaskFirebaseService.dart';
import 'TaskForm.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm công việc')),
      body: TaskForm(
        onSave: (task) async {
          await TaskFirebaseService().addTask(task);
          if (context.mounted) Navigator.pop(context, true);
        },
      ),
    );
  }
}
