// File generated manually for Firebase setup
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
          'DefaultFirebaseOptions have not been configured for iOS.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAz9KyL5y8v3-sNPX2QoPI9ndkJ_pDOKj8",
    authDomain: "mobile-service-hub-b87c5.firebaseapp.com",
    projectId: "mobile-service-hub-b87c5",
    storageBucket: "mobile-service-hub-b87c5.firebasestorage.app",
    messagingSenderId: "765200249554",
    appId: "1:765200249554:web:6746648d7864793f76b30b",
    measurementId: "G-FEHW45Y7XX",
  );


  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBNind8w4m2XnSUYWwCLELlFIn0pXBVBV8',
    appId: '1:765200249554:android:e5a94ccc2081137176b30b',
    messagingSenderId: '765200249554',
    projectId: 'mobile-service-hub-b87c5',
    storageBucket: 'mobile-service-hub-b87c5.firebasestorage.app',
  );
}
