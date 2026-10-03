// Renders every screen at iPhone 17 Pro Max size (with safe areas) and writes
// contact sheets of 4 screens each, for visual review.
//
// Run:  flutter test test/tool/screenshots_test.dart --dart-define=SHOTS_DIR=/some/dir
// Skipped when SHOTS_DIR is not set, so it never runs in the normal suite.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/core/local_date.dart';
import 'package:steady/data/budget_store.dart';
import 'package:steady/domain/models/settings.dart';
import 'package:steady/main.dart';
import 'package:steady/ui/routes.dart';

const _dir = String.fromEnvironment('SHOTS_DIR');
const _dark = bool.fromEnvironment('SHOTS_DARK');

void main() {
  const size = Size(440, 956);
  const safe = EdgeInsets.only(top: 62, bottom: 34);

  final routes = <(String, Object? Function(BudgetStore))>[
    (Routes.home, (_) => null),
    (Routes.bills, (_) => null),
    (Routes.vault, (_) => null),
    (Routes.insights, (_) => null),
    (Routes.afford, (_) => null),
    (Routes.logSpend, (_) => null),
    (Routes.logIncome, (_) => null),
    (Routes.history, (_) => null),
    (Routes.editEntry, (s) => s.history.first.id),
    (Routes.splash, (_) => null),
    (Routes.welcome, (_) => null),
    (Routes.onbIncome, (_) => null),
    (Routes.onbMoney, (_) => null),
    (Routes.onbReveal, (_) => null),
    (Routes.notifPermission, (_) => null),
    (Routes.todayEmpty, (_) => null),
    (Routes.todayLoading, (_) => null),
    (Routes.todayCatchUp, (_) => null),
    (Routes.paidPrompt, (_) => null),
    (Routes.splitSetup, (_) => null),
    (Routes.splits, (_) => null),
    (Routes.settleUp, (_) => null),
    (Routes.settings, (_) => null),
    (Routes.profile, (_) => null),
    (Routes.reminders, (_) => null),
    (Routes.categories, (_) => null),
    (Routes.categoryEdit, (s) => s.categories.first.id),
    (Routes.billEdit, (_) => null),
    (Routes.backup, (_) => null),
    (Routes.help, (_) => null),
    (Routes.notifications, (_) => null),
    (Routes.goals, (_) => null),
    (Routes.goalNew, (_) => null),
    (Routes.goalDetail, (s) => s.goals.first.id),
    (Routes.goalDone, (s) => s.goals.first.id),
    (Routes.summaryWeek, (_) => null),
    (Routes.summaryMonth, (_) => null),
    (Routes.setPin, (_) => null),
    (Routes.lock, (_) => null),
    (Routes.gallery, (_) => null),
  ];

  testWidgets('screenshots', (tester) async {
    await tester.runAsync(() async {
      Future<void> load(String family, Future<ByteData> data) async {
        await (FontLoader(family)..addFont(data)).load();
      }

      await load('Manrope', rootBundle.load('assets/fonts/Manrope.ttf'));
      await load(
        'BricolageGrotesque',
        rootBundle.load('assets/fonts/BricolageGrotesque.ttf'),
      );
      final flutterRoot =
          Platform.environment['FLUTTER_ROOT'] ??
          '${Platform.environment['HOME']}/Development/flutter';
      final icons = File(
        '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
      );
      await load(
        'MaterialIcons',
        icons.readAsBytes().then((b) => ByteData.sublistView(b)),
      );
    });

    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.view.padding = FakeViewPadding(top: safe.top, bottom: safe.bottom);
    tester.view.viewPadding = FakeViewPadding(
      top: safe.top,
      bottom: safe.bottom,
    );
    addTearDown(tester.view.reset);

    final shots = <(String, ui.Image)>[];
    for (final (route, argsOf) in routes) {
      final store = BudgetStore.sample(
        clock: () => const LocalDate(2026, 10, 2),
      );
      if (_dark) {
        store.updateSettings(
          store.settings.copyWith(theme: ThemePreference.dark),
        );
      }
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: SteadyApp(store: store, initialRoute: Routes.home),
        ),
      );
      await tester.pump();
      if (route != Routes.home) {
        tester
            .state<NavigatorState>(find.byType(Navigator).first)
            .pushNamed(route, arguments: argsOf(store));
      }
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 400));
      }
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await tester.runAsync(
        () => boundary.toImage(pixelRatio: 1),
      );
      shots.add((route, image!));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    }

    // Contact sheets: 4 per sheet, side by side, with a gap.
    await tester.runAsync(() async {
      Directory(_dir).createSync(recursive: true);
      const gap = 24.0;
      for (var start = 0; start < shots.length; start += 4) {
        final group = shots.sublist(start, (start + 4).clamp(0, shots.length));
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        final w = size.width * group.length + gap * (group.length + 1);
        final h = size.height + gap * 2;
        canvas.drawRect(
          Rect.fromLTWH(0, 0, w, h),
          Paint()..color = const Color(0xFF888888),
        );
        for (var i = 0; i < group.length; i++) {
          canvas.drawImage(
            group[i].$2,
            Offset(gap + i * (size.width + gap), gap),
            Paint(),
          );
        }
        final sheet = await recorder.endRecording().toImage(
          w.toInt(),
          h.toInt(),
        );
        final png = await sheet.toByteData(format: ui.ImageByteFormat.png);
        final names = group.map((g) => g.$1.replaceAll('/', '_')).join(' ');
        File('$_dir/sheet_${(start ~/ 4).toString().padLeft(2, '0')}.png')
            .writeAsBytesSync(png!.buffer.asUint8List());
        stdout.writeln('sheet ${start ~/ 4}: $names');
      }
    });
  }, skip: _dir.isEmpty);
}
