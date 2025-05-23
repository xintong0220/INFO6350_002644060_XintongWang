// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDsHWC-8ko4VZlPpA3f_IUaSDsCqP905e4',
    appId: '1:382917256149:web:c38676d2115d758a07935c',
    messagingSenderId: '382917256149',
    projectId: 'info-6350-final-1945a',
    authDomain: 'info-6350-final-1945a.firebaseapp.com',
    storageBucket: 'info-6350-final-1945a.firebasestorage.app',
    measurementId: 'G-E2RM86PZ3W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBFdoPQ4h_ZSyuM_sCaa6XM9TlHTz01Utc',
    appId: '1:382917256149:android:75d05cc4c6cd83a707935c',
    messagingSenderId: '382917256149',
    projectId: 'info-6350-final-1945a',
    storageBucket: 'info-6350-final-1945a.firebasestorage.app',
  );

}