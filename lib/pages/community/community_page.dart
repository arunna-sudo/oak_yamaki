import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/dialogs.dart';
import '../../widgets/list_reveal.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/post_card.dart';
import 'create_post_page.dart';
import 'post_detail_page.dart';

/// หน้าคอมมูนิตี้หอพักแบบโพสต์: ทุกคนตั้งกระทู้ (ใส่รูปได้) และเข้าไปคอมเมนต์ได้
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().start();
    });
  }

  Future<void> _deletePost(String postId) async {
    final ok = await confirmDelete(
      context,
      title: 'ลบโพสต์นี้',
      message: 'ยืนยันการลบโพสต์และความคิดเห็นทั้งหมดของโพสต์นี้ใช่หรือไม่?',
    );
    if (!ok || !mounted) return;
    final success = await context.read<PostProvider>().deletePost(postId);
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลบโพสต์ไม่สำเร็จ'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<PostProvider>();
    final myUid = auth.userProfile?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('คอมมูนิตี้หอพัก')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'สร้างโพสต์',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreatePostPage()),
        ),
        child: const PhosphorIcon(PhosphorIconsDuotone.pencilSimple),
      ),
      body: provider.isLoading && provider.posts.isEmpty
          ? const LoadingWidget()
          : provider.posts.isEmpty
              ? const EmptyStateWidget(
                  icon: PhosphorIconsRegular.chatsCircle,
                  title: 'ยังไม่มีโพสต์',
                  subtitle: 'กดปุ่มดินสอเพื่อโพสต์เรื่องแรกในคอมมูนิตี้หอพัก',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  itemCount: provider.posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final post = provider.posts[index];
                    return ListReveal(
                      index: index,
                      slideFromBottom: true,
                      child: PostCard(
                        post: post,
                        canDelete: auth.isAdmin || post.authorUid == myUid,
                        onDelete: () => _deletePost(post.id),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
