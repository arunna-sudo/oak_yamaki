import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/bill_model.dart';
import '../../models/user_model.dart';
import '../../providers/bill_provider.dart';
import '../../services/bill_service.dart';
import '../../services/user_service.dart';
import '../../services/utility_bill_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/format_utils.dart';
import '../../utils/validators.dart';

/// หน้าออกบิลค่าน้ำ-ค่าไฟ-ค่าเช่า สำหรับแอดมิน
/// 1) เลือกห้อง/ผู้พัก  2) เลขมิเตอร์ครั้งก่อนถูกเติมให้อัตโนมัติจากบิลล่าสุด
/// 3) กรอกมิเตอร์ครั้งนี้ -> คำนวณ -> ออกบิล
/// บิลจะถูกบันทึกในคอลเลกชันของผู้พักคนที่เลือก จึงไปแสดงที่หน้า "บิลค่าเช่า" ของเขา
class AdminCreateBillPage extends StatefulWidget {
  const AdminCreateBillPage({super.key});

  @override
  State<AdminCreateBillPage> createState() => _AdminCreateBillPageState();
}

class _AdminCreateBillPageState extends State<AdminCreateBillPage> {
  final _formKey = GlobalKey<FormState>();
  final BillService _billService = BillService();

  UserModel? _resident;
  BillModel? _lastBill;
  bool _loadingLast = false;
  bool _saving = false;
  UtilityBillResult? _result;

  final _month = TextEditingController(text: DateFormat('yyyy-MM').format(DateTime.now()));
  final _prevElectric = TextEditingController();
  final _curElectric = TextEditingController();
  final _prevWater = TextEditingController();
  final _curWater = TextEditingController();
  final _waterRate = TextEditingController(text: '18');
  final _rent = TextEditingController();

  List<TextEditingController> get _allControllers =>
      [_month, _prevElectric, _curElectric, _prevWater, _curWater, _waterRate, _rent];

  @override
  void dispose() {
    for (final c in _allControllers) {
      c.dispose();
    }
    super.dispose();
  }

  double _num(TextEditingController c) => double.parse(c.text.trim());

  void _invalidateResult(String _) {
    if (_result != null) setState(() => _result = null);
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.danger : AppColors.success,
      ),
    );
  }

  Future<void> _pickResident() async {
    final picked = await showModalBottomSheet<UserModel>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _ResidentPickerSheet(),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _resident = picked;
      _lastBill = null;
      _result = null;
      _prevElectric.clear();
      _curElectric.clear();
      _prevWater.clear();
      _curWater.clear();
      _rent.clear();
    });
    _loadLastBill(picked);
  }

  Future<void> _loadLastBill(UserModel resident) async {
    setState(() => _loadingLast = true);
    try {
      final last = await _billService.getLatestBill(resident.email);
      if (!mounted || _resident?.uid != resident.uid) return;
      setState(() {
        _lastBill = last;
        _loadingLast = false;
        if (last != null) {
          _prevElectric.text = formatUnit(last.currentUnit);
          _prevWater.text = formatUnit(last.currentWaterUnit);
          _rent.text = formatUnit(last.roomRent);
          if (last.waterRate > 0) _waterRate.text = formatUnit(last.waterRate);
        }
      });
    } catch (_) {
      if (mounted) setState(() => _loadingLast = false);
    }
  }

  /// ตรวจฟอร์ม + คำนวณ คืน null ถ้ายังกรอกไม่ครบ/ไม่ถูกต้อง
  UtilityBillResult? _compute() {
    if (_resident == null) {
      _snack('กรุณาเลือกห้องก่อน', error: true);
      return null;
    }
    if (_formKey.currentState?.validate() != true) return null;

    final prevE = _num(_prevElectric);
    final curE = _num(_curElectric);
    final prevW = _num(_prevWater);
    final curW = _num(_curWater);

    if (curE < prevE) {
      _snack('เลขมิเตอร์ไฟครั้งนี้ต้องมากกว่าหรือเท่ากับครั้งก่อน', error: true);
      return null;
    }
    if (curW < prevW) {
      _snack('เลขมิเตอร์น้ำครั้งนี้ต้องมากกว่าหรือเท่ากับครั้งก่อน', error: true);
      return null;
    }

    return context.read<BillProvider>().calculate(
          previousElectricUnit: prevE,
          currentElectricUnit: curE,
          previousWaterUnit: prevW,
          currentWaterUnit: curW,
          waterRatePerUnit: _num(_waterRate),
          roomRent: _num(_rent),
        );
  }

  void _calculate() {
    final result = _compute();
    if (result != null) setState(() => _result = result);
  }

  Future<void> _save() async {
    final resident = _resident;
    final result = _result;
    if (resident == null || result == null || _saving) return;
    final month = _month.text.trim();

    setState(() => _saving = true);

    try {
      final exists = await _billService.billExistsForMonth(resident.email, month);
      if (exists) {
        if (!mounted) return;
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('มีบิลเดือนนี้แล้ว'),
            content: Text('ห้อง ${resident.room} มีบิลของเดือน $month อยู่แล้ว ต้องการออกบิลซ้ำอีกใบหรือไม่?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ยกเลิก')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ออกบิลซ้ำ')),
            ],
          ),
        );
        if (proceed != true) {
          if (mounted) setState(() => _saving = false);
          return;
        }
      }
    } catch (_) {
      // ถ้าเช็คบิลซ้ำไม่ได้ (เช่นเน็ตหลุด) ปล่อยให้ขั้นตอนบันทึกจัดการ error ต่อ
    }

    if (!mounted) return;
    final success = await context.read<BillProvider>().saveBillForResident(
          residentEmail: resident.email,
          month: month,
          previousElectricUnit: _num(_prevElectric),
          currentElectricUnit: _num(_curElectric),
          previousWaterUnit: _num(_prevWater),
          currentWaterUnit: _num(_curWater),
          calc: result,
        );

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      _snack('ออกบิลให้ห้อง ${resident.room} เรียบร้อยแล้ว');
      setState(() {
        _resident = null;
        _lastBill = null;
        _result = null;
        _prevElectric.clear();
        _curElectric.clear();
        _prevWater.clear();
        _curWater.clear();
        _rent.clear();
      });
    } else {
      _snack('ออกบิลไม่สำเร็จ กรุณาลองใหม่', error: true);
    }
  }

  Widget _numberField(
    TextEditingController controller,
    String label,
    IconData? icon, {
    String? requiredMessage,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: _invalidateResult,
      validator: Validators.compose([
        Validators.required(errorMessage: requiredMessage ?? 'กรุณากรอก$label'),
        Validators.positiveNumber(),
      ]),
    );
  }

  Widget _sectionTitle(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resident = _resident;

    return Scaffold(
      appBar: AppBar(title: const Text('ออกบิลค่าน้ำ-ค่าไฟ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('เลือกห้อง', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const PhosphorIcon(PhosphorIconsDuotone.door, color: AppColors.primary),
                  title: Text(
                    resident == null
                        ? 'แตะเพื่อเลือกห้อง'
                        : (resident.room.isNotEmpty
                            ? 'ห้อง ${resident.room} · ${resident.name}'
                            : resident.name),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: resident == null ? AppColors.textMuted : null,
                    ),
                  ),
                  subtitle: resident == null ? null : Text(resident.email),
                  trailing: const PhosphorIcon(PhosphorIconsDuotone.caretUpDown),
                  onTap: _pickResident,
                ),
              ),
              if (resident != null) ...[
                const SizedBox(height: 8),
                if (_loadingLast)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: LinearProgressIndicator(),
                  )
                else if (_lastBill != null)
                  Text(
                    'บิลล่าสุด: เดือน ${_lastBill!.month} — เติมเลขมิเตอร์ครั้งก่อนและค่าเช่าให้อัตโนมัติแล้ว (แก้ไขได้)',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  )
                else
                  const Text(
                    'ยังไม่เคยออกบิลให้ห้องนี้ กรุณากรอกเลขมิเตอร์เริ่มต้น',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _month,
                decoration: const InputDecoration(
                  labelText: 'เดือนของบิล (yyyy-MM)',
                  prefixIcon: PhosphorIcon(PhosphorIconsDuotone.calendarDots),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: _invalidateResult,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'กรุณาระบุเดือน';
                  if (!RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(v)) {
                    return 'รูปแบบต้องเป็น yyyy-MM เช่น 2026-09';
                  }
                  return null;
                },
              ),
              _sectionTitle('ค่าไฟฟ้า', PhosphorIconsRegular.lightning, AppColors.accent),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _numberField(_prevElectric, 'มิเตอร์ไฟครั้งก่อน', null,
                        requiredMessage: 'กรอกเลขครั้งก่อน'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _numberField(_curElectric, 'มิเตอร์ไฟครั้งนี้', null,
                        requiredMessage: 'กรอกเลขครั้งนี้'),
                  ),
                ],
              ),
              _sectionTitle('ค่าน้ำ', PhosphorIconsRegular.drop, const Color(0xFF2F80ED)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _numberField(_prevWater, 'มิเตอร์น้ำครั้งก่อน', null,
                        requiredMessage: 'กรอกเลขครั้งก่อน'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _numberField(_curWater, 'มิเตอร์น้ำครั้งนี้', null,
                        requiredMessage: 'กรอกเลขครั้งนี้'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _numberField(_waterRate, 'ค่าน้ำต่อหน่วย (บาท)', PhosphorIconsRegular.money),
              _sectionTitle('ค่าเช่าห้อง', PhosphorIconsRegular.house, AppColors.primary),
              _numberField(_rent, 'ค่าเช่าห้องต่อเดือน (บาท)', PhosphorIconsRegular.house),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const PhosphorIcon(PhosphorIconsDuotone.calculator),
                  label: const Text('คำนวณ'),
                  onPressed: _calculate,
                ),
              ),
              if (_result != null && resident != null) ...[
                const SizedBox(height: 20),
                _ResultCard(result: _result!, resident: resident, month: _month.text.trim()),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(resident.room.isNotEmpty
                            ? 'ออกบิลให้ห้อง ${resident.room}'
                            : 'ออกบิล'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final UtilityBillResult result;
  final UserModel resident;
  final String month;

  const _ResultCard({required this.result, required this.resident, required this.month});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'th', symbol: '฿', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สรุปยอด • ${resident.room.isNotEmpty ? 'ห้อง ${resident.room} • ' : ''}เดือน $month',
            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(currency.format(result.totalAmount),
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          _row('ค่าไฟ ${formatUnit(result.electricityUnits)} หน่วย', currency.format(result.electricityAmount)),
          _row('ค่าน้ำ ${formatUnit(result.waterUnits)} หน่วย x ${formatUnit(result.waterRate)}',
              currency.format(result.waterAmount)),
          _row('ค่าเช่าห้อง', currency.format(result.roomRent)),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Bottom sheet ให้แอดมินเลือกห้อง/ผู้พัก พร้อมช่องค้นหาจากเลขห้อง/ชื่อ
class _ResidentPickerSheet extends StatefulWidget {
  const _ResidentPickerSheet();

  @override
  State<_ResidentPickerSheet> createState() => _ResidentPickerSheetState();
}

class _ResidentPickerSheetState extends State<_ResidentPickerSheet> {
  final Stream<List<UserModel>> _stream = UserService().watchAllResidents();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.7;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'ค้นหาเลขห้องหรือชื่อ',
                  prefixIcon: PhosphorIcon(PhosphorIconsDuotone.magnifyingGlass),
                ),
                onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: _stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final residents = snapshot.data!
                      .where((u) => !u.isAdmin)
                      .where((u) =>
                          _query.isEmpty ||
                          u.room.toLowerCase().contains(_query) ||
                          u.name.toLowerCase().contains(_query))
                      .toList();
                  if (residents.isEmpty) {
                    return const Center(
                      child: Text('ไม่พบผู้พัก', style: TextStyle(color: AppColors.textMuted)),
                    );
                  }
                  return ListView.builder(
                    itemCount: residents.length,
                    itemBuilder: (context, index) {
                      final r = residents[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            r.room.isNotEmpty ? r.room : '?',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        title: Text(r.room.isNotEmpty ? 'ห้อง ${r.room}' : 'ไม่ระบุห้อง',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(r.name),
                        onTap: () => Navigator.pop(context, r),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
