import 'package:flutter/material.dart';

import '../models/plan.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/markdown_view.dart';

/// The "How to prepare" sections of the plan, readable on the phone.
class GuidesScreen extends StatelessWidget {
  const GuidesScreen({super.key});

  IconData _iconFor(String title) {
    final t = title.toLowerCase();
    if (t.contains('dsa')) return Icons.extension_rounded;
    if (t.contains('react')) return Icons.web_rounded;
    if (t.contains('backend')) return Icons.dns_rounded;
    if (t.contains('sql')) return Icons.storage_rounded;
    if (t.contains('lld')) return Icons.account_tree_rounded;
    if (t.contains('flutter')) return Icons.phone_android_rounded;
    if (t.contains('system design')) return Icons.hub_rounded;
    if (t.contains('hr')) return Icons.handshake_rounded;
    if (t.contains('interview day')) return Icons.event_available_rounded;
    if (t.contains('mock')) return Icons.record_voice_over_rounded;
    if (t.contains('check-in')) return Icons.fact_check_rounded;
    return Icons.menu_book_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('How to prepare')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          for (final g in state.plan.guides)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: ListTile(
                leading: Icon(_iconFor(g.title)),
                title: Text(g.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GuideDetailScreen(guide: g)),
                ),
              ),
            ),
          if (state.plan.intro.isNotEmpty)
            SectionCard(
              title: 'How the plan works',
              child: MarkdownView(markdown: state.plan.intro.map((l) => '- $l').join('\n')),
            ),
        ],
      ),
    );
  }
}

class GuideDetailScreen extends StatelessWidget {
  const GuideDetailScreen({super.key, required this.guide});
  final Guide guide;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(guide.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [MarkdownView(markdown: guide.lines.join('\n'))],
      ),
    );
  }
}
