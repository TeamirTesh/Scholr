import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scholr/app/router.dart';
import 'package:scholr/providers/auth_provider.dart';
import 'package:scholr/providers/group_provider.dart';
import 'package:scholr/providers/task_provider.dart';
import 'package:scholr/widgets/main_nav_bar.dart';
import 'package:scholr/widgets/study_plan_widget.dart';
import 'package:scholr/widgets/task_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().uid!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scholr'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          IconButton(onPressed: () => context.goNamed(AppRoutes.profile), icon: const Icon(Icons.person_outline)),
        ],
      ),
      bottomNavigationBar: const MainNavBar(current: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder(
              stream: context.read<AuthProvider>().userStream,
              builder: (_, snap) => Text('Hi, ${snap.data?.name ?? 'Student'}', style: Theme.of(context).textTheme.headlineMedium),
            ),
            const SizedBox(height: 16),
            Text('Coming Up', style: Theme.of(context).textTheme.titleLarge),
            StreamBuilder(
              stream: context.read<AuthProvider>().userStream,
              builder: (_, userSnap) {
                final courses = userSnap.data?.courses ?? [];
                if (courses.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Add courses in your profile to get started'),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => context.goNamed(AppRoutes.profile),
                            child: const Text('Go to profile'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return StreamBuilder(
                  stream: context.read<TaskProvider>().taskStream(uid),
                  builder: (_, taskSnap) {
                    final tasks = (taskSnap.data ?? []).where((t) => t.status != 'done').take(5).toList();
                    if (tasks.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No upcoming tasks. Add one from the Tasks tab.'),
                        ),
                      );
                    }
                    return Column(
                      children: tasks
                          .map(
                            (t) => TaskCard(
                              task: t,
                              onToggle: () => context.read<TaskProvider>().toggleDone(t),
                              onOpen: () => context.pushNamed(AppRoutes.tasks, queryParameters: {'expand': t.id}),
                            ),
                          )
                          .toList(),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Text('My Groups', style: Theme.of(context).textTheme.titleLarge),
            StreamBuilder(
              stream: context.read<GroupProvider>().myGroups(uid),
              builder: (_, snap) {
                final groups = (snap.data ?? []).take(8).toList();
                if (groups.isEmpty) {
                  return const Text('Join or create a group from the Groups tab.');
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: groups
                      .map(
                        (g) => ActionChip(
                          label: Text(g.name),
                          onPressed: () => context.pushNamed(AppRoutes.groupDetail, pathParameters: {'id': g.id}),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            StreamBuilder(
              stream: context.read<TaskProvider>().taskStream(uid),
              builder: (_, snap) {
                final all = snap.data ?? [];
                final plan = context.read<TaskProvider>().generateStudyPlan(all);
                return StudyPlanWidget(blocks: plan, emptyBecauseNoTasks: all.isEmpty);
              },
            ),
          ],
        ),
      ),
    );
  }
}
