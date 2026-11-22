/// Parser for `plan/progress-log.md`: check-in scores and the revision list.
library;

class CheckInResult {
  CheckInResult({
    required this.day,
    required this.date,
    required this.average,
    required this.decision,
    required this.topics,
  });

  /// As written in the log, e.g. `2` or `2 (re-test)`.
  final String day;
  final DateTime? date;
  final double average;
  final String decision;
  final String topics;

  bool get passed => average >= 3.5;
}

class RevisionItem {
  RevisionItem({
    required this.topic,
    required this.fromDay,
    required this.score,
    required this.reviseBy,
    required this.cleared,
  });

  final String topic;
  final String fromDay;
  final String score;
  final String reviseBy;
  final bool cleared;
}

class ProgressLog {
  ProgressLog({required this.checkIns, required this.revision});

  final List<CheckInResult> checkIns;
  final List<RevisionItem> revision;

  List<RevisionItem> get openRevision =>
      revision.where((r) => !r.cleared).toList();

  static List<String> _cells(String line) {
    final parts = line.split('|');
    // A table row starts and ends with "|", so drop the empty ends.
    return parts.sublist(1, parts.length - 1).map((c) => c.trim()).toList();
  }

  static String _plain(String s) => s.replaceAll('**', '').replaceAll('`', '');

  static ProgressLog parse(String markdown) {
    final checkIns = <CheckInResult>[];
    final revision = <RevisionItem>[];
    String? table; // 'scores' or 'revision'

    for (final raw in markdown.split('\n')) {
      final line = raw.trim();
      if (!line.startsWith('|')) {
        table = null;
        continue;
      }
      if (line.startsWith('| Day | Date')) {
        table = 'scores';
        continue;
      }
      if (line.startsWith('| Topic | From day')) {
        table = 'revision';
        continue;
      }
      if (line.startsWith('|---') || table == null) continue;

      final c = _cells(line);
      if (table == 'scores' && c.length >= 6) {
        final avg = double.tryParse(c[4]);
        if (avg == null) continue;
        checkIns.add(
          CheckInResult(
            day: c[0],
            date: DateTime.tryParse(c[1]),
            topics: c[2],
            average: avg,
            decision: _plain(c[5]),
          ),
        );
      } else if (table == 'revision' && c.length >= 4) {
        final cleared = c[0].startsWith('~~');
        revision.add(
          RevisionItem(
            topic: _plain(c[0].replaceAll('~~', '')),
            fromDay: c[1],
            score: c[2],
            reviseBy: c[3],
            cleared: cleared,
          ),
        );
      }
    }
    return ProgressLog(checkIns: checkIns, revision: revision);
  }
}
