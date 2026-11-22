import 'package:flutter/material.dart';

import '../state/app_state.dart';

/// Syncs with GitHub and shows the result in a snackbar.
Future<void> syncWithFeedback(BuildContext context) async {
  final state = AppScope.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final outcome = await state.syncNow();
  final text = switch (outcome) {
    SyncOutcome.updated => 'Updated from GitHub',
    SyncOutcome.unchanged => 'Already up to date',
    SyncOutcome.failed => state.syncError ?? 'Sync failed',
    SyncOutcome.skipped => null,
  };
  if (text != null) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 2)));
  }
}

String timeAgo(DateTime t, DateTime now) {
  final d = now.difference(t);
  if (d.inSeconds < 60) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours} h ago';
  return '${d.inDays} d ago';
}

/// App-bar button: spinner while syncing, cloud icon otherwise.
class SyncButton extends StatelessWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    if (state.syncing) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4)),
      );
    }
    return IconButton(
      tooltip: 'Sync with GitHub',
      icon: Icon(state.syncError != null ? Icons.cloud_off_rounded : Icons.cloud_sync_outlined),
      onPressed: () => syncWithFeedback(context),
    );
  }
}

/// "Synced 2 min ago · 4518ab4" or the last error.
class SyncStatusLine extends StatelessWidget {
  const SyncStatusLine({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final snap = state.snapshot;
    final String text;
    if (state.syncError != null) {
      text = '${state.syncError}. Showing ${snap.commit == null ? 'the copy built into the app' : 'the last synced copy'}.';
    } else if (snap.syncedAt != null && snap.commit != null) {
      text = 'Synced from GitHub ${timeAgo(snap.syncedAt!, DateTime.now())} · commit ${snap.commit!.substring(0, 7)}';
    } else {
      text = state.syncing ? 'Syncing with GitHub…' : 'Showing the copy built into the app. Pull down to sync.';
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
      child: Row(
        children: [
          Icon(
            state.syncError != null ? Icons.cloud_off_rounded : Icons.cloud_done_outlined,
            size: 14,
            color: state.syncError != null ? scheme.error : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}
