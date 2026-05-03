import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String course;
  final String createdBy;
  final List<String> members;
  final List<String> fileUrls;
  final String description;
  final DateTime createdAt;

  const GroupModel({
    required this.id,
    required this.name,
    required this.course,
    required this.createdBy,
    required this.members,
    required this.fileUrls,
    required this.description,
    required this.createdAt,
  });

  factory GroupModel.fromMap(String id, Map<String, dynamic> map) {
    return GroupModel(
      id: id,
      name: map['name'] as String,
      course: map['course'] as String,
      createdBy: map['createdBy'] as String,
      members: List<String>.from(map['members'] ?? const []),
      fileUrls: List<String>.from(map['fileUrls'] ?? const []),
      description: (map['description'] ?? '') as String,
      createdAt: ((map['createdAt'] as Timestamp?)?.toDate()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'course': course,
      'createdBy': createdBy,
      'members': members,
      'fileUrls': fileUrls,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
