/// XP, levels, badges and streak maths. Pure functions, easy to test.
library;

import 'package:flutter/material.dart';

const xpPerTask = 10;
const xpPerDay = 25;
const xpPerPassedCheckIn = 50;

class Level {
  const Level(this.index, this.title, this.fraction);
  final int index;
  final String title;

  /// Share of the maximum XP needed to reach this level.
  final double fraction;
}

const levels = [
  Level(1, 'Rusty Coder', 0),
  Level(2, 'Syntax Remembered', 0.02),
  Level(3, 'JS Fluent', 0.06),
  Level(4, 'React Builder', 0.13),
  Level(5, 'DSA Climber', 0.22),
  Level(6, 'API Crafter', 0.33),
  Level(7, 'Database Tamer', 0.45),
  Level(8, 'System Thinker', 0.58),
  Level(9, 'Design Pro', 0.72),
  Level(10, 'Interview Ready', 0.86),
  Level(11, 'Senior Full-Stack', 1.0),
];

class LevelInfo {
  LevelInfo({
    required this.level,
    required this.next,
    required this.xp,
    required this.levelStartXp,
    required this.nextLevelXp,
  });
  final Level level;
  final Level? next;
  final int xp;
  final int levelStartXp;
  final int nextLevelXp;

  double get progressInLevel {
    if (next == null) return 1;
    final span = nextLevelXp - levelStartXp;
    return span <= 0 ? 1 : ((xp - levelStartXp) / span).clamp(0, 1);
  }
}

LevelInfo levelFor(int xp, int maxXp) {
  int threshold(Level l) => (l.fraction * maxXp).round();
  var current = levels.first;
  for (final l in levels) {
    if (xp >= threshold(l)) current = l;
  }
  final idx = levels.indexOf(current);
  final next = idx + 1 < levels.length ? levels[idx + 1] : null;
  return LevelInfo(
    level: current,
    next: next,
    xp: xp,
    levelStartXp: threshold(current),
    nextLevelXp: next == null ? threshold(current) : threshold(next),
  );
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Consecutive days with activity, ending today (or yesterday, if today is
/// still open - the streak isn't lost until the day ends).
int currentStreak(Set<DateTime> activeDays, DateTime today) {
  var day = dateOnly(today);
  if (!activeDays.contains(day)) {
    day = day.subtract(const Duration(days: 1));
  }
  var streak = 0;
  while (activeDays.contains(day)) {
    streak++;
    day = day.subtract(const Duration(days: 1));
  }
  return streak;
}

int bestStreak(Set<DateTime> activeDays) {
  if (activeDays.isEmpty) return 0;
  final sorted = activeDays.toList()..sort();
  var best = 1;
  var run = 1;
  for (var i = 1; i < sorted.length; i++) {
    final gap = sorted[i].difference(sorted[i - 1]).inDays;
    run = gap == 1 ? run + 1 : 1;
    if (run > best) best = run;
  }
  return best;
}

class Badge {
  const Badge({
    required this.icon,
    required this.title,
    required this.description,
    required this.unlocked,
  });
  final IconData icon;
  final String title;
  final String description;
  final bool unlocked;
}

/// Short lines shown on the Today screen, one per calendar day.
const motivationLines = [
  'Two focused hours beat a perfect plan you never start.',
  'You already ship features for a living. This is just reps.',
  'Every problem you solve by hand is one you can explain in an interview.',
  'The 22-25 LPA version of you is built one day at a time.',
  'Rusty is not the same as forgotten. It comes back fast.',
  'Small daily wins compound. Keep the streak alive.',
  'Write it, run it, break it, fix it. That is the job.',
  'Interviewers hire people who can explain their thinking. Practise out loud.',
  'Done today is better than perfect next week.',
  'A senior engineer is a junior who kept going.',
  'Close the laptop proud: one more day of the plan done.',
  'Skip the scroll, open the editor. Future you says thanks.',
  'Hard days count double. Show up anyway.',
  'You are not behind. You are on Day {day}, and that is where you start.',
];
