// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyBD-0jTgB9WygP_1qK0he0SBd6pY2YHGzs',
    appId: '1:338631887868:web:01cb373ab6f56df06b8079',
    messagingSenderId: '338631887868',
    projectId: 'miracle-study-d5b4f',
    authDomain: 'miracle-study-d5b4f.firebaseapp.com',
    storageBucket: 'miracle-study-d5b4f.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC9P2S3nMbn49xqoW8NsL1XyaMLn7GMXHQ',
    appId: '1:338631887868:android:f51d47a8cb5ad0526b8079',
    messagingSenderId: '338631887868',
    projectId: 'miracle-study-d5b4f',
    storageBucket: 'miracle-study-d5b4f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDA8zJJ7RvOT8SmReKWEplHRj6ciOdvr-0',
    appId: '1:338631887868:ios:448ef8ce51c6abb36b8079',
    messagingSenderId: '338631887868',
    projectId: 'miracle-study-d5b4f',
    storageBucket: 'miracle-study-d5b4f.appspot.com',
    iosClientId: '338631887868-86a2vrnang9mp31svg2p8ql8a2pmpquh.apps.googleusercontent.com',
    iosBundleId: 'com.example.miracleStudy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDA8zJJ7RvOT8SmReKWEplHRj6ciOdvr-0',
    appId: '1:338631887868:ios:423ae090446b54ed6b8079',
    messagingSenderId: '338631887868',
    projectId: 'miracle-study-d5b4f',
    storageBucket: 'miracle-study-d5b4f.appspot.com',
    iosClientId: '338631887868-vl61325nc6m8nv60t7ka9a12f7e0b778.apps.googleusercontent.com',
    iosBundleId: 'com.example.miracleStudy.RunnerTests',
  );
}