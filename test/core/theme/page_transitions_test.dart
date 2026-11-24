import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:examtree/core/theme/app_theme.dart';

void main() {
  test('Android uses the fade-forwards transition and iOS keeps Cupertino', () {
    final builders = AppTheme.lightTheme.pageTransitionsTheme.builders;
    expect(
      builders[TargetPlatform.android],
      isA<FadeForwardsPageTransitionsBuilder>(),
    );
    expect(
      builders[TargetPlatform.iOS],
      isA<CupertinoPageTransitionsBuilder>(),
    );
  });
}
