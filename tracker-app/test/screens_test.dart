import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadmap_tracker/main.dart';
import 'package:roadmap_tracker/models/plan.dart';
import 'package:roadmap_tracker/models/progress_log.dart';
import 'package:roadmap_tracker/screens/progress_screen.dart';
import 'package:roadmap_tracker/services/repo_sync.dart';
import 'package:roadmap_tracker/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Smoke tests: every screen renders at phone size without layout errors.
void main() {
  final plan = Plan.parse(File('assets/repo/plan/daily-plan.md').readAsStringSync());
  final log = ProgressLog.parse(File('assets/repo/plan/progress-log.md').readAsStringSync());

  Future<AppState> makeState({required bool onboarded}) async {
    SharedPreferences.setMockInitialValues({'onboarded': onboarded});
    final prefs = await SharedPreferences.getInstance();
    final files = <String, String>{
      for (final f in Directory('assets/repo').listSync(recursive: true).whereType<File>())
        f.path.substring('assets/repo/'.length): f.readAsStringSync(),
    };
    final state = AppState(
      plan: plan,
      log: log,
      prefs: prefs,
      snapshot: RepoSnapshot(files: files),
      clock: () => DateTime(2026, 11, 22, 19),
    );
    if (onboarded) await state.markDoneBefore(plan.dayById['d2redo']!);
    return state;
  }

  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75; // ~393 x 851 logical
    addTearDown(tester.view.reset);
  }

  testWidgets('onboarding renders and starts the app', (tester) async {
    phone(tester);
    final state = await makeState(onboarded: false);
    await tester.pumpWidget(RoadmapApp(state: state));
    expect(find.text('Your road to Senior Full-Stack'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.text('Day 2 redo'), findsOneWidget);
  });

  testWidgets('today, plan, progress and guides tabs render', (tester) async {
    phone(tester);
    final state = await makeState(onboarded: true);
    await tester.pumpWidget(RoadmapApp(state: state));
    await tester.pumpAndSettle();

    // Today
    expect(find.text('Day 2 redo'), findsOneWidget);
    expect(find.textContaining('behind schedule'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -1500));
    await tester.pumpAndSettle();
    expect(find.textContaining('Up next: Day 3'), findsOneWidget);

    // Plan
    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();
    expect(find.text('Full plan'), findsOneWidget);
    await tester.tap(find.text('Day 3').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Write word count using a Map'), findsOneWidget);
    await tester.tap(find.textContaining('input / output').first);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Progress
    await tester.tap(find.text('Progress').last);
    await tester.pumpAndSettle();
    expect(find.text('Consistency'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Badges'),
      400,
      scrollable: find
          .descendant(of: find.byType(ProgressScreen), matching: find.byType(Scrollable))
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Badges'), findsOneWidget);
    await tester.pumpAndSettle();

    // Guides
    await tester.tap(find.text('Guides'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('How to prepare for DSA'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Use one language for all problems', findRichText: true), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Sliding window', findRichText: true), 300, scrollable: find.byType(Scrollable).last);
    expect(find.text('Sliding window', findRichText: true), findsOneWidget);
  });

  testWidgets('finishing the day shows the celebration', (tester) async {
    phone(tester);
    final state = await makeState(onboarded: true);
    await tester.pumpWidget(RoadmapApp(state: state));
    await tester.pumpAndSettle();

    final day = plan.dayById['d2redo']!;
    for (final t in day.tasks.skip(1)) {
      await state.toggle(t);
    }
    await tester.pumpAndSettle();
    // Tick the last one through the UI.
    await tester.tap(find.byIcon(Icons.radio_button_unchecked_rounded).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Day 2 redo complete!'), findsOneWidget);
    await tester.tap(find.text('Next up: Day 3'));
    await tester.pumpAndSettle();
    expect(find.text('Day 3'), findsWidgets);
  });

  testWidgets('settings renders', (tester) async {
    phone(tester);
    final state = await makeState(onboarded: true);
    await tester.pumpWidget(RoadmapApp(state: state));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Daily study reminder'), findsOneWidget);
  });

  testWidgets('reviews tab lists check-ins and opens them', (tester) async {
    phone(tester);
    final state = await makeState(onboarded: true);
    await tester.pumpWidget(RoadmapApp(state: state));
    await tester.pumpAndSettle();

    // Latest review card on Today (below the task list).
    await tester.scrollUntilVisible(
      find.text('Latest review: Day 2 re-test'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Latest review: Day 2 re-test'), findsOneWidget);

    await tester.tap(find.text('Reviews'));
    await tester.pumpAndSettle();
    expect(find.text('Day 2 re-test'), findsOneWidget);
    expect(find.text('4.8'), findsWidgets);

    // A check-in: wide question table becomes cards.
    await tester.tap(find.text('Day 2'));
    await tester.pumpAndSettle();
    expect(find.text('Day 2 check-in'), findsOneWidget);
    expect(find.textContaining('for...of vs for...in', findRichText: true), findsWidgets);
    await tester.drag(find.byType(ListView).last, const Offset(0, -4000));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Revision notes with code blocks and tables.
    await tester.tap(find.text('Revision notes'));
    await tester.pumpAndSettle();
    expect(find.text('Interview habits', findRichText: true), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -6000));
    await tester.pumpAndSettle();
  });
}
