import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

/// WeatherService สาธิตการเรียกใช้ REST API ตามขั้นตอนใน Lecture 8:
/// 1. เพิ่ม package http ใน pubspec.yaml
/// 2. ใช้ async/await ไม่บล็อก UI
/// 3. decode JSON เป็น Dart object (Model)
/// 4. ใช้ try-catch จัดการ error
/// 5. แยก logic การเรียก API ออกจาก UI (Service Class)
///
/// ใช้ Open-Meteo (https://open-meteo.com) เพราะเป็น REST API ฟรี ไม่ต้องใช้ API key
/// และรองรับ HTTPS (ต่างจาก ip-api ตัวอย่างในสไลด์ที่รองรับเฉพาะ http)
class WeatherService {
  /// พิกัดตั้งต้นเป็นกรุงเทพฯ ผู้ใช้ในโปรเจกต์จริงสามารถส่งพิกัดของหอพักเข้ามาแทนได้
  Future<WeatherModel> fetchCurrentWeather({
    double latitude = 13.7563,
    double longitude = 100.5018,
  }) async {
    final apiUrl = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitude&longitude=$longitude&current_weather=true',
    );

    try {
      final response = await http.get(apiUrl).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        return WeatherModel.fromJson(jsonMap);
      } else {
        throw Exception('เรียกข้อมูลสภาพอากาศไม่สำเร็จ (สถานะ ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('ไม่สามารถเชื่อมต่อ API สภาพอากาศได้: $e');
    }
  }
}
