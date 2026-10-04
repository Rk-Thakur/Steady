// Draws Steady's icon artwork (same wave as SteadyLogo) into assets/icon/.
// Skipped unless asked for:
//   flutter test test/tool/icons_test.dart --dart-define=WRITE_ICONS=true
// then: dart run flutter_launcher_icons && dart run flutter_native_splash:create
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _write = bool.fromEnvironment('WRITE_ICONS');
const _ink = Color(0xFF12201B); // SteadyColors.light.ink
const _lime = Color(0xFFC9F26B); // SteadyColors.light.highlight

/// The logo wave: SVG "M3 16c3 0 3-8 6-8s3 8 6 8 3-8 6-8", 2.4 stroke, in a
/// 24×24 box drawn at [box].
void _wave(Canvas canvas, Rect box) {
  final s = box.width / 24;
  Offset p(double x, double y) => box.topLeft + Offset(x * s, y * s);
  final path = Path()
    ..moveTo(p(3, 16).dx, p(3, 16).dy)
    ..cubicTo(
      p(6, 16).dx,
      p(6, 16).dy,
      p(6, 8).dx,
      p(6, 8).dy,
      p(9, 8).dx,
      p(9, 8).dy,
    )
    ..cubicTo(
      p(12, 8).dx,
      p(12, 8).dy,
      p(12, 16).dx,
      p(12, 16).dy,
      p(15, 16).dx,
      p(15, 16).dy,
    )
    ..cubicTo(
      p(18, 16).dx,
      p(18, 16).dy,
      p(18, 8).dx,
      p(18, 8).dy,
      p(21, 8).dx,
      p(21, 8).dy,
    );
  canvas.drawPath(
    path,
    Paint()
      ..color = _lime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true,
  );
}

Future<void> _png(
  String path,
  int size,
  void Function(Canvas canvas, double size) draw,
) async {
  final recorder = ui.PictureRecorder();
  draw(Canvas(recorder), size.toDouble());
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('write icon artwork', (tester) async {
    await tester.runAsync(() async {
      // iOS / legacy Android: full square (the OS rounds the corners).
      await _png('assets/icon/app_icon.png', 1024, (c, s) {
        c.drawRect(Offset.zero & Size(s, s), Paint()..color = _ink);
        final w = s * .62;
        _wave(
          c,
          Rect.fromCenter(center: Offset(s / 2, s / 2), width: w, height: w),
        );
      });
      // Android adaptive foreground: wave only. flutter_launcher_icons insets
      // it 16% a side, so this ends up ≈ the iOS proportion in the mask.
      await _png('assets/icon/app_icon_foreground.png', 1024, (c, s) {
        final w = s * .6;
        _wave(
          c,
          Rect.fromCenter(center: Offset(s / 2, s / 2), width: w, height: w),
        );
      });
      // Launch screen: the rounded logo tile from the in-app splash.
      await _png('assets/icon/splash_logo.png', 768, (c, s) {
        // 768px at 4× = 192pt; the tile is 104pt like the in-app splash.
        final tile = s * 104 / 192;
        final r = Rect.fromCenter(
          center: Offset(s / 2, s / 2),
          width: tile,
          height: tile,
        );
        c.drawRRect(
          RRect.fromRectAndRadius(r, Radius.circular(tile * .29)),
          Paint()..color = _ink,
        );
        final w = tile * .54;
        _wave(c, Rect.fromCenter(center: r.center, width: w, height: w));
      });
    });
  }, skip: !_write);
}
