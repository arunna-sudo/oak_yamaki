import 'dart:async';
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/facility_model.dart';
import '../models/user_model.dart';
import '../services/booking_service.dart';
import 'loading_state_mixin.dart';

class BookingProvider extends ChangeNotifier with LoadingStateMixin {
  final BookingService _service = BookingService();
  StreamSubscription<List<BookingModel>>? _daySub;
  StreamSubscription<List<BookingModel>>? _listSub;

  List<BookingModel> _dayBookings = [];
  List<BookingModel> get dayBookings => _dayBookings;

  bool _dayLoading = false;
  bool get dayLoading => _dayLoading;

  String? _dayError;
  String? get dayError => _dayError;

  /// รายการสำหรับหน้า "การจองของฉัน" (ผู้พัก) หรือ "จัดการการจอง" (แอดมิน)
  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => _bookings;

  void watchDate(String date) {
    _daySub?.cancel();
    _dayBookings = [];
    _dayLoading = true;
    _dayError = null;
    notifyListeners();
    _daySub = _service.watchForDate(date).listen((data) {
      _dayBookings = data;
      _dayLoading = false;
      notifyListeners();
    }, onError: (e) {
      _dayError = e.toString();
      _dayLoading = false;
      notifyListeners();
    });
  }

  void startMine(String uid) => _listen(_service.watchMine(uid));

  void startAll() => _listen(_service.watchAll());

  void _listen(Stream<List<BookingModel>> stream) {
    _bookings = [];
    setLoading(true);
    _listSub?.cancel();
    _listSub = stream.listen((data) {
      _bookings = data;
      setLoading(false);
    }, onError: (e) {
      setError(e.toString());
      setLoading(false);
    });
  }

  /// คืนค่า null เมื่อจองสำเร็จ หรือข้อความ error ภาษาไทยเมื่อจองไม่ได้
  Future<String?> createBooking({
    required FacilityModel facility,
    required String date,
    required int startHour,
    required int endHour,
    required UserModel user,
  }) async {
    try {
      await _service.createBooking(BookingModel(
        id: '',
        facilityId: facility.id,
        facilityName: facility.name,
        date: date,
        startHour: startHour,
        endHour: endHour,
        uid: user.uid,
        room: user.room,
        userName: user.name,
        createdAt: DateTime.now(),
      ));
      return null;
    } on BookingConflictException {
      return 'ช่วงเวลานี้มีผู้จองแล้ว กรุณาเลือกเวลาอื่น';
    } on BookingOverlapException catch (e) {
      return 'คุณจอง${e.facilityName}ในช่วงเวลานี้ไว้แล้ว ไม่สามารถจองพร้อมกันได้';
    } catch (e) {
      return 'จองไม่สำเร็จ: $e';
    }
  }

  Future<String?> cancelBooking(BookingModel booking, {required bool byAdmin}) async {
    try {
      await _service.cancelBooking(booking, byAdmin: byAdmin);
      return null;
    } catch (e) {
      return 'ยกเลิกไม่สำเร็จ: $e';
    }
  }

  @override
  void dispose() {
    _daySub?.cancel();
    _listSub?.cancel();
    super.dispose();
  }
}
