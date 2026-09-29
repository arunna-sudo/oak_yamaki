/// ผลลัพธ์การคำนวณบิลค่าไฟ + ค่าน้ำ + ค่าเช่าห้อง
class UtilityBillResult {
  final double electricityUnits;
  final double electricityAmount;
  final double electricityRatePerUnit; // อัตราเฉลี่ยจากแบบขั้นบันได
  final double waterUnits;
  final double waterRate;
  final double waterAmount;
  final double roomRent;
  final double totalAmount;

  UtilityBillResult({
    required this.electricityUnits,
    required this.electricityAmount,
    required this.electricityRatePerUnit,
    required this.waterUnits,
    required this.waterRate,
    required this.waterAmount,
    required this.roomRent,
    required this.totalAmount,
  });
}

/// UtilityBillService ทำหน้าที่ "คำนวณ" ล้วนๆ ไม่รู้เรื่องหน้าจอ (ตามหลักการ Lecture 7)
///
/// - ค่าไฟ: อัตราขั้นบันไดอย่างง่าย (เพื่อการศึกษา ไม่ใช่อัตราจริงล่าสุดของ กฟน./กฟภ.)
/// - ค่าน้ำ: หน่วยที่ใช้ x อัตราต่อหน่วย (กำหนดได้ตอนออกบิล)
class UtilityBillService {
  static const double _tier1Rate = 4.5; // หน่วยที่ 1-150
  static const double _tier2Rate = 5.5; // หน่วยที่ 151-400
  static const double _tier3Rate = 6.5; // หน่วยที่ 401 ขึ้นไป

  UtilityBillResult calculateBill({
    required double previousElectricUnit,
    required double currentElectricUnit,
    required double previousWaterUnit,
    required double currentWaterUnit,
    required double waterRatePerUnit,
    required double roomRent,
  }) {
    if (currentElectricUnit < previousElectricUnit) {
      throw ArgumentError('เลขมิเตอร์ไฟปัจจุบันต้องมากกว่าหรือเท่ากับครั้งก่อน');
    }
    if (currentWaterUnit < previousWaterUnit) {
      throw ArgumentError('เลขมิเตอร์น้ำปัจจุบันต้องมากกว่าหรือเท่ากับครั้งก่อน');
    }

    final electricityUnits = currentElectricUnit - previousElectricUnit;
    final electricityAmount = _calculateTieredAmount(electricityUnits);
    final effectiveRate = electricityUnits == 0 ? 0.0 : electricityAmount / electricityUnits;

    final waterUnits = currentWaterUnit - previousWaterUnit;
    final waterAmount = waterUnits * waterRatePerUnit;

    return UtilityBillResult(
      electricityUnits: electricityUnits,
      electricityAmount: electricityAmount,
      electricityRatePerUnit: effectiveRate,
      waterUnits: waterUnits,
      waterRate: waterRatePerUnit,
      waterAmount: waterAmount,
      roomRent: roomRent,
      totalAmount: electricityAmount + waterAmount + roomRent,
    );
  }

  double _calculateTieredAmount(double units) {
    double remaining = units;
    double amount = 0;

    final tier1 = remaining.clamp(0, 150).toDouble();
    amount += tier1 * _tier1Rate;
    remaining -= tier1;
    if (remaining <= 0) return amount;

    final tier2 = remaining.clamp(0, 250).toDouble(); // 151-400 => 250 หน่วย
    amount += tier2 * _tier2Rate;
    remaining -= tier2;
    if (remaining <= 0) return amount;

    amount += remaining * _tier3Rate;
    return amount;
  }
}
