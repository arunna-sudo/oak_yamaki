import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../models/announcement_model.dart';
import '../utils/app_theme.dart';
import 'base64_image.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isAdmin;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.onTap,
    this.onDelete,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM y, HH:mm', 'th').format(announcement.createdAt);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (announcement.imageBase64 != null)
              Base64Image(
                data: announcement.imageBase64!,
                width: double.infinity,
                height: 150,
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (announcement.pinned)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: PhosphorIcon(PhosphorIconsDuotone.pushPin, size: 16, color: AppColors.accent),
                        ),
                      Expanded(
                        child: Text(
                          announcement.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isAdmin && onDelete != null)
                        IconButton(
                          icon: const PhosphorIcon(PhosphorIconsDuotone.trash, color: AppColors.danger),
                          onPressed: onDelete,
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    announcement.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const PhosphorIcon(PhosphorIconsDuotone.megaphoneSimple, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(announcement.createdByName,
                          style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                      const Spacer(),
                      Text(dateStr,
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
