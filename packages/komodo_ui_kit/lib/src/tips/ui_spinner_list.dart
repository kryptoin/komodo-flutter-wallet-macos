import 'package:flutter/material.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';

class UiSpinnerList extends StatelessWidget {
  const UiSpinnerList({super.key, this.height = 100});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height),
      child: const Center(child: UiSpinner()),
    );
  }
}
