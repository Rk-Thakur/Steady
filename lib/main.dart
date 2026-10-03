import 'package:flutter/material.dart';

import 'data/budget_store.dart';
import 'data/store_scope.dart';
import 'domain/models/settings.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';
import 'ui/onboarding/onboarding_screens.dart';
import 'ui/app_router.dart';
import 'ui/routes.dart';

void main() {
  runApp(SteadyApp(store: BudgetStore.sample()));
}

class SteadyApp extends StatefulWidget {
  const SteadyApp({
    super.key,
    required this.store,
    this.initialRoute = Routes.splash,
  });

  final BudgetStore store;

  /// Splash by default; tests start straight on [Routes.home].
  final String initialRoute;

  @override
  State<SteadyApp> createState() => _SteadyAppState();
}

class _SteadyAppState extends State<SteadyApp> with WidgetsBindingObserver {
  final _navigator = GlobalKey<NavigatorState>();

  /// Hides the app's contents in the app switcher (Handoff 4).
  bool _covered = false;
  DateTime? _backgroundedAt;
  bool _lockShowing = false;

  /// Lock again after this long in the background.
  static const _relockAfter = Duration(minutes: 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final s = widget.store.settings;
    final lockOn = s.appLockEnabled && s.pin != null;
    switch (state) {
      case AppLifecycleState.inactive || AppLifecycleState.hidden:
        if (lockOn) setState(() => _covered = true);
      case AppLifecycleState.paused:
        _backgroundedAt ??= DateTime.now();
      case AppLifecycleState.resumed:
        final away = _backgroundedAt == null
            ? Duration.zero
            : DateTime.now().difference(_backgroundedAt!);
        _backgroundedAt = null;
        if (lockOn && away >= _relockAfter && !_lockShowing) _showLock();
        setState(() => _covered = false);
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _showLock() async {
    final nav = _navigator.currentState;
    if (nav == null) return;
    _lockShowing = true;
    await nav.pushNamed(Routes.lock);
    _lockShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return StoreScope(
      store: store,
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) => MaterialApp(
          navigatorKey: _navigator,
          title: 'Steady',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: switch (store.settings.theme) {
            ThemePreference.light => ThemeMode.light,
            ThemePreference.dark => ThemeMode.dark,
            ThemePreference.system => ThemeMode.system,
          },
          initialRoute: widget.initialRoute,
          // Only the initial route itself; no implicit '/' underneath splash.
          onGenerateInitialRoutes: (name) => [
            onGenerateRoute(RouteSettings(name: name))!,
          ],
          onGenerateRoute: onGenerateRoute,
          builder: (context, child) => Stack(
            children: [
              ?child,
              if (_covered) const Positioned.fill(child: _PrivacyCover()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown over the app while it is in the app switcher.
class _PrivacyCover extends StatelessWidget {
  const _PrivacyCover();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: SteadyColors.light.hero,
    child: const Center(child: SteadyLogo(size: 88)),
  );
}
