import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:scholr/app/router.dart';
import 'package:scholr/providers/auth_provider.dart';
import 'package:scholr/widgets/main_nav_bar.dart';
import 'package:scholr/services/firestore_service.dart';
import 'package:scholr/services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _courseCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final uid = auth.uid!;
    final fs = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      bottomNavigationBar: const MainNavBar(current: 4),
      body: StreamBuilder(
        stream: auth.userStream,
        builder: (_, snap) {
          final user = snap.data;
          if (user == null) return const SizedBox.shrink();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
                    if (image == null || !context.mounted) return;
                    final url = await context.read<StorageService>().uploadProfilePhoto(uid, File(image.path));
                    await fs.updateUser(uid, {'profilePicUrl': url});
                  },
                  child: CircleAvatar(
                    radius: 44,
                    backgroundImage: user.profilePicUrl.isEmpty ? null : CachedNetworkImageProvider(user.profilePicUrl),
                    child: user.profilePicUrl.isEmpty ? const Icon(Icons.person, size: 44) : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(user.name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
              Text(user.email, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(controller: _courseCtrl, decoration: const InputDecoration(labelText: 'Add course'))),
                  IconButton(
                    onPressed: () async {
                      if (_courseCtrl.text.trim().isEmpty) return;
                      await fs.updateUser(uid, {'courses': [...user.courses, _courseCtrl.text.trim()]});
                      _courseCtrl.clear();
                    },
                    icon: const Icon(Icons.add_circle),
                  )
                ],
              ),
              Wrap(
                spacing: 8,
                children: user.courses
                    .map(
                      (c) => Chip(
                        label: Text(c),
                        onDeleted: () async {
                          final next = [...user.courses]..remove(c);
                          await fs.updateUser(uid, {'courses': next});
                        },
                      ),
                    )
                    .toList(),
              ),
              SwitchListTile(
                value: user.notificationsEnabled,
                title: const Text('Notifications'),
                onChanged: (v) => fs.updateUser(uid, {'notificationsEnabled': v}),
              ),
              ElevatedButton(
                onPressed: () async {
                  await auth.signOut();
                  if (!context.mounted) return;
                  context.goNamed(AppRoutes.login);
                },
                child: const Text('Sign out'),
              ),
            ],
          );
        },
      ),
    );
  }
}
