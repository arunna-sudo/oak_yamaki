import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../models/bill_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bill_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/status_chip.dart';

/// BillDetailPage สาธิตการใช้ image_picker เพื่อเลือกรูปสลิปโอนเงิน
/// แล้วแปลงเป็น base64 บันทึกลง Firestore ผ่าน BillProvider.uploadSlip()
/// (เก็บเป็น base64 string ในเอกสาร Firestore โดยตรง เพื่อไม่ต้องพึ่ง
/// Firebase Storage ซึ่งอยู่นอกเหนือขอบเขตเนื้อหาบทเรียน — เหมาะกับสลิปขนาดเล็ก)
class BillDetailPage extends StatefulWidget {
  final BillModel bill;
  const BillDetailPage({super.key, required this.bill});

  @override
  State<BillDetailPage> createState() => _BillDetailPageState();
}

class _BillDetailPageState extends State<BillDetailPage> {
  Uint8List? _pickedBytes;
  bool _uploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _pickedBytes = bytes);
  }

  Future<void> _upload() async {
    if (_pickedBytes == null) return;
    final auth = context.read<AuthProvider>();
    final email = auth.userProfile?.email;
    if (email == null) return;

    setState(() => _uploading = true);
    final bytes = _pickedBytes!;

    final success = await context.read<BillProvider>().uploadSlip(
          email: email,
          billId: widget.bill.id,
          imageBytes: bytes,
        );

    if (!mounted) return;
    setState(() => _uploading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('อัปโหลดสลิปสำเร็จ รอผู้ดูแลตรวจสอบ'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อัปโหลดสลิปไม่สำเร็จ'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;
    final currency = NumberFormat.currency(locale: 'th', symbol: '฿', decimalDigits: 2);
    final canUploadSlip = bill.status == BillStatus.unpaid || bill.status == BillStatus.rejected;

    return Scaffold(
      appBar: AppBar(title: Text('บิลเดือน ${bill.month}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ยอดที่ต้องชำระ',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                      StatusChip.bill(bill.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(currency.format(bill.totalAmount),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _detailRow('เลขมิเตอร์ครั้งก่อน', '${bill.previousUnit.toStringAsFixed(1)} หน่วย'),
            _detailRow('เลขมิเตอร์ครั้งนี้', '${bill.currentUnit.toStringAsFixed(1)} หน่วย'),
            _detailRow('หน่วยที่ใช้ไป', '${bill.unitsUsed.toStringAsFixed(1)} หน่วย'),
            _detailRow('ค่าไฟฟ้า', currency.format(bill.electricityAmount)),
            _detailRow('ค่าเช่าห้อง', currency.format(bill.roomRent)),
            const Divider(height: 32),
            const Text('หลักฐานการโอนเงิน (สลิป)',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 12),
            if (bill.slipImageBase64 != null && _pickedBytes == null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                child: Image.memory(
                  const Base64Decoder().convert(bill.slipImageBase64!),
                  fit: BoxFit.cover,
                ),
              )
            else if (_pickedBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                child: Image.memory(_pickedBytes!, fit: BoxFit.cover),
              )
            else
              GestureDetector(
                onTap: canUploadSlip ? _pickImage : null,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload_file, color: AppColors.textMuted, size: 32),
                        SizedBox(height: 8),
                        Text('แตะเพื่อเลือกรูปสลิป', style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ),
              ),
            if (canUploadSlip) ...[
              const SizedBox(height: 14),
              if (_pickedBytes != null)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _pickImage,
                        child: const Text('เลือกรูปใหม่'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _uploading ? null : _upload,
                        child: _uploading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('ส่งสลิป'),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('เลือกรูปสลิปจากคลังภาพ'),
                    onPressed: _pickImage,
                  ),
                ),
            ] else if (bill.status == BillStatus.pendingReview)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('ส่งสลิปแล้ว กำลังรอผู้ดูแลหอพักตรวจสอบ',
                    style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600)),
              )
            else if (bill.status == BillStatus.approved)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('ตรวจสอบแล้ว ชำระเงินเรียบร้อย ✅',
                    style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
