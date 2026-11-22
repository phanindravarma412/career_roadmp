import 'package:flutter/material.dart';

import '../models/plan.dart';
import '../state/app_state.dart';
import 'day_screen.dart';

/// Every week and day of the plan, with status.
class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final current = state.currentDay;

    return Scaffold(
      appBar: AppBar(title: const Text('Full plan')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          for (final week in state.plan.weeks)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              clipBehavior: Clip.antiAlias,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: week.id == current.weekId,
                  leading: _WeekBadge(week: week, fraction: state.weekFraction(week)),
                  title: Text(week.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    week.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5),
                  ),
                  children: [
                    for (final day in week.days)
                      _DayRow(day: day, isCurrent: day == current),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekBadge extends StatelessWidget {
  const _WeekBadge({required this.week, required this.fraction});
  final PlanWeek week;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final done = fraction == 1;
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: fraction,
            strokeWidth: 4,
            backgroundColor: scheme.surfaceContainerHighest,
          ),
          done
              ? Icon(Icons.check_rounded, color: scheme.primary, size: 20)
              : Text(
                  '${(fraction * 100).round()}%',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day, required this.isCurrent});
  final PlanDay day;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final done = state.doneCount(day);
    final total = day.tasks.length;
    final complete = state.isDayDone(day);

    final Widget icon;
    if (complete) {
      icon = Icon(Icons.check_circle_rounded, color: scheme.primary);
    } else if (isCurrent) {
      icon = Icon(Icons.play_circle_fill_rounded, color: scheme.tertiary);
    } else if (done > 0) {
      icon = Icon(Icons.timelapse_rounded, color: scheme.secondary);
    } else {
      icon = Icon(Icons.circle_outlined, color: scheme.outlineVariant);
    }

    final tags = <String>{
      for (final t in day.tasks)
        if (t.tag != null) t.tag!,
    };

    return ListTile(
      dense: true,
      tileColor: isCurrent ? scheme.tertiaryContainer.withValues(alpha: 0.35) : null,
      leading: icon,
      title: Text.rich(
        TextSpan(
          text: day.title,
          style: TextStyle(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600),
          children: [
            if (isCurrent)
              TextSpan(
                text: '  · today',
                style: TextStyle(color: scheme.tertiary, fontWeight: FontWeight.w700),
              ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        [
          if (day.weekdayLabel != null) '${day.weekdayLabel}, ${day.hours} h',
          if (day.isRedo) 'redo',
          ...tags,
          day.tasks.isEmpty ? '' : day.tasks.first.text.replaceAll('`', ''),
        ].where((s) => s.isNotEmpty).join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '$done/$total',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: complete ? scheme.primary : scheme.onSurfaceVariant,
        ),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DayScreen(day: day)),
      ),
    );
  }
}
