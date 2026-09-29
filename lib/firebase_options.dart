// firebase_options.dart — ตั้งค่าให้เชื่อมกับ Firebase Project: sealoveboo

// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static const String projectId = 'sealoveboo';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions ยังไม่รองรับแพลตฟอร์มนี้ - '
          'กรุณารัน `flutterfire configure --project=sealoveboo` เพื่อสร้างไฟล์นี้ใหม่',
        );
    }
  }

  /// true เมื่อกรอกค่าของแพลตฟอร์มปัจจุบันครบแล้ว (ไม่มี REPLACE_ME เหลืออยู่)
  static bool get isConfigured {
    try {
      final o = currentPlatform;
      return !(o.apiKey.contains('REPLACE_ME') ||
          o.appId.contains('REPLACE_ME') ||
          o.messagingSenderId.contains('REPLACE_ME'));
    } catch (_) {
      return false;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAG1enjRCzKZELPFh-Bs1W6EVBHdHn3K3o',
    appId: '1:280008336584:web:05873b765c81d01989b1fd',
    messagingSenderId: '280008336584',
    projectId: projectId,
    authDomain: 'sealoveboo.firebaseapp.com',
    storageBucket: 'sealoveboo.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAG1enjRCzKZELPFh-Bs1W6EVBHdHn3K3o',
    appId: '1:280008336584:web:05873b765c81d01989b1fd',
    messagingSenderId: '280008336584',
    projectId: projectId,
    storageBucket: 'sealoveboo.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAG1enjRCzKZELPFh-Bs1W6EVBHdHn3K3o',
    appId: '1:280008336584:web:05873b765c81d01989b1fd',
    messagingSenderId: '280008336584',
    projectId: projectId,
    storageBucket: 'sealoveboo.firebasestorage.app',
    iosBundleId: 'com.example.dormEase',
  );
}