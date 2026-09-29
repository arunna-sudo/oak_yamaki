import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../models/bill_model.dart';
import '../utils/app_theme.dart';
import 'status_chip.dart';

class BillCard extends StatelessWidget {
  final BillModel bill;
  final VoidCallback? onTap;

  const BillCard({super.key, required this.bill, this.onTap});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'th', symbol: '฿', decimalDigits: 2);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const PhosphorIcon(PhosphorIconsDuotone.lightning, color: AppColors.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('บิลประจำเดือน ${bill.month}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                        bill.waterUnitsUsed > 0
                            ? 'ไฟ ${bill.unitsUsed.toStringAsFixed(1)} • น้ำ ${bill.waterUnitsUsed.toStringAsFixed(1)} หน่วย'
                            : 'ไฟ ${bill.unitsUsed.toStringAsFixed(1)} หน่วย',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatter.format(bill.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 6),
                  StatusChip.bill(bill.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
