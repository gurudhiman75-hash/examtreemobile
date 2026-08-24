import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const iconDirectory = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
  const expectedDimensions = <String, (int, int)>{
    'Icon-App-20x20@1x.png': (20, 20),
    'Icon-App-20x20@2x.png': (40, 40),
    'Icon-App-20x20@3x.png': (60, 60),
    'Icon-App-29x29@1x.png': (29, 29),
    'Icon-App-29x29@2x.png': (58, 58),
    'Icon-App-29x29@3x.png': (87, 87),
    'Icon-App-40x40@1x.png': (40, 40),
    'Icon-App-40x40@2x.png': (80, 80),
    'Icon-App-40x40@3x.png': (120, 120),
    'Icon-App-60x60@2x.png': (120, 120),
    'Icon-App-60x60@3x.png': (180, 180),
    'Icon-App-76x76@1x.png': (76, 76),
    'Icon-App-76x76@2x.png': (152, 152),
    'Icon-App-83.5x83.5@2x.png': (167, 167),
    'Icon-App-1024x1024@1x.png': (1024, 1024),
  };

  test('iOS AppIcon set is complete, correctly sized and opaque', () {
    final contents = jsonDecode(
      File('$iconDirectory/Contents.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final images = contents['images'] as List<dynamic>;
    final declaredFiles = images
        .map((entry) => (entry as Map<String, dynamic>)['filename'])
        .whereType<String>()
        .toSet();

    expect(declaredFiles, containsAll(expectedDimensions.keys));

    for (final entry in expectedDimensions.entries) {
      final file = File('$iconDirectory/${entry.key}');
      expect(file.existsSync(), isTrue, reason: '${entry.key} is missing');

      final png = file.readAsBytesSync();
      expect(
        png.sublist(0, 8),
        equals(const <int>[137, 80, 78, 71, 13, 10, 26, 10]),
        reason: '${entry.key} must be a PNG',
      );

      final data = ByteData.sublistView(Uint8List.fromList(png));
      expect(data.getUint32(16), entry.value.$1, reason: '${entry.key} width');
      expect(data.getUint32(20), entry.value.$2, reason: '${entry.key} height');
      expect(
        png[25],
        equals(2),
        reason: '${entry.key} must be opaque RGB without an alpha channel',
      );
    }
  });

  test('App Store source is a reusable opaque 1024px ExamTree icon', () {
    final file = File('docs/store-assets/examtree-app-store-icon-1024.png');
    expect(file.existsSync(), isTrue);

    final png = file.readAsBytesSync();
    final data = ByteData.sublistView(Uint8List.fromList(png));
    expect(data.getUint32(16), 1024);
    expect(data.getUint32(20), 1024);
    expect(png[25], equals(2));
  });
}
