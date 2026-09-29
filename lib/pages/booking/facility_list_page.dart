import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/facility_model.dart';
import '../../utils/app_theme.dart';
import 'facility_booking_page.dart';
import 'my_bookings_page.dart';

/// หน้าเลือกห้องส่วนกลางที่ต้องการจอง (ห้องประชุม / ห้องเล่นเกม / ห้องดูหนัง)
class FacilityListPage extends StatelessWidget {
  const FacilityListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จองส่วนกลาง'),
        actions: [
          IconButton(
            icon: const PhosphorIcon(PhosphorIconsDuotone.notepad),
            tooltip: 'การจองของฉัน',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyBookingsPage()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          for (final type in FacilityType.values) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 10),
              child: Row(
                children: [
                  Icon(type.icon, color: type.color, size: 20),
                  const SizedBox(width: 8),
                  Text(type.label,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            for (final facility in FacilityConfig.ofType(type))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: type.color.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(type.icon, color: type.color),
                    ),
                    title: Text(facility.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      '${facility.sizeLabel != null ? '${facility.sizeLabel} • ' : ''}เปิด ${FacilityConfig.openingText}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    trailing: const PhosphorIcon(PhosphorIconsDuotone.caretRight),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => FacilityBookingPage(facility: facility)),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
