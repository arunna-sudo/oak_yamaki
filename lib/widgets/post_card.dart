import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/post_model.dart';
import '../utils/app_theme.dart';
import '../utils/format_utils.dart';
import 'base64_image.dart';

/// การ์ดโพสต์ในฟีดคอมมูนิตี้
/// - detailed = false: แบบย่อในฟีด (ตัดข้อความ 6 บรรทัด, รูปแบบย่อ)
/// - detailed = true : แบบเต็มในหน้ารายละเอียดโพสต์
class PostCard extends StatelessWidget {
  final PostModel post;
  final bool detailed;
  final bool canDelete;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    this.detailed = false,
    this.canDelete = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = (!post.isFromAdmin && post.authorRoom.isNotEmpty)
        ? '${post.authorName} · ห้อง ${post.authorRoom}'
        : post.authorName;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      post.authorName.isNotEmpty ? post.authorName.substring(0, 1) : '?',
                      style: const TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (post.isFromAdmin) ...[
                              const SizedBox(width: 6),
                              const _AdminChip(),
                            ],
                          ],
                        ),
                        Text(
                          timeAgo(post.createdAt),
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (canDelete && onDelete != null)
                    PopupMenuButton<String>(
                      icon: const PhosphorIcon(PhosphorIconsDuotone.dotsThree, color: AppColors.textMuted),
                      onSelected: (_) => onDelete!(),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('ลบโพสต์', style: TextStyle(color: AppColors.danger)),
                        ),
                      ],
                    ),
                ],
              ),
              if (post.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  post.text,
                  maxLines: detailed ? null : 6,
                  overflow: detailed ? TextOverflow.clip : TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, height: 1.45),
                ),
              ],
              if (post.imagesBase64.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildImages(),
              ],
              if (!detailed) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const PhosphorIcon(PhosphorIconsDuotone.chatCircle, size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      '${post.commentCount}',
                      style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImages() {
    final images = post.imagesBase64;

    if (detailed) {
      return Column(
        children: [
          for (int i = 0; i < images.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Base64Image(data: images[i], width: double.infinity, fit: BoxFit.cover),
              ),
            ),
        ],
      );
    }

    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Base64Image(data: images.first, width: double.infinity, height: 200),
      );
    }

    return Row(
      children: [
        for (int i = 0; i < images.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == images.length - 1 ? 0 : 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Base64Image(data: images[i], height: 110),
              ),
            ),
          ),
      ],
    );
  }
}

class _AdminChip extends StatelessWidget {
  const _AdminChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'ผู้ดูแล',
        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
