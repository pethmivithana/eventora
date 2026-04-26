// lib/firebase_options.dart
// ⚠️  IMPORTANT: Configure Firebase credentials before running the app!
//
// Instructions:
// 1. Create a Firebase project at https://console.firebase.google.com
// 2. Run: flutter pub global activate flutterfire_cli
// 3. Run: flutterfire configure
// 4. OR manually update values below from Firebase Console → Project Settings
//
// This file is safe to manually edit for development.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web. '
        'Please run: flutterfire configure',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform. '
          'Please run: flutterfire configure',
        );
    }
  }

  /// Android Firebase Configuration
  /// Get these values from Firebase Console:
  /// 1. Project Settings → "eventora (Android)"
  /// 2. Copy all values to the fields below
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDEXAMPLE_Android_API_Key_Here',
    appId: '1:123456789:android:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'eventora-xxxxxxx',
    storageBucket: 'eventora-xxxxxxx.appspot.com',
    // Android-specific package name (optional)
    // packageName: 'com.example.eventora',
  );

  /// iOS Firebase Configuration
  /// Get these values from Firebase Console:
  /// 1. Project Settings → "eventora (iOS)"
  /// 2. Copy all values to the fields below
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDEXAMPLE_iOS_API_Key_Here',
    appId: '1:123456789:ios:1234567890abcdef',
    messagingSenderId: '123456789',
    projectId: 'eventora-xxxxxxx',
    storageBucket: 'eventora-xxxxxxx.appspot.com',
    iosBundleId: 'com.example.eventora',
  );

  /// Web Firebase Configuration (if needed in future)
  /// Uncomment and fill when web support is added
  /*
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDEXAMPLE_Web_API_Key_Here',
    appId: '1:123456789:web:abcdef1234567890',
    messagingSenderId: '123456789',
    projectId: 'eventora-xxxxxxx',
    authDomain: 'eventora-xxxxxxx.firebaseapp.com',
    storageBucket: 'eventora-xxxxxxx.appspot.com',
  );
  */
}
