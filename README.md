# DormEase 🏠 — แอปจัดการหอพัก

โปรเจกต์ Flutter นี้สร้างขึ้นให้ครอบคลุมเนื้อหาทุกบทเรียนที่อาจารย์สอน:

| บทเรียน | ใช้อยู่ตรงไหนในแอป |
|---|---|
| Form Builder & Validation | `pages/auth/*`, `pages/announcement/create_announcement_page.dart`, `pages/maintenance/create_maintenance_page.dart`, `pages/admin/admin_create_bill_page.dart`, `utils/validators.dart` |
| Project Structure & State Management (Provider, Mixin) | โครงสร้างโฟลเดอร์ `models/ pages/ services/ providers/ widgets/`, `providers/loading_state_mixin.dart` |
| Working with REST API | (ถอดฟีเจอร์สภาพอากาศออกแล้ว — แพ็กเกจ `http` ยังอยู่ใน pubspec.yaml) |
| Persistence (SharedPreferences + Secure Storage) | `services/local_storage_service.dart`, `services/secure_storage_service.dart` |
| Cloud Firestore | `services/announcement_service.dart`, `services/maintenance_service.dart`, `services/bill_service.dart`, `services/user_service.dart`, `services/post_service.dart` (โพสต์/คอมเมนต์คอมมูนิตี้) |
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


## ตั้งค่าข้อมูลหอพักที่แสดงหน้าแรก

แก้ชื่อหอ / ตึก / ที่อยู่ ได้ที่ `lib/utils/dorm_config.dart`

## Firestore collection ที่เพิ่มใหม่

- `community_posts` (+ sub-collection `comments`) — โพสต์และคอมเมนต์ในคอมมูนิตี้ (รูปเก็บเป็น base64 ใน field `images`)
- `announcements` มี field ใหม่ `imageBase64` (รูปประกอบประกาศ ไม่บังคับ)
- `bills_<email>` มี field ใหม่เกี่ยวกับค่าน้ำ: `previousWaterUnit`, `currentWaterUnit`, `waterUnitsUsed`, `waterRate`, `waterAmount`

ถ้าตั้ง Firestore Security Rules ไว้ ต้องเพิ่มสิทธิ์ให้ผู้ใช้ที่ล็อกอินอ่าน/เขียน `community_posts` ได้ และให้แอดมินเขียนลงใน `bills_*` ของผู้พักได้

## 🎨 อัปเดต UI (v7) และการเชื่อม Firebase

- ธีมใหม่ "Royal Blue & Soft Sky" ใน `lib/utils/app_theme.dart` (ฟอนต์ Prompt ผ่านแพ็กเกจ `google_fonts` — ต้องมีอินเทอร์เน็ตตอนโหลดฟอนต์ครั้งแรก)
- แอนิเมชันกลาง `lib/widgets/motion.dart`: `FadeSlideIn`, `Pressable`, `CountUp`, `GradientBackdrop`
- แถบนำทางล่างแบบลอย + เฟดสลับแท็บ (`pages/home/main_shell.dart`), หน้าแรกแบบแดชบอร์ด, Splash/Login แบบเคลื่อนไหว
- Firebase Project ที่เชื่อม: `sealoveboo` — กรอก `apiKey / appId / messagingSenderId` ใน `lib/firebase_options.dart`
  หรือรัน `flutterfire configure --project=sealoveboo`
- หลังแก้ pubspec ให้รัน `flutter pub get`
