import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class OrderbookTableTitle extends StatelessWidget {
  const OrderbookTableTitle(
    this.title, {
    this.suffix,
    this.titleTextSize = 11,
    this.hidden = false,
  });
  final String title;
  final String? suffix;
  final bool hidden;
  final double titleTextSize;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: titleTextSize,
      fontWeight: FontWeight.w500,
      color: dexPageColors.activeText,
    );
    final coinStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: dexPageColors.blueText,
    );

    final coin = suffix;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: titleStyle),
        if (coin != null) const SizedBox(width: 3),
        if (coin != null) Text(coin, style: coinStyle),
      ],
    );
  }
}
