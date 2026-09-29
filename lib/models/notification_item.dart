enum NotificationType {
  announcement,
  newBill,
  billApproved,
  billRejected,
  repairInProgress,
  repairDone,
  parcel,
}

/// รายการแจ้งเตือนของผู้พัก (สร้างจากข้อมูลประกาศ/บิล/แจ้งซ่อม/พัสดุที่ฟังอยู่แล้ว
/// จึงไม่ต้องมี collection เพิ่ม) payload คือ model ต้นทาง ใช้เปิดหน้ารายละเอียดเมื่อกด
class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime time;
  final Object? payload;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    this.payload,
  });
}
