enum ParcelStatus { pending, received }

ParcelStatus parcelStatusFromString(String value) {
  return ParcelStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ParcelStatus.pending,
  );
}

/// โมเดลพัสดุ เก็บใน Firestore collection "parcels"
/// แอดมินเป็นผู้เพิ่มพัสดุ (เลือกห้อง + ใส่รูปได้) ผู้พักดูได้เฉพาะพัสดุของห้องตัวเอง
class ParcelModel {
  final String id;
  final String room;
  final String note; // รายละเอียด เช่น ขนส่ง / ชื่อผู้รับ (ไม่บังคับ)
  final String? imageBase64;
  final ParcelStatus status;
  final DateTime createdAt;
  final DateTime? receivedAt;

  ParcelModel({
    required this.id,
    required this.room,
    this.note = '',
    this.imageBase64,
    this.status = ParcelStatus.pending,
    required this.createdAt,
    this.receivedAt,
  });

  factory ParcelModel.fromJson(Map<String, dynamic> json, String id) {
    return ParcelModel(
      id: id,
      room: json['room'] ?? '',
      note: json['note'] ?? '',
      imageBase64: json['imageBase64'],
      status: parcelStatusFromString(json['status'] ?? 'pending'),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      receivedAt: json['receivedAt'] != null
          ? DateTime.tryParse(json['receivedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room': room,
      'note': note,
      'imageBase64': imageBase64,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'receivedAt': receivedAt?.toIso8601String(),
    };
  }
}
