import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/tokens.dart';

/// Shared building blocks for every Steady screen (Handoff 2 · Components).

// ─── Page scaffolding ──────────────────────────────────────────────────────

/// A standard screen: optional back/close button + title row, scrolling body,
/// and an optional [bottom] area pinned below the content (the design's
/// "margin-top: auto" button stacks).
class SteadyPage extends StatelessWidget {
  const SteadyPage({
    super.key,
    this.title,
    this.subtitle,
    this.leading = PageLeading.back,
    this.trailing,
    required this.children,
    this.bottom,
    this.gap = SteadySpace.s4,
    this.background,
    this.header,
  });

  final String? title;
  final String? subtitle;
  final PageLeading leading;
  final Widget? trailing;

  /// Replaces the title row entirely (e.g. onboarding step bars).
  final Widget? header;
  final List<Widget> children;
  final Widget? bottom;
  final double gap;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final headerRow =
        header ??
        (title == null && leading == PageLeading.none
            ? null
            : PageHeader(
                title: title,
                subtitle: subtitle,
                leading: leading,
                trailing: trailing,
              ));
    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          Expanded(
            child: StatusBarScrim(
              color: background,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  SteadySpace.screenMargin,
                  pad.top + SteadySpace.s3,
                  SteadySpace.screenMargin,
                  bottom == null ? pad.bottom + SteadySpace.s6 : SteadySpace.s4,
                ),
                children: [
                  if (headerRow != null) ...[
                    headerRow,
                    SizedBox(height: gap + 2),
                  ],
                  ...gapped(children, gap),
                ],
              ),
            ),
          ),
          if (bottom != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                SteadySpace.screenMargin,
                0,
                SteadySpace.screenMargin,
                pad.bottom + SteadySpace.s4,
              ),
              child: bottom,
            ),
        ],
      ),
    );
  }
}

enum PageLeading { back, close, none }

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    this.title,
    this.subtitle,
    this.leading = PageLeading.back,
    this.trailing,
  });

  final String? title;
  final String? subtitle;
  final PageLeading leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final titleBlock = title == null
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title!, style: SteadyType.title.copyWith(fontSize: 24)),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: SteadyType.caption.copyWith(color: c.muted),
                ),
            ],
          );
    // Close sits on the right (Log spend / Log income); back on the left.
    if (leading == PageLeading.close) {
      return Row(
        children: [
          Expanded(child: titleBlock),
          ?trailing,
          CircleIconButton(
            icon: Icons.close_rounded,
            label: 'Close',
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ],
      );
    }
    return Row(
      children: [
        if (leading == PageLeading.back) ...[
          CircleIconButton(
            icon: Icons.chevron_left_rounded,
            label: 'Back',
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: SteadySpace.s3),
        ],
        Expanded(child: titleBlock),
        ?trailing,
      ],
    );
  }
}

/// 44px round icon button with a hairline border (Back, Close, Notifications).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.background,
    this.foreground,
    this.bordered = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? background;
  final Color? foreground;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: background ?? c.surface,
        shape: CircleBorder(
          side: bordered ? BorderSide(color: c.line) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(
            dimension: SteadySize.iconButton,
            child: Icon(icon, size: 22, color: foreground ?? c.ink),
          ),
        ),
      ),
    );
  }
}

/// Interleaves [gap]-high spacers between [children].
List<Widget> gapped(List<Widget> children, double gap) => [
  for (var i = 0; i < children.length; i++) ...[
    if (i > 0) SizedBox(height: gap),
    children[i],
  ],
];

// ─── Text ──────────────────────────────────────────────────────────────────

/// "MONEY", "TODAY" group labels.
class Overline extends StatelessWidget {
  const Overline(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: SteadySpace.s1),
    child: Text(
      text.toUpperCase(),
      style: SteadyType.overline.copyWith(color: color ?? context.colors.muted),
    ),
  );
}

/// Small grey label above a field or chip group.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: SteadyType.caption.copyWith(color: context.colors.muted),
  );
}

// ─── Buttons ───────────────────────────────────────────────────────────────

enum ButtonKind {
  primary,
  highlight,
  secondary,
  inverse,
  danger,
  link,
  dangerLink,
}

/// Pill button in every variant from Handoff 2. Max one highlight per screen.
class SteadyButton extends StatelessWidget {
  const SteadyButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.kind = ButtonKind.primary,
    this.icon,
    this.height = SteadySize.buttonLarge,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonKind kind;
  final IconData? icon;
  final double height;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg, side) = switch (kind) {
      ButtonKind.primary => (c.primary, c.onPrimary, BorderSide.none),
      ButtonKind.highlight => (c.highlight, c.onHighlight, BorderSide.none),
      ButtonKind.secondary => (
        c.surface,
        c.ink,
        BorderSide(color: c.ink, width: 1.5),
      ),
      ButtonKind.inverse => (c.inverse, c.onInverse, BorderSide.none),
      ButtonKind.danger => (c.dangerFg, c.onPrimary, BorderSide.none),
      ButtonKind.link => (Colors.transparent, c.primary, BorderSide.none),
      ButtonKind.dangerLink => (
        Colors.transparent,
        c.dangerFg,
        BorderSide.none,
      ),
    };
    final weight = kind == ButtonKind.highlight
        ? FontWeight.w800
        : FontWeight.w700;
    // Compact buttons (44 high) use a 14px label and tighter padding.
    final compact = height <= SteadySize.buttonCompact;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: SteadySpace.s2),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: SteadyType.button.copyWith(
              fontWeight: weight,
              fontSize: compact ? 14 : 15,
            ),
          ),
        ),
      ],
    );
    final button = TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor:
            kind == ButtonKind.link || kind == ButtonKind.dangerLink
            ? Colors.transparent
            : c.disabledBg,
        disabledForegroundColor: c.disabledFg,
        minimumSize: Size(SteadySize.minTouchTarget, height),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? SteadySpace.s3 : SteadySpace.s5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SteadyRadius.pill),
          side: side,
        ),
        textStyle: SteadyType.button,
      ),
      child: child,
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Two buttons side by side with a 10px gap.
class ButtonRow extends StatelessWidget {
  const ButtonRow({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) const SizedBox(width: 10),
        Expanded(child: children[i]),
      ],
    ],
  );
}

// ─── Inputs ────────────────────────────────────────────────────────────────

/// Labelled text input (52 high, radius-md). [amount] makes the 64-high
/// Bricolage amount field with a 2px primary border.
class SteadyField extends StatelessWidget {
  const SteadyField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hint,
    this.amount = false,
    this.emphasis = false,
    this.keyboardType,
    this.onChanged,
    this.prefixIcon,
    this.hideLabel = false,
    this.readOnly = false,
    this.onTap,
    this.autofocus = false,
    this.obscure = false,
  });

  /// Hidden text (passwords). Single line, so it doesn't use [expands].
  final bool obscure;

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hint;
  final bool amount;

  /// Bold value with a 2px border (selected amount-like fields).
  final bool emphasis;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final bool hideLabel;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final strong = amount || emphasis;
    final style = amount
        ? SteadyType.title.copyWith(fontSize: 30, height: 1.1, color: c.ink)
        : SteadyType.body.copyWith(
            fontSize: 16,
            color: c.ink,
            fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500,
          );
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(SteadyRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
    final field = SizedBox(
      height: amount ? 64 : SteadySize.buttonLarge,
      child: TextFormField(
        controller: controller,
        expands: !obscure,
        maxLines: obscure ? 1 : null,
        obscureText: obscure,
        autocorrect: !obscure,
        enableSuggestions: !obscure,
        initialValue: controller == null ? initialValue : null,
        keyboardType: amount
            ? const TextInputType.numberWithOptions(decimal: true)
            : keyboardType,
        inputFormatters: amount ? [MoneyInputFormatter()] : null,
        onChanged: onChanged,
        readOnly: readOnly,
        onTap: onTap,
        autofocus: autofocus,
        style: style,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: style.copyWith(
            color: c.muted,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: c.raised,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: SteadySpace.s4,
            vertical: obscure ? 15 : 0,
          ),
          prefixIcon: prefixIcon == null
              ? null
              : Icon(prefixIcon, color: c.muted, size: 20),
          border: border(c.inputBorder, 1),
          enabledBorder: strong
              ? border(c.primary, 2)
              : border(c.inputBorder, 1),
          focusedBorder: border(c.primary, 2),
        ),
      ),
    );
    if (hideLabel) return Semantics(label: label, child: field);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [FieldLabel(label), const SizedBox(height: 6), field],
    );
  }
}

/// Lets only digits and one decimal point with at most two decimals through.
class MoneyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final ok = RegExp(r'^\d{0,7}(\.\d{0,2})?$').hasMatch(cleaned);
    if (!ok) return oldValue;
    final text = cleaned.isEmpty ? '' : '\$$cleaned';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Parses "$1,234.56" / "1234.5" into cents. Returns null if empty or invalid.
int? parseCents(String text) {
  final cleaned = text.replaceAll(RegExp(r'[^0-9.]'), '');
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  if (value == null) return null;
  return (value * 100).round();
}

/// Text for an amount field from cents: 2340 → "$23.40".
String centsToField(int cents) =>
    '\$${(cents ~/ 100)}.${(cents % 100).toString().padLeft(2, '0')}';

// ─── Selection controls ────────────────────────────────────────────────────

/// 40-high pill chip. Selected: 2px primary border + soft fill (aria-pressed).
class SteadyChip extends StatelessWidget {
  const SteadyChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.height = 40,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? c.primarySoft : c.raised,
        shape: StadiumBorder(
          side: selected
              ? BorderSide(color: c.primary, width: 2)
              : BorderSide(color: c.inputBorder),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: height,
            constraints: const BoxConstraints(
              minWidth: SteadySize.minTouchTarget,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: SteadyType.body.copyWith(
                  fontSize: 14,
                  height: 1,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? c.primary : c.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Single-select wrap of [SteadyChip]s.
class ChipGroup<T> extends StatelessWidget {
  const ChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.labelOf,
    this.label,
    this.height = 40,
  });

  final List<T> options;
  final T? selected;
  final ValueChanged<T> onSelected;
  final String Function(T) labelOf;
  final String? label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final wrap = Wrap(
      spacing: SteadySpace.s2,
      runSpacing: SteadySpace.s2,
      children: [
        for (final o in options)
          SteadyChip(
            label: labelOf(o),
            selected: o == selected,
            onTap: () => onSelected(o),
            height: height,
          ),
      ],
    );
    if (label == null) return wrap;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label!),
        const SizedBox(height: SteadySpace.s2),
        wrap,
      ],
    );
  }
}

/// "+ Phone" style add chip with a dashed-look border.
class AddChip extends StatelessWidget {
  const AddChip({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.raised,
      shape: StadiumBorder(side: BorderSide(color: c.dashed)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: SteadyType.body.copyWith(
                fontSize: 14,
                height: 1,
                fontWeight: FontWeight.w700,
                color: c.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Segmented control: track 48, items 40. Selected = surface + ink text.
class Segmented<T> extends StatelessWidget {
  const Segmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.labelOf,
    this.expand = true,
    this.itemHeight = 40,
  });

  final List<T> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final String Function(T) labelOf;
  final bool expand;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget item(T o) {
      final on = o == selected;
      final child = Semantics(
        button: true,
        selected: on,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onSelected(o),
          child: AnimatedContainer(
            duration: SteadyMotion.reduced,
            height: itemHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? c.segmentSelected : Colors.transparent,
              borderRadius: BorderRadius.circular(SteadyRadius.pill),
            ),
            child: Text(
              labelOf(o),
              style: SteadyType.body.copyWith(
                fontSize: 14,
                height: 1,
                fontWeight: FontWeight.w700,
                color: on ? c.ink : c.muted,
              ),
            ),
          ),
        ),
      );
      return expand ? Expanded(child: child) : child;
    }

    return Container(
      padding: const EdgeInsets.all(SteadySpace.s1),
      decoration: BoxDecoration(
        color: c.segmentTrack,
        borderRadius: BorderRadius.circular(SteadyRadius.pill),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: SteadySpace.s1),
            item(options[i]),
          ],
        ],
      ),
    );
  }
}

/// 52×32 switch with a 26px knob (role=switch). Null [onChanged] disables
/// it (dimmed, not tappable).
class SteadySwitch extends StatelessWidget {
  const SteadySwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final onChanged = this.onChanged;
    return Semantics(
      toggled: value,
      enabled: onChanged != null,
      label: label,
      child: GestureDetector(
        onTap: onChanged == null ? null : () => onChanged(!value),
        child: Opacity(
          opacity: onChanged == null ? 0.4 : 1,
          child: AnimatedContainer(
            duration: SteadyMotion.reduced,
            width: 52,
            height: 32,
            padding: const EdgeInsets.all(3),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            decoration: BoxDecoration(
              color: value ? c.primary : c.inputBorder,
              borderRadius: BorderRadius.circular(SteadyRadius.pill),
            ),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: value && c.primary == c.highlight
                    ? c.onPrimary
                    : Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Title + subtitle on the left, [SteadySwitch] on the right.
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MergeSemantics(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SteadyType.body.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: SteadyType.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: c.muted,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: SteadySpace.s3),
          SteadySwitch(value: value, onChanged: onChanged, label: title),
        ],
      ),
    );
  }
}

/// Radio card: dot + bold title + muted subtitle. Selected = 2px primary border.
class RadioCard extends StatelessWidget {
  const RadioCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.minHeight = 76,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: Material(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SteadyRadius.lg),
          side: selected
              ? BorderSide(color: c.primary, width: 2)
              : BorderSide(color: c.line),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(SteadyRadius.lg),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Padding(
              padding: const EdgeInsets.all(SteadySpace.s4),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: SteadyMotion.reduced,
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? c.primary : c.muted,
                        width: selected ? 7 : 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: SteadyType.body.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: SteadyType.caption.copyWith(
                            fontWeight: FontWeight.w500,
                            color: c.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Surfaces ──────────────────────────────────────────────────────────────

/// White card with hairline border.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(SteadySpace.s4),
    this.radius = SteadyRadius.lg,
    this.color,
    this.borderColor,
    this.borderWidth = 1,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: borderWidth == 0
          ? BorderSide.none
          : BorderSide(color: borderColor ?? c.line, width: borderWidth),
    );
    return Material(
      color: color ?? c.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : InkWell(
              onTap: onTap,
              child: Padding(padding: padding, child: child),
            ),
    );
  }
}

/// Soft colored banner with optional leading icon (tips, warnings, info).
enum BannerTone { primary, warning, danger, info, neutral }

class SoftBanner extends StatelessWidget {
  const SoftBanner({
    super.key,
    required this.child,
    this.tone = BannerTone.primary,
    this.icon,
    this.radius = 16,
  });

  /// Usually a [Text.rich]; the default text style is applied.
  final Widget child;
  final BannerTone tone;
  final IconData? icon;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = switch (tone) {
      BannerTone.primary => (c.primarySoft, c.positive),
      BannerTone.warning => (c.warningBg, c.warningFg),
      BannerTone.danger => (c.dangerBg, c.dangerFg),
      BannerTone.info => (c.infoBg, c.infoFg),
      BannerTone.neutral => (c.segmentTrack, c.muted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: SteadySpace.s3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: DefaultTextStyle.merge(
              style: SteadyType.body.copyWith(fontSize: 14, color: c.ink),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bold lead-in + body in a [SoftBanner] ("Worth a look. Week 3 ran over…").
class LeadText extends StatelessWidget {
  const LeadText({
    super.key,
    required this.lead,
    required this.body,
    this.leadColor,
  });
  final String lead;
  final String body;
  final Color? leadColor;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: lead,
          style: TextStyle(fontWeight: FontWeight.w800, color: leadColor),
        ),
        TextSpan(text: ' $body'),
      ],
    ),
  );
}

/// Inline dark status toast with a check (role=status). Animates in and out.
class StatusToast extends StatelessWidget {
  const StatusToast({
    super.key,
    required this.message,
    this.icon = Icons.check_rounded,
  });
  final String? message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedSize(
      duration: SteadyMotion.reduced,
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Semantics(
              liveRegion: true,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: SteadySpace.s3,
                ),
                decoration: BoxDecoration(
                  color: c.inverse,
                  borderRadius: BorderRadius.circular(SteadyRadius.md),
                ),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: c.highlight),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        message!,
                        style: SteadyType.body.copyWith(
                          fontSize: 14,
                          height: 1.4,
                          color: c.onInverse,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Destructive confirmation bottom sheet. Returns true if confirmed.
Future<bool> confirmSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      final c = context.colors;
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SteadySpace.s5,
            SteadySpace.s6,
            SteadySpace.s5,
            SteadySpace.s6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: SteadyType.heading.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: SteadySpace.s3),
              Text(
                body,
                style: SteadyType.body.copyWith(fontSize: 14, color: c.muted),
              ),
              const SizedBox(height: SteadySpace.s4),
              SteadyButton(
                confirmLabel,
                kind: ButtonKind.danger,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: SteadySpace.s3),
              SteadyButton(
                'Cancel',
                kind: ButtonKind.secondary,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}

// ─── Lists ─────────────────────────────────────────────────────────────────

/// Card holding rows separated by soft dividers.
class GroupedList extends StatelessWidget {
  const GroupedList({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 14),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Panel(
      padding: padding,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(color: c.lineSoft, height: 1),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Settings-style row: icon tile, label, value, chevron (min 56 high).
class NavRow extends StatelessWidget {
  const NavRow({
    super.key,
    required this.label,
    this.value,
    this.icon,
    this.tone = BannerTone.primary,
    this.onTap,
    this.trailing,
    this.subtitle,
  });

  final String label;
  final String? value;
  final String? subtitle;
  final IconData? icon;
  final BannerTone tone;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = switch (tone) {
      BannerTone.primary => (c.primarySoft, c.positive),
      BannerTone.warning => (c.warningBg, c.warningFg),
      BannerTone.danger => (c.dangerBg, c.dangerFg),
      BannerTone.info => (c.infoBg, c.infoFg),
      BannerTone.neutral => (c.segmentTrack, c.ink),
    };
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: fg),
              ),
              const SizedBox(width: SteadySpace.s3),
            ],
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: SteadySpace.s2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: SteadyType.body.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: SteadyType.caption.copyWith(
                          fontWeight: FontWeight.w500,
                          color: c.muted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: SteadyType.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: c.muted,
                ),
              ),
            ?trailing,
            if (onTap != null && trailing == null) ...[
              const SizedBox(width: SteadySpace.s1),
              Icon(Icons.chevron_right_rounded, size: 20, color: c.muted),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Label ........ value" line used in breakdowns and receipts.
class ValueRow extends StatelessWidget {
  const ValueRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidget,
    this.valueColor,
    this.muted = true,
    this.padding = const EdgeInsets.symmetric(vertical: 11),
  });

  final String label;
  final Widget? labelWidget;
  final String value;
  final Color? valueColor;
  final bool muted;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child:
                labelWidget ??
                Text(
                  label,
                  style: SteadyType.body.copyWith(
                    fontSize: 14,
                    color: muted ? c.muted : c.ink,
                  ),
                ),
          ),
          const SizedBox(width: SteadySpace.s3),
          Text(
            value,
            style: SteadyType.body.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: valueColor ?? c.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// "**Name** · Oct 8" label used in bill and goal lists.
class NameMeta extends StatelessWidget {
  const NameMeta({super.key, required this.name, required this.meta});
  final String name;
  final String meta;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        TextSpan(
          text: ' · $meta',
          style: TextStyle(
            fontSize: 13,
            color: context.colors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
    style: SteadyType.body.copyWith(fontSize: 15),
  );
}

// ─── Small pieces ──────────────────────────────────────────────────────────

/// 40px rounded letter tile in a tone (list rows).
class LetterTile extends StatelessWidget {
  const LetterTile({
    super.key,
    required this.letter,
    required this.tone,
    this.size = 40,
    this.radius = 12,
  });
  final String letter;
  final BannerTone tone;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = switch (tone) {
      BannerTone.primary => (c.primarySoft, c.positive),
      BannerTone.warning => (c.warningBg, c.warningFg),
      BannerTone.danger => (c.dangerBg, c.dangerFg),
      BannerTone.info => (c.infoBg, c.infoFg),
      BannerTone.neutral => (c.segmentTrack, c.ink),
    };
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Text(
          letter.isEmpty ? '?' : letter.characters.first.toUpperCase(),
          style: SteadyType.body.copyWith(
            fontWeight: FontWeight.w800,
            color: fg,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Icon in a rounded tone tile (notification rows, banners).
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    required this.tone,
    this.size = 40,
    this.radius = 12,
  });
  final IconData icon;
  final BannerTone tone;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = switch (tone) {
      BannerTone.primary => (c.primarySoft, c.positive),
      BannerTone.warning => (c.warningBg, c.warningFg),
      BannerTone.danger => (c.dangerBg, c.dangerFg),
      BannerTone.info => (c.infoBg, c.infoFg),
      BannerTone.neutral => (c.segmentTrack, c.ink),
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, size: size * 0.45, color: fg),
    );
  }
}

/// Rounded horizontal bar (goal progress, vault balance, category bars).
class Bar extends StatelessWidget {
  const Bar({
    super.key,
    required this.value,
    this.height = 10,
    this.fill,
    this.track,
  });
  final double value;
  final double height;
  final Color? fill;
  final Color? track;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduce = MediaQuery.disableAnimationsOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(SteadyRadius.pill),
      child: Container(
        height: height,
        color: track ?? c.progressTrack,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: value.clamp(0.0, 1.0)),
          duration: reduce ? SteadyMotion.reduced : SteadyMotion.progress,
          curve: SteadyMotion.progressCurve,
          builder: (context, v, _) => FractionallySizedBox(
            widthFactor: v,
            heightFactor: 1,
            child: ColoredBox(color: fill ?? c.primary),
          ),
        ),
      ),
    );
  }
}

/// Small stat card: muted label over a bold value.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.note,
    this.onDark = false,
  });
  final String label;
  final String value;
  final String? note;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: onDark ? Colors.white.withValues(alpha: 0.1) : c.surface,
        border: onDark ? null : Border.all(color: c.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: SteadyType.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: onDark ? c.onHeroMuted : c.muted,
            ),
          ),
          Text(
            value,
            style: SteadyType.heading.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: onDark ? c.onHero : c.ink,
            ),
          ),
          if (note != null)
            Text(
              note!,
              style: SteadyType.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: c.positive,
              ),
            ),
        ],
      ),
    );
  }
}

/// Three onboarding step bars.
class StepBars extends StatelessWidget {
  const StepBars({super.key, required this.step, this.total = 3});
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: 'Step $step of $total',
      child: Row(
        children: [
          for (var i = 1; i <= total; i++) ...[
            if (i > 1) const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: i <= step ? c.primary : c.line,
                  borderRadius: BorderRadius.circular(SteadyRadius.pill),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pulsing skeleton block (Handoff 2: opacity .55 → 1, 1.4 s).
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
    this.color,
  });
  final double? width;
  final double height;
  final double radius;
  final Color? color;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final box = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.color ?? context.colors.skeleton,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
    );
    if (reduce) return box;
    return FadeTransition(
      opacity: Tween(
        begin: .55,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: box,
    );
  }
}

/// Two-tone split bar (planned vs unplanned, you vs partner).
class SplitBar extends StatelessWidget {
  const SplitBar({
    super.key,
    required this.fraction,
    required this.left,
    required this.right,
    this.height = 14,
  });
  final double fraction;
  final Color left;
  final Color right;
  final double height;

  @override
  Widget build(BuildContext context) {
    final l = (fraction * 1000).round().clamp(1, 999);
    return ClipRRect(
      borderRadius: BorderRadius.circular(SteadyRadius.pill),
      child: SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: l,
              child: ColoredBox(color: left),
            ),
            const SizedBox(width: 3),
            Expanded(
              flex: 1000 - l,
              child: ColoredBox(color: right),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scrolling body for a tab screen: clears the status bar and the floating
/// tab bar (Handoff 1: 100 bottom padding).
class TabBody extends StatelessWidget {
  const TabBody({super.key, required this.children, this.gap = SteadySpace.s4});
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return StatusBarScrim(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          SteadySpace.screenMargin,
          pad.top + SteadySpace.s3,
          SteadySpace.screenMargin,
          SteadySize.tabBarClearance(pad),
        ),
        children: gapped(children, gap),
      ),
    );
  }
}

/// Tab-screen title with optional subtitle and trailing action.
class TabTitle extends StatelessWidget {
  const TabTitle(this.title, {super.key, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: SteadyType.title),
            if (subtitle != null)
              Text(
                subtitle!,
                style: SteadyType.caption.copyWith(color: context.colors.muted),
              ),
          ],
        ),
      ),
      ?trailing,
    ],
  );
}

/// A full-height column that keeps [Spacer]s working on tall screens but
/// scrolls instead of overflowing on short ones (iPhone SE, large text).
class FillOrScroll extends StatelessWidget {
  const FillOrScroll({
    super.key,
    required this.padding,
    required this.children,
  });
  final EdgeInsets padding;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: box.maxHeight),
        child: IntrinsicHeight(
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Text link that sits flush with the content edge (no button padding) but
/// keeps a 44px-high touch target. Used for "See all", "Edit", "Settings".
class LinkText extends StatelessWidget {
  const LinkText(
    this.label, {
    super.key,
    required this.onTap,
    this.fontSize = 13,
  });
  final String label;
  final VoidCallback? onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: InkResponse(
      onTap: onTap,
      radius: 28,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: SteadySize.minTouchTarget,
          minWidth: SteadySize.minTouchTarget,
        ),
        child: Align(
          widthFactor: 1,
          alignment: Alignment.centerRight,
          child: Text(
            label,
            style: SteadyType.caption.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: context.colors.primary,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Keeps scrolled content from colliding with the status bar: a band of the
/// page color over the top safe area.
class StatusBarScrim extends StatelessWidget {
  const StatusBarScrim({super.key, required this.child, this.color});
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    if (top == 0) return child;
    final bg = color ?? Theme.of(context).scaffoldBackgroundColor;
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: top,
          child: IgnorePointer(
            child: ColoredBox(color: bg.withValues(alpha: .96)),
          ),
        ),
      ],
    );
  }
}
