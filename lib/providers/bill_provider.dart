import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/bill_model.dart';
import '../services/bill_service.dart';
import '../services/user_service.dart';
import '../services/utility_bill_service.dart';
import 'loading_state_mixin.dart';

/// BillProvider คือ Controller ที่เชื่อมระหว่าง UI, UtilityBillService (คำนวณ)
/// และ BillService (บันทึกลง Firestore) ตามสถาปัตยกรรมในบทเรียนที่ 7:
/// UI -> Controller -> Service (คำนวณ) -> Controller -> Service (บันทึก Cloud)
///
/// - ฝั่งผู้พัก: start(email) เพื่อฟังบิลของตัวเองแบบเรียลไทม์
/// - ฝั่งแอดมิน: calculate() + saveBillForResident() เพื่อออกบิลให้ห้องที่เลือก
class BillProvider extends ChangeNotifier with LoadingStateMixin {
  final BillService _billService = BillService();
  final UtilityBillService _utilityService = UtilityBillService();
  final UserService _userService = UserService();
  StreamSubscription<List<BillModel>>? _subscription;

  List<BillModel> _bills = [];
  List<BillModel> get bills => _bills;

  // จำนวนสลิปที่ยังรอแอดมินตรวจสอบ (รวมทุกห้อง) ใช้แสดง badge บนกระดิ่งของแอดมิน
  int _adminPendingSlipCount = 0;
  int get adminPendingSlipCount => _adminPendingSlipCount;

  /// เรียกตอนแอดมินเข้าหน้าแรก เพื่อโหลดจำนวนสลิปที่รอตรวจสอบของทุกห้อง
  Future<void> startForAdmin() => refreshAdminPendingSlips();

  /// รีเฟรชจำนวนสลิปที่รอตรวจสอบ (เรียกซ้ำได้ เช่น pull-to-refresh
  /// หรือหลังแอดมินกลับมาจากหน้าตรวจสลิป)
  Future<void> refreshAdminPendingSlips() async {
    try {
      final residents = await _userService.watchAllResidents().first;
      final emails = residents.map((r) => r.email).where((e) => e.isNotEmpty).toList();
      final pending = await _billService.fetchPendingSlipsForEmails(emails);
      _adminPendingSlipCount = pending.length;
      notifyListeners();
    } catch (_) {
      // เงียบไว้ ไม่รบกวนแอดมินด้วย error ทุกครั้งที่รีเฟรชพื้นหลัง
    }
  }

  void start(String email) {
    _bills = []; // กันข้อมูลของผู้ใช้คนก่อนค้างอยู่
    setLoading(true);
    _subscription?.cancel();
    _subscription = _billService.watchBills(email).listen((data) {
      _bills = data;
      setLoading(false);
    }, onError: (e) {
      setError(e.toString());
      setLoading(false);
    });
  }

  /// คำนวณด้วย UtilityBillService แล้วคืนผลให้ UI แสดง (ไม่แตะ state ของ provider)
  UtilityBillResult calculate({
    required double previousElectricUnit,
    required double currentElectricUnit,
    required double previousWaterUnit,
    required double currentWaterUnit,
    required double waterRatePerUnit,
    required double roomRent,
  }) {
    return _utilityService.calculateBill(
      previousElectricUnit: previousElectricUnit,
      currentElectricUnit: currentElectricUnit,
      previousWaterUnit: previousWaterUnit,
      currentWaterUnit: currentWaterUnit,
      waterRatePerUnit: waterRatePerUnit,
      roomRent: roomRent,
    );
  }

  /// ใช้โดยแอดมิน: บันทึกบิลลงในคอลเลกชันของ "ผู้พักที่เลือก" (bills_<email ผู้พัก>)
  /// เพื่อให้บิลไปโผล่ที่หน้าค่าเช่าของผู้พักคนนั้น ไม่ใช่ของแอดมินเอง
  Future<bool> saveBillForResident({
    required String residentEmail,
    required String month,
    required double previousElectricUnit,
    required double currentElectricUnit,
    required double previousWaterUnit,
    required double currentWaterUnit,
    required UtilityBillResult calc,
  }) async {
    final result = await runWithLoading(() async {
      await _billService.addBill(
        residentEmail,
        BillModel(
          id: '',
          month: month,
          previousUnit: previousElectricUnit,
          currentUnit: currentElectricUnit,
          unitsUsed: calc.electricityUnits,
          electricityAmount: calc.electricityAmount,
          previousWaterUnit: previousWaterUnit,
          currentWaterUnit: currentWaterUnit,
          waterUnitsUsed: calc.waterUnits,
          waterRate: calc.waterRate,
          waterAmount: calc.waterAmount,
          roomRent: calc.roomRent,
          totalAmount: calc.totalAmount,
          status: BillStatus.unpaid,
          createdAt: DateTime.now(),
        ),
      );
      return true;
    });
    return result ?? false;
  }

  Future<bool> uploadSlip({
    required String email,
    required String billId,
    required List<int> imageBytes,
  }) async {
    final result = await runWithLoading(() async {
      final base64Image = base64Encode(imageBytes);
      await _billService.uploadSlip(email, billId, base64Image);
      return true;
    });
    return result ?? false;
  }

  Future<void> reviewSlip({
    required String email,
    required String billId,
    required bool approved,
  }) async {
    await _billService.reviewSlip(email, billId, approved);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
