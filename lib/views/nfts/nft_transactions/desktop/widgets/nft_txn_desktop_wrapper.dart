import 'package:flutter/material.dart';

class NftTxnDesktopWrapper extends StatelessWidget {
  const NftTxnDesktopWrapper({
    super.key,
    required this.firstChild,
    required this.secondChild,
    required this.thirdChild,
    required this.fourthChild,
    required this.fifthChild,
  });
  final Widget firstChild;
  final Widget secondChild;
  final Widget thirdChild;
  final Widget fourthChild;
  final Widget fifthChild;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 5, child: firstChild),
          const SizedBox(width: 16),
          Expanded(flex: 6, child: secondChild),
          const SizedBox(width: 16),
          Expanded(flex: 16, child: thirdChild),
          const SizedBox(width: 16),
          Expanded(flex: 5, child: fourthChild),
          const SizedBox(width: 16),
          Expanded(flex: 11, child: fifthChild),
        ],
      ),
    );
  }
}
