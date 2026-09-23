/// สถานะของบิลค่าห้อง/ค่าไฟ
enum BillStatus { unpaid, pendingReview, approved, rejected }

BillStatus billStatusFromString(String value) {
  return BillStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => BillStatus.unpaid,
  );
}

/// โมเดลบิลค่าไฟ/ค่าห้อง เก็บใน Firestore collection ที่ชื่อเปลี่ยนไปตามผู้ใช้
/// รูปแบบ: bills_<sanitized email> (ตามแนวทางที่สอนใน Lecture 11
/// เรื่อง "การระบุ collection name ที่เปลี่ยนไปตามชื่อผู้ใช้")
class BillModel {
  final String id;
  final String month; // เช่น '2026-09'
  final double previousUnit;
  final double currentUnit;
  final double unitsUsed;
  final double electricityAmount;
  final double roomRent;
  final double totalAmount;
  final BillStatus status;
  final String? slipImageBase64;
  final DateTime? slipUploadedAt;
  final DateTime createdAt;

  BillModel({
    required this.id,
    required this.month,
    required this.previousUnit,
    required this.currentUnit,
    required this.unitsUsed,
    required this.electricityAmount,
    required this.roomRent,
    required this.totalAmount,
    required this.status,
    this.slipImageBase64,
    this.slipUploadedAt,
    required this.createdAt,
  });

  factory BillModel.fromJson(Map<String, dynamic> json, String id) {
    return BillModel(
      id: id,
      month: json['month'] ?? '',
      previousUnit: (json['previousUnit'] ?? 0).toDouble(),
      currentUnit: (json['currentUnit'] ?? 0).toDouble(),
      unitsUsed: (json['unitsUsed'] ?? 0).toDouble(),
      electricityAmount: (json['electricityAmount'] ?? 0).toDouble(),
      roomRent: (json['roomRent'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: billStatusFromString(json['status'] ?? 'unpaid'),
      slipImageBase64: json['slipImageBase64'],
      slipUploadedAt: json['slipUploadedAt'] != null
          ? DateTime.tryParse(json['slipUploadedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'previousUnit': previousUnit,
      'currentUnit': currentUnit,
      'unitsUsed': unitsUsed,
      'electricityAmount': electricityAmount,
      'roomRent': roomRent,
      'totalAmount': totalAmount,
      'status': status.name,
      'slipImageBase64': slipImageBase64,
      'slipUploadedAt': slipUploadedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
