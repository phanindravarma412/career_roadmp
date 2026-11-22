import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// The repo files the app reads, keyed by their path in the repo.
class RepoSnapshot {
  RepoSnapshot({
    required this.files,
    this.blobShas = const {},
    this.commit,
    this.syncedAt,
  });

  /// path -> markdown, e.g. `plan/daily-plan.md`, `check-ins/day-02.md`.
  final Map<String, String> files;

  /// path -> git blob sha, so unchanged files aren't downloaded again.
  final Map<String, String> blobShas;

  /// Commit the files came from; null for the copy bundled in the app.
  final String? commit;
  final DateTime? syncedAt;

  static const planPath = 'plan/daily-plan.md';
  static const logPath = 'plan/progress-log.md';
  static const revisionPath = 'notes/revision-notes.md';

  String get plan => files[planPath] ?? '';
  String get log => files[logPath] ?? '';

  /// Paths this app syncs from the repo.
  static bool isWanted(String path) =>
      path == planPath ||
      path == logPath ||
      path == revisionPath ||
      (path.startsWith('check-ins/') &&
          path.endsWith('.md') &&
          !path.substring('check-ins/'.length).startsWith('_') &&
          !path.substring('check-ins/'.length).contains('/'));

  Map<String, dynamic> toJson() => {
    'files': files,
    'blobShas': blobShas,
    'commit': commit,
    'syncedAt': syncedAt?.toIso8601String(),
  };

  factory RepoSnapshot.fromJson(Map<String, dynamic> json) => RepoSnapshot(
    files: (json['files'] as Map<String, dynamic>).cast<String, String>(),
    blobShas: (json['blobShas'] as Map<String, dynamic>? ?? {}).cast<String, String>(),
    commit: json['commit'] as String?,
    syncedAt: json['syncedAt'] == null ? null : DateTime.parse(json['syncedAt'] as String),
  );
}

/// Loads the bundled copy and the cached GitHub copy.
class ContentStore {
  static const _cacheKey = 'repoCache';

  /// Files copied into `assets/repo/` by `tool/sync_plan.sh`.
  static Future<RepoSnapshot> loadBundled(AssetBundle bundle) async {
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    final files = <String, String>{};
    for (final asset in manifest.listAssets()) {
      if (!asset.startsWith('assets/repo/') || !asset.endsWith('.md')) continue;
      files[asset.substring('assets/repo/'.length)] = await bundle.loadString(asset);
    }
    return RepoSnapshot(files: files);
  }

  static RepoSnapshot? loadCached(SharedPreferences prefs) {
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    try {
      final snap = RepoSnapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      return snap.plan.isEmpty ? null : snap;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveCache(SharedPreferences prefs, RepoSnapshot snap) =>
      prefs.setString(_cacheKey, jsonEncode(snap.toJson()));
}

class SyncException implements Exception {
  SyncException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Downloads the latest repo files from a public GitHub repo.
///
/// Uses two GitHub API calls (branch head, file tree) and then downloads only
/// files whose blob sha changed, pinned to the commit so the CDN can't serve a
/// stale copy. Unauthenticated limit is 60 API calls an hour, which is plenty.
class GitHubSync {
  GitHubSync({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  static const _headers = {
    'Accept': 'application/vnd.github+json',
    'User-Agent': 'roadmap-tracker-app',
  };

  Future<Map<String, dynamic>> _getJson(String url) async {
    final http.Response res;
    try {
      res = await _client.get(Uri.parse(url), headers: _headers).timeout(const Duration(seconds: 15));
    } catch (_) {
      throw SyncException('No connection to GitHub');
    }
    if (res.statusCode == 404) throw SyncException('Repo or branch not found (is it public?)');
    if (res.statusCode == 403 || res.statusCode == 429) {
      throw SyncException('GitHub rate limit reached. Try again in a while.');
    }
    if (res.statusCode != 200) throw SyncException('GitHub error ${res.statusCode}');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Returns the new snapshot, or [current] with a fresh `syncedAt` when the
  /// branch hasn't moved.
  Future<RepoSnapshot> fetch({
    required String repo,
    required String branch,
    required RepoSnapshot current,
  }) async {
    final api = 'https://api.github.com/repos/$repo';
    final head = await _getJson('$api/branches/$branch');
    final commit = (head['commit'] as Map<String, dynamic>)['sha'] as String;
    final now = DateTime.now();

    if (commit == current.commit) {
      return RepoSnapshot(files: current.files, blobShas: current.blobShas, commit: commit, syncedAt: now);
    }

    final tree = await _getJson('$api/git/trees/$commit?recursive=1');
    final entries = (tree['tree'] as List).cast<Map<String, dynamic>>();
    final files = <String, String>{};
    final shas = <String, String>{};

    for (final e in entries) {
      final path = e['path'] as String;
      if (e['type'] != 'blob' || !RepoSnapshot.isWanted(path)) continue;
      final sha = e['sha'] as String;
      shas[path] = sha;
      if (current.blobShas[path] == sha && current.files.containsKey(path)) {
        files[path] = current.files[path]!;
        continue;
      }
      final url = 'https://raw.githubusercontent.com/$repo/$commit/${Uri.encodeFull(path)}';
      final http.Response res;
      try {
        res = await _client.get(Uri.parse(url)).timeout(const Duration(seconds: 20));
      } catch (_) {
        throw SyncException('Download interrupted');
      }
      if (res.statusCode != 200) throw SyncException('Could not download $path (${res.statusCode})');
      files[path] = utf8.decode(res.bodyBytes);
    }

    if (!files.containsKey(RepoSnapshot.planPath)) {
      throw SyncException('${RepoSnapshot.planPath} not found in $repo@$branch');
    }
    return RepoSnapshot(files: files, blobShas: shas, commit: commit, syncedAt: now);
  }
}
