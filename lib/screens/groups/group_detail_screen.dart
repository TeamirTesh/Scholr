import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholr/models/chat_message_model.dart';
import 'package:scholr/providers/auth_provider.dart';
import 'package:scholr/providers/group_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().uid!;
    return Scaffold(
      appBar: AppBar(title: const Text('Group Chat'), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.people_outline))]),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: context.read<GroupProvider>().messages(widget.groupId),
              builder: (_, snap) {
                final list = snap.data ?? [];
                return ListView.builder(
                  reverse: true,
                  itemCount: list.length,
                  itemBuilder: (_, i) => ChatBubble(message: list[i], isMe: list[i].senderId == uid),
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(type: FileType.any);
                    final file = result?.files.single;
                    if (file?.path == null || !context.mounted) return;
                    final url = await context.read<StorageService>().uploadGroupFile(widget.groupId, file!.name, File(file.path!));
                    if (!context.mounted) return;
                    final msg = ChatMessageModel(
                      id: '',
                      senderId: uid,
                      senderName: 'Member',
                      text: 'Shared file: ${file.name}',
                      timestamp: DateTime.now(),
                      type: 'file',
                      fileUrl: url,
                    );
                    await context.read<GroupProvider>().sendMessage(widget.groupId, msg);
                  },
                  icon: const Icon(Icons.attach_file),
                ),
                Expanded(
                  child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Write a message...')),
                ),
                IconButton(
                  onPressed: () async {
                    if (_controller.text.trim().isEmpty) return;
                    final msg = ChatMessageModel(
                      id: '',
                      senderId: uid,
                      senderName: 'Member',
                      text: _controller.text.trim(),
                      timestamp: DateTime.now(),
                      type: 'text',
                    );
                    await context.read<GroupProvider>().sendMessage(widget.groupId, msg);
                    _controller.clear();
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
