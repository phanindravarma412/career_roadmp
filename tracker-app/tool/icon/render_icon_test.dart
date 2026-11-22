// Draws the Roadmap app icon and writes the PNGs to assets/icon/.
//
// Regenerate with:
//   flutter test tool/icon/render_icon_test.dart
//   dart run flutter_launcher_icons
//
// Design: a winding road (the plan) climbing to a flag (the senior offer),
// on the app's indigo-to-violet gradient.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _indigo = Color(0xFF4F46E5);
const _violet = Color(0xFF7C3AED);
const _deep = Color(0xFF3730A3);
const _amber = Color(0xFFFBBF24);
const _orange = Color(0xFFF59E0B);

/// [scale] shrinks the drawing around the centre (Android adaptive icons
/// need the important part inside the middle ~66%).
void paintIcon(Canvas canvas, double size, {required bool background, required bool foreground, double scale = 1}) {
  final rect = Offset.zero & Size(size, size);

  if (background) {
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_violet, _indigo, _deep],
          stops: [0, 0.55, 1],
        ).createShader(rect),
    );
    // Soft glow behind the flag.
    canvas.drawCircle(
      Offset(size * 0.66, size * 0.28),
      size * 0.42,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withValues(alpha: 0.22), Colors.white.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: Offset(size * 0.66, size * 0.28), radius: size * 0.42)),
    );
  }
  if (!foreground) return;

  canvas.save();
  canvas.translate(size / 2, size / 2);
  canvas.scale(scale);
  canvas.translate(-size / 2, -size / 2);

  Offset p(double x, double y) => Offset(x * size, y * size);

  // The road: comes in from the bottom, bends right, bends left, ends at the flag.
  final road = Path()
    ..moveTo(p(0.30, 1.45).dx, p(0.30, 1.45).dy)
    ..lineTo(p(0.30, 1.0).dx, p(0.30, 1.0).dy)
    ..cubicTo(p(0.30, 0.82).dx, p(0.30, 0.82).dy, p(0.74, 0.86).dx, p(0.74, 0.86).dy, p(0.72, 0.66).dx, p(0.72, 0.66).dy)
    ..cubicTo(p(0.70, 0.48).dx, p(0.70, 0.48).dy, p(0.32, 0.56).dx, p(0.32, 0.56).dy, p(0.36, 0.40).dx, p(0.36, 0.40).dy)
    ..cubicTo(p(0.39, 0.30).dx, p(0.39, 0.30).dy, p(0.48, 0.30).dx, p(0.48, 0.30).dy, p(0.54, 0.31).dx, p(0.54, 0.31).dy);

  final roadWidth = size * 0.15;

  // Shadow.
  canvas.save();
  canvas.translate(0, size * 0.02);
  canvas.drawPath(
    road,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = roadWidth
      ..strokeCap = StrokeCap.round
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.012),
  );
  canvas.restore();

  // Road surface.
  canvas.drawPath(
    road,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = roadWidth
      ..strokeCap = StrokeCap.round
      ..color = Colors.white,
  );

  // Dashed centre line.
  final dash = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = size * 0.022
    ..strokeCap = StrokeCap.round
    ..color = _indigo;
  for (final metric in road.computeMetrics()) {
    final dashLen = size * 0.045;
    final gap = size * 0.04;
    // Stop short of the end so the flag's base circle stays clean.
    final end = metric.length - size * 0.08;
    for (var d = 0.0; d < end; d += dashLen + gap) {
      canvas.drawPath(metric.extractPath(d, (d + dashLen).clamp(0, end)), dash);
    }
  }

  // Flag pole on a round base at the end of the road.
  final base = p(0.555, 0.31);
  final poleTop = p(0.555, 0.07);
  canvas.drawLine(
    base,
    poleTop,
    Paint()
      ..strokeWidth = size * 0.026
      ..strokeCap = StrokeCap.round
      ..color = Colors.white,
  );

  // Waving flag.
  final fx = poleTop.dx + size * 0.008;
  final fy = poleTop.dy + size * 0.005;
  final w = size * 0.24;
  final h = size * 0.15;
  final flag = Path()
    ..moveTo(fx, fy)
    ..cubicTo(fx + w * 0.35, fy - h * 0.22, fx + w * 0.62, fy + h * 0.22, fx + w, fy)
    ..lineTo(fx + w * 0.86, fy + h * 0.5)
    ..lineTo(fx + w, fy + h)
    ..cubicTo(fx + w * 0.62, fy + h * 1.22, fx + w * 0.35, fy + h * 0.78, fx, fy + h)
    ..close();
  canvas.drawPath(
    flag,
    Paint()
      ..shader = const LinearGradient(colors: [_amber, _orange]).createShader(
        Rect.fromLTWH(fx, fy, w, h),
      ),
  );

  canvas.drawCircle(base, size * 0.05, Paint()..color = _amber);
  canvas.drawCircle(base, size * 0.022, Paint()..color = Colors.white);

  canvas.restore();
}

Future<void> _write(String path, {required bool background, required bool foreground, double scale = 1, bool circleMask = false}) async {
  const size = 1024.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  if (circleMask) {
    // What a round Android launcher shows: the middle 72dp of the 108dp layer.
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: const Offset(size / 2, size / 2), radius: size / 3)));
  }
  paintIcon(canvas, size, background: background, foreground: foreground, scale: scale);
  final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(path)..createSync(recursive: true);
  file.writeAsBytesSync(bytes!.buffer.asUint8List());
}

/// Keeps the flag inside the adaptive icon's visible circle.
const _adaptiveScale = 0.56;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('render app icon', () async {
    // iOS, web and old Android: full square icon.
    await _write('assets/icon/icon.png', background: true, foreground: true, scale: 0.9);
    // Android adaptive icon: separate layers, drawing kept in the safe zone.
    await _write('assets/icon/icon_background.png', background: true, foreground: false);
    await _write('assets/icon/icon_foreground.png', background: false, foreground: true, scale: _adaptiveScale);
    // Preview only (build/ is git-ignored): adaptive icon under a circle mask.
    await _write('build/icon_preview_circle.png', background: true, foreground: true, scale: _adaptiveScale, circleMask: true);
  });
}
