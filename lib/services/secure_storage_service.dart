import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// SecureStorageService ครอบการทำงานของ flutter_secure_storage (Lecture 9)
/// ใช้เก็บข้อมูลสำคัญแบบเข้ารหัสบนอุปกรณ์
/// - Android: Keystore (AES/RSA)
/// - iOS: Keychain
///
/// ในแอปนี้ใช้เก็บ "สถานะการล็อกอินล่าสุด" (uid + email) เพื่อสาธิตแนวทาง
/// การบันทึก/อ่าน/ลบ ข้อมูลแบบเข้ารหัส ตามที่สอนในสไลด์
class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _keyLastUid = 'last_login_uid';
  static const _keyLastEmail = 'last_login_email';

  Future<void> saveLoginSession({required String uid, required String email}) async {
    await _storage.write(key: _keyLastUid, value: uid);
    await _storage.write(key: _keyLastEmail, value: email);
  }

  Future<Map<String, String?>> readLoginSession() async {
    final uid = await _storage.read(key: _keyLastUid);
    final email = await _storage.read(key: _keyLastEmail);
    return {'uid': uid, 'email': email};
  }

  Future<void> clearLoginSession() async {
    await _storage.delete(key: _keyLastUid);
    await _storage.delete(key: _keyLastEmail);
  }
}
