import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/loading_widget.dart';
import 'announcement_detail_page.dart';
import 'create_announcement_page.dart';

class AnnouncementListPage extends StatelessWidget {
  const AnnouncementListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<AnnouncementProvider>();
    final isAdmin = auth.isAdmin;

    return Scaffold(
      appBar: AppBar(title: const Text('ประกาศจากหอพัก')),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('ประกาศใหม่'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateAnnouncementPage()),
              ),
            )
          : null,
      body: provider.isLoading
          ? const LoadingWidget()
          : provider.announcements.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.campaign_outlined,
                  title: 'ยังไม่มีประกาศ',
                  subtitle: 'เมื่อผู้ดูแลหอพักประกาศเรื่องสำคัญ จะแสดงที่นี่',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: provider.announcements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = provider.announcements[index];
                    return AnnouncementCard(
                      announcement: item,
                      isAdmin: isAdmin,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AnnouncementDetailPage(announcement: item)),
                      ),
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('ลบประกาศ'),
                            content: const Text('ยืนยันการลบประกาศนี้ใช่หรือไม่?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('ยกเลิก')),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('ลบ', style: TextStyle(color: AppColors.danger)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await provider.deleteAnnouncement(item.id);
                        }
                      },
                    );
                  },
                ),
    );
  }
}
