import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scholr/app/router.dart';
import 'package:scholr/providers/auth_provider.dart';
import 'package:scholr/providers/task_provider.dart';
import 'package:scholr/widgets/main_nav_bar.dart';
import 'package:scholr/widgets/task_card.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().uid!;
    final provider = context.watch<TaskProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      bottomNavigationBar: const MainNavBar(current: 1),
      floatingActionButton: FloatingActionButton(onPressed: () => context.goNamed(AppRoutes.addTask), child: const Icon(Icons.add)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('All')),
                ButtonSegment(value: 'pending', label: Text('Pending')),
                ButtonSegment(value: 'done', label: Text('Done')),
              ],
              selected: {provider.filter},
              onSelectionChanged: (s) => provider.setFilter(s.first),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: provider.taskStream(uid),
              builder: (_, snap) {
                final tasks = provider.applyFilter(snap.data ?? []);
                if (tasks.isEmpty) return const Center(child: Text('No tasks yet. Tap + to add one.'));
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (_, i) => TaskCard(task: tasks[i], onToggle: () => provider.toggleDone(tasks[i])),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
