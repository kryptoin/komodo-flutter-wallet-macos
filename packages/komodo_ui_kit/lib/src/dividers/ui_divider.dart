import 'package:flutter/material.dart';

class UiDivider extends StatelessWidget {
  const UiDivider({super.key, this.text});
  final String? text;

  @override
  Widget build(BuildContext context) {
    final text = this.text;
    return Row(
      children: [
        const Expanded(child: Divider()),
        if (text != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
