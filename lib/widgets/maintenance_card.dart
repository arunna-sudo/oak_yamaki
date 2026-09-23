import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/maintenance_model.dart';
import '../utils/app_theme.dart';
import 'status_chip.dart';

class MaintenanceCard extends StatelessWidget {
  final MaintenanceModel request;
  final VoidCallback? onTap;
  final bool showRoom;

  const MaintenanceCard({
    super.key,
    required this.request,
    this.onTap,
    this.showRoom = false,
  });

  IconData get _categoryIcon {
    switch (request.category) {
      case 'ไฟฟ้า':
        return Icons.bolt;
      case 'ประปา':
        return Icons.water_drop;
      case 'เครื่องใช้ไฟฟ้า':
        return Icons.kitchen;
      default:
        return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM y', 'th').format(request.createdAt);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_categoryIcon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      showRoom ? 'ห้อง ${request.room} • ${request.category}' : request.category,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        StatusChip.maintenance(request.status),
                        const SizedBox(width: 8),
                        Text(dateStr, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
