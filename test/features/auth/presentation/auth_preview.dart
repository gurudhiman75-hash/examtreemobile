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
    final phone = TextEditingController();
    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    final confirmation = TextEditingController();
    addTearDown(phone.dispose);
    addTearDown(name.dispose);
    addTearDown(email.dispose);
    addTearDown(password.dispose);
    addTearDown(confirmation.dispose);

    const campaigns = <PromotionCampaign>[
      PromotionCampaign(
        id: 'preview-learn',
        title: 'Let’s build your exam success',
        subtitle:
            'Master concepts. Practice smarter. Get real results.',
        placements: {PromotionPlacement.login},
        priority: 30,
      ),
      PromotionCampaign(
        id: 'preview-practice',
        title: 'Practice the way real exams ask',
        subtitle:
            'Focused mock tests and detailed solutions build exam readiness.',
        placements: {PromotionPlacement.login},
        priority: 20,
      ),
      PromotionCampaign(
        id: 'preview-progress',
        title: 'Know what to revise next',
        subtitle:
            'Continue where you left off and keep revision targeted.',
        placements: {PromotionPlacement.login},
        priority: 10,
      ),
    ];

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
          phoneController: phone,
          nameController: name,
          emailController: email,
          passwordController: password,
          confirmPasswordController: confirmation,
          showApple: false,
          onPhoneContinue: () {},
          onApple: () {},
          onGoogle: () {},
          onSubmit: () {},
          onTogglePassword: () {},
          onForgotPassword: () {},
          onToggleMode: () {},
          promotionalContent: const PromotionCarousel(
            campaigns: campaigns,
            visualStyle: PromotionCarouselVisualStyle.loginFeature,
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
