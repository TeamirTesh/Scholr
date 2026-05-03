import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:scholr/providers/task_provider.dart';
import 'package:scholr/utils/date_formatters.dart';

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
                ? 'Add tasks to generate your study plan'
                : 'No pending tasks to schedule.',
          ),
        ),
      );
    }

    final chartData = blocks.take(7).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("This Week's Plan", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(show: true, topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
                  barGroups: chartData.asMap().entries.map((e) {
                    return BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.task.estimatedEffortHours.clamp(1, 8))]);
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...chartData.take(5).map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('${formatStudyBlockLine(b.scheduledDate, b.timeSlot)} · ${b.task.title}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
