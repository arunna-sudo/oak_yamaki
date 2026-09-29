/// โมเดลข้อมูลผู้ใช้ (ผู้พักอาศัย/ผู้ดูแลหอพัก)
/// เก็บใน Firestore collection ชื่อ "users" โดยใช้ uid ของ Firebase Auth เป็น document id
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String room;
  final String role; // 'admin' หรือ 'resident'
  final DateTime? createdAt;
  // true = แอดมินยืนยันแล้ว ใช้งานแอปได้ตามปกติ
  // false = สมัครใหม่ รอแอดมินตรวจสอบและกดยืนยันก่อน
  final bool isApproved;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.room,
    this.role = 'resident',
    this.createdAt,
    this.isApproved = true,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json, String uid) {
    return UserModel(
      uid: uid,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      room: json['room'] ?? '',
      role: json['role'] ?? 'resident',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      // ผู้ใช้เดิมที่ยังไม่มีฟิลด์นี้ในฐานข้อมูล ถือว่ายืนยันแล้ว (true) เพื่อไม่ให้ถูกล็อกออก
      isApproved: json['isApproved'] is bool ? json['isApproved'] as bool : true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'room': room,
      'role': role,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'isApproved': isApproved,
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? room,
    String? role,
    bool? isApproved,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      room: room ?? this.room,
      role: role ?? this.role,
      createdAt: createdAt,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}
