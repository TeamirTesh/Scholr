import 'package:flutter/material.dart';
import 'package:scholr/models/room_model.dart';

class RoomCard extends StatelessWidget {
  const RoomCard({super.key, required this.room, required this.uid, required this.onBook});
  final RoomModel room;
  final String uid;
  final Future<void> Function(String slot) onBook;

  @override
  Widget build(BuildContext context) {
    final slots = room.availableSlots;
    return Card(
      child: ExpansionTile(
        title: Text(room.name),
        subtitle: Text('${room.location} · Capacity ${room.capacity}'),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: room.amenities.map((a) => Chip(label: Text(a))).toList(),
          ),
          const SizedBox(height: 8),
          if (slots.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No slots available'),
            )
          else
            ...slots.map((slot) {
              final bookedBy = room.bookedBy[slot];
              final mine = bookedBy == uid;
              final taken = bookedBy != null && !mine;
              return ListTile(
                title: Text(slot),
                trailing: mine
                    ? FilledButton.tonal(
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Cancel booking'),
                              content: Text('Cancel your booking for $slot?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                                FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
                              ],
                            ),
                          );
                          if (ok == true && context.mounted) await onBook(slot);
                        },
                        child: const Text('✓ Booked'),
                      )
                    : ElevatedButton(
                        onPressed: taken ? null : () => onBook(slot),
                        child: Text(taken ? 'Booked' : 'Book'),
                      ),
              );
            }),
        ],
      ),
    );
  }
}
