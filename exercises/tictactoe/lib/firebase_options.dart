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
    apiKey: 'AIzaSyCwrdIU_XpvpNjlcBMqzGYVbfL6ZPvAYrI',
    appId: '1:761115423237:web:09a43df8cdfb160ef4626c',
    messagingSenderId: '761115423237',
    projectId: 'xintong-spring2025',
    authDomain: 'xintong-spring2025.firebaseapp.com',
    storageBucket: 'xintong-spring2025.firebasestorage.app',
    measurementId: 'G-D5P84VRC5M',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHlnDqVy3GKjJSMMxqRrLz3fM_gXvlfCA',
    appId: '1:761115423237:android:fd34a403dbadb72ef4626c',
    messagingSenderId: '761115423237',
    projectId: 'xintong-spring2025',
    storageBucket: 'xintong-spring2025.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBYuuAsR88u1VP-WBRrd7dNSXfqi9cUFnQ',
    appId: '1:761115423237:ios:af56e01887cd2427f4626c',
    messagingSenderId: '761115423237',
    projectId: 'xintong-spring2025',
    storageBucket: 'xintong-spring2025.firebasestorage.app',
    androidClientId: '761115423237-7564jks91g06c64ksqv10h39keqaci3b.apps.googleusercontent.com',
    iosClientId: '761115423237-5sekr69sqb4tdohtnov6uf10odhj8h4a.apps.googleusercontent.com',
    iosBundleId: 'com.example.tictactoe',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBYuuAsR88u1VP-WBRrd7dNSXfqi9cUFnQ',
    appId: '1:761115423237:ios:af56e01887cd2427f4626c',
    messagingSenderId: '761115423237',
    projectId: 'xintong-spring2025',
    storageBucket: 'xintong-spring2025.firebasestorage.app',
    androidClientId: '761115423237-7564jks91g06c64ksqv10h39keqaci3b.apps.googleusercontent.com',
    iosClientId: '761115423237-5sekr69sqb4tdohtnov6uf10odhj8h4a.apps.googleusercontent.com',
    iosBundleId: 'com.example.tictactoe',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCwrdIU_XpvpNjlcBMqzGYVbfL6ZPvAYrI',
    appId: '1:761115423237:web:c26b3725b35241fcf4626c',
    messagingSenderId: '761115423237',
    projectId: 'xintong-spring2025',
    authDomain: 'xintong-spring2025.firebaseapp.com',
    storageBucket: 'xintong-spring2025.firebasestorage.app',
    measurementId: 'G-J5D9R4585V',
  );
}
