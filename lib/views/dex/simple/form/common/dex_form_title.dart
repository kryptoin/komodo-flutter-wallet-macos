import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class DexFormTitle extends StatelessWidget {
  const DexFormTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: dexPageColors.activeText,
      letterSpacing: 4,
    );

    return Text(title, style: titleStyle);
  }
}
