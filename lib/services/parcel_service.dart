import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parcel_model.dart';

/// ParcelService จัดการ Firestore collection "parcels"
class ParcelService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('parcels');

  Future<void> addParcel(ParcelModel parcel) async {
    await _collection.add(parcel.toJson());
  }

  /// ผู้พัก: ดูเฉพาะพัสดุของห้องตัวเอง
  Stream<List<ParcelModel>> watchForRoom(String room) {
    return _collection
        .where('room', isEqualTo: room)
        .snapshots()
        .map(_mapAndSort);
  }

  /// แอดมิน: ดูพัสดุทุกห้อง
  Stream<List<ParcelModel>> watchAll() {
    return _collection.snapshots().map(_mapAndSort);
  }

  Future<void> markReceived(String id) async {
    await _collection.doc(id).update({
      'status': ParcelStatus.received.name,
      'receivedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteParcel(String id) async {
    await _collection.doc(id).delete();
  }

  static List<ParcelModel> _mapAndSort(QuerySnapshot<Map<String, dynamic>> snap) {
    return snap.docs.map((d) => ParcelModel.fromJson(d.data(), d.id)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
