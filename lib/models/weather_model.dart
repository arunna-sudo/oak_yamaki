/// โมเดลสภาพอากาศ แปลงมาจาก JSON ที่ได้จาก Open-Meteo REST API
/// (https://api.open-meteo.com) ตามขั้นตอนที่สอนใน Lecture 8: Working with API
/// คือ 1) เรียก API เพื่อดู JSON ตัวอย่าง 2) สร้าง Class รองรับโครงสร้างนั้น
///
/// ใช้แสดงผลบนหน้า Home เป็นฟีเจอร์ "วันนี้ควรตากผ้าไหม" สำหรับผู้พักหอพัก
class WeatherModel {
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final DateTime time;

  WeatherModel({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.time,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current_weather'] ?? json['current'] ?? {};
    return WeatherModel(
      temperature: (current['temperature'] ?? 0).toDouble(),
      windSpeed: (current['windspeed'] ?? 0).toDouble(),
      weatherCode: (current['weathercode'] ?? 0) is int
          ? current['weathercode']
          : int.tryParse(current['weathercode'].toString()) ?? 0,
      time: current['time'] != null
          ? DateTime.tryParse(current['time'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// แปลรหัสสภาพอากาศ (WMO Weather code) เป็นข้อความและไอคอนภาษาไทยอย่างง่าย
  String get description {
    if (weatherCode == 0) return 'ท้องฟ้าแจ่มใส';
    if (weatherCode <= 2) return 'มีเมฆบางส่วน';
    if (weatherCode == 3) return 'เมฆมาก';
    if (weatherCode >= 45 && weatherCode <= 48) return 'มีหมอก';
    if (weatherCode >= 51 && weatherCode <= 67) return 'ฝนตกปรอยๆ';
    if (weatherCode >= 80 && weatherCode <= 82) return 'ฝนตกเป็นช่วง';
    if (weatherCode >= 95) return 'พายุฝนฟ้าคะนอง';
    return 'สภาพอากาศทั่วไป';
  }

  bool get isRainy =>
      (weatherCode >= 51 && weatherCode <= 67) ||
      (weatherCode >= 80 && weatherCode <= 99);

  String get laundryAdvice => isRainy
      ? 'ฝนอาจตก วันนี้ควรตากผ้าในที่ร่มหรือใช้เครื่องอบผ้านะ'
      : 'อากาศดี วันนี้ตากผ้ากลางแจ้งได้สบายเลย';
}
