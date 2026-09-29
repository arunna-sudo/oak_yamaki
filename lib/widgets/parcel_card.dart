import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../models/parcel_model.dart';
import '../utils/app_theme.dart';
import 'base64_image.dart';
import 'image_viewer_page.dart';

class ParcelCard extends StatelessWidget {
  final ParcelModel parcel;
  final bool isAdmin;
  final VoidCallback? onMarkReceived;
  final VoidCallback? onDelete;

  const ParcelCard({
    super.key,
    required this.parcel,
    this.isAdmin = false,
    this.onMarkReceived,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM y, HH:mm', 'th');
    final isPending = parcel.status == ParcelStatus.pending;
    final color = isPending ? AppColors.warning : AppColors.success;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (parcel.imageBase64 != null && parcel.imageBase64!.isNotEmpty)
            GestureDetector(
              onTap: () => ImageViewerPage.open(context, [parcel.imageBase64!], title: 'รูปพัสดุ'),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: Base64Image(data: parcel.imageBase64!, height: 180),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ห้อง ${parcel.room}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isPending ? 'ค้างรับ' : 'รับแล้ว',
                        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                if (parcel.note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(parcel.note, style: const TextStyle(height: 1.4)),
                ],
                const SizedBox(height: 8),
                Text(
                  'มาถึงเมื่อ ${fmt.format(parcel.createdAt)}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                if (!isPending && parcel.receivedAt != null)
                  Text(
                    'รับเมื่อ ${fmt.format(parcel.receivedAt!)}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                if (isAdmin) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (isPending)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onMarkReceived,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                            icon: const PhosphorIcon(PhosphorIconsDuotone.check, size: 18),
                            label: const Text('ผู้พักรับแล้ว'),
                          ),
                        )
                      else
                        const Spacer(),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onDelete,
                        tooltip: 'ลบ',
                        icon: const PhosphorIcon(PhosphorIconsDuotone.trash, color: AppColors.danger),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
