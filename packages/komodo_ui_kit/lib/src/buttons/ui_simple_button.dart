import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class UiSimpleButton extends StatelessWidget {
  const UiSimpleButton({
    required this.child,
    this.disabled = false,
    this.onPressed,
    this.borderRadius = 8,
    super.key,
  });

  final Widget child;
  final bool disabled;
  final double borderRadius;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: disabled ? null : onPressed,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
          decoration: BoxDecoration(
            color: disabled
                ? Colors.transparent
                : theme.custom.simpleButtonBackgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}
