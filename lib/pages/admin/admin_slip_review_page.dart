import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/bill_model.dart';
import '../../models/user_model.dart';
import '../../providers/bill_provider.dart';
import '../../services/bill_service.dart';
import '../../services/user_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/image_viewer_page.dart';
import '../../widgets/loading_widget.dart';

/// AdminSlipReviewPage: เมนูเฉพาะผู้ดูแลหอพัก (admin) สำหรับ "ตรวจสลิปโอนเงิน"
/// ของผู้พักทุกห้อง เนื่องจากแต่ละห้องมี Firestore collection แยกกัน
/// (ตามรูปแบบ bills_<email> ที่ BillService ใช้) หน้านี้จะอ่านรายชื่ออีเมล
/// ผู้พักทั้งหมดจาก collection "users" ก่อน แล้วจึงไปสอบถามบิลที่ค้างตรวจ
/// ทีละ collection ของแต่ละคน
class AdminSlipReviewPage extends StatefulWidget {
  const AdminSlipReviewPage({super.key});

  @override
  State<AdminSlipReviewPage> createState() => _AdminSlipReviewPageState();
}

class _AdminSlipReviewPageState extends State<AdminSlipReviewPage> {
  final UserService _userService = UserService();
  final BillService _billService = BillService();
  bool _loading = true;
  List<MapEntry<String, BillModel>> _pending = [];
  Map<String, UserModel> _residentsByEmail = {};

  @override
  void initState() {
    super.initState();
    _loadPendingSlips();
  }

  Future<void> _loadPendingSlips() async {
    setState(() => _loading = true);
    try {
      final residentsStream = _userService.watchAllResidents();
      final residents = await residentsStream.first;
      final emails = residents.map((r) => r.email).where((e) => e.isNotEmpty).toList();

      final pending = await _billService.fetchPendingSlipsForEmails(emails);

      if (!mounted) return;
      setState(() {
        _pending = pending;
        _residentsByEmail = {for (final r in residents) r.email: r};
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('โหลดข้อมูลสลิปไม่สำเร็จ: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _review(String email, BillModel bill, bool approved) async {
    await context.read<BillProvider>().reviewSlip(
          email: email,
          billId: bill.id,
          approved: approved,
        );
    if (!mounted) return;
    setState(() {
      _pending.removeWhere((e) => e.key == email && e.value.id == bill.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(approved ? 'อนุมัติสลิปเรียบร้อย' : 'ปฏิเสธสลิปเรียบร้อย'),
        backgroundColor: approved ? AppColors.success : AppColors.danger,
      ),
    );
  }

  String _residentLabel(String email) {
    final resident = _residentsByEmail[email];
    if (resident == null) return email;
    return resident.room.isNotEmpty ? 'ห้อง ${resident.room} · ${resident.name}' : resident.name;
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'th', symbol: '฿', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ตรวจสอบสลิปโอนเงิน'),
        actions: [
          IconButton(icon: const PhosphorIcon(PhosphorIconsDuotone.arrowsClockwise), onPressed: _loadPendingSlips),
        ],
      ),
      body: _loading
          ? const LoadingWidget(message: 'กำลังโหลดสลิปที่รอตรวจสอบ...')
          : _pending.isEmpty
              ? const EmptyStateWidget(
                  icon: PhosphorIconsRegular.checkSquareOffset,
                  title: 'ไม่มีสลิปที่รอตรวจสอบ',
                  subtitle: 'เมื่อผู้พักส่งสลิปใหม่ จะปรากฏที่นี่',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _pending.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final email = _pending[index].key;
                    final bill = _pending[index].value;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_residentLabel(email),
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text('บิลเดือน ${bill.month} • ${currency.format(bill.totalAmount)}',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                            const SizedBox(height: 12),
                            if (bill.slipImageBase64 != null)
                              GestureDetector(
                                onTap: () => ImageViewerPage.open(
                                  context,
                                  [bill.slipImageBase64!],
                                  title: 'สลิป ${_residentLabel(email)}',
                                  allowSave: true,
                                  fileName: 'slip_${bill.month}',
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    children: [
                                      Image.memory(
                                        base64Decode(bill.slipImageBase64!),
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        right: 8,
                                        bottom: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              PhosphorIcon(PhosphorIconsDuotone.magnifyingGlassPlus, color: Colors.white, size: 16),
                                              SizedBox(width: 4),
                                              Text('แตะเพื่อดูรูปเต็ม',
                                                  style: TextStyle(
                                                      color: Colors.white, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _review(email, bill, false),
                                    style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.danger,
                                        side: const BorderSide(color: AppColors.danger)),
                                    child: const Text('ปฏิเสธ'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _review(email, bill, true),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                    child: const Text('อนุมัติ'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
