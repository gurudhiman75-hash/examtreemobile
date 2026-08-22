import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/profile/presentation/account_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpAccount(
    WidgetTester tester, {
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              textScaler: TextScaler.linear(textScale),
              disableAnimations: true,
            ),
            child: const AccountSettingsScreen(),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('account settings presents privacy before deletion', (tester) async {
    await pumpAccount(tester);

    expect(find.byKey(const Key('account-privacy-hero')), findsOneWidget);
    expect(find.text('Your learner data'), findsOneWidget);
    expect(find.text('Learning activity'), findsOneWidget);
    expect(find.text('Privacy policy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('account settings remains usable at 200 percent text scaling', (
    tester,
  ) async {
    await pumpAccount(tester, textScale: 2);

    expect(tester.takeException(), isNull);
    final scrollable = find.byKey(const Key('account-settings-scroll'));

    // Drive the lazy ListView through its full lower content instead of
    // assuming a fixed number of drags is enough at large text sizes.
    for (var index = 0; index < 12; index++) {
      await tester.drag(scrollable, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    expect(find.byKey(const Key('account-danger-zone')), findsOneWidget);
    expect(find.byKey(const Key('account-delete-start')), findsOneWidget);
    expect(find.text('Delete account'), findsWidgets);
  });
}
