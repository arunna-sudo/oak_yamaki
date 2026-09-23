import 'package:firebase_auth/firebase_auth.dart';

/// AuthService ทำหน้าที่ติดต่อกับ Firebase Authentication เท่านั้น
/// ตามหลักการที่สอนใน Lecture 7 (Structure of Project):
/// "Service จะต้องไม่รู้เรื่องเกี่ยวกับหน้าจอ ห้ามมี BuildContext"
/// เพื่อให้สามารถนำไปเขียน Unit Test หรือ Re-use ที่อื่นได้ง่าย
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// แปลง Error code ของ FirebaseAuthException ให้เป็นข้อความภาษาไทยที่เข้าใจง่าย
  String describeError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'ไม่พบบัญชีผู้ใช้นี้ในระบบ';
        case 'wrong-password':
        case 'invalid-credential':
          return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
        case 'email-already-in-use':
          return 'อีเมลนี้ถูกใช้ลงทะเบียนไปแล้ว';
        case 'weak-password':
          return 'รหัสผ่านควรมีความยาวอย่างน้อย 6 ตัวอักษร';
        case 'invalid-email':
          return 'รูปแบบอีเมลไม่ถูกต้อง';
        case 'network-request-failed':
          return 'เชื่อมต่อเครือข่ายไม่สำเร็จ กรุณาตรวจสอบอินเทอร์เน็ต';
        default:
          return error.message ?? 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
      }
    }
    return 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
  }
}
