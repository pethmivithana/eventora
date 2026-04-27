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
  /// ⚠️ REQUIRED: Fill these with your Firebase project values from:
  /// Firebase Console → Project Settings → Android app settings
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY', // Copy from Firebase Console
    appId: 'YOUR_ANDROID_APP_ID', // e.g., 1:123456789:android:abc123xyz
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID', // Copy from Firebase Console
    projectId: 'YOUR_PROJECT_ID', // e.g., eventora-xxxxx
    storageBucket: 'YOUR_STORAGE_BUCKET', // e.g., eventora-xxxxx.appspot.com
    packageName: 'com.example.eventora', // ✓ Keep as-is
  );

  /// iOS Firebase Configuration
  /// ⚠️ REQUIRED: Fill these with your Firebase project values from:
  /// Firebase Console → Project Settings → iOS app settings
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY', // Copy from Firebase Console
    appId: 'YOUR_IOS_APP_ID', // e.g., 1:123456789:ios:abc123xyz
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID', // Copy from Firebase Console
    projectId: 'YOUR_PROJECT_ID', // e.g., eventora-xxxxx
    storageBucket: 'YOUR_STORAGE_BUCKET', // e.g., eventora-xxxxx.appspot.com
    iosBundleId: 'com.example.eventora', // ✓ Keep as-is
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
