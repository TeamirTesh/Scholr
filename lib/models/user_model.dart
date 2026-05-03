import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String profilePicUrl;
  final List<String> courses;
  final String fcmToken;
  final bool notificationsEnabled;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePicUrl,
    required this.courses,
    required this.fcmToken,
    required this.notificationsEnabled,
    required this.createdAt,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: (map['name'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      profilePicUrl: (map['profilePicUrl'] ?? '') as String,
      courses: List<String>.from(map['courses'] ?? const []),
      fcmToken: (map['fcmToken'] ?? '') as String,
      notificationsEnabled: (map['notificationsEnabled'] ?? true) as bool,
      createdAt: ((map['createdAt'] as Timestamp?)?.toDate()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profilePicUrl': profilePicUrl,
      'courses': courses,
      'fcmToken': fcmToken,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
