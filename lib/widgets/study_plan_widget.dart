import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:scholr/providers/task_provider.dart';

class StudyPlanWidget extends StatelessWidget {
  const StudyPlanWidget({super.key, required this.blocks});
  final List<StudyBlock> blocks;

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No pending tasks to schedule.')));
    }

    final chartData = blocks.take(7).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Study Plan', style: Theme.of(context).textTheme.titleLarge),
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
            ...chartData.take(3).map((b) => Text('${b.timeSlot} · ${b.task.title}')),
          ],
        ),
      ),
    );
  }
}
