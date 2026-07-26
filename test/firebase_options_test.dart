import 'package:examtree/firebase_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultFirebaseOptions.forValues', () {
    test('requires a registered Android app ID', () {
      final configuration = DefaultFirebaseOptions.forValues(
        platform: FirebaseClientPlatform.android,
        apiKey: 'api-key',
        projectId: 'sarbedutech',
        messagingSenderId: '1083299267005',
        storageBucket: 'sarbedutech.firebasestorage.app',
        androidAppId: '',
      );

      expect(configuration.isConfigured, isFalse);
      expect(configuration.options, isNull);
      expect(configuration.missingDefines, ['FIREBASE_ANDROID_APP_ID']);
    });

    test('builds Android options from explicit values', () {
      final configuration = DefaultFirebaseOptions.forValues(
        platform: FirebaseClientPlatform.android,
        apiKey: 'api-key',
        projectId: 'sarbedutech',
        messagingSenderId: '1083299267005',
        storageBucket: 'sarbedutech.firebasestorage.app',
        androidAppId: '1:1083299267005:android:abc123',
      );

      expect(configuration.isConfigured, isTrue);
      expect(configuration.missingDefines, isEmpty);
      expect(configuration.options?.appId, '1:1083299267005:android:abc123');
      expect(configuration.options?.projectId, 'sarbedutech');
      expect(configuration.options?.messagingSenderId, '1083299267005');
    });

    test('validates common Firebase fields', () {
      final configuration = DefaultFirebaseOptions.forValues(
        platform: FirebaseClientPlatform.android,
        apiKey: '',
        projectId: '',
        messagingSenderId: '',
        storageBucket: '',
        androidAppId: 'android-app-id',
      );

      expect(
        configuration.missingDefines,
        [
          'FIREBASE_API_KEY',
          'FIREBASE_PROJECT_ID',
          'FIREBASE_MESSAGING_SENDER_ID',
          'FIREBASE_STORAGE_BUCKET',
        ],
      );
    });

    test('requires both iOS app and bundle identifiers', () {
      final configuration = DefaultFirebaseOptions.forValues(
        platform: FirebaseClientPlatform.ios,
        apiKey: 'api-key',
        projectId: 'sarbedutech',
        messagingSenderId: '1083299267005',
        storageBucket: 'sarbedutech.firebasestorage.app',
        iosAppId: '',
        iosBundleId: '',
      );

      expect(
        configuration.missingDefines,
        ['FIREBASE_IOS_APP_ID', 'FIREBASE_IOS_BUNDLE_ID'],
      );
    });
  });
}
