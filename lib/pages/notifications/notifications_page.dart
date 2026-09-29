import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/announcement_model.dart';
import '../../models/bill_model.dart';
import '../../models/maintenance_model.dart';
import '../../models/notification_item.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bill_provider.dart';
import '../../providers/maintenance_provider.dart';
import '../../providers/parcel_provider.dart';
import '../../services/local_storage_service.dart';
import '../../services/notification_builder.dart';
import '../../utils/app_theme.dart';
import '../../widgets/loading_widget.dart';
import '../announcement/announcement_detail_page.dart';
import '../bills/bill_detail_page.dart';
import '../maintenance/maintenance_detail_page.dart';
import '../parcels/parcels_page.dart';

/// หน้าการแจ้งเตือนของผู้พัก: ประกาศใหม่ / บิลใหม่ / บิลได้รับการยืนยัน /
/// แจ้งซ่อมได้รับการยืนยัน-กำลังซ่อม-เสร็จสิ้น / พัสดุมาถึง
/// รายการที่ใหม่กว่าครั้งล่าสุดที่เปิดหน้านี้จะมีจุดสีส้มกำกับ
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _storage = LocalStorageService();
  DateTime? _previousSeenAt;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _markSeen();
  }

  Future<void> _markSeen() async {
    final uid = context.read<AuthProvider>().userProfile?.uid;
    if (uid != null) {
      _previousSeenAt = await _storage.getNotificationsSeenAt(uid);
      await _storage.saveNotificationsSeenAt(uid, DateTime.now());
    }
    if (!mounted) return;
    setState(() => _ready = true);
  }

  ({IconData icon, Color color}) _style(NotificationType type) {
    switch (type) {
      case NotificationType.announcement:
        return (icon: PhosphorIconsRegular.megaphoneSimple, color: const Color(0xFF2F80ED));
      case NotificationType.newBill:
        return (icon: PhosphorIconsRegular.receipt, color: AppColors.accent);
      case NotificationType.billApproved:
        return (icon: PhosphorIconsRegular.checkCircle, color: AppColors.success);
      case NotificationType.billRejected:
        return (icon: PhosphorIconsRegular.warningCircle, color: AppColors.danger);
      case NotificationType.repairInProgress:
        return (icon: PhosphorIconsRegular.wrench, color: AppColors.primary);
      case NotificationType.repairDone:
        return (icon: PhosphorIconsRegular.checkCircle, color: AppColors.success);
      case NotificationType.parcel:
        return (icon: PhosphorIconsRegular.package, color: const Color(0xFF8E6BBF));
    }
  }

  void _open(NotificationItem item) {
    final payload = item.payload;
    Widget? page;
    if (payload is AnnouncementModel) {
      page = AnnouncementDetailPage(announcement: payload);
    } else if (payload is BillModel) {
      page = BillDetailPage(bill: payload);
    } else if (payload is MaintenanceModel) {
      page = MaintenanceDetailPage(request: payload);
    } else if (item.type == NotificationType.parcel) {
      page = const ParcelsPage();
    }
    if (page == null) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page!));
  }

  @override
  Widget build(BuildContext context) {
    final items = NotificationBuilder.build(
      announcements: context.watch<AnnouncementProvider>().announcements,
      bills: context.watch<BillProvider>().bills,
      requests: context.watch<MaintenanceProvider>().requests,
      parcels: context.watch<ParcelProvider>().parcels,
    );
    final fmt = DateFormat('d MMM y, HH:mm', 'th');

    return Scaffold(
      appBar: AppBar(title: const Text('การแจ้งเตือน')),
      body: !_ready
          ? const LoadingWidget()
          : items.isEmpty
              ? const EmptyStateWidget(
                  icon: PhosphorIconsRegular.bell,
                  title: 'ยังไม่มีการแจ้งเตือน',
                  subtitle: 'ประกาศ บิล การแจ้งซ่อม และพัสดุใหม่จะแสดงที่นี่',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final style = _style(item.type);
                    final unread =
                        _previousSeenAt == null || item.time.isAfter(_previousSeenAt!);
                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _open(item),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: style.color.withOpacity(0.14),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(style.icon, color: style.color),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.title,
                                        style: TextStyle(
                                            fontWeight: unread ? FontWeight.w800 : FontWeight.w600)),
                                    const SizedBox(height: 3),
                                    Text(item.message,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: AppColors.textMuted, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    Text(fmt.format(item.time),
                                        style: const TextStyle(
                                            color: AppColors.textMuted, fontSize: 11)),
                                  ],
                                ),
                              ),
                              if (unread)
                                Container(
                                  margin: const EdgeInsets.only(top: 4, left: 8),
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
