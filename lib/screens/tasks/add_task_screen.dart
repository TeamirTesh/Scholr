import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scholr/models/task_model.dart';
import 'package:scholr/providers/auth_provider.dart';
import 'package:scholr/providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _title = TextEditingController();
  final _effort = TextEditingController(text: '2');
  String _course = 'General Studies';
  double _weight = 0.5;
  DateTime _deadline = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().uid!;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder(
          stream: context.read<AuthProvider>().userStream,
          builder: (_, userSnap) {
            final courses = userSnap.data?.courses ?? const ['General Studies'];
            if (!courses.contains(_course)) _course = courses.first;
            return ListView(
              children: [
                TextField(controller: _title, decoration: const InputDecoration(labelText: 'Task Title')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _course,
                  items: courses.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _course = v!),
                  decoration: const InputDecoration(labelText: 'Course'),
                ),
                const SizedBox(height: 12),
                Text('Course Weight (${_weight.toStringAsFixed(2)})'),
                Slider(value: _weight, min: 0, max: 1, divisions: 20, onChanged: (v) => setState(() => _weight = v)),
                TextField(controller: _effort, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Estimated effort (hours)')),
                const SizedBox(height: 12),
                ListTile(
                  title: Text('Deadline: ${_deadline.toString().split('.').first}'),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDate: _deadline,
                    );
                    if (picked != null) {
                      setState(() => _deadline = DateTime(picked.year, picked.month, picked.day, 23, 59));
                    }
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final task = TaskModel(
                      id: '',
                      userId: uid,
                      title: _title.text.trim(),
                      course: _course,
                      courseWeight: _weight,
                      deadline: _deadline,
                      estimatedEffortHours: double.tryParse(_effort.text) ?? 2,
                      status: 'pending',
                      createdAt: DateTime.now(),
                    );
                    await context.read<TaskProvider>().addTask(task);
                    if (context.mounted) context.pop();
                  },
                  child: const Text('Save Task'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
