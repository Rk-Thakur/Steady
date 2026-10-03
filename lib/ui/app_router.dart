import 'package:flutter/material.dart';

import '../core/local_date.dart';

import 'afford/afford_screen.dart';
import 'bills/bills_screen.dart';
import 'gallery_screen.dart';
import 'goals/goal_screens.dart';
import 'history/edit_entry_screen.dart';
import 'history/history_screen.dart';
import 'insights/insights_screen.dart';
import 'insights/summary_screen.dart';
import 'lock/lock_screens.dart';
import 'log/log_income_screen.dart';
import 'log/log_spend_screen.dart';
import 'onboarding/onboarding_screens.dart';
import 'routes.dart';
import 'widgets/kit.dart';
import '../theme/tokens.dart';
import 'settings/backup_screen.dart';
import 'settings/bill_edit_screen.dart';
import 'settings/categories_screen.dart';
import 'settings/category_edit_screen.dart';
import 'settings/help_screen.dart';
import 'settings/notifications_screen.dart';
import 'settings/profile_screen.dart';
import 'settings/reminders_screen.dart';
import 'settings/settings_screen.dart';
import 'shell/home_shell.dart';
import 'splits/split_screens.dart';
import 'today/today_states.dart';
import 'vault/vault_screen.dart';

/// Builds every named route. Log spend / Log income open as full-screen
/// sheets (Handoff 2: bottom sheet slides up).
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final args = settings.arguments;
  Widget? page = switch (settings.name) {
    Routes.home => const HomeShell(),
    Routes.splash => const SplashScreen(),
    Routes.welcome => const WelcomeScreen(),
    Routes.onbIncome => OnbIncomeScreen(editing: args == true),
    Routes.onbMoney => const OnbMoneyScreen(),
    Routes.onbReveal => const OnbRevealScreen(),
    Routes.notifPermission => const NotifPermissionScreen(),
    Routes.afford => const AffordScreen(),
    Routes.logSpend => LogSpendScreen(
      args: args is LogSpendArgs ? args : const LogSpendArgs(),
    ),
    Routes.logIncome => const LogIncomeScreen(),
    // Tabs, when opened from elsewhere (e.g. a notification).
    Routes.bills => const _Standalone(BillsScreen()),
    Routes.vault => const _Standalone(VaultScreen()),
    Routes.insights => const _Standalone(InsightsScreen()),
    Routes.todayEmpty => const _Standalone(TodayEmptyBody()),
    Routes.todayLoading => const _Standalone(TodayLoadingBody()),
    Routes.todayCatchUp => const _Standalone(_CatchUpPreview()),
    Routes.paidPrompt => const _Standalone(PaidPromptBody()),
    Routes.splitSetup => const SplitSetupScreen(),
    Routes.splits => const SplitsScreen(),
    Routes.settleUp => const SettleUpScreen(),
    Routes.settings => const SettingsScreen(),
    Routes.profile => const ProfileScreen(),
    Routes.reminders => const RemindersScreen(),
    Routes.categories => const CategoriesScreen(),
    Routes.categoryEdit => CategoryEditScreen(categoryId: args as String?),
    Routes.billEdit => BillEditScreen(
      billId: args is String ? args : null,
      prefill: args is BillPrefill ? args : null,
    ),
    Routes.backup => const BackupScreen(),
    Routes.help => const HelpScreen(),
    Routes.notifications => const NotificationsScreen(),
    Routes.goals => const GoalsScreen(),
    Routes.goalNew => GoalNewScreen(
      args: args is GoalNewArgs ? args : const GoalNewArgs(),
    ),
    Routes.goalDetail => GoalDetailScreen(goalId: args! as String),
    Routes.goalDone => GoalDoneScreen(goalId: args as String?),
    Routes.history => const HistoryScreen(),
    Routes.editEntry => EditEntryScreen(entryId: args! as String),
    Routes.summaryWeek => const SummaryScreen(),
    Routes.summaryMonth => const SummaryScreen(month: true),
    Routes.gallery => const GalleryScreen(),
    Routes.lock => const LockScreen(),
    Routes.setPin => const SetPinScreen(),
    _ => null,
  };
  if (page == null) return null;
  final sheet =
      settings.name == Routes.logSpend || settings.name == Routes.logIncome;
  return MaterialPageRoute(
    settings: settings,
    fullscreenDialog: sheet || settings.name == Routes.lock,
    builder: (_) => page,
  );
}

/// A tab body shown outside the shell, with a way back.
class _Standalone extends StatelessWidget {
  const _Standalone(this.body);
  final Widget body;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: body,
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: SteadyButton(
      'Back',
      kind: ButtonKind.inverse,
      icon: Icons.chevron_left_rounded,
      height: SteadySize.buttonCompact,
      expand: false,
      onPressed: () => Navigator.of(context).maybePop(),
    ),
  );
}

/// Catch-up preview with the design's example: the two days before today.
class _CatchUpPreview extends StatelessWidget {
  const _CatchUpPreview();

  @override
  Widget build(BuildContext context) {
    final today = LocalDate.today();
    return TodayCatchUpBody(demoMissed: [today.addDays(-2), today.addDays(-1)]);
  }
}
