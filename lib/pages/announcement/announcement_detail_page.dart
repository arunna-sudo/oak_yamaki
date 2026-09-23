import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/announcement_model.dart';
import '../../utils/app_theme.dart';

class AnnouncementDetailPage extends StatelessWidget {
  final AnnouncementModel announcement;
  const AnnouncementDetailPage({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('EEEE d MMMM y เวลา HH:mm น.', 'th').format(announcement.createdAt);

    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดประกาศ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (announcement.pinned)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.push_pin, size: 16, color: AppColors.accent),
                    SizedBox(width: 4),
                    Text('ประกาศปักหมุด',
                        style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            Text(announcement.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Row(
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.campaign, size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Text(announcement.createdByName, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            Text(dateStr, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const Divider(height: 32),
            Text(announcement.body, style: const TextStyle(fontSize: 15, height: 1.6)),
          ],
        ),
      ),
    );
  }
}
