import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roadmap_tracker/logic/gamification.dart';
import 'package:roadmap_tracker/models/plan.dart';
import 'package:roadmap_tracker/models/progress_log.dart';
import 'package:roadmap_tracker/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final plan = Plan.parse(File('assets/repo/plan/daily-plan.md').readAsStringSync());
  final log = ProgressLog.parse(File('assets/repo/plan/progress-log.md').readAsStringSync());

  group('plan parser', () {
    test('finds every day from 0 to 98 plus the redo and Day 99', () {
      final numbers = plan.days.where((d) => !d.isRedo && !d.isFinal).map((d) => d.number).toList();
      expect(numbers, List.generate(99, (i) => i));
      expect(plan.dayById['d2redo'], isNotNull);
      expect(plan.days.last.isFinal, isTrue);
      expect(plan.countedDays.length, 100); // 0..98 + Day 2 redo
    });

    test('groups days into setup, F1, F2, 1-12 and job search', () {
      expect(plan.weeks.map((w) => w.id).toList(), [
        '0', 'F1', 'F2', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', 'jobs',
      ]);
      expect(plan.weekOf(plan.dayById['d1']!).id, 'F1');
      expect(plan.weekOf(plan.dayById['d2redo']!).id, 'F1');
    });

    test('every counted day has tasks', () {
      for (final d in plan.countedDays) {
        expect(d.tasks, isNotEmpty, reason: d.title);
      }
    });

    test('splits chips, tags and Input/Output details', () {
      final day1 = plan.dayById['d1']!;
      final converter = day1.tasks[1];
      expect(converter.text, 'Write a temperature converter');
      expect(converter.chips, ['js-ts/']);
      expect(converter.details.first, startsWith('Input:'));

      final setupTask = plan.dayById['d0']!.tasks.first;
      expect(setupTask.chips, ['setup']);
      expect(setupTask.text, contains('`node -v`')); // inline code kept

      final dsa = plan.dayById['d8']!.tasks.firstWhere((t) => t.tag == 'DSA');
      expect(dsa.category, Category.dsa);
      expect(dsa.text, isNot(startsWith('(DSA)')));
    });

    test('weekend days have 5 hours', () {
      final d6 = plan.dayById['d6']!;
      expect(d6.hours, 5);
      expect(d6.weekdayLabel, 'Saturday');
      expect(plan.dayById['d3']!.hours, 2);
    });

    test('parses the How to prepare guides', () {
      expect(plan.guides.map((g) => g.title), contains('How to prepare for DSA'));
      expect(plan.guides.any((g) => g.title.startsWith('Day ')), isFalse);
    });
  });

  group('progress log parser', () {
    test('reads check-in averages', () {
      expect(log.checkIns.map((c) => c.average), containsAllInOrder([3.9, 2.9, 4.8]));
      expect(log.checkIns.first.date, DateTime(2026, 11, 8));
    });

    test('separates cleared and open revision topics', () {
      expect(log.revision.where((r) => r.cleared).length, greaterThanOrEqualTo(3));
      expect(log.openRevision.any((r) => r.topic.startsWith('var/let/const')), isTrue);
    });
  });

  group('streaks', () {
    final today = DateTime(2026, 11, 22);
    DateTime d(int day) => DateTime(2026, 11, day);

    test('counts back from today', () {
      expect(currentStreak({d(20), d(21), d(22)}, today), 3);
    });

    test('stays alive until today ends', () {
      expect(currentStreak({d(20), d(21)}, today), 2);
    });

    test('breaks after a missed day', () {
      expect(currentStreak({d(19), d(20)}, today), 0);
      expect(bestStreak({d(1), d(2), d(3), d(10), d(11)}), 3);
    });
  });

  group('app state', () {
    late AppState state;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      state = AppState(plan: plan, log: log, prefs: prefs, clock: () => DateTime(2026, 11, 22, 10));
    });

    test('onboarding back-fill moves the current day without faking a streak', () async {
      await state.markDoneBefore(plan.dayById['d3']!);
      expect(state.currentDay.id, 'd3');
      expect(state.doneDays, 4); // Day 0, 1, 2, 2 redo
      expect(state.streak, 0);
    });

    test('finishing a day reports it for the celebration', () async {
      await state.markDoneBefore(plan.dayById['d3']!);
      final day3 = plan.dayById['d3']!;
      ToggleOutcome? last;
      for (final t in day3.tasks) {
        last = await state.toggle(t);
      }
      expect(last!.completedDay, day3);
      expect(state.currentDay.id, 'd4');
      expect(state.streak, 1);
      expect(state.tasksToday, day3.tasks.length);
    });

    test('schedule: behind by the gap between expected and current day', () async {
      await state.setStartDate(DateTime(2026, 11, 8));
      await state.markDoneBefore(plan.dayById['d3']!);
      expect(state.expectedDayNumber, 15);
      expect(state.daysBehind, 12);
      await state.replanFromToday();
      expect(state.daysBehind, 0);
    });

    test('backup round-trips', () async {
      await state.toggle(plan.dayById['d1']!.tasks.first);
      final backup = state.exportBackup();
      await state.resetProgress();
      expect(state.doneTasks, 0);
      await state.importBackup(backup);
      expect(state.doneTasks, 1);
    });
  });
}
