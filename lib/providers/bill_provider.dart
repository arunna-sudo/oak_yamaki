import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/bill_model.dart';
import '../services/bill_service.dart';
import '../services/electricity_service.dart';
import 'loading_state_mixin.dart';

/// BillProvider คือ Controller ที่เชื่อมระหว่าง UI, ElectricityService (คำนวณ)
/// และ BillService (บันทึกลง Firestore) ตามสถาปัตยกรรมในบทเรียนที่ 7:
/// UI -> Controller -> Service (คำนวณ) -> Controller -> Service (บันทึก Cloud)
class BillProvider extends ChangeNotifier with LoadingStateMixin {
  final BillService _billService = BillService();
  final ElectricityService _electricityService = ElectricityService();
  StreamSubscription<List<BillModel>>? _subscription;

  List<BillModel> _bills = [];
  List<BillModel> get bills => _bills;

  ElectricityCalculationResult? _lastCalculation;
  ElectricityCalculationResult? get lastCalculation => _lastCalculation;

  void start(String email) {
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

  /// คำนวณค่าไฟด้วย ElectricityService แล้วเก็บผลลัพธ์ไว้ให้ UI แสดง
  ElectricityCalculationResult calculate({
    required double previousUnit,
    required double currentUnit,
    required double roomRent,
  }) {
    final result = _electricityService.calculateBill(
      previousUnit: previousUnit,
      currentUnit: currentUnit,
      roomRent: roomRent,
    );
    _lastCalculation = result;
    notifyListeners();
    return result;
  }

  Future<bool> saveBillFromCalculation({
    required String email,
    required String month,
    required double previousUnit,
    required double currentUnit,
    required ElectricityCalculationResult calc,
  }) async {
    final result = await runWithLoading(() async {
      await _billService.addBill(
        email,
        BillModel(
          id: '',
          month: month,
          previousUnit: previousUnit,
          currentUnit: currentUnit,
          unitsUsed: calc.unitsUsed,
          electricityAmount: calc.electricityAmount,
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
