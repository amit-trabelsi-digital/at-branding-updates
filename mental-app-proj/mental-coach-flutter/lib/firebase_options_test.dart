// Firebase configuration for TEST environment
// Version: 1.1.0-test
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Test environment [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options_test.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: TestFirebaseOptions.currentPlatform,
/// );
/// ```
class TestFirebaseOptions {
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
          'TestFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'TestFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TEST Firebase Project Configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyTest-web-xxxxxxxxxxxxxxxxxxxx',
    appId: '1:123456789012:web:test_web_app_id',
    messagingSenderId: '123456789012',
    projectId: 'mental-coach-test',
    authDomain: 'mental-coach-test.firebaseapp.com',
    storageBucket: 'mental-coach-test.firebasestorage.app',
    measurementId: 'G-TEST12345',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyTest-android-xxxxxxxxxxxxxxxxx',
    appId: '1:123456789012:android:test_android_app_id',
    messagingSenderId: '123456789012',
    projectId: 'mental-coach-test',
    storageBucket: 'mental-coach-test.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyTest-ios-xxxxxxxxxxxxxxxxxxxxxxx',
    appId: '1:123456789012:ios:test_ios_app_id',
    messagingSenderId: '123456789012',
    projectId: 'mental-coach-test',
    storageBucket: 'mental-coach-test.firebasestorage.app',
    androidClientId:
        '123456789012-test.apps.googleusercontent.com',
    iosClientId:
        '123456789012-test-ios.apps.googleusercontent.com',
    iosBundleId: 'com.eitanazaria.mentalcoach.test',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyTest-macos-xxxxxxxxxxxxxxxxxxxxxx',
    appId: '1:123456789012:ios:test_macos_app_id',
    messagingSenderId: '123456789012',
    projectId: 'mental-coach-test',
    storageBucket: 'mental-coach-test.firebasestorage.app',
    androidClientId:
        '123456789012-test-macos-android.apps.googleusercontent.com',
    iosClientId:
        '123456789012-test-macos.apps.googleusercontent.com',
    iosBundleId: 'com.example.mentalCoachFlutterFirebase.test',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyTest-windows-xxxxxxxxxxxxxxxxxxxx',
    appId: '1:123456789012:web:test_windows_app_id',
    messagingSenderId: '123456789012',
    projectId: 'mental-coach-test',
    authDomain: 'mental-coach-test.firebaseapp.com',
    storageBucket: 'mental-coach-test.firebasestorage.app',
    measurementId: 'G-TESTWIN123',
  );
}
