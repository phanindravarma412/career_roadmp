import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/plan.dart';

/// Renders the small subset of inline markdown the plan uses:
/// `code`, **bold** and ~~strike~~.
class RichLine extends StatelessWidget {
  const RichLine(this.text, {super.key, this.style, this.maxLines});

  final String text;
  final TextStyle? style;
  final int? maxLines;

  static final _re = RegExp(r'(`[^`]+`|\*\*[^*]+\*\*|~~[^~]+~~|\[[^\]]+\]\([^)]+\))');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = style ?? DefaultTextStyle.of(context).style;
    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in _re.allMatches(text)) {
      if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start)));
      final token = m[0]!;
      if (token.startsWith('`')) {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: (base.fontSize ?? 14) * 0.92,
              backgroundColor: scheme.surfaceContainerHighest,
              color: scheme.onSurface,
            ),
          ),
        );
      } else if (token.startsWith('[')) {
        spans.add(
          TextSpan(
            text: token.substring(1, token.indexOf(']')),
            style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600),
          ),
        );
      } else if (token.startsWith('**')) {
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: const TextStyle(decoration: TextDecoration.lineThrough),
          ),
        );
      }
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return Text.rich(
      TextSpan(style: base, children: spans),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}

Color categoryColor(Category c, ColorScheme scheme) {
  final dark = scheme.brightness == Brightness.dark;
  Color pick(Color light, Color darkC) => dark ? darkC : light;
  switch (c) {
    case Category.dsa:
      return pick(const Color(0xFF7C3AED), const Color(0xFFC4B5FD));
    case Category.sql:
      return pick(const Color(0xFF0E7490), const Color(0xFF67E8F9));
    case Category.lld:
      return pick(const Color(0xFFB45309), const Color(0xFFFCD34D));
    case Category.jsTs:
      return pick(const Color(0xFFA16207), const Color(0xFFFDE047));
    case Category.react:
      return pick(const Color(0xFF0369A1), const Color(0xFF7DD3FC));
    case Category.backend:
      return pick(const Color(0xFF15803D), const Color(0xFF86EFAC));
    case Category.flutter:
      return pick(const Color(0xFF1D4ED8), const Color(0xFF93C5FD));
    case Category.systemDesign:
      return pick(const Color(0xFFBE185D), const Color(0xFFF9A8D4));
    case Category.career:
      return pick(const Color(0xFFC2410C), const Color(0xFFFDBA74));
    case Category.checkIn:
      return pick(const Color(0xFFDC2626), const Color(0xFFFCA5A5));
    case Category.notes:
    case Category.setup:
      return pick(const Color(0xFF475569), const Color(0xFFCBD5E1));
  }
}

class SmallChip extends StatelessWidget {
  const SmallChip(this.label, {super.key, this.color, this.icon});
  final String label;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = color ?? scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: c),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: c,
              fontFamily: label.endsWith('/') ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular progress with a label in the middle.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.size,
    required this.child,
    this.stroke = 10,
    this.color,
  });

  final double value;
  final double size;
  final double stroke;
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(
            value: v,
            stroke: stroke,
            track: scheme.surfaceContainerHighest,
            color: color ?? scheme.primary,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.stroke,
    required this.track,
    required this.color,
  });
  final double value;
  final double stroke;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, 0, math.pi * 2, false, paint..color = track);
    if (value > 0) {
      canvas.drawArc(
        r,
        -math.pi / 2,
        math.pi * 2 * value,
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}

/// Thin labelled progress bar.
class LabeledBar extends StatelessWidget {
  const LabeledBar({
    super.key,
    required this.label,
    required this.value,
    required this.trailing,
    this.color,
  });
  final String label;
  final double value;
  final String trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                trailing,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              color: color ?? scheme.primary,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final String? title;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
              const SizedBox(height: 10),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

String shortDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
