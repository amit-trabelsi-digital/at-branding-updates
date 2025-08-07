// Firebase configuration for DEV environment
// Version: 1.1.0-dev
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Development environment [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options_dev.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DevFirebaseOptions.currentPlatform,
/// );
/// ```
class DevFirebaseOptions {
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
          'DevFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DevFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // DEV Firebase Project Configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDev-web-xxxxxxxxxxxxxxxxxxxx',
    appId: '1:987654321098:web:dev_web_app_id',
    messagingSenderId: '987654321098',
    projectId: 'mental-coach-dev',
    authDomain: 'mental-coach-dev.firebaseapp.com',
    storageBucket: 'mental-coach-dev.firebasestorage.app',
    measurementId: 'G-DEV12345',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDev-android-xxxxxxxxxxxxxxxxx',
    appId: '1:987654321098:android:dev_android_app_id',
    messagingSenderId: '987654321098',
    projectId: 'mental-coach-dev',
    storageBucket: 'mental-coach-dev.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDev-ios-xxxxxxxxxxxxxxxxxxxxxxx',
    appId: '1:987654321098:ios:dev_ios_app_id',
    messagingSenderId: '987654321098',
    projectId: 'mental-coach-dev',
    storageBucket: 'mental-coach-dev.firebasestorage.app',
    androidClientId:
        '987654321098-dev.apps.googleusercontent.com',
    iosClientId:
        '987654321098-dev-ios.apps.googleusercontent.com',
    iosBundleId: 'com.eitanazaria.mentalcoach.dev',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDev-macos-xxxxxxxxxxxxxxxxxxxxxx',
    appId: '1:987654321098:ios:dev_macos_app_id',
    messagingSenderId: '987654321098',
    projectId: 'mental-coach-dev',
    storageBucket: 'mental-coach-dev.firebasestorage.app',
    androidClientId:
        '987654321098-dev-macos-android.apps.googleusercontent.com',
    iosClientId:
        '987654321098-dev-macos.apps.googleusercontent.com',
    iosBundleId: 'com.example.mentalCoachFlutterFirebase.dev',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDev-windows-xxxxxxxxxxxxxxxxxxxx',
    appId: '1:987654321098:web:dev_windows_app_id',
    messagingSenderId: '987654321098',
    projectId: 'mental-coach-dev',
    authDomain: 'mental-coach-dev.firebaseapp.com',
    storageBucket: 'mental-coach-dev.firebasestorage.app',
    measurementId: 'G-DEVWIN123',
  );
}
