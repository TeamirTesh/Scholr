import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scholr/app/router.dart';
import 'package:scholr/models/task_model.dart';
import 'package:scholr/providers/auth_provider.dart';
import 'package:scholr/providers/task_provider.dart';
import 'package:scholr/widgets/main_nav_bar.dart';
import 'package:scholr/widgets/task_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _submittingAdd = false;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().uid!;
    final provider = context.watch<TaskProvider>();
    final expandId = GoRouterState.of(context).uri.queryParameters['expand'];

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      bottomNavigationBar: const MainNavBar(current: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: _submittingAdd
            ? null
            : () async {
                setState(() => _submittingAdd = true);
                try {
                  final added = await context.pushNamed<bool>(AppRoutes.addTask);
                  if (!context.mounted) return;
                  if (added == true) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task added!')));
                  }
                } finally {
                  if (mounted) setState(() => _submittingAdd = false);
                }
              },
        child: const Icon(Icons.add),
      ),
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
                final raw = snap.data ?? [];
                final tasks = provider.applyFilter(raw);
                final plan = provider.generateStudyPlan(raw);
                final blockByTask = {for (final b in plan) b.task.id: b};
                if (tasks.isEmpty) return const Center(child: Text('No tasks yet. Tap + to add one.'));
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: tasks.length,
                  itemBuilder: (_, i) {
                    final t = tasks[i];
                    return Dismissible(
                      key: Key('task-${t.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red.shade700,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        final backup = t;
                        await provider.deleteTask(t);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Task deleted'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () async {
                                await provider.addTask(
                                  TaskModel(
                                    id: '',
                                    userId: backup.userId,
                                    title: backup.title,
                                    course: backup.course,
                                    courseWeight: backup.courseWeight,
                                    deadline: backup.deadline,
                                    estimatedEffortHours: backup.estimatedEffortHours,
                                    status: backup.status,
                                    createdAt: DateTime.now(),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: TaskCard(
                        task: t,
                        onToggle: () => provider.toggleDone(t),
                        studyBlock: blockByTask[t.id],
                        priorityScore: provider.priorityScore(t),
                        initiallyExpanded: t.id == expandId,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
