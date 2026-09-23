/// โมเดลประกาศจากผู้ดูแลหอพัก เก็บใน Firestore collection "announcements"
/// เฉพาะผู้ใช้ที่มี role เป็น admin เท่านั้นที่สร้าง/แก้ไข/ลบได้
class AnnouncementModel {
  final String id;
  final String title;
  final String body;
  final String createdByName;
  final String createdByUid;
  final bool pinned;
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdByName,
    required this.createdByUid,
    required this.pinned,
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
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
