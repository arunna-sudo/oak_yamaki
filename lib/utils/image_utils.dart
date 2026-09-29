import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

/// ตัวช่วยเลือกรูปจากคลังภาพ แล้วแปลงเป็น base64 เพื่อเก็บใน Firestore
/// (โปรเจกต์นี้ไม่ใช้ Firebase Storage จึงเก็บรูปเป็น base64 ในเอกสารโดยตรง
/// ซึ่ง Firestore จำกัดขนาดเอกสารไม่เกิน 1 MiB จึงต้องย่อรูปและจำกัดขนาดรวม)
class ImageUtils {
  ImageUtils._();

  /// ขนาด base64 รวมสูงสุดต่อ 1 เอกสาร (อักขระ) เหลือที่ไว้ให้ข้อความและ field อื่น
  static const int maxTotalBase64Chars = 700000;

  static final ImagePicker _picker = ImagePicker();

  static Future<List<Uint8List>> pickImages({int maxCount = 1}) async {
    if (maxCount <= 0) return [];
    if (maxCount == 1) {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 65,
      );
      if (file == null) return [];
      return [await file.readAsBytes()];
    }
    final files = await _picker.pickMultiImage(maxWidth: 1024, imageQuality: 65);
    final result = <Uint8List>[];
    for (final file in files.take(maxCount)) {
      result.add(await file.readAsBytes());
    }
    return result;
  }

  static int base64Length(Iterable<Uint8List> images) {
    return images.fold<int>(0, (sum, bytes) => sum + ((bytes.length + 2) ~/ 3) * 4);
  }

  static bool fitsInDocument(Iterable<Uint8List> images) {
    return base64Length(images) <= maxTotalBase64Chars;
  }

  static String encode(Uint8List bytes) => base64Encode(bytes);
}
