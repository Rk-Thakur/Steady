import 'package:flutter/material.dart';

import '../../core/date_format.dart';
import '../../core/money.dart';
import '../../data/store_scope.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../widgets/kit.dart';

/// V4 Edit entry. Saving or deleting recalculates the daily number.
class EditEntryScreen extends StatefulWidget {
  const EditEntryScreen({super.key, required this.entryId});
  final String entryId;

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  TextEditingController? _amount;
  TextEditingController? _where;
  TextEditingController? _note;
  String? _categoryId;
  Mood? _mood;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_amount != null) return;
    final e = StoreScope.of(context).entryById(widget.entryId);
    _amount = TextEditingController(
      text: e == null
          ? ''
          : centsToField(e.amountCents, symbol: MoneySymbol.read(context)),
    );
    _where = TextEditingController(text: e?.merchant ?? '');
    _note = TextEditingController(text: e?.note ?? '');
    _categoryId = e?.categoryId;
    _mood = e?.mood;
  }

  @override
  void dispose() {
    _amount?.dispose();
    _where?.dispose();
    _note?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final entry = store.entryById(widget.entryId);
    if (entry == null) {
      return const SteadyPage(
        title: 'Edit entry',
        children: [Text('This entry no longer exists.')],
      );
    }
    final cents = parseCents(_amount!.text);
    final local = entry.createdAtUtc.toLocal();
    final dateLabel =
        '${formatShortDate(entry.localDate)}, ${formatTime(local)}';
    final categories = store.categories
        .where((c) => c.id != 'bills' || entry.categoryId == 'bills')
        .toList();

    void save() {
      final merchant = _where!.text.trim();
      final note = _note!.text.trim();
      store.updateEntry(
        Entry(
          id: entry.id,
          type: entry.type,
          amountCents: cents!,
          localDate: entry.localDate,
          createdAtUtc: entry.createdAtUtc,
          timeZoneId: entry.timeZoneId,
          merchant: merchant.isEmpty ? null : merchant,
          categoryId: _categoryId,
          mood: _mood,
          planned: entry.planned,
          note: note.isEmpty ? null : note,
          splitId: entry.splitId,
          toVault: entry.toVault,
        ),
      );
      Navigator.of(context).pop();
    }

    Future<void> delete() async {
      final name = entry.merchant ?? 'This entry';
      final ok = await confirmSheet(
        context,
        title: 'Delete this entry?',
        body:
            '$name, ${formatMoney(entry.amountCents, symbol: store.symbol)}. '
            'Your daily number will be recalculated.',
        confirmLabel: 'Delete',
      );
      if (!ok || !context.mounted) return;
      store.removeEntry(entry.id);
      Navigator.of(context).pop();
    }

    return SteadyPage(
      title: 'Edit entry',
      gap: 14,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SteadyButton(
            'Save changes',
            onPressed: cents == null || cents <= 0 ? null : save,
          ),
          const SizedBox(height: 6),
          SteadyButton(
            'Delete entry',
            kind: ButtonKind.dangerLink,
            height: 48,
            onPressed: delete,
          ),
        ],
      ),
      children: [
        SteadyField(
          label: 'Amount',
          amount: true,
          controller: _amount,
          onChanged: (_) => setState(() {}),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SteadyField(
                label: entry.isIncome ? 'From' : 'Where',
                controller: _where,
              ),
            ),
            const SizedBox(width: SteadySpace.s3),
            Expanded(
              child: SteadyField(
                label: 'Date',
                initialValue: dateLabel,
                readOnly: true,
              ),
            ),
          ],
        ),
        if (entry.isSpend) ...[
          ChipGroup<String>(
            label: 'Category',
            options: [for (final c in categories) c.id],
            selected: _categoryId,
            labelOf: (id) => store.categoryById(id)?.name ?? id,
            onSelected: (id) => setState(() => _categoryId = id),
          ),
          ChipGroup<Mood>(
            label: 'Mood',
            options: Mood.values,
            selected: _mood,
            labelOf: (m) => m.label,
            onSelected: (m) => setState(() => _mood = _mood == m ? null : m),
          ),
        ],
        SteadyField(label: 'Note', controller: _note, hint: 'Optional'),
      ],
    );
  }
}
