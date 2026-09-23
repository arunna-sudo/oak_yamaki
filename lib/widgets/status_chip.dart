import 'package:flutter/material.dart';
import '../models/bill_model.dart';
import '../models/maintenance_model.dart';
import '../utils/app_theme.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  factory StatusChip.bill(BillStatus status) {
    switch (status) {
      case BillStatus.unpaid:
        return StatusChip(label: 'รอชำระ', color: AppColors.textMuted);
      case BillStatus.pendingReview:
        return StatusChip(label: 'รอตรวจสลิป', color: AppColors.warning);
      case BillStatus.approved:
        return StatusChip(label: 'ชำระแล้ว', color: AppColors.success);
      case BillStatus.rejected:
        return StatusChip(label: 'สลิปไม่ผ่าน', color: AppColors.danger);
    }
  }

  factory StatusChip.maintenance(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.pending:
        return StatusChip(label: 'รอดำเนินการ', color: AppColors.warning);
      case MaintenanceStatus.inProgress:
        return StatusChip(label: 'กำลังซ่อม', color: AppColors.primary);
      case MaintenanceStatus.done:
        return StatusChip(label: 'เสร็จสิ้น', color: AppColors.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
