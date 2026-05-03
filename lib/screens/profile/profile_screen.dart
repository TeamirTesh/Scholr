import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:scholr/app/router.dart';
import 'package:scholr/models/user_model.dart';
import 'package:scholr/providers/auth_provider.dart';
import 'package:scholr/widgets/main_nav_bar.dart';
import 'package:scholr/services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editingName = false;
  final _nameCtrl = TextEditingController();
  bool _savingName = false;
  bool _savingNotif = false;
  bool _uploadingPhoto = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _showAddCourseDialog(UserModel user) async {
    final ctrl = TextEditingController();
    var busy = false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Add course'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: 'Course name'),
            textCapitalization: TextCapitalization.words,
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: busy ? null : () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      final name = ctrl.text.trim();
                      if (name.isEmpty) return;
                      setSt(() => busy = true);
                      try {
                        final auth = context.read<AuthProvider>();
                        if (user.courses.contains(name)) {
                          if (ctx.mounted) Navigator.pop(ctx);
                          return;
                        }
                        await auth.updateProfile({'courses': [...user.courses, name]});
                        if (ctx.mounted) Navigator.pop(ctx);
                      } finally {
                        if (ctx.mounted) setSt(() => busy = false);
                      }
                    },
              child: busy
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: context.canPop()
              ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())
              : null,
          title: const Text('Profile'),
        ),
        bottomNavigationBar: const MainNavBar(current: 4),
        body: StreamBuilder(
          stream: auth.userStream,
          builder: (_, snap) {
            final user = snap.data;
            if (user == null) return const Center(child: CircularProgressIndicator());

            if (!_editingName && _nameCtrl.text != user.name) {
              _nameCtrl.text = user.name;
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _uploadingPhoto
                        ? null
                        : () async {
                            final picker = ImagePicker();
                            final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
                            if (image == null || !context.mounted) return;
                            setState(() => _uploadingPhoto = true);
                            try {
                              final uid = auth.uid!;
                              final url = await context.read<StorageService>().uploadProfilePhoto(uid, File(image.path));
                              await auth.updateProfile({'profilePicUrl': url});
                            } finally {
                              if (mounted) setState(() => _uploadingPhoto = false);
                            }
                          },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          key: ValueKey(user.profilePicUrl),
                          radius: 44,
                          backgroundImage: user.profilePicUrl.isEmpty ? null : CachedNetworkImageProvider(user.profilePicUrl),
                          child: user.profilePicUrl.isEmpty ? const Icon(Icons.person, size: 44) : null,
                        ),
                        if (_uploadingPhoto) const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_editingName)
                      Expanded(
                        child: TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(labelText: 'Name'),
                          textCapitalization: TextCapitalization.words,
                          onSubmitted: (_) async {
                            await _saveName(auth, user);
                          },
                        ),
                      )
                    else
                      Expanded(child: Text(user.name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge)),
                    IconButton(
                      icon: Icon(_editingName ? Icons.check : Icons.edit),
                      onPressed: _savingName
                          ? null
                          : () async {
                              if (_editingName) {
                                await _saveName(auth, user);
                              } else {
                                setState(() {
                                  _editingName = true;
                                  _nameCtrl.text = user.name;
                                });
                              }
                            },
                    ),
                  ],
                ),
                if (_savingName) const Center(child: Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator())),
                Text(user.email, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text('Courses', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...user.courses.map(
                      (c) => InputChip(
                        label: Text(c),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () async {
                          final next = [...user.courses]..remove(c);
                          await auth.updateProfile({'courses': next});
                        },
                      ),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                      onPressed: () => _showAddCourseDialog(user),
                    ),
                  ],
                ),
                SwitchListTile(
                  value: user.notificationsEnabled,
                  title: const Text('Notifications'),
                  onChanged: _savingNotif
                      ? null
                      : (v) async {
                          setState(() => _savingNotif = true);
                          try {
                            await auth.updateProfile({'notificationsEnabled': v});
                          } finally {
                            if (mounted) setState(() => _savingNotif = false);
                          }
                        },
                ),
                if (_savingNotif) const LinearProgressIndicator(),
                const SizedBox(height: 24),
                FilledButton(
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
      ),
    );
  }

  Future<void> _saveName(AuthProvider auth, UserModel user) async {
    final next = _nameCtrl.text.trim();
    if (next.isEmpty || next == user.name) {
      setState(() => _editingName = false);
      return;
    }
    setState(() => _savingName = true);
    try {
      await auth.updateProfile({'name': next});
      if (mounted) setState(() => _editingName = false);
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }
}