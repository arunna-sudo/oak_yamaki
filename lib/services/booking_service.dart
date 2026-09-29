import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

/// จองซ้ำห้องเดียวกัน/ช่วงเวลาทับกัน
class BookingConflictException implements Exception {}

/// ผู้จองมีการจองห้องอื่นในช่วงเวลาเดียวกันอยู่แล้ว
class BookingOverlapException implements Exception {
  final String facilityName;
  BookingOverlapException(this.facilityName);
}

/// BookingService กันการจองซ้ำด้วย "เอกสารล็อก" collection booking_locks
/// หนึ่งชั่วโมงของหนึ่งห้อง = หนึ่งเอกสาร (id = ห้อง_วันที่_ชั่วโมง)
/// ตอนจองใช้ transaction เช็คว่ายังไม่มีเอกสารล็อกก่อนจึงเขียน
/// ทำให้ต่อให้ 2 คนกดพร้อมกัน จะมีคนเดียวที่จองสำเร็จ
class BookingService {
  /// ตั้งเป็น true ถ้าอนุญาตให้ผู้พักคนเดียวจองหลายห้องในเวลาเดียวกันได้
  static const bool allowOverlapAcrossRooms = false;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _bookings => _db.collection('bookings');
  CollectionReference<Map<String, dynamic>> get _locks => _db.collection('booking_locks');

  static String lockId(String facilityId, String date, int hour) =>
      '${facilityId}_${date}_$hour';

  List<BookingModel> _mapDocs(QuerySnapshot<Map<String, dynamic>> snap) =>
      snap.docs.map((d) => BookingModel.fromJson(d.data(), d.id)).toList();

  /// การจองทุกห้องของวันที่เลือก (ใช้แสดงว่าช่วงไหนว่าง/ไม่ว่าง)
  Stream<List<BookingModel>> watchForDate(String date) {
    return _bookings.where('date', isEqualTo: date).snapshots().map(_mapDocs);
  }

  Stream<List<BookingModel>> watchMine(String uid) {
    return _bookings.where('uid', isEqualTo: uid).snapshots().map(_mapDocs);
  }

  Stream<List<BookingModel>> watchAll() {
    return _bookings.snapshots().map(_mapDocs);
  }

  Future<void> createBooking(BookingModel booking) async {
    if (!allowOverlapAcrossRooms) {
      final mine = await _bookings.where('uid', isEqualTo: booking.uid).get();
      for (final b in _mapDocs(mine)) {
        if (b.status == BookingStatus.confirmed &&
            b.date == booking.date &&
            b.startHour < booking.endHour &&
            booking.startHour < b.endHour) {
          throw BookingOverlapException(b.facilityName);
        }
      }
    }

    await _db.runTransaction((tx) async {
      final lockRefs = [
        for (final h in booking.hours)
          _locks.doc(lockId(booking.facilityId, booking.date, h)),
      ];
      // ใน transaction ต้องอ่านทั้งหมดก่อนแล้วค่อยเขียน
      for (final ref in lockRefs) {
        final snap = await tx.get(ref);
        if (snap.exists) throw BookingConflictException();
      }
      final bookingRef = _bookings.doc();
      tx.set(bookingRef, booking.toJson());
      for (final ref in lockRefs) {
        tx.set(ref, {'bookingId': bookingRef.id, 'uid': booking.uid});
      }
    });
  }

  Future<void> cancelBooking(BookingModel booking, {required bool byAdmin}) async {
    final batch = _db.batch();
    batch.update(_bookings.doc(booking.id), {
      'status': BookingStatus.cancelled.name,
      'cancelledBy': byAdmin ? 'admin' : 'user',
      'cancelledAt': DateTime.now().toIso8601String(),
    });
    for (final h in booking.hours) {
      batch.delete(_locks.doc(lockId(booking.facilityId, booking.date, h)));
    }
    await batch.commit();
  }
}
