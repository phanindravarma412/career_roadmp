import 'package:flutter/material.dart';

import '../logic/gamification.dart';
import '../models/progress_log.dart';

/// GitHub-style grid of tasks ticked per day, oldest week on the left.
class ActivityHeatmap extends StatelessWidget {
  const ActivityHeatmap({
    super.key,
    required this.activity,
    required this.today,
    this.weeks = 15,
  });

  final Map<DateTime, int> activity;
  final DateTime today;
  final int weeks;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Start on the Monday `weeks - 1` weeks before this week's Monday.
    final thisMonday = today.subtract(Duration(days: today.weekday - 1));
    final start = thisMonday.subtract(Duration(days: 7 * (weeks - 1)));

    Color cellColor(int count) {
      if (count == 0) return scheme.surfaceContainerHighest;
      final t = (count / 8).clamp(0.25, 1.0);
      return Color.lerp(scheme.primaryContainer, scheme.primary, t)!;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const labelWidth = 18.0;
        const gap = 3.0;
        final cell = ((constraints.maxWidth - labelWidth) / weeks - gap).clamp(8.0, 18.0);
        const dayLabels = ['M', '', 'W', '', 'F', '', 'S'];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: labelWidth,
                  child: Column(
                    children: [
                      for (final l in dayLabels)
                        SizedBox(
                          height: cell + gap,
                          child: Text(
                            l,
                            style: TextStyle(fontSize: 9, color: scheme.onSurfaceVariant),
                          ),
                        ),
                    ],
                  ),
                ),
                for (var w = 0; w < weeks; w++)
                  Padding(
                    padding: const EdgeInsets.only(right: gap),
                    child: Column(
                      children: [
                        for (var d = 0; d < 7; d++)
                          Builder(
                            builder: (context) {
                              final date = dateOnly(start.add(Duration(days: w * 7 + d)));
                              final future = date.isAfter(today);
                              final count = activity[date] ?? 0;
                              return Container(
                                width: cell,
                                height: cell,
                                margin: const EdgeInsets.only(bottom: gap),
                                decoration: BoxDecoration(
                                  color: future ? Colors.transparent : cellColor(count),
                                  borderRadius: BorderRadius.circular(3),
                                  border: date == today
                                      ? Border.all(color: scheme.onSurface, width: 1.2)
                                      : null,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Less ', style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
                for (final c in [0, 2, 4, 6, 8])
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(left: 2),
                    decoration: BoxDecoration(
                      color: cellColor(c),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                Text(' More', style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Bar per check-in (average out of 5) with the 3.5 pass line.
class CheckInChart extends StatelessWidget {
  const CheckInChart({super.key, required this.checkIns});
  final List<CheckInResult> checkIns;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const height = 150.0;
    const passLine = 3.5;
    final pass = const Color(0xFF16A34A);
    final fail = scheme.error;

    String label(String day) => day
        .replaceAll('(re-test)', 'R')
        .replaceAll(' ', '');

    return SizedBox(
      height: height + 40,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Bars sit on a 22px label row and grow up to (height - 18).
          final lineY = (height + 40) - 22 - (height - 18) * passLine / 5;
          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: lineY,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(height: 1, color: scheme.outline.withValues(alpha: 0.6)),
                    ),
                    Text(
                      ' 3.5 pass',
                      style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                right: 48,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final c in checkIns)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                c.average.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 3),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: c.average / 5),
                                duration: const Duration(milliseconds: 600),
                                builder: (context, v, _) => Container(
                                  width: 26,
                                  height: (height - 18) * v,
                                  decoration: BoxDecoration(
                                    color: c.passed ? pass : fail,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 18,
                                child: Text(
                                  'D${label(c.day)}',
                                  style: TextStyle(fontSize: 10.5, color: scheme.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
