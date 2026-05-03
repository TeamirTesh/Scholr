import 'package:flutter/foundation.dart';
import 'package:scholr/models/chat_message_model.dart';
import 'package:scholr/models/group_model.dart';
import 'package:scholr/services/firestore_service.dart';

class GroupProvider extends ChangeNotifier {
  GroupProvider(this._firestore);

  final FirestoreService _firestore;

  Stream<List<GroupModel>> myGroups(String uid) => _firestore.streamMyGroups(uid);
  Stream<List<GroupModel>> discover(String uid) => _firestore.streamDiscoverGroups(uid);
  Stream<List<ChatMessageModel>> messages(String groupId) => _firestore.streamMessages(groupId);

  Future<String> createGroup(GroupModel group) async {
    final id = await _firestore.createGroup(group);
    notifyListeners();
    return id;
  }

  Future<void> joinGroup(String groupId, String uid) async {
    await _firestore.joinGroup(groupId, uid);
    notifyListeners();
  }

  Future<void> sendMessage(String groupId, ChatMessageModel message) async {
    await _firestore.sendMessage(groupId, message);
    notifyListeners();
  }
}
