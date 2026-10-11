import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/date_format.dart';
import '../../core/money.dart';
import '../../data/budget_store.dart';
import '../../data/store_scope.dart';
import '../../domain/models/models.dart';
import '../../domain/split_math.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';
import '../widgets/empty_state.dart';

/// Split expenses in groups (a partner, flatmates, a trip). The people are
/// just names on this phone; you're the bookkeeper.

String _m(BudgetStore store, int cents) =>
    formatMoney(cents, symbol: store.symbol);

String _people(int n) => n == 1 ? '1 person' : '$n people';

/// "Sam pays you", "You pay Priya", "Sam pays Priya".
String _transferLabel(SplitBook book, Transfer t) {
  if (t.toId == youId) return '${book.nameOf(t.fromId)} pays you';
  if (t.fromId == youId) return 'You pay ${book.nameOf(t.toId)}';
  return '${book.nameOf(t.fromId)} pays ${book.nameOf(t.toId)}';
}

// ─── H2 Splits home ────────────────────────────────────────────────────────

class SplitsScreen extends StatelessWidget {
  const SplitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final book = store.splits;
    final balances = store.splitBalances;
    final owedToYou = balances.fold<int>(0, (a, b) => a + b.owesYou);
    final youOwe = balances.fold<int>(0, (a, b) => a + b.youOwe);

    return SteadyPage(
      title: 'Split expenses',
      subtitle: 'On this phone only',
      gap: 18,
      bottom: SteadyButton(
        'New group',
        onPressed: () => Navigator.of(context).pushNamed(Routes.splitSetup),
      ),
      children: [
        if (book.groups.isEmpty)
          const EmptyState(
            icon: Icons.people_outline_rounded,
            tone: BannerTone.warning,
            title: 'Share costs, fairly',
            body:
                'Make a group for anyone you share costs with: a partner, '
                'flatmates, a trip. They don\'t need the app, and nothing '
                'leaves this phone.',
          )
        else ...[
          Container(
            padding: const EdgeInsets.all(SteadySpace.s5),
            decoration: BoxDecoration(
              color: c.inverse,
              borderRadius: BorderRadius.circular(SteadyRadius.lg),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _HeroFigure(
                    label: 'Owed to you',
                    value: _m(store, owedToYou),
                    color: c.highlight,
                  ),
                ),
                Expanded(
                  child: _HeroFigure(
                    label: 'You owe',
                    value: _m(store, youOwe),
                    color: c.onInverse,
                  ),
                ),
              ],
            ),
          ),
          const Overline('People'),
          if (balances.isEmpty)
            Text(
              'All square with everyone.',
              style: SteadyType.body.copyWith(color: c.muted),
            )
          else
            GroupedList(
              children: [
                for (final b in balances)
                  NavRow(
                    icon: Icons.person_outline_rounded,
                    tone: b.net >= 0 ? BannerTone.primary : BannerTone.warning,
                    label: book.nameOf(b.personId),
                    subtitle: [
                      for (final g in {for (final t in b.transfers) t.groupId})
                        book.group(g!)?.name ?? '',
                    ].join(' · '),
                    value: b.net > 0
                        ? 'Owes you ${_m(store, b.net)}'
                        : b.net < 0
                        ? 'You owe ${_m(store, -b.net)}'
                        : 'Even',
                    onTap: () =>
                        Navigator.of(context)
                            .pushNamed(Routes.settleUp, arguments: b.personId),
                  ),
              ],
            ),
          const Overline('Groups'),
          GroupedList(
            children: [
              for (final g in book.groups)
                NavRow(
                  icon: Icons.groups_outlined,
                  tone: BannerTone.info,
                  label: g.name,
                  subtitle: _people(g.memberIds.length + 1),
                  value: _yourPosition(store, g),
                  onTap: () =>
                      Navigator.of(context)
                          .pushNamed(Routes.splitGroup, arguments: g.id),
                ),
            ],
          ),
        ],
      ],
    );
  }

  static String _yourPosition(BudgetStore store, SplitGroup g) {
    var cents = 0;
    for (final t in groupTransfers(g, store.splits)) {
      if (t.toId == youId) cents += t.amountCents;
      if (t.fromId == youId) cents -= t.amountCents;
    }
    if (cents > 0) return 'Owed ${_m(store, cents)}';
    if (cents < 0) return 'You owe ${_m(store, -cents)}';
    return 'All square';
  }
}

class _HeroFigure extends StatelessWidget {
  const _HeroFigure({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: SteadyType.caption.copyWith(
          color: context.colors.onInverseMuted,
        ),
      ),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: SteadyType.title.copyWith(fontSize: 26, color: color),
        ),
      ),
    ],
  );
}

// ─── H1 New / edit group ───────────────────────────────────────────────────

class SplitSetupScreen extends StatefulWidget {
  const SplitSetupScreen({super.key, this.groupId});

  /// Null for a new group.
  final String? groupId;

  @override
  State<SplitSetupScreen> createState() => _SplitSetupScreenState();
}

class _SplitSetupScreenState extends State<SplitSetupScreen> {
  final _name = TextEditingController();
  final _newPerson = TextEditingController();
  final _members = <String>[];
  final _weights = <String, TextEditingController>{};
  SplitMethod _method = SplitMethod.equal;
  bool _simplify = true;
  bool _loaded = false;

  SplitGroup? get _existing => widget.groupId == null
      ? null
      : StoreScope.read(context).splits.group(widget.groupId!);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final g = _existing;
    if (g != null) {
      _name.text = g.name;
      _members.addAll(g.memberIds);
      _method = g.method;
      _simplify = g.simplifyDebts;
      for (final e in g.weights.entries) {
        _weight(e.key).text = '${e.value}';
      }
    }
  }

  TextEditingController _weight(String id) =>
      _weights.putIfAbsent(id, TextEditingController.new);

  @override
  void dispose() {
    _name.dispose();
    _newPerson.dispose();
    for (final w in _weights.values) {
      w.dispose();
    }
    super.dispose();
  }

  void _addPerson(BudgetStore store) {
    final name = _newPerson.text.trim();
    if (name.isEmpty) return;
    final existing = store.splits.people
        .where((p) => p.name.toLowerCase() == name.toLowerCase())
        .firstOrNull;
    final person = existing ?? store.addSplitPerson(name);
    setState(() {
      if (!_members.contains(person.id)) _members.add(person.id);
      _newPerson.clear();
    });
  }

  void _save(BudgetStore store) {
    final existing = _existing;
    final group = SplitGroup(
      id: existing?.id ?? store.newId('group'),
      name: _name.text.trim(),
      memberIds: List.of(_members),
      method: _method,
      weights: _method == SplitMethod.byIncome
          ? {
              for (final id in [youId, ..._members])
                id: int.tryParse(_weight(id).text.trim()) ?? 0,
            }
          : const {},
      simplifyDebts: _simplify,
      createdOn: existing?.createdOn ?? store.today,
    );
    store.saveSplitGroup(group);
    if (existing == null) {
      Navigator.of(context)
          .pushReplacementNamed(Routes.splitGroup, arguments: group.id);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete(BudgetStore store) async {
    final g = _existing!;
    final ok = await confirmSheet(
      context,
      title: 'Delete ${g.name}?',
      body:
          'Its shared expenses and settle-ups are removed. Spending and '
          'income already logged stay in your history.',
      confirmLabel: 'Delete group',
    );
    if (!ok || !mounted) return;
    store.deleteSplitGroup(g.id);
    Navigator.of(context)
        .popUntil((r) => r.settings.name == Routes.splits || r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final book = store.splits;
    final ready = _name.text.trim().isNotEmpty && _members.isNotEmpty;
    final others = book.people.where((p) => !_members.contains(p.id));

    return SteadyPage(
      title: _existing == null ? 'New group' : 'Edit group',
      gap: 18,
      bottom: SteadyButton(
        _existing == null ? 'Create group' : 'Save',
        onPressed: ready ? () => _save(store) : null,
      ),
      children: [
        SteadyField(
          label: 'Group name',
          controller: _name,
          hint: 'e.g. Flat 4B, Goa trip',
          onChanged: (_) => setState(() {}),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldLabel('Who\'s in it (besides you)'),
            const SizedBox(height: SteadySpace.s2),
            Wrap(
              spacing: SteadySpace.s2,
              runSpacing: 0, // chips carry their own touch padding
              children: [
                for (final id in _members)
                  SteadyChip(
                    label: '${book.nameOf(id)}  ✕',
                    selected: true,
                    onTap: () => setState(() => _members.remove(id)),
                  ),
                for (final p in others)
                  AddChip(
                    label: '+ ${p.name}',
                    onTap: () => setState(() => _members.add(p.id)),
                  ),
              ],
            ),
            const SizedBox(height: SteadySpace.s2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: SteadyField(
                    label: 'Add someone new',
                    hideLabel: true,
                    controller: _newPerson,
                    hint: 'Their name',
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: SteadySpace.s2),
                SteadyButton(
                  'Add',
                  kind: ButtonKind.secondary,
                  expand: false,
                  height: 52,
                  onPressed: _newPerson.text.trim().isEmpty
                      ? null
                      : () => _addPerson(store),
                ),
              ],
            ),
          ],
        ),
        ChipGroup<SplitMethod>(
          label: 'Usually split',
          options: SplitMethod.values,
          selected: _method,
          labelOf: (m) => switch (m) {
            SplitMethod.equal => 'Equally',
            SplitMethod.byIncome => 'By income %',
            SplitMethod.exact => 'Exact amounts',
          },
          onSelected: (m) => setState(() => _method = m),
        ),
        if (_method == SplitMethod.byIncome)
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final id in [youId, ..._members])
                  Padding(
                    padding: const EdgeInsets.only(bottom: SteadySpace.s2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            book.nameOf(id),
                            style: SteadyType.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 96,
                          child: SteadyField(
                            label: '${book.nameOf(id)} %',
                            hideLabel: true,
                            controller: _weight(id),
                            hint: '%',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  'Percentages are rescaled when not everyone is in an '
                  'expense.',
                  style: SteadyType.caption.copyWith(color: c.muted),
                ),
              ],
            ),
          ),
        if (_method == SplitMethod.exact)
          Text(
            'You\'ll type each person\'s amount when you add an expense.',
            style: SteadyType.caption.copyWith(color: c.muted),
          ),
        GroupedList(
          padding: const EdgeInsets.symmetric(horizontal: SteadySpace.s4),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SwitchRow(
                title: 'Simplify debts',
                subtitle:
                    'Show the fewest payments that settle everyone. Someone '
                    'may pay a person they never split with; totals stay '
                    'the same.',
                value: _simplify,
                onChanged: (v) => setState(() => _simplify = v),
              ),
            ),
          ],
        ),
        if (_existing != null)
          Center(child: LinkText('Delete group', onTap: () => _delete(store))),
      ],
    );
  }
}

// ─── Group ─────────────────────────────────────────────────────────────────

class SplitGroupScreen extends StatelessWidget {
  const SplitGroupScreen({super.key, required this.groupId});
  final String groupId;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final book = store.splits;
    final group = book.group(groupId);
    if (group == null) {
      return const SteadyPage(title: 'Group', children: [Text('Not found.')]);
    }
    final transfers = groupTransfers(group, book);
    final expenses = book.expenses.where((e) => e.groupId == groupId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    // Every IOU, for comparing with the simplified payments.
    final iou = group.simplifyDebts
        ? pairwiseDebts(
            expenses,
            book.settlements.where((s) => s.groupId == groupId),
            groupId: groupId,
          )
        : transfers;
    final simplified = group.simplifyDebts && !_samePayments(iou, transfers);

    Future<void> recordBetweenOthers(Transfer t) async {
      final ok = await confirmSheet(
        context,
        title:
            'Record ${_transferLabel(book, t).toLowerCase()} '
            '${_m(store, t.amountCents)}?',
        body:
            'For money that changed hands between them. Your own money '
            'isn\'t affected.',
        confirmLabel: 'Record payment',
      );
      if (ok) {
        store.recordSettlement(
          groupId: groupId,
          fromId: t.fromId,
          toId: t.toId,
          amountCents: t.amountCents,
          logMoney: false,
        );
      }
    }

    Future<void> deleteExpense(GroupExpense e) async {
      final ok = await confirmSheet(
        context,
        title: 'Delete ${e.name}?',
        body: e.paidBy == youId
            ? 'The ${_m(store, e.amountCents)} you logged for it is removed '
                  'too.'
            : 'Balances in ${group.name} update straight away.',
        confirmLabel: 'Delete expense',
      );
      if (ok) store.deleteGroupExpense(e.id);
    }

    return SteadyPage(
      title: group.name,
      subtitle: [
        'You',
        for (final id in group.memberIds) book.nameOf(id),
      ].join(', '),
      trailing: LinkText(
        'Edit',
        onTap: () =>
            Navigator.of(context)
                .pushNamed(Routes.splitSetup, arguments: groupId),
      ),
      gap: 16,
      bottom: SteadyButton(
        'Add expense',
        onPressed: () =>
            Navigator.of(context)
                .pushNamed(Routes.groupExpense, arguments: groupId),
      ),
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                group.simplifyDebts ? 'To settle up' : 'Who owes whom',
                style: SteadyType.body.copyWith(fontWeight: FontWeight.w700),
              ),
              if (simplified)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Simplified: ${transfers.length} '
                        '${transfers.length == 1 ? 'payment' : 'payments'} '
                        'instead of ${iou.length}. Everyone ends up even.',
                        style: SteadyType.caption.copyWith(
                          fontWeight: FontWeight.w500,
                          color: c.muted,
                        ),
                      ),
                    ),
                    const SizedBox(width: SteadySpace.s2),
                    LinkText(
                      'How?',
                      onTap: () => _explainSimplified(
                        context,
                        store,
                        book,
                        iou: iou,
                        simplified: transfers,
                      ),
                    ),
                  ],
                ),
              if (transfers.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: SteadySpace.s2),
                  child: Text(
                    'All square.',
                    style: SteadyType.body.copyWith(color: c.muted),
                  ),
                ),
              for (final t in transfers)
                Row(
                  children: [
                    Expanded(
                      child: ValueRow(
                        label: _transferLabel(book, t),
                        value: _m(store, t.amountCents),
                        muted: false,
                        valueColor: t.toId == youId ? c.positive : null,
                      ),
                    ),
                    const SizedBox(width: SteadySpace.s2),
                    LinkText(
                      t.fromId == youId || t.toId == youId
                          ? 'Settle'
                          : 'Record',
                      onTap: () => t.fromId == youId || t.toId == youId
                          ? Navigator.of(context).pushNamed(
                              Routes.settleUp,
                              arguments: t.fromId == youId ? t.toId : t.fromId,
                            )
                          : recordBetweenOthers(t),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const Overline('Expenses'),
        if (expenses.isEmpty)
          const EmptyState(
            compact: true,
            icon: Icons.receipt_long_outlined,
            title: 'No expenses yet',
            body: 'Add what someone paid for the group.',
          )
        else
          GroupedList(
            children: [
              for (final e in expenses)
                InkWell(
                  onTap: () => deleteExpense(e),
                  child: ValueRow(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    label: e.name,
                    labelWidget: NameMeta(
                      name: e.name,
                      meta:
                          '${book.nameOf(e.paidBy)} paid · '
                          '${formatShortDate(e.date)} · '
                          '${e.shares.length == group.everyone.length ? 'everyone' : 'split ${e.shares.length} ways'}',
                    ),
                    value: _m(store, e.amountCents),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// Same payments, in any order.
bool _samePayments(List<Transfer> a, List<Transfer> b) {
  String key(Transfer t) => '${t.fromId}>${t.toId}:${t.amountCents}';
  final ka = a.map(key).toList()..sort();
  final kb = b.map(key).toList()..sort();
  return ka.join(',') == kb.join(',');
}

/// "Simplify debts", shown with this group's own numbers: every IOU next
/// to the fewer payments that settle the same totals.
void _explainSimplified(
  BuildContext context,
  BudgetStore store,
  SplitBook book, {
  required List<Transfer> iou,
  required List<Transfer> simplified,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      final c = context.colors;
      Widget list(String title, List<Transfer> ts) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: SteadySpace.s4),
          Overline(title),
          for (final t in ts)
            ValueRow(
              label: _transferLabel(book, t),
              value: _m(store, t.amountCents),
              muted: false,
            ),
        ],
      );
      return SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            SteadySpace.screenMargin,
            0,
            SteadySpace.screenMargin,
            SteadySpace.s6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Fewer payments, same result', style: SteadyType.title),
              const SizedBox(height: SteadySpace.s2),
              Text(
                'Steady adds up what each person paid and what their share '
                'was, then finds the fewest payments that square everyone. '
                'Someone may pay a person they never split with directly. '
                "That's fine: everyone gives or gets exactly the same total.",
                style: SteadyType.body.copyWith(color: c.muted),
              ),
              list('Every IOU (${iou.length})', iou),
              list('Simplified (${simplified.length})', simplified),
              const SizedBox(height: SteadySpace.s3),
              Text(
                'Prefer to see every IOU? Turn off "Simplify debts" in Edit.',
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.muted,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ─── Add a shared expense ──────────────────────────────────────────────────

class GroupExpenseScreen extends StatefulWidget {
  const GroupExpenseScreen({super.key, required this.groupId});
  final String groupId;

  @override
  State<GroupExpenseScreen> createState() => _GroupExpenseScreenState();
}

class _GroupExpenseScreenState extends State<GroupExpenseScreen> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _exact = <String, TextEditingController>{};
  String _paidBy = youId;
  Set<String>? _between;
  SplitMethod? _method;
  String? _categoryId;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    for (final e in _exact.values) {
      e.dispose();
    }
    super.dispose();
  }

  TextEditingController _exactFor(String id) =>
      _exact.putIfAbsent(id, TextEditingController.new);

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final book = store.splits;
    final group = book.group(widget.groupId);
    if (group == null) {
      return const SteadyPage(
        title: 'Add expense',
        children: [Text('Not found.')],
      );
    }
    final everyone = group.everyone;
    final between = _between ??= everyone.toSet();
    final method = _method ??= group.method;
    final amount = parseCents(_amount.text) ?? 0;
    final participants = [
      for (final id in everyone)
        if (between.contains(id)) id,
    ];

    Map<String, int>? shares;
    String? problem;
    if (amount > 0 && participants.isNotEmpty) {
      if (method == SplitMethod.exact) {
        final exact = {
          for (final id in participants)
            id: parseCents(_exactFor(id).text) ?? 0,
        };
        final left = amount - exact.values.fold<int>(0, (a, b) => a + b);
        if (left != 0) {
          problem = left > 0
              ? '${_m(store, left)} left to assign'
              : '${_m(store, -left)} too much';
        } else {
          shares = splitShares(
            amountCents: amount,
            participants: participants,
            paidBy: _paidBy,
            method: method,
            exact: exact,
          );
        }
      } else {
        shares = splitShares(
          amountCents: amount,
          participants: participants,
          paidBy: _paidBy,
          method: method,
          weights: group.weights,
        );
      }
    }
    final name = _name.text.trim();
    final ready = shares != null && name.isNotEmpty;
    final othersOwe = shares == null || _paidBy != youId
        ? 0
        : amount - (shares[youId] ?? 0);

    void save() {
      store.addGroupExpense(
        groupId: group.id,
        name: name,
        amountCents: amount,
        date: store.today,
        paidBy: _paidBy,
        shares: shares!,
        categoryId: _paidBy == youId ? _categoryId : null,
      );
      Navigator.of(context).pop();
    }

    return SteadyPage(
      title: 'Add expense',
      subtitle: group.name,
      leading: PageLeading.close,
      gap: 16,
      bottom: SteadyButton('Save', onPressed: ready ? save : null),
      children: [
        SteadyField(
          label: 'What for',
          controller: _name,
          hint: 'e.g. Dinner, Internet',
          onChanged: (_) => setState(() {}),
        ),
        SteadyField(
          label: 'Amount',
          amount: true,
          controller: _amount,
          hint: '${store.symbol}0.00',
          onChanged: (_) => setState(() {}),
        ),
        ChipGroup<String>(
          label: 'Paid by',
          options: everyone,
          selected: _paidBy,
          labelOf: book.nameOf,
          onSelected: (id) => setState(() => _paidBy = id),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldLabel('Split between'),
            const SizedBox(height: SteadySpace.s2),
            Wrap(
              spacing: SteadySpace.s2,
              runSpacing: 0, // chips carry their own touch padding
              children: [
                for (final id in everyone)
                  SteadyChip(
                    label: book.nameOf(id),
                    selected: between.contains(id),
                    onTap: () => setState(() {
                      if (!between.remove(id)) between.add(id);
                    }),
                  ),
              ],
            ),
          ],
        ),
        Segmented<SplitMethod>(
          options: [
            SplitMethod.equal,
            if (group.weights.isNotEmpty) SplitMethod.byIncome,
            SplitMethod.exact,
          ],
          selected: method,
          labelOf: (m) => switch (m) {
            SplitMethod.equal => 'Equally',
            SplitMethod.byIncome => 'By income',
            SplitMethod.exact => 'Exact',
          },
          onSelected: (m) => setState(() => _method = m),
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final id in participants)
                method == SplitMethod.exact
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: SteadySpace.s2),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                book.nameOf(id),
                                style: SteadyType.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: SteadyField(
                                label: '${book.nameOf(id)} amount',
                                hideLabel: true,
                                amount: true,
                                controller: _exactFor(id),
                                hint: '${store.symbol}0.00',
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ValueRow(
                        label: book.nameOf(id),
                        value: shares == null ? '—' : _m(store, shares[id]!),
                        muted: false,
                      ),
              if (participants.isEmpty)
                Text(
                  'Pick who it\'s split between.',
                  style: SteadyType.body.copyWith(color: c.muted),
                ),
              if (problem != null)
                Text(
                  problem,
                  style: SteadyType.caption.copyWith(color: c.warningFg),
                ),
            ],
          ),
        ),
        if (_paidBy == youId) ...[
          ChipGroup<String>(
            label: 'Category (for your spending)',
            options: [
              for (final cat in store.categories)
                if (cat.id != 'bills') cat.id,
            ],
            selected: _categoryId,
            labelOf: (id) => store.categoryById(id)?.name ?? id,
            onSelected: (id) =>
                setState(() => _categoryId = _categoryId == id ? null : id),
          ),
          if (amount > 0)
            SoftBanner(
              icon: Icons.info_outline_rounded,
              child: Text(
                othersOwe > 0
                    ? 'The full ${_m(store, amount)} counts as your spending '
                          'today. The ${_m(store, othersOwe)} others owe comes '
                          'back when they settle up.'
                    : 'The full ${_m(store, amount)} counts as your '
                          'spending today.',
              ),
            ),
        ],
      ],
    );
  }
}

// ─── H3 Settle up with a person ────────────────────────────────────────────

class SettleUpScreen extends StatefulWidget {
  const SettleUpScreen({super.key, required this.personId});
  final String personId;

  @override
  State<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends State<SettleUpScreen> {
  bool _logMoney = true;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final book = store.splits;
    final person = book.person(widget.personId);
    if (person == null) {
      return const SteadyPage(
        title: 'Settle up',
        children: [Text('Not found.')],
      );
    }
    final balance = store.splitBalances
        .where((b) => b.personId == person.id)
        .firstOrNull;
    final net = balance?.net ?? 0;
    final owesYou = net > 0;
    final snoozed =
        person.remindSnoozedUntil != null &&
        person.remindSnoozedUntil!.isAfter(store.today);

    Future<void> settle() async {
      final ok = await confirmSheet(
        context,
        title: 'Settle up with ${person.name}?',
        body: net == 0
            ? 'Clears what you owe each other in every group.'
            : owesYou
            ? '${person.name} paid you ${_m(store, net)}. Clears it in every '
                  'group.'
            : 'You paid ${person.name} ${_m(store, -net)}. Clears it in every '
                  'group.',
        confirmLabel: 'Record as settled',
      );
      if (!ok || !context.mounted) return;
      store.settleUpWith(person.id, logMoney: _logMoney);
      Navigator.of(context).pop();
    }

    Future<void> nudge() async {
      final groups = {
        for (final t in balance!.transfers)
          if (t.toId == youId) book.group(t.groupId!)?.name,
      }.whereType<String>().join(' and ');
      try {
        await SharePlus.instance.share(
          ShareParams(
            text:
                'Hi ${person.name}! Quick reminder about '
                '${_m(store, balance.owesYou)} for $groups 🙂',
          ),
        );
      } catch (e) {
        debugPrint('Steady: share failed: $e');
      }
    }

    return SteadyPage(
      title: 'Settle up',
      subtitle: person.name,
      gap: 16,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (owesYou && balance!.owesYou > 0) ...[
            SteadyButton(
              'Send ${person.name} a nudge',
              icon: Icons.ios_share_rounded,
              kind: ButtonKind.secondary,
              onPressed: nudge,
            ),
            const SizedBox(height: 10),
          ],
          SteadyButton(
            'Record as settled',
            onPressed: balance == null ? null : settle,
          ),
        ],
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(SteadySpace.s5),
          decoration: BoxDecoration(
            color: c.primarySoft,
            borderRadius: BorderRadius.circular(SteadyRadius.lg),
          ),
          child: Column(
            children: [
              Text(
                balance == null
                    ? 'All square with ${person.name}'
                    : owesYou
                    ? '${person.name} owes you'
                    : net < 0
                    ? 'You owe ${person.name}'
                    : 'You\'re even overall',
                style: SteadyType.body.copyWith(color: c.muted),
              ),
              if (balance != null)
                Text(
                  _m(store, net.abs()),
                  style: SteadyType.title.copyWith(fontSize: 40),
                ),
            ],
          ),
        ),
        if (balance != null)
          GroupedList(
            children: [
              for (final t in balance.transfers)
                ValueRow(
                  label: book.group(t.groupId!)?.name ?? '',
                  labelWidget: NameMeta(
                    name: book.group(t.groupId!)?.name ?? '',
                    meta: _transferLabel(book, t),
                  ),
                  value: _m(store, t.amountCents),
                  valueColor: t.toId == youId ? c.positive : null,
                ),
            ],
          ),
        if (balance != null)
          GroupedList(
            padding: const EdgeInsets.symmetric(horizontal: SteadySpace.s4),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SwitchRow(
                  title: 'Log it in my money',
                  subtitle: owesYou
                      ? 'Adds ${_m(store, net)} to today\'s money'
                      : 'Counts ${_m(store, net.abs())} as spent today',
                  value: _logMoney,
                  onChanged: (v) => setState(() => _logMoney = v),
                ),
              ),
            ],
          ),
        GroupedList(
          padding: const EdgeInsets.symmetric(horizontal: SteadySpace.s4),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SwitchRow(
                title: 'Reminders about ${person.name}',
                subtitle: snoozed
                    ? 'Snoozed until ${formatShortDay(person.remindSnoozedUntil!)}'
                    : 'When money is owed for a week',
                value: !person.remindMuted,
                onChanged: (on) =>
                    store.updateSplitPerson(person.copyWith(remindMuted: !on)),
              ),
            ),
          ],
        ),
        if (!person.remindMuted)
          Center(
            child: LinkText(
              snoozed ? 'Stop snoozing' : 'Snooze reminders for a week',
              onTap: () => store.updateSplitPerson(
                person.copyWith(
                  remindSnoozedUntil: () =>
                      snoozed ? null : store.today.addDays(7),
                ),
              ),
            ),
          ),
        Text(
          'Steady doesn\'t move money. Pay each other however you like, then '
          'record it here.',
          textAlign: TextAlign.center,
          style: SteadyType.caption.copyWith(color: c.muted),
        ),
      ],
    );
  }
}

/// For tests and the gallery: the first person with money outstanding.
String? firstSplitPerson(BudgetStore store) =>
    store.splitBalances.firstOrNull?.personId ??
    store.splits.people.firstOrNull?.id;
