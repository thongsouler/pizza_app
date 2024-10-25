// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDpEypefX5OMmKBKcWzwGDpBk1v8oT14sA',
    appId: '1:46689285122:android:1974a3d79b24cf0649631b',
    messagingSenderId: '46689285122',
    projectId: 'thcshaixuan-81559',
  );
}
