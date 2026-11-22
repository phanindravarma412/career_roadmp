import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../logic/gamification.dart';
import '../models/plan.dart';
import '../state/app_state.dart';

/// Confetti dialog shown when a day is finished or a level is reached.
Future<void> showCelebration(
  BuildContext context, {
  required AppState state,
  PlanDay? day,
  Level? levelUp,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, _, _) =>
        _CelebrationView(state: state, day: day, levelUp: levelUp),
    transitionBuilder: (context, anim, _, child) => ScaleTransition(
      scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
      child: child,
    ),
  );
}

class _CelebrationView extends StatefulWidget {
  const _CelebrationView({required this.state, this.day, this.levelUp});
  final AppState state;
  final PlanDay? day;
  final Level? levelUp;

  @override
  State<_CelebrationView> createState() => _CelebrationViewState();
}

class _CelebrationViewState extends State<_CelebrationView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();
  final _particles = List.generate(70, (i) => _Particle(math.Random(i * 7 + 3)));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = widget.state;
    final next = widget.day == null ? null : state.dayAfter(widget.day!);
    final title = widget.day != null
        ? '${widget.day!.title} complete!'
        : 'Level up!';
    final xpLine = widget.day != null
        ? '+${widget.day!.tasks.length * xpPerTask + xpPerDay} XP'
        : null;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => CustomPaint(
                painter: _ConfettiPainter(_particles, _c.value),
              ),
            ),
          ),
        ),
        Center(
          child: Material(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 320,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.levelUp != null
                        ? Icons.workspace_premium_rounded
                        : Icons.emoji_events_rounded,
                    size: 64,
                    color: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (xpLine != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      xpLine,
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                  if (widget.levelUp != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'You are now Level ${widget.levelUp!.index}: ${widget.levelUp!.title}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    '${(state.overallFraction * 100).toStringAsFixed(1)}% of the plan done'
                    '${state.streak > 1 ? ' · ${state.streak}-day streak' : ''}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  if (widget.day != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tell Claude: "Interview me" for the check-in.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(next == null ? 'Nice' : 'Next up: ${next.title}'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Particle {
  _Particle(math.Random r)
    : x = r.nextDouble(),
      speed = 0.5 + r.nextDouble() * 0.8,
      drift = (r.nextDouble() - 0.5) * 0.3,
      size = 5 + r.nextDouble() * 7,
      spin = r.nextDouble() * math.pi * 4,
      delay = r.nextDouble() * 0.3,
      color = _colors[r.nextInt(_colors.length)];

  static const _colors = [
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFF6366F1),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFFEF4444),
  ];

  final double x, speed, drift, size, spin, delay;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.t);
  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final y = -0.05 + local * p.speed * 1.2;
      final x = p.x + p.drift * local;
      final opacity = local > 0.8 ? (1 - local) / 0.2 : 1.0;
      paint.color = p.color.withValues(alpha: opacity);
      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(p.spin * local);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
