import 'package:flutter/material.dart';

import '../../core/date_format.dart';
import '../../core/local_date.dart';
import '../../data/store_scope.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../routes.dart';
import '../widgets/kit.dart';

/// N5 Add a bill (or edit one when [billId] is given).
class BillEditScreen extends StatefulWidget {
  const BillEditScreen({super.key, this.billId, this.prefill});
  final String? billId;
  final BillPrefill? prefill;

  @override
  State<BillEditScreen> createState() => _BillEditScreenState();
}

class _BillEditScreenState extends State<BillEditScreen> {
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late LocalDate _due;
  Recurrence _recurrence = Recurrence.monthly;
  bool _estimate = false;
  Bill? _existing;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    final store = StoreScope.of(context);
    for (final b in store.bills) {
      if (b.id == widget.billId) _existing = b;
    }
    final pre = widget.prefill;
    _name = TextEditingController(text: _existing?.name ?? pre?.name ?? '');
    _amount = TextEditingController(
      text: _existing != null
          ? centsToField(_existing!.amountCents)
          : pre?.amountCents != null
          ? centsToField(pre!.amountCents!)
          : '',
    );
    _due = _existing?.dueDate ?? store.today.addDays(pre?.dueInDays ?? 3);
    _recurrence = _existing?.recurrence ?? Recurrence.monthly;
    _estimate = _existing?.isEstimate ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final today = StoreScope.of(context).today;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_due.year, _due.month, _due.day),
      firstDate: DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(const Duration(days: 31)),
      lastDate: DateTime(today.year + 1, today.month, today.day),
    );
    if (picked != null) setState(() => _due = LocalDate.fromDateTime(picked));
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final cents = parseCents(_amount.text);
    final name = _name.text.trim();

    void save() {
      final bill = Bill(
        id: _existing?.id ?? store.newId('bill'),
        name: name,
        amountCents: cents!,
        recurrence: _recurrence,
        dueDate: _due,
        isEstimate: _estimate,
        isSubscription:
            _existing?.isSubscription ?? widget.prefill?.subscription ?? false,
        paidOn: _existing?.paidOn,
      );
      _existing == null ? store.addBill(bill) : store.updateBill(bill);
      Navigator.of(context).pop();
    }

    return SteadyPage(
      title: _existing == null ? 'Add a bill' : 'Edit bill',
      gap: 18,
      bottom: SteadyButton(
        'Save bill',
        onPressed: name.isEmpty || cents == null || cents <= 0 ? null : save,
      ),
      children: [
        SteadyField(
          label: 'Bill name',
          controller: _name,
          hint: 'e.g. Phone',
          onChanged: (_) => setState(() {}),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SteadyField(
                label: 'Amount',
                controller: _amount,
                emphasis: true,
                hint: '${store.symbol}0.00',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: SteadySpace.s3),
            Expanded(
              child: SteadyField(
                key: ValueKey(_due),
                label: 'Next due',
                initialValue: formatShortDate(_due),
                emphasis: true,
                readOnly: true,
                onTap: _pickDue,
              ),
            ),
          ],
        ),
        ChipGroup<Recurrence>(
          label: 'Repeats',
          options: Recurrence.values,
          selected: _recurrence,
          labelOf: (r) => switch (r) {
            Recurrence.weekly => 'Weekly',
            Recurrence.everyTwoWeeks => 'Every 2 weeks',
            Recurrence.monthly => 'Monthly',
            Recurrence.yearly => 'Yearly',
          },
          onSelected: (r) => setState(() => _recurrence = r),
        ),
        Panel(
          padding: const EdgeInsets.symmetric(
            horizontal: SteadySpace.s4,
            vertical: 14,
          ),
          child: SwitchRow(
            title: 'Amount changes',
            subtitle: 'Mark as an estimate (like electric)',
            value: _estimate,
            onChanged: (v) => setState(() => _estimate = v),
          ),
        ),
      ],
    );
  }
}
