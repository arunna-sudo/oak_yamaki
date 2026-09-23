import 'package:flutter/foundation.dart';

/// ตัวอย่าง Mixin ตามที่สอนใน Lecture 7:
/// "รูปแบบการแชร์ความสามารถของโค้ดด้วยการใช้ with (Mixin)"
///
/// Provider หลายตัวในแอปนี้ต้องการความสามารถ "บอกสถานะกำลังโหลด"
/// และ "เก็บข้อความ error" เหมือนกัน แทนที่จะเขียนโค้ดซ้ำในทุก Provider
/// จึงรวบรวมไว้ใน Mixin นี้ แล้วนำไปใช้ร่วมกับ ChangeNotifier ด้วยคำสั่ง `with`
///
/// ตัวอย่างการใช้งาน:
/// class BillProvider extends ChangeNotifier with LoadingStateMixin { ... }
mixin LoadingStateMixin on ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() => setError(null);

  /// ตัวช่วยรัน future ใดๆ พร้อมจัดการ isLoading / error ให้อัตโนมัติ
  Future<T?> runWithLoading<T>(Future<T> Function() action) async {
    setLoading(true);
    clearError();
    try {
      final result = await action();
      return result;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }
}
