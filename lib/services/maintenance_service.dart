import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/maintenance_model.dart';

/// MaintenanceService จัดการ Firestore collection "maintenance_requests"
class MaintenanceService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('maintenance_requests');

  Future<void> createRequest(MaintenanceModel request) async {
    await _collection.add(request.toJson());
  }

  /// ใช้โดยผู้พักอาศัย: ดูเฉพาะคำขอของตนเอง
  Stream<List<MaintenanceModel>> watchMyRequests(String uid) {
    return _collection.where('uid', isEqualTo: uid).snapshots().map((snap) =>
        snap.docs.map((d) => MaintenanceModel.fromJson(d.data(), d.id)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  /// ใช้โดย Admin: ดูคำขอทุกห้อง
  Stream<List<MaintenanceModel>> watchAllRequests() {
    return _collection.snapshots().map((snap) =>
        snap.docs.map((d) => MaintenanceModel.fromJson(d.data(), d.id)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  Future<void> updateStatus(String id, MaintenanceStatus status) async {
    await _collection.doc(id).update({'status': status.name});
  }
}
