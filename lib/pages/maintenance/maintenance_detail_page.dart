import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/maintenance_model.dart';
import '../../providers/maintenance_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/status_chip.dart';

class MaintenanceDetailPage extends StatelessWidget {
  final MaintenanceModel request;
  final bool isAdmin;

  const MaintenanceDetailPage({super.key, required this.request, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM y, HH:mm', 'th').format(request.createdAt);
    final preferredStr = request.preferredDate != null
        ? DateFormat('d MMM y', 'th').format(request.preferredDate!)
        : 'ไม่ระบุ';

    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดการแจ้งซ่อม')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(request.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                ),
                StatusChip.maintenance(request.status),
              ],
            ),
            const SizedBox(height: 8),
            if (isAdmin) Text('ห้อง ${request.room}', style: const TextStyle(color: AppColors.textMuted)),
            Text('หมวดหมู่: ${request.category} • ความเร่งด่วน: ${request.urgency}',
                style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text('แจ้งเมื่อ $dateStr', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            Text('วันที่สะดวกให้เข้าซ่อม: $preferredStr',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const Divider(height: 32),
            const Text('รายละเอียดปัญหา', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(request.description, style: const TextStyle(fontSize: 15, height: 1.6)),
            if (isAdmin) ...[
              const SizedBox(height: 28),
              const Text('อัปเดตสถานะ', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: MaintenanceStatus.values.map((status) {
                  final selected = status == request.status;
                  return ChoiceChip(
                    label: Text(_label(status)),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textDark),
                    onSelected: (_) {
                      context.read<MaintenanceProvider>().updateStatus(request.id, status);
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _label(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.pending:
        return 'รอดำเนินการ';
      case MaintenanceStatus.inProgress:
        return 'กำลังซ่อม';
      case MaintenanceStatus.done:
        return 'เสร็จสิ้น';
    }
  }
}
