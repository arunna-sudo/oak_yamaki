import 'dart:convert';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

/// บันทึกรูป (base64) ลงเครื่องผู้ใช้
/// - Flutter Web: เบราว์เซอร์ดาวน์โหลดไฟล์ให้
/// - Android/iOS/Desktop: บันทึกเป็นไฟล์รูปในเครื่อง (ผ่านแพ็กเกจ file_saver)
class ImageSaver {
  ImageSaver._();

  /// คืน true เมื่อบันทึกสำเร็จ
  static Future<bool> saveBase64(String base64Data, {required String fileName}) async {
    try {
      final Uint8List bytes = base64Decode(base64Data);
      final isPng = bytes.length > 3 && bytes[0] == 0x89 && bytes[1] == 0x50;
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        ext: isPng ? 'png' : 'jpg',
        mimeType: isPng ? MimeType.png : MimeType.jpeg,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
