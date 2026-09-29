import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';

void main() {
  Widget buildField({String? labelText, String? hintText}) {
    return MaterialApp(
      home: Scaffold(
        body: UiTextFormField(labelText: labelText, hintText: hintText),
      ),
    );
  }

  testWidgets(
    'hint-only field does not render a duplicate floating label',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildField(hintText: 'Wallet password'));
      await tester.pumpAndSettle();

      // The hint text appears exactly once (inside the field).
      expect(find.text('Wallet password'), findsOneWidget);
    },
  );

  testWidgets(
    'explicit labelText renders the floating label',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildField(labelText: 'Gas Price (Gwei)', hintText: 'e.g. 20'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gas Price (Gwei)'), findsOneWidget);
      expect(find.text('e.g. 20'), findsOneWidget);
    },
  );
}
