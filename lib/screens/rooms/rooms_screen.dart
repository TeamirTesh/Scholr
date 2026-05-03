import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholr/models/room_model.dart';
import 'package:scholr/providers/auth_provider.dart';
import 'package:scholr/providers/room_provider.dart';
import 'package:scholr/widgets/main_nav_bar.dart';
import 'package:scholr/widgets/room_card.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().loadRooms();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
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
            onPressed: () => provider.seedRooms(),
            icon: const Icon(Icons.auto_fix_high),
            tooltip: 'Seed rooms',
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Browse'),
            Tab(text: 'My Bookings'),
          ],
        ),
      ),
      bottomNavigationBar: const MainNavBar(current: 3),
      body: rooms == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _BrowseTab(rooms: rooms, uid: uid, provider: provider),
                _MyBookingsTab(rooms: rooms, uid: uid, provider: provider),
              ],
            ),
    );
  }
}

class _BrowseTab extends StatelessWidget {
  const _BrowseTab({required this.rooms, required this.uid, required this.provider});
  final List<RoomModel> rooms;
  final String uid;
  final RoomProvider provider;

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return const Center(child: Text('No rooms yet. Tap the wand icon to seed rooms.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: rooms.length,
      itemBuilder: (_, i) => RoomCard(
        room: rooms[i],
        uid: uid,
        onBook: (slot) => provider.bookOrCancel(roomId: rooms[i].id, slot: slot, uid: uid),
      ),
    );
  }
}

class _MyBookingsTab extends StatelessWidget {
  const _MyBookingsTab({required this.rooms, required this.uid, required this.provider});
  final List<RoomModel> rooms;
  final String uid;
  final RoomProvider provider;

  @override
  Widget build(BuildContext context) {
    // Collect every (room, slot) pair booked by this user
    final bookings = <({RoomModel room, String slot})>[];
    for (final room in rooms) {
      for (final entry in room.bookedBy.entries) {
        if (entry.value == uid) {
          bookings.add((room: room, slot: entry.key));
        }
      }
    }

    if (bookings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_seat_outlined, size: 56, color: Colors.grey),
              SizedBox(height: 16),
              Text("You haven't booked any rooms yet.", textAlign: TextAlign.center),
              SizedBox(height: 8),
              Text('Go to Browse to reserve a slot.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bookings.length,
      itemBuilder: (_, i) {
        final b = bookings[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.meeting_room_outlined),
            title: Text(b.room.name),
            subtitle: Text('${b.room.location}  ·  ${b.slot}'),
            trailing: TextButton.icon(
              icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
              label: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
              onPressed: () => provider.bookOrCancel(roomId: b.room.id, slot: b.slot, uid: uid),
            ),
          ),
        );
      },
    );
  }
}
