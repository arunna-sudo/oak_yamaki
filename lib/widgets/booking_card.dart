import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../models/facility_model.dart';
import '../utils/app_theme.dart';
import 'status_chip.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool showResident; // แอดมิน: แสดงห้องพัก/ชื่อผู้จอง
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    this.showResident = false,
    this.onCancel,
  });

  StatusChip get _chip {
    if (booking.status == BookingStatus.cancelled) {
      return StatusChip(
        label: booking.cancelledBy == 'admin' ? 'ยกเลิกโดยผู้ดูแล' : 'ยกเลิกแล้ว',
        color: AppColors.danger,
      );
    }
    if (booking.isActive) return StatusChip(label: 'ยืนยันแล้ว', color: AppColors.success);
    return StatusChip(label: 'เสร็จสิ้น', color: AppColors.textMuted);
  }

  @override
  Widget build(BuildContext context) {
    final facility = FacilityConfig.byId(booking.facilityId);
    final type = facility?.type ?? FacilityType.meeting;
    final dateStr = DateFormat('EEE d MMM y', 'th').format(booking.startTime);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: type.color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(type.icon, color: type.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.facilityName,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('$dateStr • ${booking.timeRange}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ],
                  ),
                ),
                _chip,
              ],
            ),
            if (showResident) ...[
              const SizedBox(height: 10),
              Text(
                'ผู้จอง: ${booking.room.isNotEmpty ? 'ห้อง ${booking.room} · ' : ''}${booking.userName}',
                style: const TextStyle(fontSize: 13),
              ),
            ],
            if (booking.isActive && onCancel != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  icon: const PhosphorIcon(PhosphorIconsDuotone.calendarX, size: 18),
                  label: const Text('ยกเลิกการจอง'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
