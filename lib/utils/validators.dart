import 'package:flutter/material.dart';

/// คลาส Validator ที่เขียนขึ้นเองเพื่อใช้ซ้ำได้หลายจุดในแอป
/// (ตามแนวทางที่สอนใน Lecture 6: Form Builder and Validation
/// -- "การเขียนโปรแกรมตรวจสอบแยกส่วนเป็น Class ย่อยสำหรับเรียกใช้ซ้ำได้")
///
/// นอกจากนี้แอปยังใช้ package `form_builder_validators` (Validation แบบใช้ Library
/// เสริม) ควบคู่กันไปในบางฟอร์ม เพื่อสาธิตทั้ง 2 แนวทางที่บทเรียนกล่าวถึง
class Validators {
  Validators._();

  static FormFieldValidator<String> required({String? errorMessage}) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return errorMessage ?? 'กรุณากรอกข้อมูลนี้';
      }
      return null;
    };
  }

  static FormFieldValidator<String> email({String? errorMessage}) {
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      if (!regex.hasMatch(value)) {
        return errorMessage ?? 'รูปแบบอีเมลไม่ถูกต้อง';
      }
      return null;
    };
  }

  static FormFieldValidator<String> minLength(int length, {String? errorMessage}) {
    return (String? value) {
      if (value == null || value.length < length) {
        return errorMessage ?? 'ต้องมีความยาวอย่างน้อย $length ตัวอักษร';
      }
      return null;
    };
  }

  static FormFieldValidator<String> numberValidator({String? errorMessage}) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      final numValue = double.tryParse(value);
      if (numValue == null) {
        return errorMessage ?? 'กรุณากรอกเป็นตัวเลขเท่านั้น';
      }
      return null;
    };
  }

  static FormFieldValidator<String> positiveNumber({String? errorMessage}) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      final numValue = double.tryParse(value);
      if (numValue == null || numValue < 0) {
        return errorMessage ?? 'ค่าต้องเป็นตัวเลขและมากกว่าหรือเท่ากับ 0';
      }
      return null;
    };
  }

  /// รวมหลาย validator เข้าด้วยกัน จะคืนค่า error ของตัวแรกที่ไม่ผ่าน
  static FormFieldValidator<String> compose(List<FormFieldValidator<String>> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  /// ใช้ตรวจว่าค่ายืนยันรหัสผ่าน ตรงกับรหัสผ่านที่กรอกไว้ก่อนหน้าหรือไม่
  static FormFieldValidator<String> confirmPassword(
    String Function() getPassword, {
    String? errorMessage,
  }) {
    return (String? value) {
      if (value != getPassword()) {
        return errorMessage ?? 'รหัสผ่านไม่ตรงกัน';
      }
      return null;
    };
  }
}
