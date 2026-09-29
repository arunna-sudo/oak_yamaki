import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/dialogs.dart';
import '../../utils/format_utils.dart';
import '../../widgets/post_card.dart';

/// หน้ารายละเอียดโพสต์ + รายการคอมเมนต์แบบเรียลไทม์ + ช่องพิมพ์คอมเมนต์
class PostDetailPage extends StatefulWidget {
  final PostModel post;
  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _controller = TextEditingController();
  late final Stream<List<CommentModel>> _commentsStream;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // สร้าง stream ครั้งเดียว เพื่อไม่ให้ StreamBuilder subscribe ใหม่ทุกครั้งที่ rebuild
    _commentsStream = context.read<PostProvider>().watchComments(widget.post.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  Future<void> _sendComment() async {
    final user = context.read<AuthProvider>().userProfile;
    final text = _controller.text;
    if (user == null || text.trim().isEmpty || _sending) return;

    setState(() => _sending = true);
    final ok = await context.read<PostProvider>().addComment(
          postId: widget.post.id,
          text: text,
          author: user,
        );
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) {
      _controller.clear();
      FocusScope.of(context).unfocus();
    } else {
      _showError('ส่งความคิดเห็นไม่สำเร็จ');
    }
  }

  Future<void> _deletePost() async {
    final ok = await confirmDelete(
      context,
      title: 'ลบโพสต์นี้',
      message: 'ยืนยันการลบโพสต์และความคิดเห็นทั้งหมดของโพสต์นี้ใช่หรือไม่?',
    );
    if (!ok || !mounted) return;
    final success = await context.read<PostProvider>().deletePost(widget.post.id);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      _showError('ลบโพสต์ไม่สำเร็จ');
    }
  }

  Future<void> _deleteComment(CommentModel comment) async {
    final ok = await confirmDelete(
      context,
      title: 'ลบความคิดเห็น',
      message: 'ยืนยันการลบความคิดเห็นนี้ใช่หรือไม่?',
    );
    if (!ok || !mounted) return;
    final success =
        await context.read<PostProvider>().deleteComment(widget.post.id, comment.id);
    if (!mounted) return;
    if (!success) _showError('ลบความคิดเห็นไม่สำเร็จ');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final myUid = auth.userProfile?.uid;
    final post = widget.post;
    final canDeletePost = auth.isAdmin || post.authorUid == myUid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('โพสต์'),
        actions: [
          if (canDeletePost)
            IconButton(
              icon: const PhosphorIcon(PhosphorIconsDuotone.trash, color: AppColors.danger),
              tooltip: 'ลบโพสต์',
              onPressed: _deletePost,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<CommentModel>>(
              stream: _commentsStream,
              builder: (context, snapshot) {
                final comments = snapshot.data ?? const <CommentModel>[];
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    PostCard(post: post, detailed: true),
                    const SizedBox(height: 20),
                    Text(
                      'ความคิดเห็น (${comments.length})',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    if (snapshot.hasError)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text('โหลดความคิดเห็นไม่สำเร็จ: ${snapshot.error}',
                            style: const TextStyle(color: AppColors.danger)),
                      )
                    else if (!snapshot.hasData)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text('ยังไม่มีความคิดเห็น เป็นคนแรกที่คอมเมนต์เลย',
                              style: TextStyle(color: AppColors.textMuted)),
                        ),
                      )
                    else
                      for (final comment in comments)
                        _CommentTile(
                          comment: comment,
                          canDelete: auth.isAdmin || comment.authorUid == myUid,
                          onDelete: () => _deleteComment(comment),
                        ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendComment(),
                      decoration: InputDecoration(
                        hintText: 'เขียนความคิดเห็น...',
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Theme.of(context).dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Theme.of(context).dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppColors.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _sending ? null : _sendComment,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: _sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const PhosphorIcon(PhosphorIconsDuotone.paperPlaneTilt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final bool canDelete;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = (!comment.isFromAdmin && comment.authorRoom.isNotEmpty)
        ? '${comment.authorName} · ห้อง ${comment.authorRoom}'
        : comment.authorName;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  comment.authorName.isNotEmpty ? comment.authorName.substring(0, 1) : '?',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13),
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
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                        if (comment.isFromAdmin) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('ผู้ดูแล',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Text(timeAgo(comment.createdAt),
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(comment.text, style: const TextStyle(fontSize: 14, height: 1.4)),
                  ],
                ),
              ),
              if (canDelete)
                IconButton(
                  icon: const PhosphorIcon(PhosphorIconsDuotone.trash, size: 18, color: AppColors.textMuted),
                  tooltip: 'ลบความคิดเห็น',
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                )
              else
                const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
