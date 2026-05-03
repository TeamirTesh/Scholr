import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholr/providers/auth_provider.dart';
import 'package:scholr/providers/room_provider.dart';
import 'package:scholr/widgets/main_nav_bar.dart';
import 'package:scholr/widgets/room_card.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().uid!;
    final provider = context.read<RoomProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
        actions: [IconButton(onPressed: () => provider.seedRooms(), icon: const Icon(Icons.auto_fix_high))],
      ),
      bottomNavigationBar: const MainNavBar(current: 3),
      body: FutureBuilder(
        future: provider.fetchRooms(),
        builder: (_, snap) {
          final rooms = snap.data ?? [];
          if (rooms.isEmpty) return const Center(child: Text('No rooms found yet. Tap wand icon to seed rooms.'));
          return ListView(
            children: rooms
                .map(
                  (r) => RoomCard(
                    room: r,
                    uid: uid,
                    onBook: (slot) => provider.bookOrCancel(roomId: r.id, slot: slot, uid: uid),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
