/// Data model and parser for `plan/daily-plan.md`.
///
/// The app ships a copy of the markdown file (see `tool/sync_plan.sh`) and
/// parses it at start-up, so the plan in the repo stays the single source.
library;

enum Category {
  dsa('DSA'),
  sql('SQL'),
  lld('LLD'),
  jsTs('JS / TS'),
  react('React'),
  backend('Backend'),
  flutter('Flutter'),
  systemDesign('System design'),
  career('Career'),
  checkIn('Check-ins'),
  notes('Notes'),
  setup('Setup');

  const Category(this.label);
  final String label;
}

class PlanTask {
  PlanTask({
    required this.id,
    required this.number,
    required this.text,
    required this.chips,
    required this.tag,
    required this.details,
  });

  /// Stable key used to store completion, e.g. `d3-4`.
  final String id;
  final int number;

  /// Task text without the tag prefix and folder chips.
  final String text;

  /// Folder chips such as `js-ts/` or `setup`.
  final List<String> chips;

  /// `DSA`, `SQL` or `LLD` when the task starts with that tag.
  final String? tag;

  /// Indented sub-lines: Input, Output, hints.
  final List<String> details;

  bool get isOptional => text.toLowerCase().startsWith('optional');

  Category get category {
    switch (tag) {
      case 'DSA':
        return Category.dsa;
      case 'SQL':
        return Category.sql;
      case 'LLD':
        return Category.lld;
    }
    final chip = chips.isEmpty ? '' : chips.first;
    switch (chip) {
      case 'dsa/':
        return Category.dsa;
      case 'sql/':
        return Category.sql;
      case 'lld/':
        return Category.lld;
      case 'js-ts/':
        return Category.jsTs;
      case 'react/':
        return Category.react;
      case 'backend/':
        return Category.backend;
      case 'flutter/':
      case 'dart/':
        return Category.flutter;
      case 'system-design/':
        return Category.systemDesign;
      case 'resume/':
        return Category.career;
      case 'check-ins/':
        return Category.checkIn;
      case 'setup':
        return Category.setup;
      default:
        return Category.notes;
    }
  }
}

class PlanDay {
  PlanDay({
    required this.id,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.weekId,
    required this.isRedo,
    required this.isFinal,
    required this.hours,
    required this.weekdayLabel,
  });

  /// `d3`, `d2redo`, `d99`.
  final String id;
  final int number;

  /// `Day 3`, `Day 2 redo`, `Day 99+`.
  final String title;

  /// Text in brackets after the heading, if any.
  final String? subtitle;
  final String weekId;
  final bool isRedo;

  /// `Day 99 onward`: ongoing, not counted in progress.
  final bool isFinal;
  final int? hours;

  /// `Saturday` / `Sunday` when the heading says so.
  final String? weekdayLabel;
  final List<PlanTask> tasks = [];
}

class PlanWeek {
  PlanWeek({required this.id, required this.title});

  /// `0` (setup), `F1`, `F2`, `1`..`12`, `jobs`.
  final String id;
  final String title;
  final List<PlanDay> days = [];

  String get label {
    if (id == '0') return 'Setup';
    if (id == 'jobs') return 'Job search';
    return 'Week $id';
  }
}

class Guide {
  Guide({required this.title, required this.lines});
  final String title;
  final List<String> lines;
}

class Plan {
  Plan({required this.weeks, required this.guides, required this.intro});

  final List<PlanWeek> weeks;
  final List<Guide> guides;

  /// Bullet lines at the top of the file (legend).
  final List<String> intro;

  late final List<PlanDay> days = [for (final w in weeks) ...w.days];

  /// Days that count towards progress (everything except "Day 99 onward").
  late final List<PlanDay> countedDays =
      days.where((d) => !d.isFinal).toList();

  late final List<PlanTask> countedTasks = [
    for (final d in countedDays) ...d.tasks,
  ];

  late final Map<String, PlanDay> dayById = {for (final d in days) d.id: d};

  PlanWeek weekOf(PlanDay day) => weeks.firstWhere((w) => w.id == day.weekId);

  static final _weekRe = RegExp(r'^# Week (\S+) - (.+)$');
  static final _dayRe = RegExp(r'^## Day (\d+)(.*)$');
  static final _taskRe = RegExp(r'^(\d+)\.\s+(.*)$');
  static final _subRe = RegExp(r'^\s+(?:-|\d+\.)\s+(.*)$');
  static final _tagRe = RegExp(r'^\((DSA|SQL|LLD)\)\s*');
  static final _trailingCodeRe = RegExp(r'\s*`([^`]+)`\s*$');
  static final _hoursRe = RegExp(r'(\d+)\s*h\b');

  static bool _isChip(String token) =>
      token == 'setup' || RegExp(r'^[a-z][a-z-]*/$').hasMatch(token);

  static Plan parse(String markdown) {
    final weeks = <PlanWeek>[];
    final guides = <Guide>[];
    final intro = <String>[];

    PlanWeek? week;
    PlanDay? day;
    PlanTask? task;
    Guide? guide;
    var beforeFirstSection = true;

    PlanWeek ensureWeek(String id, String title) {
      final existing = weeks.where((w) => w.id == id);
      if (existing.isNotEmpty) return existing.first;
      final w = PlanWeek(id: id, title: title);
      weeks.add(w);
      return w;
    }

    for (final raw in markdown.split('\n')) {
      final line = raw.trimRight();

      final weekMatch = _weekRe.firstMatch(line);
      if (weekMatch != null) {
        week = ensureWeek(weekMatch[1]!, weekMatch[2]!.trim());
        day = null;
        task = null;
        guide = null;
        beforeFirstSection = false;
        continue;
      }

      if (line.startsWith('# ')) {
        // "# How to prepare" and similar top-level sections.
        beforeFirstSection = false;
        day = null;
        task = null;
        guide = null;
        continue;
      }

      final dayMatch = _dayRe.firstMatch(line);
      if (dayMatch != null) {
        guide = null;
        task = null;
        final number = int.parse(dayMatch[1]!);
        var rest = dayMatch[2]!.trim();
        final isRedo = rest.startsWith('redo');
        final isFinal = rest.startsWith('onward');
        if (isRedo) rest = rest.substring(4).trim();
        if (isFinal) rest = rest.substring(6).trim();

        String? subtitle;
        if (rest.startsWith('(') && rest.endsWith(')')) {
          subtitle = rest.substring(1, rest.length - 1);
        }
        final hoursMatch =
            subtitle == null ? null : _hoursRe.firstMatch(subtitle);
        String? weekdayLabel;
        for (final name in ['Saturday', 'Sunday']) {
          if (subtitle?.contains(name) ?? false) weekdayLabel = name;
        }

        final PlanWeek target;
        if (isFinal) {
          target = ensureWeek('jobs', 'Applications and interviews');
        } else if (number == 0 || week == null) {
          target = ensureWeek('0', 'Machine and account setup');
        } else {
          target = week;
        }

        final id = isRedo ? 'd${number}redo' : 'd$number';
        day = PlanDay(
          id: id,
          number: number,
          title: isRedo
              ? 'Day $number redo'
              : isFinal
              ? 'Day $number+'
              : 'Day $number',
          subtitle: subtitle,
          weekId: target.id,
          isRedo: isRedo,
          isFinal: isFinal,
          hours: number == 0
              ? null
              : hoursMatch != null
              ? int.parse(hoursMatch[1]!)
              : isFinal
              ? null
              : 2,
          weekdayLabel: weekdayLabel,
        );
        target.days.add(day);
        continue;
      }

      if (line.startsWith('## ')) {
        // A guide section ("How to prepare for DSA", "Daily check-in with me").
        day = null;
        task = null;
        guide = Guide(title: line.substring(3).trim(), lines: []);
        guides.add(guide);
        continue;
      }

      if (guide != null) {
        if (line.trim() == '---') continue;
        guide.lines.add(raw);
        continue;
      }

      if (day != null) {
        final taskMatch = _taskRe.firstMatch(line);
        if (taskMatch != null) {
          task = _parseTask(day, int.parse(taskMatch[1]!), taskMatch[2]!);
          day.tasks.add(task);
          continue;
        }
        final subMatch = _subRe.firstMatch(line);
        if (subMatch != null && task != null) {
          task.details.add(subMatch[1]!);
        }
        continue;
      }

      if (beforeFirstSection && line.startsWith('- ')) {
        intro.add(line.substring(2));
      }
    }

    // Keep the order: setup first, job search last.
    weeks.sort((a, b) {
      int rank(PlanWeek w) => w.id == '0' ? 0 : (w.id == 'jobs' ? 2 : 1);
      return rank(a).compareTo(rank(b));
    });

    return Plan(weeks: weeks, guides: guides, intro: intro);
  }

  static PlanTask _parseTask(PlanDay day, int number, String body) {
    var text = body.trim();
    final chips = <String>[];
    while (true) {
      final m = _trailingCodeRe.firstMatch(text);
      if (m == null || !_isChip(m[1]!)) break;
      chips.insert(0, m[1]!);
      text = text.substring(0, m.start).trimRight();
    }
    String? tag;
    final tagMatch = _tagRe.firstMatch(text);
    if (tagMatch != null) {
      tag = tagMatch[1];
      text = text.substring(tagMatch.end);
    }
    return PlanTask(
      id: '${day.id}-$number',
      number: number,
      text: text,
      chips: chips,
      tag: tag,
      details: [],
    );
  }
}
