import 'package:intl/intl.dart';

/// แปลงเวลาเป็นข้อความแบบ "9 นาทีที่แล้ว" สำหรับโพสต์/คอมเมนต์
String timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inSeconds < 60) return 'เมื่อสักครู่';
  if (diff.inMinutes < 60) return '${diff.inMinutes} นาทีที่แล้ว';
  if (diff.inHours < 24) return '${diff.inHours} ชม.ที่แล้ว';
  if (diff.inDays < 7) return '${diff.inDays} วันที่แล้ว';
  return DateFormat('d MMM y', 'th').format(time);
}

/// แสดงตัวเลขมิเตอร์แบบไม่มีทศนิยมถ้าเป็นจำนวนเต็ม (เช่น 1250 แทน 1250.0)
String formatUnit(double value) {
  return value == value.roundToDouble() ? value.toInt().toString() : value.toString();
}
