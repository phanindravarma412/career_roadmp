import 'package:flutter/material.dart';

import 'common.dart';

/// Phone-friendly renderer for the repo's markdown: headings, lists, code
/// blocks, quotes and tables. Wide tables (4+ columns, like the check-in
/// question tables) become one card per row.
class MarkdownView extends StatelessWidget {
  const MarkdownView({super.key, required this.markdown, this.skipFirstHeading = false});

  final String markdown;

  /// Skip the `# Title` line when the screen's app bar already shows it.
  final bool skipFirstHeading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _blocks(context),
    );
  }

  List<Widget> _blocks(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final out = <Widget>[];
    final lines = markdown.split('\n');
    var skippedHeading = !skipFirstHeading;

    var i = 0;
    while (i < lines.length) {
      final line = lines[i].trimRight();
      final trimmed = line.trimLeft();

      // Code fence.
      if (trimmed.startsWith('```')) {
        final code = <String>[];
        i++;
        while (i < lines.length && !lines[i].trimLeft().startsWith('```')) {
          code.add(lines[i]);
          i++;
        }
        i++; // closing fence
        out.add(_CodeBlock(code.join('\n')));
        continue;
      }

      // Table.
      if (trimmed.startsWith('|')) {
        final rows = <List<String>>[];
        while (i < lines.length && lines[i].trimLeft().startsWith('|')) {
          final t = lines[i].trim();
          if (!RegExp(r'^\|[\s\-:|]+\|$').hasMatch(t)) {
            final parts = t.split('|');
            rows.add(parts.sublist(1, parts.length - 1).map((c) => c.trim()).toList());
          }
          i++;
        }
        if (rows.isNotEmpty) out.add(_Table(rows));
        continue;
      }

      i++;

      if (trimmed.isEmpty) {
        out.add(const SizedBox(height: 6));
        continue;
      }
      if (trimmed == '---') {
        out.add(const Divider(height: 24));
        continue;
      }

      final heading = RegExp(r'^(#{1,4})\s+(.*)$').firstMatch(trimmed);
      if (heading != null) {
        final level = heading[1]!.length;
        if (!skippedHeading && level == 1) {
          skippedHeading = true;
          continue;
        }
        final style = switch (level) {
          1 => theme.textTheme.headlineSmall,
          2 => theme.textTheme.titleLarge,
          _ => theme.textTheme.titleMedium,
        };
        out.add(
          Padding(
            padding: EdgeInsets.only(top: level <= 2 ? 16 : 12, bottom: 4),
            child: RichLine(heading[2]!, style: style?.copyWith(fontWeight: FontWeight.w800, color: scheme.onSurface)),
          ),
        );
        continue;
      }

      if (trimmed.startsWith('> ')) {
        out.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: scheme.primary, width: 3)),
              color: scheme.primaryContainer.withValues(alpha: 0.3),
            ),
            child: RichLine(trimmed.substring(2), style: TextStyle(fontSize: 14.5, height: 1.4, color: scheme.onSurface)),
          ),
        );
        continue;
      }

      final indent = line.length - trimmed.length;
      final numbered = RegExp(r'^(\d+)\.\s+(.*)$').firstMatch(trimmed);
      if (numbered != null) {
        out.add(_Bullet(text: numbered[2]!, marker: '${numbered[1]}.', indent: indent));
        continue;
      }
      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        out.add(_Bullet(text: trimmed.substring(2), indent: indent));
        continue;
      }

      out.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: RichLine(trimmed, style: TextStyle(fontSize: 14.5, height: 1.45, color: scheme.onSurface)),
        ),
      );
    }
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
            child: Text(marker ?? '•', style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700, height: 1.45)),
          ),
          Expanded(
            child: RichLine(text, style: TextStyle(fontSize: 14.5, height: 1.45, color: scheme.onSurface)),
          ),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock(this.code);
  final String code;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        child: Text(
          code,
          style: TextStyle(fontFamily: 'monospace', fontSize: 12.5, height: 1.45, color: scheme.onSurface),
        ),
      ),
    );
  }
}

class _Table extends StatelessWidget {
  const _Table(this.rows);
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final header = rows.first;
    return header.length >= 4 ? _cards(context) : _grid(context);
  }

  Widget _grid(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var r = 0; r < rows.length; r++)
            Container(
              color: r == 0 ? scheme.surfaceContainerHighest : null,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final cell in rows[r])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: RichLine(
                          cell,
                          style: TextStyle(fontSize: 13, height: 1.35, fontWeight: r == 0 ? FontWeight.w700 : null, color: scheme.onSurface),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _cards(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final header = rows.first;
    final scoreCol = header.indexWhere((h) => h.toLowerCase().startsWith('score'));

    return Column(
      children: [
        for (final row in rows.skip(1))
          Builder(
            builder: (context) {
              final cells = [for (var c = 0; c < header.length; c++) c < row.length ? row[c] : ''];
              // "1" + "switch fall-through" -> "1 · switch fall-through".
              final combine = cells[0].length <= 3 && cells.length > 1;
              final title = combine ? '${cells[0]} · ${cells[1]}' : cells[0];
              final used = {0, if (combine) 1, if (scoreCol >= 0) scoreCol};
              final score = scoreCol >= 0 ? double.tryParse(cells[scoreCol].split(RegExp(r'[ ,(]')).first) : null;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RichLine(
                            title.isEmpty ? '-' : title,
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: scheme.onSurface),
                          ),
                        ),
                        if (scoreCol >= 0 && cells[scoreCol].isNotEmpty) ScoreBadge(text: cells[scoreCol], score: score),
                      ],
                    ),
                    for (var c = 0; c < cells.length; c++)
                      if (!used.contains(c) && cells[c].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                header[c].isEmpty ? '' : header[c].toUpperCase(),
                                style: TextStyle(fontSize: 10.5, letterSpacing: 0.6, fontWeight: FontWeight.w700, color: scheme.primary),
                              ),
                              const SizedBox(height: 1),
                              RichLine(cells[c], style: TextStyle(fontSize: 13.5, height: 1.4, color: scheme.onSurface)),
                            ],
                          ),
                        ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Coloured pill for a 1-5 score (green >= 4, amber 3, red <= 2).
class ScoreBadge extends StatelessWidget {
  const ScoreBadge({super.key, required this.text, this.score});
  final String text;
  final double? score;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = score;
    final color = s == null
        ? scheme.onSurfaceVariant
        : s >= 4
        ? const Color(0xFF16A34A)
        : s >= 3
        ? const Color(0xFFD97706)
        : scheme.error;
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      constraints: const BoxConstraints(maxWidth: 140),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
      child: RichLine(
        text,
        maxLines: 2,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }
}
