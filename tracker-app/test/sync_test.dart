import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:roadmap_tracker/models/docs.dart';
import 'package:roadmap_tracker/services/repo_sync.dart';
import 'package:roadmap_tracker/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A fake GitHub serving [files] at [commit], counting raw downloads.
class FakeGitHub {
  FakeGitHub(this.commit, this.files);
  String commit;
  Map<String, String> files;
  final downloads = <String>[];
  int apiCalls = 0;
  int status = 200;

  String sha(String content) => content.hashCode.toRadixString(16);

  late final client = MockClient((req) async {
    final url = req.url.toString();
    if (status != 200) return http.Response('', status);
    if (url.endsWith('/branches/main')) {
      apiCalls++;
      return http.Response(jsonEncode({'commit': {'sha': commit}}), 200);
    }
    if (url.contains('/git/trees/')) {
      apiCalls++;
      return http.Response(
        jsonEncode({
          'tree': [
            for (final e in files.entries) {'path': e.key, 'type': 'blob', 'sha': sha(e.value)},
            {'path': 'check-ins', 'type': 'tree', 'sha': 'x'},
          ],
        }),
        200,
      );
    }
    if (url.startsWith('https://raw.githubusercontent.com/me/repo/$commit/')) {
      final path = Uri.decodeFull(url.substring('https://raw.githubusercontent.com/me/repo/$commit/'.length));
      downloads.add(path);
      return http.Response.bytes(utf8.encode(files[path]!), 200);
    }
    return http.Response('not found', 404);
  });
}

void main() {
  final planText = File('assets/repo/plan/daily-plan.md').readAsStringSync();
  final logText = File('assets/repo/plan/progress-log.md').readAsStringSync();

  Map<String, String> repoFiles({String extraTask = ''}) => {
    'plan/daily-plan.md': planText.replaceFirst('## Day 3\n', '## Day 3\n$extraTask'),
    'plan/progress-log.md': logText,
    'check-ins/day-01.md': '# Day 01 Check-in - 2026-11-08\n**Average:** 3.9 / 5\n**Decision:** Move on.',
    'check-ins/day-02-retest.md': '# Day 02 Re-test - 2026-11-19\n**Average:** 4.8 / 5\n**Decision:** Move on to Day 3.',
    'check-ins/_template.md': 'template',
    'notes/revision-notes.md': '# Revision Notes',
    'notes/stories.md': 'not synced',
    'README.md': 'not synced',
  };

  test('downloads only wanted files, then only changed ones', () async {
    final gh = FakeGitHub('c1', repoFiles());
    final sync = GitHubSync(client: gh.client);

    final first = await sync.fetch(repo: 'me/repo', branch: 'main', current: RepoSnapshot(files: {}));
    expect(first.commit, 'c1');
    expect(first.files.keys.toSet(), {
      'plan/daily-plan.md',
      'plan/progress-log.md',
      'check-ins/day-01.md',
      'check-ins/day-02-retest.md',
      'notes/revision-notes.md',
    });

    // Same commit: one API call, nothing downloaded.
    gh.downloads.clear();
    gh.apiCalls = 0;
    final same = await sync.fetch(repo: 'me/repo', branch: 'main', current: first);
    expect(gh.apiCalls, 1);
    expect(gh.downloads, isEmpty);
    expect(same.commit, 'c1');

    // New commit that changes the plan and adds a check-in.
    gh.commit = 'c2';
    gh.files = repoFiles(extraTask: '0. Redo task\n')..['check-ins/day-03.md'] = '# Day 03 Check-in';
    final next = await sync.fetch(repo: 'me/repo', branch: 'main', current: first);
    expect(gh.downloads.toSet(), {'plan/daily-plan.md', 'check-ins/day-03.md'});
    expect(next.files['check-ins/day-03.md'], '# Day 03 Check-in');
  });

  test('app state picks up a pushed change without a reinstall', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final gh = FakeGitHub('c1', repoFiles());
    final bundled = RepoSnapshot(files: {'plan/daily-plan.md': planText, 'plan/progress-log.md': logText});
    final state = AppState.fromSnapshot(
      bundled,
      prefs: prefs,
      sync: GitHubSync(client: gh.client),
    )..repo = 'me/repo';

    expect(state.checkIns, isEmpty);
    expect(await state.syncNow(), SyncOutcome.updated);
    expect(state.checkIns.map((c) => c.title), ['Day 2 re-test', 'Day 1']);
    expect(state.revisionNotes, '# Revision Notes');
    expect(await state.syncNow(), SyncOutcome.unchanged);

    // Cached for offline use.
    expect(ContentStore.loadCached(prefs)!.commit, 'c1');

    // Push a new day; next sync shows it.
    gh.commit = 'c2';
    gh.files = repoFiles()
      ..['plan/daily-plan.md'] = planText.replaceFirst('## Day 3\n', '## Day 3 redo (from the Day 3 check-in)\n1. Fix it `js-ts/`\n\n## Day 3\n');
    expect(await state.syncNow(), SyncOutcome.updated);
    expect(state.plan.dayById['d3redo'], isNotNull);
  });

  test('failures keep the current content and report a message', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final gh = FakeGitHub('c1', repoFiles())..status = 403;
    final state = AppState.fromSnapshot(
      RepoSnapshot(files: {'plan/daily-plan.md': planText, 'plan/progress-log.md': logText}),
      prefs: prefs,
      sync: GitHubSync(client: gh.client),
    );
    final days = state.plan.days.length;
    expect(await state.syncNow(), SyncOutcome.failed);
    expect(state.syncError, contains('rate limit'));
    expect(state.plan.days.length, days);
  });

  test('check-in docs: title, date, average and decision', () {
    final docs = CheckInDoc.fromFiles({
      'check-ins/day-02.md': File('assets/repo/check-ins/day-02.md').readAsStringSync(),
      'check-ins/day-02-retest.md': File('assets/repo/check-ins/day-02-retest.md').readAsStringSync(),
      'check-ins/day-01.md': File('assets/repo/check-ins/day-01.md').readAsStringSync(),
    });
    expect(docs.map((d) => d.title), ['Day 2 re-test', 'Day 2', 'Day 1']);
    expect(docs.first.average, 4.8);
    expect(docs.first.date, '2026-11-19');
    expect(docs.first.decision, 'Move on to Day 3.');
    expect(docs[1].passed, isFalse);
  });
}
