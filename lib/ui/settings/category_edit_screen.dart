import 'package:flutter/material.dart';

import '../../data/store_scope.dart';
import '../../domain/models/models.dart';
import '../../theme/tokens.dart';
import '../widgets/kit.dart';

/// N4 Edit category (or New category when [categoryId] is null).
class CategoryEditScreen extends StatefulWidget {
  const CategoryEditScreen({super.key, this.categoryId});
  final String? categoryId;

  @override
  State<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends State<CategoryEditScreen> {
  late final TextEditingController _name;
  late final TextEditingController _limit;
  CategoryTone _tone = CategoryTone.primary;
  bool _limitOn = false;
  BudgetCategory? _existing;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    _existing = widget.categoryId == null
        ? null
        : StoreScope.of(context).categoryById(widget.categoryId);
    _name = TextEditingController(text: _existing?.name ?? '');
    _limit = TextEditingController(
      text: _existing?.monthlyLimitCents == null
          ? ''
          : centsToField(
              _existing!.monthlyLimitCents!,
              symbol: MoneySymbol.read(context),
            ),
    );
    _tone = _existing?.tone ?? CategoryTone.primary;
    _limitOn = _existing?.monthlyLimitCents != null;
  }

  @override
  void dispose() {
    _name.dispose();
    _limit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final c = context.colors;
    final swatches = {
      CategoryTone.primary: c.primary == c.highlight ? c.positive : c.primary,
      CategoryTone.warning: c.warningFg,
      CategoryTone.info: c.infoFg,
      CategoryTone.danger: c.dangerFg,
      CategoryTone.neutral: c.ink,
    };
    final name = _name.text.trim();

    void save() {
      final limit = parseCents(_limit.text);
      store.upsertCategory(
        BudgetCategory(
          id: _existing?.id ?? store.newId('cat'),
          name: name,
          tone: _tone,
          monthlyLimitCents: _limitOn && limit != null && limit > 0
              ? limit
              : null,
        ),
      );
      Navigator.of(context).pop();
    }

    Future<void> delete() async {
      final ok = await confirmSheet(
        context,
        title: 'Delete ${_existing!.name}?',
        body: 'Entries in this category keep their amounts but lose the category.',
        confirmLabel: 'Delete category',
      );
      if (!ok || !context.mounted) return;
      store.removeCategory(_existing!.id);
      Navigator.of(context).pop();
    }

    return SteadyPage(
      title: _existing == null ? 'New category' : 'Edit category',
      gap: 18,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SteadyButton('Save', onPressed: name.isEmpty ? null : save),
          if (_existing != null) ...[
            const SizedBox(height: SteadySpace.s2),
            SteadyButton(
              'Delete category',
              kind: ButtonKind.dangerLink,
              height: 48,
              onPressed: delete,
            ),
          ],
        ],
      ),
      children: [
        SteadyField(
          label: 'Name',
          controller: _name,
          hint: 'e.g. Pets',
          onChanged: (_) => setState(() {}),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldLabel('Color'),
            const SizedBox(height: SteadySpace.s2),
            Row(
              children: [
                for (final entry in swatches.entries) ...[
                  Semantics(
                    button: true,
                    selected: entry.key == _tone,
                    label: 'Color ${entry.key.index + 1}',
                    child: GestureDetector(
                      onTap: () => setState(() => _tone = entry.key),
                      child: Container(
                        width: SteadySize.minTouchTarget,
                        height: SteadySize.minTouchTarget,
                        decoration: BoxDecoration(
                          color: entry.value,
                          shape: BoxShape.circle,
                          border: entry.key == _tone
                              ? Border.all(color: c.surface, width: 3)
                              : null,
                          boxShadow: entry.key == _tone
                              ? [BoxShadow(color: entry.value, spreadRadius: 2)]
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: SteadySpace.s3),
                ],
              ],
            ),
          ],
        ),
        Panel(
          padding: const EdgeInsets.symmetric(
            horizontal: SteadySpace.s4,
            vertical: 14,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchRow(
                title: 'Monthly limit',
                subtitle:
                    'A warning when you log a spend that gets close (80%) '
                    'or goes over. It doesn\'t change your daily number.',
                value: _limitOn,
                onChanged: (v) => setState(() => _limitOn = v),
              ),
              if (_limitOn) ...[
                const SizedBox(height: SteadySpace.s3),
                SteadyField(
                  label: 'Limit',
                  controller: _limit,
                  emphasis: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  hint: '${store.symbol}0.00',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
