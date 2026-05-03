import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scholr/providers/task_provider.dart';

class StudyPlanWidget extends StatelessWidget {
  const StudyPlanWidget({super.key, required this.blocks, this.emptyBecauseNoTasks = false});

  final List<StudyBlock> blocks;
  final bool emptyBecauseNoTasks;

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            emptyBecauseNoTasks
                ? 'Add tasks to generate your study plan.'
                : 'No pending tasks to schedule.',
          ),
        ),
      );
    }

    final shown = blocks.take(7).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("This Week's Plan", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...shown.map((b) => _StudyBlockRow(block: b)),
            if (blocks.length > 7) ...[
              const SizedBox(height: 8),
              Text(
                '+${blocks.length - 7} more sessions',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StudyBlockRow extends StatelessWidget {
  const _StudyBlockRow({required this.block});
  final StudyBlock block;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 44,
            margin: const EdgeInsets.only(right: 12, top: 2),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.task.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${DateFormat('EEE, MMM d').format(block.scheduledDate)}  ${block.timeSlot}  ·  ${block.hours.toStringAsFixed(1)}h',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
