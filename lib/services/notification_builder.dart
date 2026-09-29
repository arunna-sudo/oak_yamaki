import '../models/announcement_model.dart';
import '../models/bill_model.dart';
import '../models/maintenance_model.dart';
import '../models/notification_item.dart';
import '../models/parcel_model.dart';

/// รวมเหตุการณ์ต่างๆ เป็นรายการแจ้งเตือนเดียว เรียงจากใหม่ไปเก่า (ย้อนหลัง 30 วัน)
class NotificationBuilder {
  NotificationBuilder._();

  static const Duration window = Duration(days: 30);

  static List<NotificationItem> build({
    required List<AnnouncementModel> announcements,
    required List<BillModel> bills,
    required List<MaintenanceModel> requests,
    required List<ParcelModel> parcels,
  }) {
    final items = <NotificationItem>[];

    for (final a in announcements) {
      items.add(NotificationItem(
        id: 'ann_${a.id}',
        type: NotificationType.announcement,
        title: 'มีประกาศใหม่',
        message: a.title,
        time: a.createdAt,
        payload: a,
      ));
    }

    for (final b in bills) {
      items.add(NotificationItem(
        id: 'bill_new_${b.id}',
        type: NotificationType.newBill,
        title: 'มีบิลค่าเช่าใหม่',
        message: 'บิลเดือน ${b.month} กรุณาชำระและแนบสลิป',
        time: b.createdAt,
        payload: b,
      ));
      final reviewedTime = b.reviewedAt ?? b.slipUploadedAt ?? b.createdAt;
      if (b.status == BillStatus.approved) {
        items.add(NotificationItem(
          id: 'bill_ok_${b.id}',
          type: NotificationType.billApproved,
          title: 'บิลค่าเช่าได้รับการยืนยันแล้ว',
          message: 'บิลเดือน ${b.month} ชำระเงินเรียบร้อย',
          time: reviewedTime,
          payload: b,
        ));
      } else if (b.status == BillStatus.rejected) {
        items.add(NotificationItem(
          id: 'bill_no_${b.id}',
          type: NotificationType.billRejected,
          title: 'สลิปไม่ผ่านการตรวจสอบ',
          message: 'บิลเดือน ${b.month} กรุณาส่งสลิปใหม่อีกครั้ง',
          time: reviewedTime,
          payload: b,
        ));
      }
    }

    for (final r in requests) {
      final time = r.updatedAt ?? r.createdAt;
      if (r.status == MaintenanceStatus.inProgress) {
        items.add(NotificationItem(
          id: 'mt_${r.id}_progress',
          type: NotificationType.repairInProgress,
          title: 'การแจ้งซ่อมได้รับการยืนยันแล้ว / กำลังซ่อม',
          message: r.title,
          time: time,
          payload: r,
        ));
      } else if (r.status == MaintenanceStatus.done) {
        items.add(NotificationItem(
          id: 'mt_${r.id}_done',
          type: NotificationType.repairDone,
          title: 'การแจ้งซ่อมเสร็จสิ้นแล้ว',
          message: r.title,
          time: time,
          payload: r,
        ));
      }
    }

    for (final p in parcels) {
      items.add(NotificationItem(
        id: 'parcel_${p.id}',
        type: NotificationType.parcel,
        title: 'มีพัสดุมาถึง',
        message: p.note.isNotEmpty ? p.note : 'ห้อง ${p.room}',
        time: p.createdAt,
        payload: p,
      ));
    }

    final cutoff = DateTime.now().subtract(window);
    items.removeWhere((i) => i.time.isBefore(cutoff));
    items.sort((a, b) => b.time.compareTo(a.time));
    return items;
  }

  /// จำนวนที่ยังไม่ได้อ่าน (เกิดหลังเวลาที่เปิดหน้าแจ้งเตือนครั้งล่าสุด)
  static int unreadCount(List<NotificationItem> items, DateTime? seenAt) {
    if (seenAt == null) return items.length;
    return items.where((i) => i.time.isAfter(seenAt)).length;
  }
}
