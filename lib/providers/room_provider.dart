import 'package:flutter/foundation.dart';
import 'package:scholr/models/room_model.dart';
import 'package:scholr/services/firestore_service.dart';

class RoomProvider extends ChangeNotifier {
  RoomProvider(this._firestore);

  final FirestoreService _firestore;

  List<RoomModel>? _rooms;
  List<RoomModel>? get cachedRooms => _rooms;

  Future<void> loadRooms() async {
    _rooms = await _firestore.fetchRooms();
    notifyListeners();
  }

  void _replaceRoom(RoomModel updated) {
    if (_rooms == null) return;
    _rooms = _rooms!.map((r) => r.id == updated.id ? updated : r).toList();
    notifyListeners();
  }

  /// Optimistically update [bookedBy] while the server write runs.
  Future<void> bookOrCancel({required String roomId, required String slot, required String uid}) async {
    final list = _rooms;
    if (list != null) {
      final idx = list.indexWhere((r) => r.id == roomId);
      if (idx >= 0) {
        final r = list[idx];
        final nextMap = Map<String, String>.from(r.bookedBy);
        if (nextMap[slot] == uid) {
          nextMap.remove(slot);
        } else if (nextMap[slot] == null) {
          nextMap[slot] = uid;
        }
        _replaceRoom(r.copyWith(bookedBy: nextMap));
      }
    }
    try {
      await _firestore.bookOrCancelSlot(roomId: roomId, slot: slot, uid: uid);
    } catch (_) {
      await loadRooms();
      rethrow;
    }
    _rooms = await _firestore.fetchRooms();
    notifyListeners();
  }

  Future<void> seedRooms() async {
    await _firestore.seedRooms();
    await loadRooms();
  }
}
