import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/budget_store.dart';
import '../data/store_scope.dart';
import '../domain/models/settings.dart';
import '../domain/reminders.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../ui/app_router.dart';
import '../ui/onboarding/onboarding_screens.dart';
import '../ui/routes.dart';
import '../ui/shell/home_shell.dart';
import 'notifications.dart';

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

  /// Fires just after local midnight: the daily number resets (Handoff 3).
  Timer? _midnight;

  void _scheduleMidnight() {
    _midnight?.cancel();
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day + 1, 0, 0, 1);
    _midnight = Timer(next.difference(now), () {
      widget.store.onClockTick();
      _scheduleMidnight();
    });
  }

  // ─── Reminders ───────────────────────────────────────────────────────────

  StreamSubscription<String>? _taps;
  Timer? _rescheduleSoon;
  List<PlannedNotification>? _scheduled;

  /// A tapped notification's screen, held back while the lock is showing.
  String? _pendingRoute;

  /// Every change can move a reminder (a bill paid, a time changed), so the
  /// plan is rebuilt shortly after any of them; unchanged plans are skipped.
  void _queueReschedule() {
    _rescheduleSoon?.cancel();
    _rescheduleSoon = Timer(const Duration(seconds: 1), _reschedule);
  }

  void _reschedule() {
    final store = widget.store;
    final plan = store.settings.onboarded
        ? store.plannedNotifications(DateTime.now())
        : const <PlannedNotification>[];
    if (listEquals(plan, _scheduled)) return;
    _scheduled = plan;
    Notifications.instance.replaceAll(plan).catchError((Object e) {
      _scheduled = null; // try again next time
      debugPrint('Steady: could not schedule reminders: $e');
    });
  }

  void _openFromNotification(String route) {
    if (!widget.store.settings.onboarded) return;
    final nav = _navigator.currentState;
    if (nav == null || _lockShowing) {
      // Never above the lock screen: open it once unlocked.
      _pendingRoute = route;
      if (nav == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _openPending());
      }
      return;
    }
    switch (route) {
      case Routes.home || Routes.bills:
        HomeShell.tab.value = route == Routes.bills
            ? ShellTab.bills
            : ShellTab.today;
        nav.popUntil((r) => r.isFirst);
      default:
        openRouteLink(nav, route);
    }
  }

  void _openPending() {
    final route = _pendingRoute;
    _pendingRoute = null;
    if (route != null) _openFromNotification(route);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnight();
    final s = widget.store.settings;
    if (widget.initialRoute == Routes.home &&
        s.appLockEnabled &&
        s.pin != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showLock());
    }
    final notifications = Notifications.instance;
    if (notifications.enabled) {
      widget.store.addListener(_queueReschedule);
      _queueReschedule();
      _taps = notifications.taps.listen(_openFromNotification);
      notifications.launchRoute().then((route) {
        if (route != null && mounted) _openFromNotification(route);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnight?.cancel();
    _rescheduleSoon?.cancel();
    _taps?.cancel();
    widget.store.removeListener(_queueReschedule);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final s = widget.store.settings;
    final lockOn = s.appLockEnabled && s.pin != null;
    switch (state) {
      case AppLifecycleState.inactive || AppLifecycleState.hidden:
        // The lock screen shows nothing private, so it stays visible behind
        // the Face ID / fingerprint dialog instead of the cover.
        if (lockOn && !_lockShowing) setState(() => _covered = true);
      case AppLifecycleState.paused:
        _backgroundedAt ??= DateTime.now();
      case AppLifecycleState.resumed:
        final away = _backgroundedAt == null
            ? Duration.zero
            : DateTime.now().difference(_backgroundedAt!);
        _backgroundedAt = null;
        if (lockOn && away >= _relockAfter && !_lockShowing) _showLock();
        // The date may have changed while away; timers don't run then.
        widget.store.onClockTick();
        _scheduleMidnight();
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
    _openPending();
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
          builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: Theme.of(context).brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            child: Stack(
              children: [
                ?child,
                if (_covered) const Positioned.fill(child: _PrivacyCover()),
              ],
            ),
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
