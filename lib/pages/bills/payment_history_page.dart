import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/bill_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bill_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_saver.dart';
import '../../widgets/base64_image.dart';
import '../../widgets/image_viewer_page.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/status_chip.dart';
import 'bill_detail_page.dart';

enum _PaymentFilter { all, approved, pending, rejected }

/// ประวัติการชำระเงินของผู้พัก: รายการบิลที่เคยส่งสลิป เรียงจากล่าสุด
/// กดดูสลิปเต็มจอ (ซูมได้) และบันทึกสลิปลงเครื่องได้
class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  _PaymentFilter _filter = _PaymentFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final email = context.read<AuthProvider>().userProfile?.email;
      if (email != null) {
        context.read<BillProvider>().start(email);
      }
    });
  }

  /// บิลที่นับเป็น "ประวัติการชำระ" = เคยส่งสลิป หรือแอดมินอนุมัติแล้ว
  bool _hasPayment(BillModel b) =>
      b.slipImageBase64 != null ||
      b.status == BillStatus.approved ||
      b.status == BillStatus.pendingReview ||
      (b.status == BillStatus.rejected && b.slipUploadedAt != null);

  DateTime _paymentTime(BillModel b) => b.slipUploadedAt ?? b.reviewedAt ?? b.createdAt;

  bool _matches(BillModel b) {
    switch (_filter) {
      case _PaymentFilter.all:
        return true;
      case _PaymentFilter.approved:
        return b.status == BillStatus.approved;
      case _PaymentFilter.pending:
        return b.status == BillStatus.pendingReview;
      case _PaymentFilter.rejected:
        return b.status == BillStatus.rejected;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillProvider>();
    final currency = NumberFormat.currency(locale: 'th', symbol: '฿', decimalDigits: 2);

    final history = provider.bills.where(_hasPayment).toList()
      ..sort((a, b) => _paymentTime(b).compareTo(_paymentTime(a)));
    final paid = history.where((b) => b.status == BillStatus.approved).toList();
    final paidTotal = paid.fold<double>(0, (sum, b) => sum + b.totalAmount);
    final visible = history.where(_matches).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('ประวัติการชำระเงิน')),
      body: provider.isLoading
          ? const LoadingWidget()
          : history.isEmpty
              ? const EmptyStateWidget(
                  icon: PhosphorIconsRegular.clockCounterClockwise,
                  title: 'ยังไม่มีประวัติการชำระเงิน',
                  subtitle: 'เมื่อคุณส่งสลิปชำระบิลแล้ว รายการจะแสดงที่นี่ พร้อมเก็บสลิปไว้ให้ดูย้อนหลัง',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ชำระแล้วทั้งหมด',
                              style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text(currency.format(paidTotal),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 6),
                          Text('${paid.length} รายการที่ตรวจสอบแล้ว',
                              style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _chip('ทั้งหมด', _PaymentFilter.all),
                          _chip('ชำระแล้ว', _PaymentFilter.approved),
                          _chip('รอตรวจสอบ', _PaymentFilter.pending),
                          _chip('ไม่ผ่าน', _PaymentFilter.rejected),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (visible.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text('ไม่มีรายการในหมวดนี้',
                              style: TextStyle(color: AppColors.textMuted)),
                        ),
                      )
                    else
                      for (final bill in visible)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PaymentTile(
                            bill: bill,
                            paymentTime: _paymentTime(bill),
                          ),
                        ),
                  ],
                ),
    );
  }

  Widget _chip(String label, _PaymentFilter value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _filter == value,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: _filter == value ? Colors.white : null,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final BillModel bill;
  final DateTime paymentTime;

  const _PaymentTile({required this.bill, required this.paymentTime});

  Future<void> _saveSlip(BuildContext context) async {
    final ok = await ImageSaver.saveBase64(
      bill.slipImageBase64!,
      fileName: 'slip_${bill.month}',
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'บันทึกสลิปเดือน ${bill.month} เรียบร้อยแล้ว' : 'บันทึกสลิปไม่สำเร็จ'),
        backgroundColor: ok ? AppColors.success : AppColors.danger,
      ),
    );
  }

  void _viewSlip(BuildContext context) {
    ImageViewerPage.open(
      context,
      [bill.slipImageBase64!],
      title: 'สลิปบิลเดือน ${bill.month}',
      allowSave: true,
      fileName: 'slip_${bill.month}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'th', symbol: '฿', decimalDigits: 2);
    final dateStr = DateFormat('d MMM y, HH:mm', 'th').format(paymentTime);
    final hasSlip = bill.slipImageBase64 != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => BillDetailPage(bill: bill)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: hasSlip ? () => _viewSlip(context) : null,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: hasSlip
                          ? Base64Image(data: bill.slipImageBase64!, width: 56, height: 56)
                          : Container(
                              width: 56,
                              height: 56,
                              color: AppColors.accentLight,
                              child: const PhosphorIcon(PhosphorIconsDuotone.receipt, color: AppColors.accent),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('บิลประจำเดือน ${bill.month}',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('ส่งสลิปเมื่อ $dateStr',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(currency.format(bill.totalAmount),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 6),
                      StatusChip.bill(bill.status),
                    ],
                  ),
                ],
              ),
              if (hasSlip) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const PhosphorIcon(PhosphorIconsDuotone.image, size: 18),
                        label: const Text('ดูสลิป'),
                        onPressed: () => _viewSlip(context),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        icon: const PhosphorIcon(PhosphorIconsDuotone.downloadSimple, size: 18),
                        label: const Text('บันทึกสลิป'),
                        onPressed: () => _saveSlip(context),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
