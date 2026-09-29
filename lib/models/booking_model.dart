enum BookingStatus { confirmed, cancelled }

BookingStatus bookingStatusFromString(String value) {
  return BookingStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => BookingStatus.confirmed,
  );
}

/// การจองห้องส่วนกลาง เก็บใน Firestore collection "bookings"
/// date เก็บเป็นข้อความ 'yyyy-MM-dd' และเวลาเป็นชั่วโมงเต็ม (startHour ถึง endHour)
class BookingModel {
  final String id;
  final String facilityId;
  final String facilityName;
  final String date;
  final int startHour;
  final int endHour; // ไม่รวมชั่วโมงนี้ เช่น 10-12 = 10:00 ถึง 12:00
  final String uid;
  final String room;
  final String userName;
  final BookingStatus status;
  final String? cancelledBy; // 'admin' หรือ 'user'
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.facilityId,
    required this.facilityName,
    required this.date,
    required this.startHour,
    required this.endHour,
    required this.uid,
    required this.room,
    required this.userName,
    this.status = BookingStatus.confirmed,
    this.cancelledBy,
    required this.createdAt,
  });

  DateTime _at(int hour) {
    final p = date.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]), hour);
  }

  DateTime get startTime => _at(startHour);
  DateTime get endTime => _at(endHour);

  /// ชั่วโมงทั้งหมดที่จองไว้ เช่น 10-12 => [10, 11]
  List<int> get hours => [for (var h = startHour; h < endHour; h++) h];

  bool get isActive =>
      status == BookingStatus.confirmed && endTime.isAfter(DateTime.now());

  String get timeRange =>
      '${startHour.toString().padLeft(2, '0')}:00–${endHour.toString().padLeft(2, '0')}:00';

  factory BookingModel.fromJson(Map<String, dynamic> json, String id) {
    return BookingModel(
      id: id,
      facilityId: json['facilityId'] ?? '',
      facilityName: json['facilityName'] ?? '',
      date: json['date'] ?? '1970-01-01',
      startHour: (json['startHour'] ?? 0).toInt(),
      endHour: (json['endHour'] ?? 0).toInt(),
      uid: json['uid'] ?? '',
      room: json['room'] ?? '',
      userName: json['userName'] ?? '',
      status: bookingStatusFromString(json['status'] ?? 'confirmed'),
      cancelledBy: json['cancelledBy'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facilityId': facilityId,
      'facilityName': facilityName,
      'date': date,
      'startHour': startHour,
      'endHour': endHour,
      'uid': uid,
      'room': room,
      'userName': userName,
      'status': status.name,
      'cancelledBy': cancelledBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
