import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:scholr/models/task_model.dart';
import 'package:scholr/services/firestore_service.dart';
import 'package:scholr/services/notification_service.dart';

class StudyBlock {
  final TaskModel task;
  final DateTime scheduledDate;
  final String timeSlot;

  const StudyBlock({required this.task, required this.scheduledDate, required this.timeSlot});
}

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._firestore, this._notification);

  final FirestoreService _firestore;
  final NotificationService _notification;

  String _filter = 'all';
  String get filter => _filter;

  void setFilter(String value) {
    _filter = value;
    notifyListeners();
  }

  Stream<List<TaskModel>> taskStream(String uid) => _firestore.streamTasks(uid);

  double priorityScore(TaskModel task, [DateTime? now]) {
    final reference = now ?? DateTime.now();
    final daysUntilDeadline = max(1, task.deadline.difference(reference).inDays + 1);
    final deadlineUrgency = 1 / daysUntilDeadline;
    final effortNormalized = min(1.0, task.estimatedEffortHours / 8.0);
    return (task.courseWeight * 0.4) + (deadlineUrgency * 0.4) + (effortNormalized * 0.2);
  }

  Future<void> addTask(TaskModel task) async {
    await _firestore.addTask(task);
    await _notification.scheduleDueSoonReminder(task);
    notifyListeners();
  }

  Future<void> toggleDone(TaskModel task) async {
    final next = task.status == 'done' ? 'pending' : 'done';
    await _firestore.updateTaskStatus(task.id, next);
    notifyListeners();
  }

  Future<void> deleteTask(TaskModel task) async {
    await _firestore.deleteTask(task.id);
    notifyListeners();
  }

  List<TaskModel> applyFilter(List<TaskModel> tasks) {
    if (_filter == 'pending') return tasks.where((t) => t.status != 'done').toList();
    if (_filter == 'done') return tasks.where((t) => t.status == 'done').toList();
    return tasks;
  }

  List<StudyBlock> generateStudyPlan(List<TaskModel> tasks) {
    final pending = tasks.where((t) => t.status != 'done').toList();
    final now = DateTime.now();

    final scored = pending.map((task) {
      final score = priorityScore(task, now);
      return (task: task, score: score);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    const slots = ['9:00 AM', '11:00 AM', '1:00 PM', '3:00 PM', '5:00 PM', '7:00 PM'];
    final scheduled = <String>{};
    final blocks = <StudyBlock>[];

    for (var i = 0; i < scored.length; i++) {
      final dayOffset = i ~/ slots.length;
      final slotIndex = i % slots.length;
      if (dayOffset > 6) break;

      var candidateDay = dayOffset;
      var candidateSlot = slotIndex;

      while (candidateDay <= 6) {
        final key = '$candidateDay-$candidateSlot';
        if (!scheduled.contains(key)) {
          scheduled.add(key);
          blocks.add(
            StudyBlock(
              task: scored[i].task,
              scheduledDate: DateTime(now.year, now.month, now.day).add(Duration(days: candidateDay)),
              timeSlot: slots[candidateSlot],
            ),
          );
          break;
        }
        candidateSlot++;
        if (candidateSlot >= slots.length) {
          candidateSlot = 0;
          candidateDay++;
        }
      }
    }

    return blocks;
  }
}
