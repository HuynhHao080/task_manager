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
    apiKey: 'AIzaSyCmBpgflNSMfFtSwkYSHqeucSfvC3yNPEo',
    appId: '1:79341673852:web:d8465958b5a2b71d4198f9',
    messagingSenderId: '79341673852',
    projectId: 'flutter-task-manager-ad52e',
    authDomain: 'flutter-task-manager-ad52e.firebaseapp.com',
    storageBucket: 'flutter-task-manager-ad52e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBAMNx1FLfFHk6kWn7WgJMrF-Izqo8tLE0',
    appId: '1:79341673852:android:88185a66081dd8944198f9',
    messagingSenderId: '79341673852',
    projectId: 'flutter-task-manager-ad52e',
    storageBucket: 'flutter-task-manager-ad52e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAU64HmEGEN_X_NxXOZMjPv5i6svQym874',
    appId: '1:79341673852:ios:a180e4865fa0b61f4198f9',
    messagingSenderId: '79341673852',
    projectId: 'flutter-task-manager-ad52e',
    storageBucket: 'flutter-task-manager-ad52e.firebasestorage.app',
    iosBundleId: 'com.example.taskManager01',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAU64HmEGEN_X_NxXOZMjPv5i6svQym874',
    appId: '1:79341673852:ios:a180e4865fa0b61f4198f9',
    messagingSenderId: '79341673852',
    projectId: 'flutter-task-manager-ad52e',
    storageBucket: 'flutter-task-manager-ad52e.firebasestorage.app',
    iosBundleId: 'com.example.taskManager01',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCmBpgflNSMfFtSwkYSHqeucSfvC3yNPEo',
    appId: '1:79341673852:web:c3ce3b65441fa7604198f9',
    messagingSenderId: '79341673852',
    projectId: 'flutter-task-manager-ad52e',
    authDomain: 'flutter-task-manager-ad52e.firebaseapp.com',
    storageBucket: 'flutter-task-manager-ad52e.firebasestorage.app',
  );

}