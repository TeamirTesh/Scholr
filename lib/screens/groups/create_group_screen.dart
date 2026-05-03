import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scholr/app/router.dart';
import 'package:scholr/models/group_model.dart';
import 'package:scholr/providers/auth_provider.dart';
import 'package:scholr/providers/group_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _name = TextEditingController();
  final _course = TextEditingController();
  final _desc = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().uid!;
    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Group name')),
            const SizedBox(height: 12),
            TextField(controller: _course, decoration: const InputDecoration(labelText: 'Course')),
            const SizedBox(height: 12),
            TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final group = GroupModel(
                  id: '',
                  name: _name.text.trim(),
                  course: _course.text.trim(),
                  createdBy: uid,
                  members: [uid],
                  fileUrls: const [],
                  description: _desc.text.trim(),
                  createdAt: DateTime.now(),
                );
                await context.read<GroupProvider>().createGroup(group);
                if (context.mounted) context.goNamed(AppRoutes.groups);
              },
              child: const Text('Create'),
            )
          ],
        ),
      ),
    );
  }
}
