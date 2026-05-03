import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfilePhoto(String uid, File file) async {
    try {
      final ref = _storage.ref('profile_pics/$uid.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e, st) {
      log('uploadProfilePhoto failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<String> uploadGroupFile(String groupId, String filename, File file) async {
    try {
      final ref = _storage.ref('group_files/$groupId/$filename');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e, st) {
      log('uploadGroupFile failed', error: e, stackTrace: st);
      rethrow;
    }
  }
}
