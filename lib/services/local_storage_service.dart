import 'package:shared_preferences/shared_preferences.dart';

/// LocalStorageService ครอบการทำงานของ SharedPreferences (Lecture 9)
/// ใช้เก็บข้อมูลเล็กๆ น้อยๆ แบบ Key-Value ที่ไม่ใช่ความลับ เช่น
/// - ธีมของแอป (light/dark)
/// - อีเมลล่าสุดที่ใช้ล็อกอิน (สำหรับติ๊ก "จดจำฉันไว้")
/// - สถานะเคยดู Onboarding/Tutorial หรือยัง
///
/// หมายเหตุจากสไลด์: "No guarantee that writes will be persisted to disk
/// immediately after returning" จึงไม่ควรใช้เก็บข้อมูลสำคัญ (ให้ใช้ SecureStorageService แทน)
class LocalStorageService {
  static const _keyThemeMode = 'theme_mode'; // 'light' | 'dark' | 'system'
  static const _keyRememberedEmail = 'remembered_email';
  static const _keySeenOnboarding = 'seen_onboarding';

  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }

  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode);
  }

  Future<void> saveRememberedEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRememberedEmail, email);
  }

  Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRememberedEmail);
  }

  Future<void> clearRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberedEmail);
  }

  Future<void> setSeenOnboarding(bool seen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySeenOnboarding, seen);
  }

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySeenOnboarding) ?? false;
  }

  /// เวลาที่ผู้ใช้เปิดหน้าแจ้งเตือนล่าสุด (เก็บแยกตาม uid) ใช้คำนวณจำนวนที่ยังไม่ได้อ่าน
  Future<void> saveNotificationsSeenAt(String uid, DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notifications_seen_at_$uid', time.toIso8601String());
  }

  Future<DateTime?> getNotificationsSeenAt(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('notifications_seen_at_$uid');
    return raw == null ? null : DateTime.tryParse(raw);
  }
}
