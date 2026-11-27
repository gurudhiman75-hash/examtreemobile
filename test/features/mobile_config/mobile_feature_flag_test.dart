import 'package:examtree/features/mobile_config/domain/mobile_app_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unset flags use their default, set flags win', () {
    const base = MobileAppConfiguration.fallback;
    expect(base.isEnabled('series_test_type_tabs', defaultValue: true), isTrue);
    expect(base.isEnabled('unreleased_module'), isFalse);
  });
}
