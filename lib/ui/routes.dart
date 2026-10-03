import '../core/local_date.dart';

/// Route names for every screen on the design canvas.
abstract final class Routes {
  // Shell & Today states
  static const home = '/';
  static const todayEmpty = '/today/empty';
  static const todayLoading = '/today/loading';
  static const todayCatchUp = '/today/catch-up';
  static const paidPrompt = '/today/paid-prompt';

  // Key screens
  static const afford = '/afford';
  static const logSpend = '/log/spend';
  static const logIncome = '/log/income';
  static const bills = '/bills';
  static const vault = '/vault';
  static const insights = '/insights';

  // Onboarding
  static const splash = '/splash';
  static const welcome = '/onboarding/welcome';
  static const onbIncome = '/onboarding/income';
  static const onbMoney = '/onboarding/money';
  static const onbReveal = '/onboarding/reveal';
  static const notifPermission = '/onboarding/reminders';

  // Splits
  static const splitSetup = '/splits/setup';
  static const splits = '/splits';
  static const settleUp = '/splits/settle';

  // Settings & profile
  static const settings = '/settings';
  static const profile = '/settings/profile';
  static const reminders = '/settings/reminders';
  static const categories = '/settings/categories';
  static const categoryEdit = '/settings/categories/edit';
  static const billEdit = '/settings/bills/edit';
  static const backup = '/settings/backup';
  static const help = '/settings/help';
  static const notifications = '/notifications';

  // Goals
  static const goals = '/goals';
  static const goalNew = '/goals/new';
  static const goalDetail = '/goals/detail';
  static const goalDone = '/goals/done';

  // Offline v1
  static const history = '/history';
  static const editEntry = '/history/edit';
  static const summaryWeek = '/summary/week';
  static const summaryMonth = '/summary/month';

  // App lock (required by Handoff 4; not drawn on the canvas)
  static const lock = '/lock';
  static const setPin = '/lock/set-pin';

  // Debug
  static const gallery = '/debug/screens';
}

/// Prefill for Log spend (from Can I afford it? or Add shared).
class LogSpendArgs {
  const LogSpendArgs({
    this.amountCents,
    this.merchant,
    this.shared = false,
    this.date,
  });
  final int? amountCents;
  final String? merchant;
  final bool shared;

  /// Log for an earlier day (catch-up). Defaults to today.
  final LocalDate? date;
}

/// Prefill for Add a bill (onboarding "+ Phone", "+ Subscriptions").
class BillPrefill {
  const BillPrefill({
    this.name,
    this.amountCents,
    this.dueInDays,
    this.subscription = false,
  });
  final String? name;
  final int? amountCents;
  final int? dueInDays;
  final bool subscription;
}

/// Prefill for New goal (from "Save for it").
class GoalNewArgs {
  const GoalNewArgs({this.name, this.targetCents});
  final String? name;
  final int? targetCents;
}
