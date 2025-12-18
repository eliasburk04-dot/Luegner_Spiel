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
    apiKey: 'AIzaSyBoIaz-Obn9p0zKlEhSLFGj642nFWLpyic',
    appId: '1:729126001858:web:b20ad05ac9697d5b5e2f5b',
    messagingSenderId: '729126001858',
    projectId: 'luegnerspiel',
    authDomain: 'luegnerspiel.firebaseapp.com',
    databaseURL: 'https://luegnerspiel-default-rtdb.firebaseio.com',
    storageBucket: 'luegnerspiel.firebasestorage.app',
    measurementId: 'G-GE6GCVDG6X',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD4R17zzFUQCN-NH-vIZXLKpBrw2neXrUg',
    appId: '1:729126001858:android:61fcebb785d377fb5e2f5b',
    messagingSenderId: '729126001858',
    projectId: 'luegnerspiel',
    databaseURL: 'https://luegnerspiel-default-rtdb.firebaseio.com',
    storageBucket: 'luegnerspiel.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDthipxXhJguRfGb-jYLWkxipHr4rdTlLg',
    appId: '1:729126001858:ios:9cd66840fc31a77c5e2f5b',
    messagingSenderId: '729126001858',
    projectId: 'luegnerspiel',
    databaseURL: 'https://luegnerspiel-default-rtdb.firebaseio.com',
    storageBucket: 'luegnerspiel.firebasestorage.app',
    iosBundleId: 'com.example.luegnerSpiel',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDthipxXhJguRfGb-jYLWkxipHr4rdTlLg',
    appId: '1:729126001858:ios:9cd66840fc31a77c5e2f5b',
    messagingSenderId: '729126001858',
    projectId: 'luegnerspiel',
    databaseURL: 'https://luegnerspiel-default-rtdb.firebaseio.com',
    storageBucket: 'luegnerspiel.firebasestorage.app',
    iosBundleId: 'com.example.luegnerSpiel',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBoIaz-Obn9p0zKlEhSLFGj642nFWLpyic',
    appId: '1:729126001858:web:547d0a78287aedcf5e2f5b',
    messagingSenderId: '729126001858',
    projectId: 'luegnerspiel',
    authDomain: 'luegnerspiel.firebaseapp.com',
    databaseURL: 'https://luegnerspiel-default-rtdb.firebaseio.com',
    storageBucket: 'luegnerspiel.firebasestorage.app',
    measurementId: 'G-VM21LWXQF1',
  );

}