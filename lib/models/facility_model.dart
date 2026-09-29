import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum FacilityType { meeting, game, movie }

extension FacilityTypeLabel on FacilityType {
  String get label {
    switch (this) {
      case FacilityType.meeting:
        return 'ห้องประชุม';
      case FacilityType.game:
        return 'ห้องเล่นเกม';
      case FacilityType.movie:
        return 'ห้องดูหนัง';
    }
  }

  IconData get icon {
    switch (this) {
      case FacilityType.meeting:
        return PhosphorIconsRegular.usersThree;
      case FacilityType.game:
        return PhosphorIconsRegular.gameController;
      case FacilityType.movie:
        return PhosphorIconsRegular.filmSlate;
    }
  }

  Color get color {
    switch (this) {
      case FacilityType.meeting:
        return const Color(0xFF2A6F6F);
      case FacilityType.game:
        return const Color(0xFF7C5CDB);
      case FacilityType.movie:
        return const Color(0xFFE0703B);
    }
  }
}

/// ห้องส่วนกลางที่จองได้ (กำหนดตายตัวในโค้ด ไม่ต้องเก็บใน Firestore)
class FacilityModel {
  final String id; // ใช้เป็นส่วนหนึ่งของ id เอกสารใน Firestore ห้ามเปลี่ยนหลังเริ่มใช้งาน
  final String name;
  final String? sizeLabel;
  final FacilityType type;

  const FacilityModel({
    required this.id,
    required this.name,
    required this.type,
    this.sizeLabel,
  });
}

/// รายการห้องทั้งหมด + ค่ากำหนดการจอง แก้ตัวเลขได้ตรงนี้
class FacilityConfig {
  FacilityConfig._();

  static const int openHour = 8; // เปิด 08:00
  static const int closeHour = 22; // ปิด 22:00 (ช่วงสุดท้ายเริ่ม 21:00)
  static const int maxHours = 3; // จองต่อครั้งได้สูงสุดกี่ชั่วโมง
  static const int advanceDays = 14; // จองล่วงหน้าได้กี่วัน (นับรวมวันนี้)

  static const List<FacilityModel> all = [
    FacilityModel(id: 'meeting_s', name: 'ห้องประชุมเล็ก', sizeLabel: 'ขนาดเล็ก', type: FacilityType.meeting),
    FacilityModel(id: 'meeting_m', name: 'ห้องประชุมกลาง', sizeLabel: 'ขนาดกลาง', type: FacilityType.meeting),
    FacilityModel(id: 'meeting_l', name: 'ห้องประชุมใหญ่', sizeLabel: 'ขนาดใหญ่', type: FacilityType.meeting),
    FacilityModel(id: 'game_1', name: 'ห้องเล่นเกม 1', type: FacilityType.game),
    FacilityModel(id: 'game_2', name: 'ห้องเล่นเกม 2', type: FacilityType.game),
    FacilityModel(id: 'game_3', name: 'ห้องเล่นเกม 3', type: FacilityType.game),
    FacilityModel(id: 'movie_1', name: 'ห้องดูหนัง 1', type: FacilityType.movie),
    FacilityModel(id: 'movie_2', name: 'ห้องดูหนัง 2', type: FacilityType.movie),
    FacilityModel(id: 'movie_3', name: 'ห้องดูหนัง 3', type: FacilityType.movie),
  ];

  static List<FacilityModel> ofType(FacilityType type) =>
      all.where((f) => f.type == type).toList();

  static FacilityModel? byId(String id) {
    for (final f in all) {
      if (f.id == id) return f;
    }
    return null;
  }

  static String hh(int hour) => '${hour.toString().padLeft(2, '0')}:00';

  static String get openingText => '${hh(openHour)}–${hh(closeHour)} น.';
}
