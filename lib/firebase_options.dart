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
    apiKey: 'AIzaSyCPOknvRKc29jnUCm_aVURvwzPctGYQTDU',
    appId: '1:421825036732:web:d9d38e97e7c4987d54ebb9',
    messagingSenderId: '421825036732',
    projectId: 'megavent-3b356',
    authDomain: 'megavent-3b356.firebaseapp.com',
    storageBucket: 'megavent-3b356.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAUKc3uT6ksR4rXOXw6LCZzo4AhCTDs3mY',
    appId: '1:421825036732:android:f0e6249e4154588b54ebb9',
    messagingSenderId: '421825036732',
    projectId: 'megavent-3b356',
    storageBucket: 'megavent-3b356.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDApZeSf_2O3Wrz96FDBHFrsYaE4JPzWNA',
    appId: '1:421825036732:ios:648b3bc92e62911554ebb9',
    messagingSenderId: '421825036732',
    projectId: 'megavent-3b356',
    storageBucket: 'megavent-3b356.firebasestorage.app',
    iosBundleId: 'com.abelndocha.megavent',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDApZeSf_2O3Wrz96FDBHFrsYaE4JPzWNA',
    appId: '1:421825036732:ios:648b3bc92e62911554ebb9',
    messagingSenderId: '421825036732',
    projectId: 'megavent-3b356',
    storageBucket: 'megavent-3b356.firebasestorage.app',
    iosBundleId: 'com.abelndocha.megavent',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCPOknvRKc29jnUCm_aVURvwzPctGYQTDU',
    appId: '1:421825036732:web:68f540512582b2a654ebb9',
    messagingSenderId: '421825036732',
    projectId: 'megavent-3b356',
    authDomain: 'megavent-3b356.firebaseapp.com',
    storageBucket: 'megavent-3b356.firebasestorage.app',
  );
}
