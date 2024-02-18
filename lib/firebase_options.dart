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
    apiKey: 'AIzaSyCnelM0iNUDhe5MC5xmwtwk-AsQfhmFKkY',
    appId: '1:185379667405:web:f09ade9f6cd7a614d59884',
    messagingSenderId: '185379667405',
    projectId: 'romanceradar-b996e',
    authDomain: 'romanceradar-b996e.firebaseapp.com',
    storageBucket: 'romanceradar-b996e.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAbZs-pkpg66rYYV83kFl1EecuGZNyruKQ',
    appId: '1:185379667405:android:b58b0ff464dec370d59884',
    messagingSenderId: '185379667405',
    projectId: 'romanceradar-b996e',
    storageBucket: 'romanceradar-b996e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAniKTyj7q-FSiYUBc1mmqyCzopedO4vuc',
    appId: '1:185379667405:ios:cf0c9fcbf4e8502ad59884',
    messagingSenderId: '185379667405',
    projectId: 'romanceradar-b996e',
    storageBucket: 'romanceradar-b996e.appspot.com',
    iosBundleId: 'com.example.romanceradar',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAniKTyj7q-FSiYUBc1mmqyCzopedO4vuc',
    appId: '1:185379667405:ios:5af5854fea25968ad59884',
    messagingSenderId: '185379667405',
    projectId: 'romanceradar-b996e',
    storageBucket: 'romanceradar-b996e.appspot.com',
    iosBundleId: 'com.example.romanceradar.RunnerTests',
  );
}
