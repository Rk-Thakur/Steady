import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/budget_store.dart';
import '../data/db/budget_repository.dart';
import '../data/db/database_key.dart';
import '../data/db/open_database.dart';
import 'steady_app.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../ui/onboarding/onboarding_screens.dart';
import '../ui/routes.dart';
import '../ui/settings/backup_flows.dart';
import '../ui/widgets/kit.dart';

/// Opens the encrypted database, then starts the app.
///
/// While the database opens the splash stays up (at least [_minSplash] so it
/// doesn't flash). Then: Today if onboarded, otherwise onboarding. If the
/// database can't be decrypted, a recovery screen explains why.
class SteadyBootstrap extends StatefulWidget {
  const SteadyBootstrap({super.key, this.open = _openOnDevice});

  /// How to load the store; replaceable in tests.
  final Future<BudgetStore> Function() open;

  @override
  State<SteadyBootstrap> createState() => _SteadyBootstrapState();
}

Future<BudgetStore> _openOnDevice() async {
  final db = await openSteadyDatabase();
  final repo = BudgetRepository(db);
  final snapshot = await repo.load();
  final pinVault = SecureKeyVault.pin();
  final pin = await pinVault.read();
  return BudgetStore.fromSnapshot(
    snapshot,
    repository: repo,
    pinVault: pinVault,
    pin: pin,
  );
}

enum _Phase { loading, ready, keyLost, failed }

class _SteadyBootstrapState extends State<SteadyBootstrap> {
  static const _minSplash = Duration(milliseconds: 900);

  _Phase _phase = _Phase.loading;
  BudgetStore? _store;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() => _phase = _Phase.loading);
    final minimum = Future<void>.delayed(_minSplash);
    try {
      final store = await widget.open();
      await minimum;
      if (!mounted) return;
      setState(() {
        _store = store;
        _phase = _Phase.ready;
      });
    } on DatabaseKeyLostException {
      await minimum;
      if (mounted) setState(() => _phase = _Phase.keyLost);
    } catch (e, st) {
      debugPrint('Steady: could not open the database: $e\n$st');
      await minimum;
      if (!mounted) return;
      setState(() {
        _error = e;
        _phase = _Phase.failed;
      });
    }
  }

  /// Restore after a lost key: a fresh database (new key), then the backup.
  Future<void> _restoreInto(BudgetSnapshot snapshot) async {
    await resetSteadyDatabase();
    await SecureKeyVault.pin().delete();
    final repo = BudgetRepository(await openSteadyDatabase());
    await repo.replaceAll(snapshot);
    await repo.close();
    await _start();
  }

  Future<void> _startOver() async {
    await resetSteadyDatabase();
    await SecureKeyVault.pin().delete();
    await _start();
  }

  @override
  Widget build(BuildContext context) {
    final store = _store;
    if (_phase == _Phase.ready && store != null) {
      return SteadyApp(
        store: store,
        initialRoute: store.settings.onboarded ? Routes.home : Routes.welcome,
      );
    }
    return MaterialApp(
      title: 'Steady',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: switch (_phase) {
        _Phase.loading || _Phase.ready => const SplashScreen.loading(),
        _Phase.keyLost => _RecoveryScreen(
          onStartOver: _startOver,
          onRestore: _restoreInto,
        ),
        _Phase.failed => _FailedScreen(error: _error, onRetry: _start),
      },
    );
  }
}

/// The database exists but its key is gone (e.g. app data restored onto a new
/// phone; the key never leaves the old one).
class _RecoveryScreen extends StatelessWidget {
  const _RecoveryScreen({required this.onStartOver, required this.onRestore});
  final Future<void> Function() onStartOver;
  final Future<void> Function(BudgetSnapshot snapshot) onRestore;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SteadyPage(
      leading: PageLeading.none,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SteadyButton(
            'Restore from a backup file',
            onPressed: () => restoreFlow(context, apply: onRestore),
          ),
          const SizedBox(height: 10),
          SteadyButton(
            'Start over',
            kind: ButtonKind.dangerLink,
            onPressed: () async {
              final ok = await confirmSheet(
                context,
                title: 'Start over?',
                body:
                    "The data on this phone can't be opened, so it will be deleted and Steady "
                    'starts fresh. Backup files you saved elsewhere are not touched.',
                confirmLabel: 'Delete and start over',
              );
              if (ok) await onStartOver();
            },
          ),
        ],
      ),
      children: [
        const SizedBox(height: SteadySpace.s7),
        const Align(
          alignment: Alignment.centerLeft,
          child: SteadyLogo(size: 64),
        ),
        Text(
          "We can't open your data",
          style: SteadyType.title.copyWith(fontSize: 30, height: 1.1),
        ),
        Text(
          "Steady's data is encrypted with a key that never leaves the phone it was created on. "
          "That key isn't here, which usually means this phone's data was restored from another "
          'phone or the key was removed.',
          style: SteadyType.body.copyWith(color: c.muted, height: 1.5),
        ),
        const SoftBanner(
          icon: Icons.lock_outline_rounded,
          child: Text(
            'If you have a .steady backup file, restoring it brings your history back. '
            "Otherwise, you can start over; nobody, including us, can decrypt the old data.",
          ),
        ),
      ],
    );
  }
}

class _FailedScreen extends StatelessWidget {
  const _FailedScreen({required this.error, required this.onRetry});
  final Object? error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SteadyPage(
      leading: PageLeading.none,
      bottom: SteadyButton('Try again', onPressed: onRetry),
      children: [
        const SizedBox(height: SteadySpace.s7),
        const Align(
          alignment: Alignment.centerLeft,
          child: SteadyLogo(size: 64),
        ),
        Text(
          "Steady couldn't start",
          style: SteadyType.title.copyWith(fontSize: 30, height: 1.1),
        ),
        Text(
          'Something went wrong opening your data. Nothing has been deleted. '
          'Try again, and if it keeps happening, restart your phone.',
          style: SteadyType.body.copyWith(color: c.muted, height: 1.5),
        ),
        if (kDebugMode && error != null)
          SoftBanner(
            tone: BannerTone.danger,
            child: Text('$error', style: const TextStyle(fontSize: 12)),
          ),
      ],
    );
  }
}
