import 'package:flutter/material.dart';

import '../models/plan.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

/// First launch: where are you in the plan, and when did Day 1 start?
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PlanDay? _day;
  DateTime? _start;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final days = state.plan.countedDays;
    final day = _day ?? state.plan.dayById['d2redo'] ?? days.first;
    final start = _start ?? state.startDate;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Icon(Icons.rocket_launch_rounded, size: 56, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'Your road to Senior Full-Stack',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              '${days.length} days, ${state.totalTasks} tasks. Tick them off here, keep your streak, '
              'and watch the percentage climb.',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 28),
            Text('Which day are you on?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Every day before it is marked done. Tick the rest of this day yourself.',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<PlanDay>(
              initialValue: day,
              isExpanded: true,
              menuMaxHeight: 400,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: [
                for (final d in days)
                  DropdownMenuItem(
                    value: d,
                    child: Text('${d.title}${d.weekdayLabel != null ? ' (${d.weekdayLabel})' : ''}'),
                  ),
              ],
              onChanged: (d) => setState(() => _day = d),
            ),
            const SizedBox(height: 24),
            Text('When did you do Day 1?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Used to show whether you are on schedule. You can change it later.',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.event_rounded),
              label: Text(shortDate(start)),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: start,
                  firstDate: DateTime(2026),
                  lastDate: DateTime(2028),
                );
                if (picked != null) setState(() => _start = picked);
              },
            ),
            const SizedBox(height: 36),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      await state.setStartDate(start);
                      await state.markDoneBefore(day);
                      await state.setReminder(on: true);
                      await state.completeOnboarding();
                    },
              child: const Text('Start', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
