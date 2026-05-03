import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scholr/app/router.dart';
import 'package:scholr/providers/auth_provider.dart';
import 'package:scholr/providers/group_provider.dart';
import 'package:scholr/providers/task_provider.dart';
import 'package:scholr/widgets/group_card.dart';
import 'package:scholr/widgets/study_plan_widget.dart';
import 'package:scholr/widgets/task_card.dart';
import 'package:scholr/widgets/main_nav_bar.dart';

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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          StreamBuilder(
            stream: context.read<AuthProvider>().userStream,
            builder: (_, snap) => Text('Hi, ${snap.data?.name ?? 'Student'}', style: Theme.of(context).textTheme.headlineMedium),
          ),
          const SizedBox(height: 16),
          Text('Upcoming Tasks', style: Theme.of(context).textTheme.titleLarge),
          StreamBuilder(
            stream: context.read<TaskProvider>().taskStream(uid),
            builder: (_, snap) {
              final tasks = (snap.data ?? []).where((t) => t.status != 'done').take(3).toList();
              return Column(children: tasks.map((t) => TaskCard(task: t, onToggle: () => context.read<TaskProvider>().toggleDone(t))).toList());
            },
          ),
          const SizedBox(height: 16),
          Text('My Groups', style: Theme.of(context).textTheme.titleLarge),
          StreamBuilder(
            stream: context.read<GroupProvider>().myGroups(uid),
            builder: (_, snap) => Column(
              children: (snap.data ?? []).take(3).map((g) => GroupCard(group: g, onTap: () => context.goNamed(AppRoutes.groupDetail, pathParameters: {'id': g.id}))).toList(),
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder(
            stream: context.read<TaskProvider>().taskStream(uid),
            builder: (_, snap) => StudyPlanWidget(blocks: context.read<TaskProvider>().generateStudyPlan(snap.data ?? [])),
          ),
        ]),
      ),
    );
  }
}
