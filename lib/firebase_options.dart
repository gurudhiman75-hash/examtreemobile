import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCar09eV3t6KwFKwDwkKKe8auXIHmBz5Ek',
    appId: '1:1234567890:web:1234567890abcdef',
    messagingSenderId: '1234567890',
    projectId: 'sarbedutech',
    authDomain: 'sarbedutech.firebaseapp.com',
    storageBucket: 'sarbedutech.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCar09eV3t6KwFKwDwkKKe8auXIHmBz5Ek',
    appId: '1:1234567890:android:1234567890abcdef',
    messagingSenderId: '1234567890',
    projectId: 'sarbedutech',
    storageBucket: 'sarbedutech.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCar09eV3t6KwFKwDwkKKe8auXIHmBz5Ek',
    appId: '1:1234567890:ios:1234567890abcdef',
    messagingSenderId: '1234567890',
    projectId: 'sarbedutech',
    storageBucket: 'sarbedutech.appspot.com',
    iosBundleId: 'com.example.examtree',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCar09eV3t6KwFKwDwkKKe8auXIHmBz5Ek',
    appId: '1:1234567890:ios:1234567890abcdef',
    messagingSenderId: '1234567890',
    projectId: 'sarbedutech',
    storageBucket: 'sarbedutech.appspot.com',
    iosBundleId: 'com.example.examtree',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCar09eV3t6KwFKwDwkKKe8auXIHmBz5Ek',
    appId: '1:1234567890:web:1234567890abcdef',
    messagingSenderId: '1234567890',
    projectId: 'sarbedutech',
    authDomain: 'sarbedutech.firebaseapp.com',
    storageBucket: 'sarbedutech.appspot.com',
  );
}
