import 'package:flutter/material.dart';

class UiGradientIcon extends StatelessWidget {
  const UiGradientIcon({
    Key? key,
    required this.icon,
    this.size = 24,
    this.color,
  }) : super(key: key);

  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('return-button'),
      width: size,
      height: size,
      child: Icon(
        icon,
        size: size,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
