import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scholr/models/chat_message_model.dart';
import 'package:scholr/providers/auth_provider.dart';
import 'package:scholr/providers/group_provider.dart';
import 'package:scholr/services/firestore_service.dart';
import 'package:scholr/services/storage_service.dart';
import 'package:scholr/widgets/chat_bubble.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});
  final String groupId;

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final _controller = TextEditingController();
  bool _uploading = false;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final uid = auth.uid!;
    final displayName = auth.currentUser?.name ?? 'Member';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
          title: const Text('Group Chat'),
          actions: [
            IconButton(
              icon: const Icon(Icons.people_outline),
              onPressed: () async {
                final g = await context.read<FirestoreService>().getGroup(widget.groupId);
                if (!context.mounted || g == null) return;
                await showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Members'),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${g.members.length} members'),
                          const SizedBox(height: 8),
                          ...g.members.map((id) => SelectableText(id, style: Theme.of(ctx).textTheme.bodySmall)),
                        ],
                      ),
                    ),
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: context.read<GroupProvider>().messages(widget.groupId),
                builder: (_, snap) {
                  final list = snap.data ?? [];
                  if (list.isEmpty) {
                    return const Center(child: Text('No messages yet. Say hello!'));
                  }
                  return ListView.builder(
                    reverse: true,
                    itemCount: list.length,
                    itemBuilder: (_, i) => ChatBubble(message: list[i], isMe: list[i].senderId == uid),
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    if (_uploading)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    else
                      IconButton(
                        onPressed: _sending
                            ? null
                            : () async {
                                final result = await FilePicker.platform.pickFiles(type: FileType.any);
                                final file = result?.files.single;
                                if (file?.path == null || !context.mounted) return;
                                setState(() => _uploading = true);
                                try {
                                  final url = await context.read<StorageService>().uploadGroupFile(widget.groupId, file!.name, File(file.path!));
                                  if (!context.mounted) return;
                                  final msg = ChatMessageModel(
                                    id: '',
                                    senderId: uid,
                                    senderName: displayName,
                                    text: 'Shared file: ${file.name}',
                                    timestamp: DateTime.now(),
                                    type: 'file',
                                    fileUrl: url,
                                  );
                                  await context.read<GroupProvider>().sendMessage(widget.groupId, msg);
                                } finally {
                                  if (mounted) setState(() => _uploading = false);
                                }
                              },
                        icon: const Icon(Icons.attach_file),
                      ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(hintText: 'Write a message...'),
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 4,
                      ),
                    ),
                    IconButton(
                      onPressed: _sending || _uploading
                          ? null
                          : () async {
                              if (_controller.text.trim().isEmpty) return;
                              setState(() => _sending = true);
                              try {
                                final msg = ChatMessageModel(
                                  id: '',
                                  senderId: uid,
                                  senderName: displayName,
                                  text: _controller.text.trim(),
                                  timestamp: DateTime.now(),
                                  type: 'text',
                                );
                                await context.read<GroupProvider>().sendMessage(widget.groupId, msg);
                                _controller.clear();
                              } finally {
                                if (mounted) setState(() => _sending = false);
                              }
                            },
                      icon: _sending
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
