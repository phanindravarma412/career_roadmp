import 'package:flutter/material.dart';

import '../models/plan.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/task_tile.dart';

class DayScreen extends StatelessWidget {
  const DayScreen({super.key, required this.day});
  final PlanDay day;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    // Use the latest version of this day if a sync replaced the plan.
    final day = state.plan.dayById[this.day.id] ?? this.day;
    final scheme = Theme.of(context).colorScheme;
    final week = state.plan.weekOf(day);
    final done = state.doneCount(day);
    final total = day.tasks.length;
    final plannedDate = day.number == 0 || day.isFinal
        ? null
        : state.startDate.add(Duration(days: day.number - 1));

    return Scaffold(
      appBar: AppBar(title: Text(day.title)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SectionCard(
            child: Row(
              children: [
                ProgressRing(
                  value: total == 0 ? 0 : done / total,
                  size: 72,
                  stroke: 8,
                  child: Text('$done/$total', style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${week.label} · ${week.title}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (day.subtitle != null)
                        Text(day.subtitle!, style: TextStyle(color: scheme.onSurfaceVariant)),
                      if (day.hours != null)
                        Text('${day.hours} hours', style: TextStyle(color: scheme.onSurfaceVariant)),
                      if (plannedDate != null)
                        Text(
                          'Planned for ${shortDate(plannedDate)}',
                          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SectionCard(
            title: 'Tasks',
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
            child: Column(children: [for (final t in day.tasks) TaskTile(task: t)]),
          ),
        ],
      ),
    );
  }
}
