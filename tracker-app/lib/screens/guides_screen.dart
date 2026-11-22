import 'package:flutter/material.dart';

import '../models/plan.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (final l in state.plan.intro) _Bullet(text: l, indent: 0)],
              ),
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
        children: _blocks(context, guide.lines),
      ),
    );
  }

  List<Widget> _blocks(BuildContext context, List<String> lines) {
    final scheme = Theme.of(context).colorScheme;
    final out = <Widget>[];
    final table = <List<String>>[];

    void flushTable() {
      if (table.isEmpty) return;
      out.add(
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < table.length; i++)
                Container(
                  color: i == 0 ? scheme.surfaceContainerHighest : null,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final cell in table[i])
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: RichLine(
                              cell,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: i == 0 ? FontWeight.w700 : null,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
      table.clear();
    }

    for (final raw in lines) {
      final line = raw.trimRight();
      if (line.trim().startsWith('|')) {
        if (RegExp(r'^\|[\s\-:|]+\|$').hasMatch(line.trim())) continue;
        final parts = line.trim().split('|');
        table.add(parts.sublist(1, parts.length - 1).map((c) => c.trim()).toList());
        continue;
      }
      flushTable();
      if (line.trim().isEmpty) {
        out.add(const SizedBox(height: 6));
        continue;
      }
      if (line.startsWith('### ')) {
        out.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              line.substring(4),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        );
        continue;
      }
      final indent = line.length - line.trimLeft().length;
      final trimmed = line.trimLeft();
      final numbered = RegExp(r'^(\d+)\.\s+(.*)$').firstMatch(trimmed);
      if (numbered != null) {
        out.add(_Bullet(text: numbered[2]!, marker: '${numbered[1]}.', indent: indent));
      } else if (trimmed.startsWith('- ')) {
        out.add(_Bullet(text: trimmed.substring(2), indent: indent));
      } else {
        out.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: RichLine(trimmed, style: const TextStyle(fontSize: 14.5, height: 1.4)),
          ),
        );
      }
    }
    flushTable();
    return out;
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text, required this.indent, this.marker});
  final String text;
  final int indent;
  final String? marker;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(left: indent * 6.0, top: 3, bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              marker ?? '•',
              style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: RichLine(
              text,
              style: TextStyle(fontSize: 14.5, height: 1.4, color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
