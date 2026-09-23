import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bill_model.dart';

/// BillService สาธิตแนวทางตาม Lecture 11 (Authentication with Firebase):
/// "การระบุ collection name ที่ใช้ในการเก็บข้อมูล จะเปลี่ยนไปตามชื่อผู้ใช้ที่ login
/// โดยมีรูปแบบคือ electricity_bills_<ชื่อ email ที่ทำการ login>"
///
/// ในแอปนี้ใช้ชื่อ collection แบบ bills_<sanitized-email>
/// ทำให้ข้อมูลบิลของผู้พักแต่ละคนถูกแยกเก็บเป็นอิสระต่อกัน
class BillService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// email อาจมีอักขระที่ใช้เป็นชื่อ collection ไม่ได้สวยงาม จึงแทนที่
  /// เครื่องหมาย @ และ . ด้วย _ เพื่อความปลอดภัยของชื่อ collection
  String collectionNameFor(String email) {
    final sanitized = email.replaceAll('@', '_at_').replaceAll('.', '_dot_');
    return 'bills_$sanitized';
  }

  CollectionReference<Map<String, dynamic>> _collectionFor(String email) {
    return _db.collection(collectionNameFor(email));
  }

  Stream<List<BillModel>> watchBills(String email) {
    return _collectionFor(email).snapshots().map((snap) => snap.docs
        .map((d) => BillModel.fromJson(d.data(), d.id))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  Future<void> addBill(String email, BillModel bill) async {
    await _collectionFor(email).add(bill.toJson());
  }

  Future<void> uploadSlip(String email, String billId, String base64Image) async {
    await _collectionFor(email).doc(billId).update({
      'slipImageBase64': base64Image,
      'slipUploadedAt': DateTime.now().toIso8601String(),
      'status': BillStatus.pendingReview.name,
    });
  }

  Future<void> reviewSlip(String email, String billId, bool approved) async {
    await _collectionFor(email).doc(billId).update({
      'status': (approved ? BillStatus.approved : BillStatus.rejected).name,
    });
  }

  /// ใช้โดย Admin: รวมบิลที่รออนุมัติของ "ทุกห้อง"
  /// เนื่องจากแต่ละห้องมี collection แยกกัน จึงต้องอาศัยรายชื่ออีเมลของผู้พัก
  /// ทั้งหมด (จาก users collection) มาประกอบการ query ทีละ collection
  Future<List<MapEntry<String, BillModel>>> fetchPendingSlipsForEmails(
      List<String> emails) async {
    final result = <MapEntry<String, BillModel>>[];
    for (final email in emails) {
      final snap = await _collectionFor(email)
          .where('status', isEqualTo: BillStatus.pendingReview.name)
          .get();
      for (final doc in snap.docs) {
        result.add(MapEntry(email, BillModel.fromJson(doc.data(), doc.id)));
      }
    }
    return result;
  }
}
