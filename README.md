# DormEase 🏠 — แอปจัดการหอพัก

โปรเจกต์ Flutter นี้สร้างขึ้นให้ครอบคลุมเนื้อหาทุกบทเรียนที่อาจารย์สอน:

| บทเรียน | ใช้อยู่ตรงไหนในแอป |
|---|---|
| Form Builder & Validation | `pages/auth/*`, `pages/announcement/create_announcement_page.dart`, `pages/maintenance/create_maintenance_page.dart`, `pages/bills/electricity_calculator_page.dart`, `utils/validators.dart` |
| Project Structure & State Management (Provider, Mixin) | โครงสร้างโฟลเดอร์ `models/ pages/ services/ providers/ widgets/`, `providers/loading_state_mixin.dart` |
| Working with REST API | `services/weather_service.dart` + `models/weather_model.dart` (Open-Meteo API) |
| Persistence (SharedPreferences + Secure Storage) | `services/local_storage_service.dart`, `services/secure_storage_service.dart` |
| Cloud Firestore | `services/announcement_service.dart`, `services/maintenance_service.dart`, `services/bill_service.dart`, `services/user_service.dart` |
| Firebase Authentication | `services/auth_service.dart`, `providers/auth_provider.dart` |

## เริ่มต้นใช้งานแบบย่อ

1. สร้างโปรเจกต์ Flutter เปล่าด้วย `flutter create dorm_ease`
2. คัดลอกโฟลเดอร์ `lib/`, ไฟล์ `pubspec.yaml`, และโฟลเดอร์ `assets/` จากที่นี่ไปวางทับ
3. รัน `flutter pub get`
4. รัน `firebase login` แล้ว `flutterfire configure` เพื่อสร้างไฟล์ `lib/firebase_options.dart` ที่ถูกต้อง (ไฟล์ปัจจุบันเป็นเพียง placeholder)
5. เปิดใช้งาน Firebase Authentication (Email/Password) และสร้าง Firestore Database (Test mode) ใน Firebase Console
6. ตั้งค่าผู้ใช้คนแรกให้เป็น admin โดยแก้ field `role` เป็น `"admin"` ใน Firestore collection `users`
7. รัน `flutter run`

**คู่มือฉบับเต็มแบบทีละขั้นตอน (ภาษาไทย)**: ดูไฟล์ `DormEase_คู่มือติดตั้งและเรียนรู้.docx` ที่แนบมาพร้อมกัน
