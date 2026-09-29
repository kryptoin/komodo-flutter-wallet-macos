import 'package:flutter/material.dart';

class ChartTooltipContainer extends StatelessWidget {
  const ChartTooltipContainer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: IntrinsicWidth(child: child),
      ),
    );
  }
}
