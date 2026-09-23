// ไฟล์นี้เป็นไฟล์ตัวอย่าง (placeholder) เท่านั้น
//
// ห้ามใช้ค่าคอนฟิกด้านล่างนี้จริง! ให้รันคำสั่งต่อไปนี้ในโฟลเดอร์โปรเจกต์
// เพื่อให้ FlutterFire CLI สร้างไฟล์นี้ใหม่โดยอัตโนมัติ (แทนที่ไฟล์นี้ทั้งหมด)
// ให้เชื่อมกับ Firebase Project จริงของท่าน (ตามขั้นตอนใน Lecture 10):
//
//   firebase login
//   flutterfire configure
//
// ดูรายละเอียดขั้นตอนแบบเต็มได้ในคู่มือ "DormEase_Setup_Guide.docx"
// ที่แนบมาพร้อมกับโปรเจกต์นี้

// ignore_for_file: type=lint
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions ยังไม่รองรับแพลตฟอร์มนี้ - '
          'กรุณารัน `flutterfire configure` เพื่อสร้างไฟล์นี้ใหม่',
        );
    }
  }

  // ⚠️ ค่าด้านล่างนี้เป็นค่าตัวอย่างเปล่าๆ (placeholder) ต้องถูกแทนที่
  // ด้วยคำสั่ง `flutterfire configure` เท่านั้น มิฉะนั้น Firebase จะเชื่อมต่อไม่ได้

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    authDomain: 'REPLACE_ME.firebaseapp.com',
    storageBucket: 'REPLACE_ME.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME.appspot.com',
    iosBundleId: 'com.example.dormEase',
  );
}
