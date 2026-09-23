import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// UserService ติดต่อกับ Firestore collection "users" เท่านั้น
/// (แยก logic การจัดการข้อมูลออกจาก UI ตามที่สอนใน Lecture 7)
class UserService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('users');

  Future<void> createUserProfile(UserModel user) async {
    await _collection.doc(user.uid).set(user.toJson());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _collection.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromJson(doc.data()!, uid);
  }

  Stream<UserModel?> watchUserProfile(String uid) {
    return _collection.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromJson(doc.data()!, uid);
    });
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _collection.doc(uid).update(data);
  }

  /// ใช้โดย Admin เท่านั้น: ดูรายชื่อผู้พักอาศัยทั้งหมด
  Stream<List<UserModel>> watchAllResidents() {
    return _collection.orderBy('room').snapshots().map((snap) => snap.docs
        .map((d) => UserModel.fromJson(d.data(), d.id))
        .toList());
  }
}
