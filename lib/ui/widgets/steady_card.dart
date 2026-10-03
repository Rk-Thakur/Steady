import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import 'kit.dart';

/// White card with a hairline border (radius-lg, padding 16).
class SteadyCard extends StatelessWidget {
  const SteadyCard({
    super.key,
    required this.child,
    this.padding = SteadySpace.s4,
  });

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(SteadyRadius.lg),
      ),
      child: child,
    );
  }
}

/// "Before next payday ........ See all"
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: SteadyType.heading)),
        if (actionLabel != null) LinkText(actionLabel!, onTap: onAction),
      ],
    );
  }
}
