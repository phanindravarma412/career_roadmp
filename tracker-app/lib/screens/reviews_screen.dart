import 'package:flutter/material.dart';

import '../models/docs.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/markdown_view.dart';
import '../widgets/sync_status.dart';

/// Check-in results from Claude and the revision notes, synced from GitHub.
class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final docs = state.checkIns;
    final notes = state.revisionNotes;
    final open = state.log.openRevision;

    return Scaffold(
      appBar: AppBar(title: const Text('Reviews'), actions: const [SyncButton()]),
      body: RefreshIndicator(
        onRefresh: () => syncWithFeedback(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const SyncStatusLine(),
            if (notes != null)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: scheme.tertiaryContainer,
                    child: Icon(Icons.menu_book_rounded, color: scheme.onTertiaryContainer),
                  ),
                  title: const Text('Revision notes', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    open.isEmpty ? 'Correct answers from every check-in' : '${open.length} topics still to revise',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DocScreen(title: 'Revision notes', markdown: notes)),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(
                'CHECK-INS (${docs.length})',
                style: TextStyle(fontSize: 12, letterSpacing: 0.8, fontWeight: FontWeight.w700, color: scheme.primary),
              ),
            ),
            if (docs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No check-ins yet. After a day, tell Claude "Interview me".'),
              ),
            for (final d in docs) _CheckInCard(doc: d),
          ],
        ),
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({required this.doc});
  final CheckInDoc doc;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final passed = doc.passed;
    final color = passed == null
        ? scheme.outline
        : passed
        ? const Color(0xFF16A34A)
        : scheme.error;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DocScreen(title: '${doc.title} check-in', markdown: doc.body)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(14)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      doc.average?.toStringAsFixed(1) ?? '-',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
                    ),
                    Text('/ 5', style: TextStyle(fontSize: 10, color: color)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
                    if (doc.date != null)
                      Text(
                        shortDate(DateTime.parse(doc.date!)),
                        style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                      ),
                    if (doc.decision != null) ...[
                      const SizedBox(height: 4),
                      RichLine(doc.decision!, maxLines: 2, style: TextStyle(fontSize: 13, color: scheme.onSurface)),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class DocScreen extends StatelessWidget {
  const DocScreen({super.key, required this.title, required this.markdown});
  final String title;
  final String markdown;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [MarkdownView(markdown: markdown, skipFirstHeading: true)],
      ),
    );
  }
}
