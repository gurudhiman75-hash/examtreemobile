import 'package:examtree/core/network/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('API device label reflects the actual Flutter target platform', () {
    expect(examtreeDeviceLabel(TargetPlatform.android), 'android');
    expect(examtreeDeviceLabel(TargetPlatform.iOS), 'ios');
    expect(examtreeDeviceLabel(TargetPlatform.macOS), 'macos');
    expect(examtreeDeviceLabel(TargetPlatform.windows), 'windows');
    expect(examtreeDeviceLabel(TargetPlatform.linux), 'linux');
    expect(examtreeDeviceLabel(TargetPlatform.fuchsia), 'fuchsia');
  });
}
