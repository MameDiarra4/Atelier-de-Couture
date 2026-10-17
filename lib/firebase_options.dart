// Configuration Firebase pour le projet digitsagnse
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
      default:
        return web;
    }
  }

  // Configuration Web (utilisée par Chrome)

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAQUw983Ha4UYkeGCo4qY4BRLzE_KyIgLU',
    appId: '1:286982569686:web:25b58d7a9f2eb191a05377',
    messagingSenderId: '286982569686',
    projectId: 'digitsagnse-app',
    authDomain: 'digitsagnse-app.firebaseapp.com',
    storageBucket: 'digitsagnse-app.firebasestorage.app',
    measurementId: 'G-LS7BQJRWQD',
  );
  // Configuration Android

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD39oTk38PZR6j5M1ojlpYMOud16uKtJDM',
    appId: '1:286982569686:android:e6d05853ba88c90ba05377',
    messagingSenderId: '286982569686',
    projectId: 'digitsagnse-app',
    storageBucket: 'digitsagnse-app.firebasestorage.app',
  );
}
