import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

/// ThemeProvider เก็บสถานะโหมดสี (Light/Dark) ของทั้งแอป
/// และบันทึกค่าที่ผู้ใช้เลือกไว้ด้วย SharedPreferences (Lecture 9)
/// เพื่อให้เปิดแอปครั้งถัดไปยังจำโหมดที่เลือกไว้ได้
class ThemeProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// เรียกครั้งเดียวตอนแอปเริ่มทำงาน เพื่ออ่านค่าธีมเดิมที่เคยบันทึกไว้
  Future<void> loadSavedTheme() async {
    final saved = await _storage.getThemeMode();
    if (saved == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (saved == 'light') {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    await _storage.saveThemeMode(_themeMode == ThemeMode.dark ? 'dark' : 'light');
  }
}
