import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholr/providers/auth_provider.dart';
import 'package:scholr/providers/room_provider.dart';
import 'package:scholr/widgets/main_nav_bar.dart';
import 'package:scholr/widgets/room_card.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().loadRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().uid!;
    final provider = context.watch<RoomProvider>();
    final rooms = provider.cachedRooms;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
        actions: [
          IconButton(
            onPressed: () async {
              await provider.seedRooms();
            },
            icon: const Icon(Icons.auto_fix_high),
          ),
        ],
      ),
      bottomNavigationBar: const MainNavBar(current: 3),
      body: rooms == null
          ? const Center(child: CircularProgressIndicator())
          : rooms.isEmpty
          ? const Center(child: Text('No rooms found yet. Tap wand icon to seed rooms.'))
          : ListView(
              children: rooms
                  .map(
                    (r) => RoomCard(
                      room: r,
                      uid: uid,
                      onBook: (slot) => provider.bookOrCancel(roomId: r.id, slot: slot, uid: uid),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
