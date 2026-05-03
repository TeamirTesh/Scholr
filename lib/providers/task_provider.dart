import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:scholr/models/task_model.dart';
import 'package:scholr/services/firestore_service.dart';
import 'package:scholr/services/notification_service.dart';

class StudyBlock {
  final TaskModel task;
  final DateTime scheduledDate;
  final String timeSlot;
  final double hours;

  const StudyBlock({required this.task, required this.scheduledDate, required this.timeSlot, required this.hours});
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
  }

  Future<void> toggleDone(TaskModel task) async {
    final next = task.status == 'done' ? 'pending' : 'done';
    await _firestore.updateTaskStatus(task.id, next);
  }

  Future<void> deleteTask(TaskModel task) async {
    await _firestore.deleteTask(task.id);
  }

  List<TaskModel> applyFilter(List<TaskModel> tasks) {
    if (_filter == 'pending') return tasks.where((t) => t.status != 'done').toList();
    if (_filter == 'done') return tasks.where((t) => t.status == 'done').toList();
    return tasks;
  }

  List<StudyBlock> generateStudyPlan(List<TaskModel> tasks) {
    final pending = tasks.where((t) => t.status != 'done').toList();
    if (pending.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const maxHoursPerDay = 5.0;
    const minChunk = 0.5;

    // Sort highest priority first
    final sorted = pending
        .map((t) => (task: t, score: priorityScore(t)))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    // Remaining daily budget for next 30 days
    final budget = <DateTime, double>{};
    for (var i = 0; i < 30; i++) {
      budget[today.add(Duration(days: i))] = maxHoursPerDay;
    }

    // Raw chunks before time-slot assignment
    final chunks = <({TaskModel task, DateTime date, double hours})>[];

    for (final item in sorted) {
      final task = item.task;
      var remaining = task.estimatedEffortHours;

      final deadlineDay = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
      final daysUntilDue = max(1, deadlineDay.difference(today).inDays);

      // All days available for this task (today through day before deadline,
      // or just today if deadline is today/past)
      final availDays = List.generate(daysUntilDue, (i) => today.add(Duration(days: i)));

      if (availDays.length == 1) {
        // No room to spread — schedule as much as today's budget allows
        final day = availDays[0];
        final b = budget[day] ?? 0;
        final hours = min(remaining, b);
        if (hours >= minChunk) {
          budget[day] = b - hours;
          chunks.add((task: task, date: day, hours: hours));
        }
      } else {
        // Spread evenly: target hours per day = remaining / days available,
        // capped at maxHoursPerDay so no single day is overloaded
        final targetPerDay = (remaining / availDays.length).clamp(minChunk, maxHoursPerDay);

        for (final day in availDays) {
          if (remaining < minChunk) break;
          final b = budget[day] ?? 0;
          if (b < minChunk) continue;

          // On the last available day take whatever is left (up to budget)
          // so we don't leave work unscheduled
          final isLast = day == availDays.last;
          final take = min(isLast ? remaining : targetPerDay, min(remaining, b));
          if (take < minChunk) continue;

          budget[day] = b - take;
          remaining -= take;
          chunks.add((task: task, date: day, hours: take));
        }
      }
    }

    // Sort by date so the widget shows a chronological plan
    chunks.sort((a, b) => a.date.compareTo(b.date));

    // Assign time slots sequentially within each day
    const slots = ['9:00 AM', '11:00 AM', '1:00 PM', '3:00 PM', '5:00 PM', '7:00 PM'];
    final slotIdx = <DateTime, int>{};

    return chunks.map((c) {
      final i = slotIdx[c.date] ?? 0;
      slotIdx[c.date] = i + 1;
      final slot = i < slots.length ? slots[i] : '${9 + (i * 2)}:00 PM';
      return StudyBlock(task: c.task, scheduledDate: c.date, timeSlot: slot, hours: c.hours);
    }).toList();
  }
}
