enum MaintenanceStatus { pending, inProgress, done }

MaintenanceStatus maintenanceStatusFromString(String value) {
  return MaintenanceStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => MaintenanceStatus.pending,
  );
}

/// โมเดลคำขอแจ้งซ่อม เก็บใน Firestore collection "maintenance_requests"
/// เป็น collection กลางที่ทุกผู้ใช้เขียนได้ แต่จะกรองแสดงผลด้วย uid ของตนเอง
/// ส่วน admin จะเห็นคำขอของทุกห้อง
class MaintenanceModel {
  final String id;
  final String uid;
  final String room;
  final String category; // ไฟฟ้า, ประปา, เครื่องใช้ไฟฟ้า, อื่นๆ
  final String title;
  final String description;
  final String urgency; // ต่ำ, ปานกลาง, สูง
  final MaintenanceStatus status;
  final DateTime? preferredDate;
  final List<String> imagesBase64; // รูปประกอบ (ไม่บังคับ) เก็บเป็น base64
  final DateTime createdAt;
  final DateTime? updatedAt; // เวลาที่สถานะเปลี่ยนล่าสุด

  MaintenanceModel({
    required this.id,
    required this.uid,
    required this.room,
    required this.category,
    required this.title,
    required this.description,
    required this.urgency,
    required this.status,
    this.preferredDate,
    this.imagesBase64 = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json, String id) {
    return MaintenanceModel(
      id: id,
      uid: json['uid'] ?? '',
      room: json['room'] ?? '',
      category: json['category'] ?? 'อื่นๆ',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      urgency: json['urgency'] ?? 'ปานกลาง',
      status: maintenanceStatusFromString(json['status'] ?? 'pending'),
      preferredDate: json['preferredDate'] != null
          ? DateTime.tryParse(json['preferredDate'].toString())
          : null,
      imagesBase64:
          (json['imagesBase64'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'room': room,
      'category': category,
      'title': title,
      'description': description,
      'urgency': urgency,
      'status': status.name,
      'preferredDate': preferredDate?.toIso8601String(),
      'imagesBase64': imagesBase64,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
