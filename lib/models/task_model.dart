import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String course;
  final double courseWeight;
  final DateTime deadline;
  final double estimatedEffortHours;
  final String status;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.course,
    required this.courseWeight,
    required this.deadline,
    required this.estimatedEffortHours,
    required this.status,
    required this.createdAt,
  });

  bool get isDone => status == 'done';

  factory TaskModel.fromMap(String id, Map<String, dynamic> map) {
    return TaskModel(
      id: id,
      userId: map['userId'] as String,
      title: map['title'] as String,
      course: map['course'] as String,
      courseWeight: (map['courseWeight'] as num).toDouble(),
      deadline: (map['deadline'] as Timestamp).toDate(),
      estimatedEffortHours: (map['estimatedEffortHours'] as num).toDouble(),
      status: map['status'] as String,
      createdAt: ((map['createdAt'] as Timestamp?)?.toDate()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'course': course,
      'courseWeight': courseWeight,
      'deadline': Timestamp.fromDate(deadline),
      'estimatedEffortHours': estimatedEffortHours,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  TaskModel copyWith({String? status}) {
    return TaskModel(
      id: id,
      userId: userId,
      title: title,
      course: course,
      courseWeight: courseWeight,
      deadline: deadline,
      estimatedEffortHours: estimatedEffortHours,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
