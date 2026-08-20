import 'dart:io';

import 'package:examtree/core/theme/app_theme.dart';
import 'package:examtree/features/auth/presentation/widgets/auth_entry_view.dart';
import 'package:examtree/features/promotions/domain/promotion_campaign.dart';
import 'package:examtree/features/promotions/presentation/widgets/promotion_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var fontsLoaded = false;
  const phoneSize = Size(390, 844);

  Future<void> loadFont(String family, String path) async {
    final bytes = await File(path).readAsBytes();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  }

  Future<void> loadFonts() async {
    if (fontsLoaded) return;
    await loadFont(
      'Roboto',
      'test/features/auth/presentation/previews/Roboto-Regular.ttf',
    );
    await loadFont(
      'MaterialIcons',
      'test/features/auth/presentation/previews/MaterialIcons-Regular.otf',
    );
    fontsLoaded = true;
  }

  ThemeData previewTheme() {
    final base = AppTheme.lightTheme;
    final text = base.textTheme.apply(fontFamily: 'Roboto');
    return base.copyWith(
      textTheme: text,
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Future<void> configurePhone(WidgetTester tester) async {
    await tester.runAsync(loadFonts);
    tester.view
      ..physicalSize = phoneSize
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget preview({required bool registering}) {
    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    final confirmation = TextEditingController();
    addTearDown(name.dispose);
    addTearDown(email.dispose);
    addTearDown(password.dispose);
    addTearDown(confirmation.dispose);

    const campaign = PromotionCampaign(
      id: 'preview-current-affairs',
      title: 'Free current affairs',
      subtitle: 'Daily updates, quizzes and monthly revision material in one place.',
      placements: {PromotionPlacement.login},
      ctaLabel: 'Explore free material',
      deepLink: '/learn',
      priority: 10,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: previewTheme(),
      home: MediaQuery(
        data: const MediaQueryData(
          size: phoneSize,
          devicePixelRatio: 1,
          disableAnimations: true,
        ),
        child: AuthEntryView(
          registering: registering,
          isLoading: false,
          obscurePassword: true,
          loadingMessage: null,
          nameController: name,
          emailController: email,
          passwordController: password,
          confirmPasswordController: confirmation,
          onGoogle: () {},
          onSubmit: () {},
          onTogglePassword: () {},
          onForgotPassword: () {},
          onToggleMode: () {},
          promotionalContent: const PromotionCarousel(
            campaigns: [campaign],
            compact: true,
          ),
        ),
      ),
    );
  }

  testWidgets('render modern Login phone preview', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(preview(registering: false));
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/login_modern_390x844.png'),
    );
  });

  testWidgets('render modern registration phone preview', (tester) async {
    await configurePhone(tester);
    await tester.pumpWidget(preview(registering: true));
    await tester.pump(const Duration(milliseconds: 250));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('previews/register_modern_390x844.png'),
    );
  });
}
