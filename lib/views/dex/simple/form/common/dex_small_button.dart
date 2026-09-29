import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class DexSmallButton extends StatelessWidget {
  const DexSmallButton(this.text, this.onTap);

  final String text;
  final Function(BuildContext)? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null ? null : () => onTap!(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: dexPageColors.smallButton,
        ),
        width: 46,
        height: 16,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: dexPageColors.smallButtonText,
            ),
          ),
        ),
      ),
    );
  }
}
