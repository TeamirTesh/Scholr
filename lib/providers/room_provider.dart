import 'package:flutter/foundation.dart';
import 'package:scholr/models/room_model.dart';
import 'package:scholr/services/firestore_service.dart';

class RoomProvider extends ChangeNotifier {
  RoomProvider(this._firestore);

  final FirestoreService _firestore;

  Future<List<RoomModel>> fetchRooms() => _firestore.fetchRooms();

  Future<void> bookOrCancel({required String roomId, required String slot, required String uid}) async {
    await _firestore.bookOrCancelSlot(roomId: roomId, slot: slot, uid: uid);
    notifyListeners();
  }

  Future<void> seedRooms() => _firestore.seedRooms();
}
