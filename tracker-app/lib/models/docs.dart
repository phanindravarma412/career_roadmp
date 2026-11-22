/// Check-in documents (`check-ins/day-NN.md`) as shown in the Reviews tab.
library;

class CheckInDoc {
  CheckInDoc({
    required this.path,
    required this.title,
    required this.date,
    required this.average,
    required this.decision,
    required this.body,
    required this.sortKey,
  });

  final String path;

  /// `Day 2 re-test`, `Day 1`.
  final String title;
  final String? date;
  final double? average;
  final String? decision;
  final String body;
  final String sortKey;

  bool? get passed => average == null ? null : average! >= 3.5;

  static final _fileRe = RegExp(r'day-(\d+)(?:-(.+))?\.md$');
  static final _headingRe = RegExp(r'^#\s+(.+?)(?:\s+-\s+(\d{4}-\d{2}-\d{2}))?\s*$', multiLine: true);
  static final _avgRe = RegExp(r'\*\*Average:\*\*\s*([\d.]+)');
  static final _decisionRe = RegExp(r'\*\*Decision:\*\*\s*(.+)$', multiLine: true);

  static CheckInDoc parse(String path, String body) {
    final file = _fileRe.firstMatch(path);
    final dayNum = file == null ? null : int.parse(file[1]!);
    final suffix = file?[2]?.replaceAll('-', ' ');
    final heading = _headingRe.firstMatch(body);

    final title = dayNum == null
        ? (heading?[1] ?? path)
        : 'Day $dayNum${suffix == null ? '' : ' ${suffix.replaceAll('retest', 're-test')}'}';

    return CheckInDoc(
      path: path,
      title: title,
      date: heading?[2],
      average: double.tryParse(_avgRe.firstMatch(body)?[1] ?? ''),
      decision: _decisionRe.firstMatch(body)?[1]?.replaceAll('**', '').trim(),
      body: body,
      // day-02.md before day-02-retest.md; newest first is the reverse.
      sortKey: '${(dayNum ?? 0).toString().padLeft(3, '0')}-${suffix ?? ''}',
    );
  }

  /// Newest first.
  static List<CheckInDoc> fromFiles(Map<String, String> files) {
    final docs = [
      for (final e in files.entries)
        if (e.key.startsWith('check-ins/')) parse(e.key, e.value),
    ];
    docs.sort((a, b) => b.sortKey.compareTo(a.sortKey));
    return docs;
  }
}
