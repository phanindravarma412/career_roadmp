import 'package:flutter/material.dart';

import '../logic/gamification.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/task_tile.dart';
import 'day_screen.dart';
import 'settings_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  String _greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final day = state.currentDay;
    final week = state.plan.weekOf(day);
    final next = state.dayAfter(day);
    final done = state.doneCount(day);
    final total = day.tasks.length;
    final open = state.log.openRevision;
    final quote = motivationLines[state.today.difference(DateTime(2026)).inDays %
            motivationLines.length]
        .replaceAll('{day}', '${day.number}');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_greeting(DateTime.now())}, Phani',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              shortDate(state.today),
              style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _HeroCard(dayTitle: day.title, weekLabel: '${week.label} · ${week.title}', done: done, total: total, hours: day.hours, weekday: day.weekdayLabel),
          _ScheduleBanner(),
          SectionCard(
            title: day.isRedo ? '${day.title} - fix and re-test' : 'Today\'s tasks',
            trailing: Text(
              '$done / $total',
              style: TextStyle(fontWeight: FontWeight.w700, color: scheme.primary),
            ),
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (day.subtitle != null && day.weekdayLabel == null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 6),
                    child: Text(
                      day.subtitle!,
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                    ),
                  ),
                for (final t in day.tasks) TaskTile(task: t),
              ],
            ),
          ),
          if (open.isNotEmpty)
            SectionCard(
              title: 'Revise (from your check-ins)',
              trailing: Icon(Icons.replay_rounded, color: scheme.tertiary),
              child: Column(
                children: [
                  for (final r in open)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2, right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: scheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              r.score.split(' ').first,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: scheme.onTertiaryContainer,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichLine(r.topic, style: const TextStyle(fontSize: 14)),
                                if (r.reviseBy.isNotEmpty && r.reviseBy != '-')
                                  Text(
                                    'Revise by ${r.reviseBy}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Answers are in notes/revision-notes.md.',
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          if (next != null)
            SectionCard(
              title: 'Up next: ${next.title}',
              trailing: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DayScreen(day: next)),
                ),
                child: const Text('Preview'),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final t in next.tasks.take(3))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${t.number}.  ', style: TextStyle(color: scheme.onSurfaceVariant)),
                          Expanded(child: RichLine(t.text, maxLines: 2)),
                        ],
                      ),
                    ),
                  if (next.tasks.length > 3)
                    Text(
                      '+ ${next.tasks.length - 3} more',
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5),
                    ),
                ],
              ),
            ),
          SectionCard(
            child: Row(
              children: [
                Icon(Icons.format_quote_rounded, color: scheme.primary, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    quote,
                    style: const TextStyle(fontSize: 14.5, fontStyle: FontStyle.italic, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          SectionCard(
            child: Row(
              children: [
                Icon(Icons.flag_circle_rounded, color: scheme.secondary, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why I\'m doing this',
                        style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 2),
                      Text(state.goal, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
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

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.dayTitle,
    required this.weekLabel,
    required this.done,
    required this.total,
    required this.hours,
    required this.weekday,
  });

  final String dayTitle;
  final String weekLabel;
  final int done;
  final int total;
  final int? hours;
  final String? weekday;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final level = state.levelInfo;
    final onHero = scheme.onPrimary;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, Color.lerp(scheme.primary, scheme.tertiary, 0.7)!],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayTitle,
                      style: TextStyle(
                        color: onHero,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weekLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: onHero.withValues(alpha: 0.85), fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (hours != null)
                          _HeroPill(icon: Icons.schedule_rounded, label: '$hours h${weekday != null ? ' · $weekday' : ''}'),
                        _HeroPill(
                          icon: Icons.local_fire_department_rounded,
                          label: '${state.streak}-day streak',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ProgressRing(
                value: total == 0 ? 0 : done / total,
                size: 96,
                stroke: 9,
                color: onHero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$done/$total',
                      style: TextStyle(color: onHero, fontWeight: FontWeight.w800, fontSize: 20),
                    ),
                    Text('today', style: TextStyle(color: onHero.withValues(alpha: 0.8), fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Lv ${level.level.index} · ${level.level.title}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: onHero, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                level.next == null ? '${level.xp} XP' : '${level.xp} / ${level.nextLevelXp} XP',
                style: TextStyle(color: onHero.withValues(alpha: 0.85), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: level.progressInLevel,
              minHeight: 7,
              color: onHero,
              backgroundColor: onHero.withValues(alpha: 0.25),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(state.overallFraction * 100).toStringAsFixed(1)}% of the plan done · '
            '${state.doneDays} of ${state.totalDays} days',
            style: TextStyle(color: onHero.withValues(alpha: 0.85), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final on = Theme.of(context).colorScheme.onPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: on.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: on),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: on, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ScheduleBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (state.currentDay.isFinal) return const SizedBox.shrink();
    final behind = state.daysBehind;
    final projected = state.projectedApplicationsDate;

    final (IconData icon, Color bg, Color fg, String title, String body) = behind <= 0
        ? (
            Icons.verified_rounded,
            const Color(0xFF16A34A).withValues(alpha: 0.12),
            const Color(0xFF15803D),
            behind < 0 ? '${-behind} day${behind == -1 ? '' : 's'} ahead of schedule' : 'On schedule',
            'Applications start ${shortDate(state.plannedApplicationsDate)}.',
          )
        : (
            Icons.directions_run_rounded,
            scheme.tertiaryContainer,
            scheme.onTertiaryContainer,
            '$behind day${behind == 1 ? '' : 's'} behind schedule',
            projected == null
                ? 'Finish today\'s tasks to set a pace.'
                : 'At your pace, applications start ${shortDate(projected)}.',
          );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: bg,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        child: Row(
          children: [
            Icon(icon, color: fg),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: fg)),
                  Text(body, style: TextStyle(fontSize: 12.5, color: fg)),
                ],
              ),
            ),
            if (behind > 3)
              TextButton(
                onPressed: () => _confirmReplan(context, state),
                child: const Text('Re-plan'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReplan(BuildContext context, AppState state) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-plan from today?'),
        content: Text(
          'This moves the plan\'s start date so that today is ${state.currentDay.title}. '
          'Your ticked tasks stay as they are. Applications would start '
          '${shortDate(state.today.add(Duration(days: 99 - state.currentDay.number)))}.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Re-plan')),
        ],
      ),
    );
    if (ok == true) await state.replanFromToday();
  }
}
