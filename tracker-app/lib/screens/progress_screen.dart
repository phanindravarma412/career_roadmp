import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final pct = state.overallFraction * 100;
    final level = state.levelInfo;
    final readiness = state.readiness;
    final badges = state.badges;
    final unlocked = badges.where((b) => b.unlocked).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Overall
          SectionCard(
            child: Row(
              children: [
                ProgressRing(
                  value: state.overallFraction,
                  size: 120,
                  stroke: 12,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${pct.toStringAsFixed(pct < 10 ? 1 : 0)}%',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                      ),
                      Text('done', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Stat(label: 'Tasks done', value: '${state.doneTasks} / ${state.totalTasks}'),
                      _Stat(label: 'Days done', value: '${state.doneDays} / ${state.totalDays}'),
                      _Stat(
                        label: 'Pending',
                        value: '${(100 - pct).toStringAsFixed(1)}%',
                      ),
                      _Stat(
                        label: 'Applications',
                        value: state.projectedApplicationsDate == null
                            ? 'Set a pace'
                            : shortDate(state.projectedApplicationsDate!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Level
          SectionCard(
            title: 'Level ${level.level.index}: ${level.level.title}',
            trailing: Text('${level.xp} XP', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: level.progressInLevel,
                    minHeight: 10,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  level.next == null
                      ? 'Top level reached. Go get that offer.'
                      : '${level.nextLevelXp - level.xp} XP to Level ${level.next!.index}: ${level.next!.title}',
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5),
                ),
                const SizedBox(height: 4),
                Text(
                  '10 XP per task · 25 XP per finished day · 50 XP per passed check-in',
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11.5),
                ),
              ],
            ),
          ),

          // Streak
          SectionCard(
            title: 'Consistency',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _BigNumber(
                      icon: Icons.local_fire_department_rounded,
                      color: const Color(0xFFF97316),
                      value: '${state.streak}',
                      label: 'current streak',
                    ),
                    _BigNumber(
                      icon: Icons.emoji_events_rounded,
                      color: const Color(0xFFEAB308),
                      value: '${state.longestStreak}',
                      label: 'best streak',
                    ),
                    _BigNumber(
                      icon: Icons.today_rounded,
                      color: scheme.primary,
                      value: '${state.tasksToday}',
                      label: 'tasks today',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ActivityHeatmap(activity: state.activity, today: state.today),
              ],
            ),
          ),

          // Interview readiness
          if (state.log.checkIns.isNotEmpty)
            SectionCard(
              title: 'Check-in scores',
              trailing: readiness == null
                  ? null
                  : Text(
                      'Readiness ${(readiness * 100).round()}%',
                      style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700),
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckInChart(checkIns: state.log.checkIns),
                  Text(
                    'Readiness = average of your last 3 check-ins out of 5. '
                    'Scores come from plan/progress-log.md (synced at build time).',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11.5),
                  ),
                ],
              ),
            ),

          // Skills
          SectionCard(
            title: 'Skill tracks',
            child: Column(
              children: [
                for (final e in state.categoryProgress.entries)
                  LabeledBar(
                    label: e.key.label,
                    value: e.value.$2 == 0 ? 0 : e.value.$1 / e.value.$2,
                    trailing: '${e.value.$1} / ${e.value.$2}',
                    color: categoryColor(e.key, scheme),
                  ),
              ],
            ),
          ),

          // Weeks
          SectionCard(
            title: 'Weeks',
            child: Column(
              children: [
                for (final w in state.plan.weeks.where((w) => w.id != 'jobs'))
                  LabeledBar(
                    label: '${w.label} · ${w.title}',
                    value: state.weekFraction(w),
                    trailing: '${(state.weekFraction(w) * 100).round()}%',
                  ),
              ],
            ),
          ),

          // Badges
          SectionCard(
            title: 'Badges',
            trailing: Text('$unlocked / ${badges.length}', style: TextStyle(color: scheme.onSurfaceVariant)),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.9,
              children: [
                for (final b in badges)
                  Tooltip(
                    message: b.description,
                    triggerMode: TooltipTriggerMode.tap,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: b.unlocked
                            ? scheme.primaryContainer
                            : scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            b.unlocked ? b.icon : Icons.lock_outline_rounded,
                            size: 30,
                            color: b.unlocked ? scheme.onPrimaryContainer : scheme.outline,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            b.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: b.unlocked ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            b.description,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
        ],
      ),
    );
  }
}

class _BigNumber extends StatelessWidget {
  const _BigNumber({required this.icon, required this.color, required this.value, required this.label});
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 4),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
          Text(label, style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
