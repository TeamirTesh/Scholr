import 'package:flutter/material.dart';
import 'package:scholr/models/task_model.dart';
import 'package:scholr/providers/task_provider.dart';
import 'package:scholr/utils/date_formatters.dart';
import 'package:timeago/timeago.dart' as timeago;

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    this.onOpen,
    this.studyBlock,
    this.priorityScore,
    this.initiallyExpanded = false,
  });

  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback? onOpen;
  final StudyBlock? studyBlock;
  final double? priorityScore;
  final bool initiallyExpanded;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id) {
      _expanded = widget.initiallyExpanded;
    } else if (widget.initiallyExpanded && !oldWidget.initiallyExpanded) {
      _expanded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final relative = timeago.format(widget.task.deadline, allowFromNow: true);
    final fullDue = scholrDeadlineFormat.format(widget.task.deadline);
    final score = widget.priorityScore;

    return Card(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            ListTile(
              onTap: () {
                if (widget.onOpen != null) {
                  widget.onOpen!();
                } else {
                  setState(() => _expanded = !_expanded);
                }
              },
              leading: Checkbox(
                value: widget.task.status == 'done',
                onChanged: (_) => widget.onToggle(),
              ),
              title: Text(widget.task.title),
              subtitle: Text('${widget.task.course} · $relative · ${widget.task.estimatedEffortHours}h'),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
            ),
            if (_expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (score != null) Text('Priority score: ${score.toStringAsFixed(2)}'),
                      if (widget.studyBlock != null)
                        Text(
                          'Scheduled block: ${formatStudyBlockLine(widget.studyBlock!.scheduledDate, widget.studyBlock!.timeSlot)}',
                        ),
                      const SizedBox(height: 6),
                      Text('Deadline: $fullDue'),
                      const SizedBox(height: 6),
                      Chip(
                        label: Text(widget.task.status.toUpperCase()),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
