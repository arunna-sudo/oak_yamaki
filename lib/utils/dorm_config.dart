/// ข้อมูลหอพักที่แสดงในส่วนหัวของหน้าแรกและหน้า "ข้อมูลหอพัก"
/// แก้ค่าตรงนี้ให้ตรงกับหอพักจริงได้เลย
class DormConfig {
  DormConfig._();

  static const String dormName = 'Hugo condo';
  static const String building = 'ตึก A';

  /// เว้นว่างไว้ได้ ถ้าไม่อยากให้แสดงที่อยู่
  static const String address =
      '81,81/1,86,111 หมู่ที่ 12 ถนน มาลัยแมน ต.กำแพงแสน อ.กำแพงแสน จ.นครปฐม';

  /// เบอร์โทรติดต่อหอพัก (ใส่กี่เบอร์ก็ได้)
  static const List<String> phones = ['061-853-3344', '094-881-8944'];
  static const String email = 'siripatplace@gmail.com';

  /// บัญชีธนาคารสำหรับโอนค่าเช่า
  static const String bankName = 'ธนาคารกรุงเทพ';
  static const String bankAccountName = 'บริษัท สิริภัสร์';
  static const String bankAccountNumber = '2130299908';

  static String get fullName => '$dormName ($building)';
}
