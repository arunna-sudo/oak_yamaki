import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement_model.dart';

/// AnnouncementService จัดการ Firestore collection "announcements"
/// เป็น collection กลางที่ทุกคนในหอพัก "อ่าน" ได้ แต่ "เขียน/ลบ" ได้เฉพาะ admin
/// (การจำกัดสิทธิ์จริงควรตั้งค่าผ่าน Firestore Security Rules เพิ่มเติม
/// ตัวอย่าง rule จะอธิบายไว้ในคู่มือประกอบโปรเจกต์)
class AnnouncementService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('announcements');

  Stream<List<AnnouncementModel>> watchAnnouncements() {
    return _collection.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs
              .map((d) => AnnouncementModel.fromJson(d.data(), d.id))
              .toList()
            ..sort((a, b) {
              if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
              return b.createdAt.compareTo(a.createdAt);
            }),
        );
  }

  Future<void> createAnnouncement(AnnouncementModel announcement) async {
    await _collection.add(announcement.toJson());
  }

  Future<void> deleteAnnouncement(String id) async {
    await _collection.doc(id).delete();
  }

  Future<void> togglePinned(String id, bool pinned) async {
    await _collection.doc(id).update({'pinned': pinned});
  }
}
