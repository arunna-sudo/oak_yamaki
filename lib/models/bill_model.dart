/// สถานะของบิลค่าห้อง/ค่าไฟ
enum BillStatus { unpaid, pendingReview, approved, rejected }

BillStatus billStatusFromString(String value) {
  return BillStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => BillStatus.unpaid,
  );
}

/// โมเดลบิลค่าไฟ/ค่าน้ำ/ค่าห้อง เก็บใน Firestore collection ที่ชื่อเปลี่ยนไปตามผู้ใช้
/// รูปแบบ: bills_<sanitized email> (ตามแนวทางที่สอนใน Lecture 11
/// เรื่อง "การระบุ collection name ที่เปลี่ยนไปตามชื่อผู้ใช้")
class BillModel {
  final String id;
  final String month; // เช่น '2026-09'
  final double previousUnit; // มิเตอร์ไฟครั้งก่อน
  final double currentUnit; // มิเตอร์ไฟครั้งนี้
  final double unitsUsed; // หน่วยไฟที่ใช้
  final double electricityAmount;
  final double previousWaterUnit;
  final double currentWaterUnit;
  final double waterUnitsUsed;
  final double waterRate; // บาท/หน่วย
  final double waterAmount;
  final double roomRent;
  final double totalAmount;
  final BillStatus status;
  final String? slipImageBase64;
  final DateTime? slipUploadedAt;
  final DateTime? reviewedAt; // เวลาที่แอดมินอนุมัติ/ปฏิเสธสลิป
  final DateTime createdAt;

  BillModel({
    required this.id,
    required this.month,
    required this.previousUnit,
    required this.currentUnit,
    required this.unitsUsed,
    required this.electricityAmount,
    this.previousWaterUnit = 0,
    this.currentWaterUnit = 0,
    this.waterUnitsUsed = 0,
    this.waterRate = 0,
    this.waterAmount = 0,
    required this.roomRent,
    required this.totalAmount,
    required this.status,
    this.slipImageBase64,
    this.slipUploadedAt,
    this.reviewedAt,
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
      previousWaterUnit: (json['previousWaterUnit'] ?? 0).toDouble(),
      currentWaterUnit: (json['currentWaterUnit'] ?? 0).toDouble(),
      waterUnitsUsed: (json['waterUnitsUsed'] ?? 0).toDouble(),
      waterRate: (json['waterRate'] ?? 0).toDouble(),
      waterAmount: (json['waterAmount'] ?? 0).toDouble(),
      roomRent: (json['roomRent'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: billStatusFromString(json['status'] ?? 'unpaid'),
      slipImageBase64: json['slipImageBase64'],
      slipUploadedAt: json['slipUploadedAt'] != null
          ? DateTime.tryParse(json['slipUploadedAt'].toString())
          : null,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'].toString())
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
      'previousWaterUnit': previousWaterUnit,
      'currentWaterUnit': currentWaterUnit,
      'waterUnitsUsed': waterUnitsUsed,
      'waterRate': waterRate,
      'waterAmount': waterAmount,
      'roomRent': roomRent,
      'totalAmount': totalAmount,
      'status': status.name,
      'slipImageBase64': slipImageBase64,
      'slipUploadedAt': slipUploadedAt?.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
