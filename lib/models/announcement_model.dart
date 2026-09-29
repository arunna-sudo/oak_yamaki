/// โมเดลประกาศจากผู้ดูแลหอพัก เก็บใน Firestore collection "announcements"
/// เฉพาะผู้ใช้ที่มี role เป็น admin เท่านั้นที่สร้าง/แก้ไข/ลบได้
class AnnouncementModel {
  final String id;
  final String title;
  final String body;
  final String createdByName;
  final String createdByUid;
  final bool pinned;
  final String? imageBase64; // รูปประกอบประกาศ (ไม่บังคับ) เก็บเป็น base64
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdByName,
    required this.createdByUid,
    required this.pinned,
    this.imageBase64,
    required this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json, String id) {
    return AnnouncementModel(
      id: id,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      createdByName: json['createdByName'] ?? 'ผู้ดูแลหอพัก',
      createdByUid: json['createdByUid'] ?? '',
      pinned: json['pinned'] ?? false,
      imageBase64: json['imageBase64'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'createdByName': createdByName,
      'createdByUid': createdByUid,
      'pinned': pinned,
      'imageBase64': imageBase64,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
