/// ผลลัพธ์การคำนวณค่าไฟ แยกรายละเอียดไว้ให้ UI นำไปแสดงผลได้ง่าย
class ElectricityCalculationResult {
  final double unitsUsed;
  final double electricityAmount;
  final double roomRent;
  final double totalAmount;
  final double ratePerUnit;

  ElectricityCalculationResult({
    required this.unitsUsed,
    required this.electricityAmount,
    required this.roomRent,
    required this.totalAmount,
    required this.ratePerUnit,
  });
}

/// ElectricityService ทำหน้าที่ "คำนวณ" ล้วนๆ ไม่รู้เรื่องเกี่ยวกับหน้าจอ
/// (Service จะต้องเป็นอิสระจาก UI ตามหลักการใน Lecture 7)
/// สอดคล้องกับตัวอย่าง BmrService.calculateBMR() ในบทเรียน Structure of Project
///
/// สูตรคำนวณใช้อัตราค่าไฟฟ้าแบบขั้นบันไดอย่างง่าย (อ้างอิงแนวทางของ กฟน./กฟภ.
/// แบบย่อเพื่อการศึกษา ไม่ใช่อัตราจริงล่าสุด) บวกค่าเช่าห้องที่กำหนดได้เอง
class ElectricityService {
  /// อัตราค่าไฟฟ้าแบบขั้นบันได (บาท/หน่วย) แบบง่ายสำหรับหอพัก
  static const double _tier1Rate = 4.5; // หน่วยที่ 1-150
  static const double _tier2Rate = 5.5; // หน่วยที่ 151-400
  static const double _tier3Rate = 6.5; // หน่วยที่ 401 ขึ้นไป

  ElectricityCalculationResult calculateBill({
    required double previousUnit,
    required double currentUnit,
    required double roomRent,
  }) {
    if (currentUnit < previousUnit) {
      throw ArgumentError('เลขมิเตอร์ปัจจุบันต้องมากกว่าหรือเท่ากับเลขมิเตอร์ครั้งก่อน');
    }

    final unitsUsed = currentUnit - previousUnit;
    final electricityAmount = _calculateTieredAmount(unitsUsed);
    final effectiveRate = unitsUsed == 0 ? 0 : electricityAmount / unitsUsed;

    return ElectricityCalculationResult(
      unitsUsed: unitsUsed,
      electricityAmount: electricityAmount,
      roomRent: roomRent,
      totalAmount: electricityAmount + roomRent,
      ratePerUnit: effectiveRate.toDouble(),
    );
  }

  double _calculateTieredAmount(double units) {
    double remaining = units;
    double amount = 0;

    final tier1 = remaining.clamp(0, 150);
    amount += tier1 * _tier1Rate;
    remaining -= tier1;
    if (remaining <= 0) return amount;

    final tier2 = remaining.clamp(0, 250); // 151-400 => 250 หน่วย
    amount += tier2 * _tier2Rate;
    remaining -= tier2;
    if (remaining <= 0) return amount;

    amount += remaining * _tier3Rate;
    return amount;
  }
}
