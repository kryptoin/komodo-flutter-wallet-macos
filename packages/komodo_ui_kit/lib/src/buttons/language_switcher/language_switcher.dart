import 'package:flutter/material.dart';
import 'package:komodo_ui_kit/src/buttons/language_switcher/language_line.dart';
import 'package:komodo_ui_kit/src/buttons/language_switcher/ui_action_button.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({
    required this.currentLocale,
    required this.languageCodes,
    required this.flags,
    super.key,
  });
  final String currentLocale;
  final List<String> languageCodes;
  final Map<String, Widget>? flags;

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      child: LanguageLine(
        currentLocale: currentLocale,
        showChevron: true,
        flag: flags?[currentLocale],
      ),
      onTap: (Offset position, Size size) {
        showMenu(
          context: context,
          elevation: 0,
          color: Theme.of(context).colorScheme.tertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          position: RelativeRect.fromLTRB(
            position.dx - 12,
            45,
            (position.dx - 12) + size.width,
            45 + size.height,
          ),
          items: _getLocaleItems(),
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _getLocaleItems() {
    return languageCodes
        .map(
          (e) => PopupMenuItem<String>(
            value: e,
            child: LanguageLine(currentLocale: e, flag: flags?[e]),
          ),
        )
        .toList();
  }
}
