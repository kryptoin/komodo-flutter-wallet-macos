import 'package:flutter/material.dart';

class SettingsContentWrapper extends StatelessWidget {
  const SettingsContentWrapper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.0),
          color: Theme.of(context).cardColor,
        ),
        child: child,
      ),
    );
  }
}
