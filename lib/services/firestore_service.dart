import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scholr/models/chat_message_model.dart';
import 'package:scholr/models/group_model.dart';
import 'package:scholr/models/room_model.dart';
import 'package:scholr/models/task_model.dart';
import 'package:scholr/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get users => _db.collection('users');
  CollectionReference<Map<String, dynamic>> get tasks => _db.collection('tasks');
  CollectionReference<Map<String, dynamic>> get groups => _db.collection('groups');
  CollectionReference<Map<String, dynamic>> get rooms => _db.collection('rooms');

  Future<void> createUser(UserModel user) async {
    try {
      await users.doc(user.id).set(user.toMap(), SetOptions(merge: true));
    } catch (e, st) {
      log('createUser failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Stream<UserModel?> streamUser(String uid) {
    return users.doc(uid).snapshots().map((doc) => doc.exists ? UserModel.fromMap(doc.id, doc.data()!) : null);
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await users.doc(uid).get();
      return doc.exists ? UserModel.fromMap(doc.id, doc.data()!) : null;
    } catch (e, st) {
      log('getUser failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await users.doc(uid).set(data, SetOptions(merge: true));
    } catch (e, st) {
      log('updateUser failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Stream<List<TaskModel>> streamTasks(String uid) {
    return tasks.where('userId', isEqualTo: uid).orderBy('deadline').snapshots().map(
      (s) => s.docs.map((d) => TaskModel.fromMap(d.id, d.data())).toList(),
    );
  }

  Future<void> addTask(TaskModel task) async {
    try {
      await tasks.add(task.toMap());
    } catch (e, st) {
      log('addTask failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      await tasks.doc(taskId).update({'status': status});
    } catch (e, st) {
      log('updateTaskStatus failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Stream<List<GroupModel>> streamMyGroups(String uid) {
    return groups.where('members', arrayContains: uid).snapshots().map(
      (s) => s.docs.map((d) => GroupModel.fromMap(d.id, d.data())).toList(),
    );
  }

  Stream<List<GroupModel>> streamDiscoverGroups(String uid) {
    return groups.snapshots().map(
      (s) => s.docs.map((d) => GroupModel.fromMap(d.id, d.data())).where((g) => !g.members.contains(uid)).toList(),
    );
  }

  Future<String> createGroup(GroupModel group) async {
    try {
      final ref = await groups.add(group.toMap());
      return ref.id;
    } catch (e, st) {
      log('createGroup failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> joinGroup(String groupId, String uid) async {
    try {
      await groups.doc(groupId).update({
        'members': FieldValue.arrayUnion([uid]),
      });
    } catch (e, st) {
      log('joinGroup failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Stream<List<ChatMessageModel>> streamMessages(String groupId) {
    return groups.doc(groupId).collection('messages').orderBy('timestamp', descending: true).snapshots().map(
      (s) => s.docs.map((d) => ChatMessageModel.fromMap(d.id, d.data())).toList(),
    );
  }

  Future<void> sendMessage(String groupId, ChatMessageModel message) async {
    try {
      await groups.doc(groupId).collection('messages').add(message.toMap());
      if (message.fileUrl != null && message.fileUrl!.isNotEmpty) {
        await groups.doc(groupId).update({'fileUrls': FieldValue.arrayUnion([message.fileUrl])});
      }
    } catch (e, st) {
      log('sendMessage failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<List<RoomModel>> fetchRooms() async {
    try {
      final s = await rooms.get();
      return s.docs.map((d) => RoomModel.fromMap(d.id, d.data())).toList();
    } catch (e, st) {
      log('fetchRooms failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> bookOrCancelSlot({required String roomId, required String slot, required String uid}) async {
    try {
      await _db.runTransaction((tx) async {
        final doc = await tx.get(rooms.doc(roomId));
        final data = doc.data();
        if (data == null) return;
        final bookedBy = Map<String, dynamic>.from(data['bookedBy'] ?? {});
        if (bookedBy[slot] == uid) {
          bookedBy.remove(slot);
        } else if (bookedBy[slot] == null) {
          bookedBy[slot] = uid;
        }
        tx.update(rooms.doc(roomId), {'bookedBy': bookedBy});
      });
    } catch (e, st) {
      log('bookOrCancelSlot failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> seedRooms() async {
    const seeds = [
      {
        'name': 'Library Room A',
        'location': 'Main Library',
        'capacity': 6,
        'availableSlots': ['9:00 AM', '11:00 AM', '1:00 PM', '3:00 PM'],
        'amenities': ['Whiteboard', 'Power Outlets', 'Wi-Fi']
      },
      {
        'name': 'Engineering Lab 2',
        'location': 'Engineering Building',
        'capacity': 4,
        'availableSlots': ['10:00 AM', '12:00 PM', '2:00 PM', '4:00 PM'],
        'amenities': ['Monitors', 'Projector', 'Wi-Fi']
      },
      {
        'name': 'Student Union 3B',
        'location': 'Student Union',
        'capacity': 8,
        'availableSlots': ['9:00 AM', '11:00 AM', '3:00 PM', '5:00 PM'],
        'amenities': ['Couch', 'TV Display', 'Snacks Nearby']
      },
      {
        'name': 'Science Hall 104',
        'location': 'Science Hall',
        'capacity': 5,
        'availableSlots': ['1:00 PM', '3:00 PM', '5:00 PM', '7:00 PM'],
        'amenities': ['Whiteboard', 'Lab Tables', 'Wi-Fi']
      },
      {
        'name': 'Business Center Study Pod',
        'location': 'Business Center',
        'capacity': 3,
        'availableSlots': ['10:00 AM', '12:00 PM', '2:00 PM', '6:00 PM'],
        'amenities': ['Quiet Zone', 'Power Outlets', 'Wi-Fi']
      },
    ];

    try {
      for (final room in seeds) {
        final name = room['name'] as String;
        final exists = await rooms.where('name', isEqualTo: name).limit(1).get();
        if (exists.docs.isEmpty) {
          await rooms.add({...room, 'bookedBy': <String, String>{}});
        }
      }
    } catch (e, st) {
      log('seedRooms failed', error: e, stackTrace: st);
      rethrow;
    }
  }
}

/*
Recommended Firestore security rules:

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /tasks/{taskId} {
      allow read, create, update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }

    match /groups/{groupId} {
      allow read: if request.auth != null && request.auth.uid in resource.data.members;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if request.auth != null && request.auth.uid == resource.data.createdBy;

      match /messages/{messageId} {
        allow read, create: if request.auth != null
          && request.auth.uid in get(/databases/$(database)/documents/groups/$(groupId)).data.members;
      }
    }

    match /rooms/{roomId} {
      allow read: if request.auth != null;
      allow update: if request.auth != null
        && request.resource.data.diff(resource.data).changedKeys().hasOnly(['bookedBy']);
      allow create, delete: if false;
    }
  }
}
*/
