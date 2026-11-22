import 'dart:convert';

import 'package:flutter/material.dart' hide Badge;
import 'package:shared_preferences/shared_preferences.dart';

import '../logic/gamification.dart';
import '../models/docs.dart';
import '../models/plan.dart';
import '../models/progress_log.dart';
import '../services/reminders.dart';
import '../services/repo_sync.dart';

/// Result of toggling a task, so the UI can celebrate.
class ToggleOutcome {
  ToggleOutcome({this.completedDay, this.levelUp});
  final PlanDay? completedDay;
  final Level? levelUp;
}

/// Outcome of a GitHub sync, for a snackbar.
enum SyncOutcome { updated, unchanged, failed, skipped }

class AppState extends ChangeNotifier {
  AppState({
    required this.plan,
    required this.log,
    required SharedPreferences prefs,
    RepoSnapshot? snapshot,
    Reminders? reminders,
    GitHubSync? sync,
    DateTime Function()? clock,
  }) : _prefs = prefs,
       _reminders = reminders,
       _sync = sync,
       _clock = clock ?? DateTime.now,
       snapshot = snapshot ?? RepoSnapshot(files: {}) {
    _load();
    checkIns = CheckInDoc.fromFiles(this.snapshot.files);
  }

  /// Builds the state from a snapshot of repo files.
  factory AppState.fromSnapshot(
    RepoSnapshot snap, {
    required SharedPreferences prefs,
    Reminders? reminders,
    GitHubSync? sync,
    DateTime Function()? clock,
  }) => AppState(
    plan: Plan.parse(snap.plan),
    log: ProgressLog.parse(snap.log),
    snapshot: snap,
    prefs: prefs,
    reminders: reminders,
    sync: sync,
    clock: clock,
  );

  Plan plan;
  ProgressLog log;
  RepoSnapshot snapshot;
  late List<CheckInDoc> checkIns;
  final SharedPreferences _prefs;
  final Reminders? _reminders;
  final GitHubSync? _sync;
  final DateTime Function() _clock;

  static const defaultRepo = 'phanindravarma412/career_roadmp';
  static const defaultBranch = 'main';
  static const _kRepo = 'repo';
  static const _kBranch = 'branch';

  late String repo;
  late String branch;
  bool syncing = false;
  String? syncError;
  DateTime? _lastAttempt;

  String? get revisionNotes => snapshot.files[RepoSnapshot.revisionPath];

  static const _kDone = 'done';
  static const _kStart = 'startDate';
  static const _kOnboarded = 'onboarded';
  static const _kGoal = 'goal';
  static const _kReminderOn = 'reminderOn';
  static const _kReminderMinutes = 'reminderMinutes';

  static final defaultStart = DateTime(2026, 11, 8);
  static const defaultGoal =
      'Senior Full-Stack Engineer at a product company. 15 -> 22-25 LPA.';

  /// taskId -> ISO date it was ticked ('' when back-filled at onboarding).
  final Map<String, String> _done = {};
  late DateTime startDate;
  late bool onboarded;
  late String goal;
  late bool reminderOn;
  late int reminderMinutes;

  DateTime get today => dateOnly(_clock());

  void _load() {
    final raw = _prefs.getString(_kDone);
    if (raw != null) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      map.forEach((k, v) => _done[k] = v as String);
    }
    final start = _prefs.getString(_kStart);
    startDate = start == null ? defaultStart : DateTime.parse(start);
    onboarded = _prefs.getBool(_kOnboarded) ?? false;
    goal = _prefs.getString(_kGoal) ?? defaultGoal;
    reminderOn = _prefs.getBool(_kReminderOn) ?? true;
    reminderMinutes = _prefs.getInt(_kReminderMinutes) ?? 20 * 60;
    repo = _prefs.getString(_kRepo) ?? defaultRepo;
    branch = _prefs.getString(_kBranch) ?? defaultBranch;
  }

  // ---------------------------------------------------------------- sync

  /// Pulls the latest plan, scores and check-ins from GitHub.
  /// With [ifOlderThan], skips when the last attempt was more recent.
  Future<SyncOutcome> syncNow({Duration? ifOlderThan}) async {
    final sync = _sync;
    if (sync == null || syncing) return SyncOutcome.skipped;
    final last = _lastAttempt;
    if (ifOlderThan != null && last != null && _clock().difference(last) < ifOlderThan) {
      return SyncOutcome.skipped;
    }
    _lastAttempt = _clock();
    syncing = true;
    notifyListeners();
    try {
      final next = await sync.fetch(repo: repo, branch: branch, current: snapshot);
      final changed = next.commit != snapshot.commit;
      applySnapshot(next);
      await ContentStore.saveCache(_prefs, next);
      syncError = null;
      return changed ? SyncOutcome.updated : SyncOutcome.unchanged;
    } catch (e) {
      syncError = e is SyncException ? e.message : 'Sync failed';
      return SyncOutcome.failed;
    } finally {
      syncing = false;
      notifyListeners();
    }
  }

  void applySnapshot(RepoSnapshot snap) {
    if (snap.commit != snapshot.commit || snapshot.files.isEmpty) {
      plan = Plan.parse(snap.plan);
      log = ProgressLog.parse(snap.log);
      checkIns = CheckInDoc.fromFiles(snap.files);
    }
    snapshot = snap;
    notifyListeners();
    _refreshReminders();
  }

  Future<void> setRepo(String newRepo, String newBranch) async {
    repo = newRepo.trim().isEmpty ? defaultRepo : newRepo.trim();
    branch = newBranch.trim().isEmpty ? defaultBranch : newBranch.trim();
    await _prefs.setString(_kRepo, repo);
    await _prefs.setString(_kBranch, branch);
    // Force a full download from the new source.
    snapshot = RepoSnapshot(files: snapshot.files);
    notifyListeners();
  }

  Future<void> _save() async {
    await _prefs.setString(_kDone, jsonEncode(_done));
  }

  String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ---------------------------------------------------------------- tasks

  bool isDone(PlanTask t) => _done.containsKey(t.id);

  int doneCount(PlanDay d) => d.tasks.where(isDone).length;

  bool isDayDone(PlanDay d) => d.tasks.isNotEmpty && doneCount(d) == d.tasks.length;

  double dayFraction(PlanDay d) =>
      d.tasks.isEmpty ? 0 : doneCount(d) / d.tasks.length;

  Future<ToggleOutcome> toggle(PlanTask task) async {
    // Match by id: after a sync the plan objects are new.
    final day = plan.days.firstWhere((d) => d.tasks.any((t) => t.id == task.id));
    final wasDayDone = isDayDone(day);
    final levelBefore = levelInfo.level;
    if (isDone(task)) {
      _done.remove(task.id);
    } else {
      _done[task.id] = _iso(today);
    }
    await _save();
    notifyListeners();
    _refreshReminders();
    final levelAfter = levelInfo.level;
    return ToggleOutcome(
      completedDay: !wasDayDone && isDayDone(day) ? day : null,
      levelUp: levelAfter.index > levelBefore.index ? levelAfter : null,
    );
  }

  /// Onboarding: mark every counted day before [day] as done (no date, so it
  /// doesn't fake a streak).
  Future<void> markDoneBefore(PlanDay day) async {
    for (final d in plan.countedDays) {
      if (d == day) break;
      for (final t in d.tasks) {
        _done.putIfAbsent(t.id, () => '');
      }
    }
    await _save();
    notifyListeners();
  }

  // ---------------------------------------------------------------- progress

  /// The day to work on: the first counted day that isn't finished.
  PlanDay get currentDay => plan.countedDays.firstWhere(
    (d) => !isDayDone(d),
    orElse: () => plan.days.last,
  );

  PlanDay? dayAfter(PlanDay day) {
    final i = plan.days.indexOf(day);
    return i >= 0 && i + 1 < plan.days.length ? plan.days[i + 1] : null;
  }

  int get totalTasks => plan.countedTasks.length;
  int get doneTasks => plan.countedTasks.where(isDone).length;
  double get overallFraction => totalTasks == 0 ? 0 : doneTasks / totalTasks;

  int get totalDays => plan.countedDays.length;
  int get doneDays => plan.countedDays.where(isDayDone).length;

  double weekFraction(PlanWeek w) {
    final tasks = [for (final d in w.days) ...d.tasks];
    if (tasks.isEmpty) return 0;
    return tasks.where(isDone).length / tasks.length;
  }

  /// (done, total) per category, in enum order, skipping empty ones.
  Map<Category, (int, int)> get categoryProgress {
    final result = <Category, (int, int)>{};
    for (final c in Category.values) {
      final tasks = plan.countedTasks.where((t) => t.category == c).toList();
      if (tasks.isEmpty) continue;
      result[c] = (tasks.where(isDone).length, tasks.length);
    }
    return result;
  }

  // ---------------------------------------------------------------- activity

  Map<DateTime, int> get activity {
    final map = <DateTime, int>{};
    for (final v in _done.values) {
      final d = DateTime.tryParse(v);
      if (d == null) continue;
      final key = dateOnly(d);
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  int get tasksToday => activity[today] ?? 0;
  int get streak => currentStreak(activity.keys.toSet(), today);
  int get longestStreak => bestStreak(activity.keys.toSet());

  // ---------------------------------------------------------------- schedule

  /// The plan day number you'd be on if you never missed a day.
  int get expectedDayNumber {
    final n = today.difference(dateOnly(startDate)).inDays + 1;
    return n.clamp(0, 99);
  }

  /// Positive = behind schedule by this many days.
  int get daysBehind {
    final current = currentDay;
    if (current.isFinal) return 0;
    return expectedDayNumber - current.number;
  }

  /// Days finished in the last 14 days, per day.
  double get recentPace {
    final cutoff = today.subtract(const Duration(days: 13));
    var finished = 0;
    for (final d in plan.countedDays) {
      if (!isDayDone(d)) continue;
      final last = d.tasks
          .map((t) => DateTime.tryParse(_done[t.id] ?? ''))
          .whereType<DateTime>()
          .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);
      if (last != null && !last.isBefore(cutoff)) finished++;
    }
    return finished / 14;
  }

  /// When Day 99 (applications) arrives at the recent pace, if there is one.
  DateTime? get projectedApplicationsDate {
    final remaining = totalDays - doneDays;
    if (remaining == 0) return today;
    final pace = recentPace;
    if (pace <= 0) return null;
    return today.add(Duration(days: (remaining / pace).ceil()));
  }

  DateTime get plannedApplicationsDate =>
      dateOnly(startDate).add(const Duration(days: 98));

  /// Re-plan: move the start date so today's expected day is the current day.
  Future<void> replanFromToday() async {
    final n = currentDay.isFinal ? 99 : currentDay.number;
    await setStartDate(today.subtract(Duration(days: n - 1)));
  }

  Future<void> setStartDate(DateTime d) async {
    startDate = dateOnly(d);
    await _prefs.setString(_kStart, _iso(startDate));
    notifyListeners();
  }

  // ---------------------------------------------------------------- XP

  int get maxXp =>
      totalTasks * xpPerTask +
      totalDays * xpPerDay +
      log.checkIns.length * xpPerPassedCheckIn;

  int get xp =>
      doneTasks * xpPerTask +
      doneDays * xpPerDay +
      log.checkIns.where((c) => c.passed).length * xpPerPassedCheckIn;

  LevelInfo get levelInfo => levelFor(xp, maxXp);

  /// Latest check-in averages as a 0-1 "interview readiness" signal.
  double? get readiness {
    if (log.checkIns.isEmpty) return null;
    final last = log.checkIns.reversed.take(3).toList();
    return last.map((c) => c.average).reduce((a, b) => a + b) /
        last.length /
        5;
  }

  List<Badge> get badges {
    final cat = categoryProgress;
    final dsaDone = cat[Category.dsa]?.$1 ?? 0;
    final best = longestStreak;
    bool weekDone(String id) {
      final w = plan.weeks.where((w) => w.id == id);
      return w.isNotEmpty && weekFraction(w.first) == 1;
    }

    bool dayDone(String id) {
      final d = plan.dayById[id];
      return d != null && isDayDone(d);
    }

    final redoDone = plan.countedDays.any((d) => d.isRedo && isDayDone(d));
    final weekendDone = plan.countedDays.any(
      (d) => d.weekdayLabel == 'Sunday' && isDayDone(d),
    );

    return [
      Badge(
        icon: Icons.flag_rounded,
        title: 'First step',
        description: 'Tick your first task',
        unlocked: doneTasks > 0,
      ),
      Badge(
        icon: Icons.looks_one_rounded,
        title: 'Day 1 done',
        description: 'Finish every Day 1 task',
        unlocked: dayDone('d1'),
      ),
      Badge(
        icon: Icons.replay_rounded,
        title: 'Bounced back',
        description: 'Finish a redo day',
        unlocked: redoDone,
      ),
      Badge(
        icon: Icons.local_fire_department_rounded,
        title: 'On fire',
        description: '3-day streak',
        unlocked: best >= 3,
      ),
      Badge(
        icon: Icons.whatshot_rounded,
        title: 'Week warrior',
        description: '7-day streak',
        unlocked: best >= 7,
      ),
      Badge(
        icon: Icons.bolt_rounded,
        title: 'Unstoppable',
        description: '21-day streak',
        unlocked: best >= 21,
      ),
      Badge(
        icon: Icons.weekend_rounded,
        title: 'Weekend warrior',
        description: 'Finish a 5-hour Sunday',
        unlocked: weekendDone,
      ),
      Badge(
        icon: Icons.javascript_rounded,
        title: 'JS foundations',
        description: 'Finish Week F1',
        unlocked: weekDone('F1'),
      ),
      Badge(
        icon: Icons.web_rounded,
        title: 'React rookie',
        description: 'Finish Week F2',
        unlocked: weekDone('F2'),
      ),
      Badge(
        icon: Icons.extension_rounded,
        title: 'DSA x10',
        description: '10 DSA tasks done',
        unlocked: dsaDone >= 10,
      ),
      Badge(
        icon: Icons.psychology_rounded,
        title: 'DSA x50',
        description: '50 DSA tasks done',
        unlocked: dsaDone >= 50,
      ),
      Badge(
        icon: Icons.star_rounded,
        title: 'Check-in ace',
        description: 'Score 4.5+ in a check-in',
        unlocked: log.checkIns.any((c) => c.average >= 4.5),
      ),
      Badge(
        icon: Icons.terrain_rounded,
        title: 'Halfway there',
        description: '50% of all tasks',
        unlocked: overallFraction >= 0.5,
      ),
      Badge(
        icon: Icons.workspace_premium_rounded,
        title: 'Senior ready',
        description: 'Finish all 98 days',
        unlocked: doneDays == totalDays,
      ),
    ];
  }

  // ---------------------------------------------------------------- settings

  Future<void> completeOnboarding() async {
    onboarded = true;
    await _prefs.setBool(_kOnboarded, true);
    notifyListeners();
    _refreshReminders();
  }

  Future<void> setGoal(String value) async {
    goal = value.trim().isEmpty ? defaultGoal : value.trim();
    await _prefs.setString(_kGoal, goal);
    notifyListeners();
  }

  Future<bool> setReminder({required bool on, int? minutes}) async {
    var granted = true;
    // Ask on first enable, and once during onboarding.
    if (on && (!reminderOn || !onboarded)) {
      granted = await _reminders?.requestPermission() ?? true;
    }
    reminderOn = on && granted;
    if (minutes != null) reminderMinutes = minutes;
    await _prefs.setBool(_kReminderOn, reminderOn);
    await _prefs.setInt(_kReminderMinutes, reminderMinutes);
    notifyListeners();
    _refreshReminders();
    return granted;
  }

  void refreshReminders() => _refreshReminders();

  void _refreshReminders() {
    final r = _reminders;
    if (r == null || !onboarded) return;
    final day = currentDay;
    final left = day.tasks.length - doneCount(day);
    r.schedule(
      enabled: reminderOn,
      minutesOfDay: reminderMinutes,
      title: day.isFinal
          ? 'Keep going: applications and interviews'
          : '${day.title}: $left task${left == 1 ? '' : 's'} waiting',
      body: streak > 0
          ? '$streak-day streak. ${day.hours ?? 2} focused hours keeps it alive.'
          : 'Start a streak today. ${day.hours ?? 2} focused hours.',
      streak: streak,
      doneToday: tasksToday > 0,
    );
  }

  // ---------------------------------------------------------------- backup

  String exportBackup() => jsonEncode({
    'version': 1,
    'startDate': _iso(startDate),
    'goal': goal,
    'done': _done,
  });

  Future<void> importBackup(String json) async {
    final map = jsonDecode(json) as Map<String, dynamic>;
    final done = (map['done'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, v as String),
    );
    _done
      ..clear()
      ..addAll(done);
    await _save();
    if (map['startDate'] is String) {
      await setStartDate(DateTime.parse(map['startDate'] as String));
    }
    if (map['goal'] is String) await setGoal(map['goal'] as String);
    notifyListeners();
    _refreshReminders();
  }

  Future<void> resetProgress() async {
    _done.clear();
    await _save();
    notifyListeners();
    _refreshReminders();
  }
}

/// Gives widgets access to [AppState] and rebuilds them on change.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
