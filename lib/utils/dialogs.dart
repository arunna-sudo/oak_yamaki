import 'package:flutter/material.dart';
import 'app_theme.dart';

/// กล่องยืนยันการลบ คืนค่า true เมื่อผู้ใช้กดยืนยัน
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ยกเลิก')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('ลบ', style: TextStyle(color: AppColors.danger)),
        ),
      ],
    ),
  );
  return result == true;
}

/// กล่องยืนยันทั่วไป คืนค่า true เมื่อผู้ใช้กดยืนยัน
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'ยืนยัน',
  Color confirmColor = AppColors.danger,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ไม่ใช่')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel, style: TextStyle(color: confirmColor)),
        ),
      ],
    ),
  );
  return result == true;
}
