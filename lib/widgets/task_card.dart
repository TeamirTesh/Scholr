import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scholr/models/task_model.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.onToggle});
  final TaskModel task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final due = DateFormat('MMM d, h:mm a').format(task.deadline);
    return Card(
      child: ListTile(
        leading: Checkbox(value: task.status == 'done', onChanged: (_) => onToggle()),
        title: Text(task.title),
        subtitle: Text('${task.course} · Due $due · ${task.estimatedEffortHours}h'),
      ),
    );
  }
}
