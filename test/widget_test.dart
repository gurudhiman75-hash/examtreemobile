import 'package:examtree/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PrimaryButton invokes its action', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            text: 'Continue Test',
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Continue Test'), findsOneWidget);
    await tester.tap(find.text('Continue Test'));
    await tester.pump();

    expect(pressed, isTrue);
  });

  testWidgets('PrimaryButton disables interaction while loading', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            text: 'Continue Test',
            isLoading: true,
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(pressed, isFalse);
  });
}
