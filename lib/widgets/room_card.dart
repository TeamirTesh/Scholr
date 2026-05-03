import 'package:flutter/material.dart';
import 'package:scholr/models/room_model.dart';

class RoomCard extends StatelessWidget {
  const RoomCard({super.key, required this.room, required this.uid, required this.onBook});
  final RoomModel room;
  final String uid;
  final Future<void> Function(String slot) onBook;

  @override
  Widget build(BuildContext context) {
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
          ...room.availableSlots.map((slot) {
            final bookedBy = room.bookedBy[slot];
            final mine = bookedBy == uid;
            final available = bookedBy == null || mine;
            return ListTile(
              title: Text(slot),
              trailing: ElevatedButton(
                onPressed: available ? () => onBook(slot) : null,
                child: Text(mine ? 'Cancel Booking' : (available ? 'Book' : 'Booked')),
              ),
            );
          }),
        ],
      ),
    );
  }
}
