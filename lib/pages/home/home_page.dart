import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/bill_model.dart';
import '../../models/user_model.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bill_provider.dart';
import '../../providers/maintenance_provider.dart';
import '../../providers/parcel_provider.dart';
import '../../services/local_storage_service.dart';
import '../../services/notification_builder.dart';
import '../../utils/app_theme.dart';
import '../../utils/dorm_config.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/floating_bubbles.dart';
import '../../widgets/list_reveal.dart';
import '../admin/admin_create_bill_page.dart';
import '../admin/admin_residents_page.dart';
import '../admin/admin_slip_review_page.dart';
import '../announcement/announcement_detail_page.dart';
import '../announcement/announcement_list_page.dart';
import '../announcement/create_announcement_page.dart';
import '../analytics/usage_analytics_page.dart';
import '../bills/bills_page.dart';
import '../bills/payment_history_page.dart';
import '../booking/admin_bookings_page.dart';
import '../booking/facility_list_page.dart';
import '../dorm/dorm_info_page.dart';
import '../maintenance/maintenance_list_page.dart';
import '../notifications/notifications_page.dart';
import '../parcels/parcels_page.dart';

/// หน้าแรก: การ์ด "หอพักของฉัน" (ชื่อหอ/ตึก/เลขห้อง) -> เมนูลัดแบบตาราง -> ข่าวสารหอพัก
/// เมนูจะต่างกันตามบทบาท (ผู้พัก / แอดมิน)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _storage = LocalStorageService();
  DateTime? _notifSeenAt;
  bool _notifSeenLoaded = false;

  Future<void> _loadNotifSeenAt() async {
    final uid = context.read<AuthProvider>().userProfile?.uid;
    if (uid == null) return;
    final seenAt = await _storage.getNotificationsSeenAt(uid);
    if (!mounted) return;
    setState(() {
      _notifSeenAt = seenAt;
      _notifSeenLoaded = true;
    });
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
    _loadNotifSeenAt(); // อัปเดตตัวเลขบนกระดิ่งหลังกลับมา
  }

  @override
  void initState() {
    super.initState();
    _loadNotifSeenAt();

    // เริ่มฟังข้อมูลแบบเรียลไทม์จาก Firestore ผ่าน Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<AnnouncementProvider>().start();
      final user = auth.userProfile;
      if (user == null) return;
      if (auth.isAdmin) {
        context.read<MaintenanceProvider>().startForAdmin();
        context.read<ParcelProvider>().startForAdmin();
        context.read<BillProvider>().startForAdmin();
      } else {
        context.read<MaintenanceProvider>().startForUser(user.uid);
        context.read<BillProvider>().start(user.email);
        context.read<ParcelProvider>().startForRoom(user.room);
      }
    });
  }

  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  /// เปิดหน้าตรวจสลิป แล้วรีเฟรชจำนวนสลิปที่รอตรวจสอบเมื่อกลับมา
  /// (ใช้กับทั้งปุ่มกระดิ่งและเมนู "ตรวจสลิป" ของแอดมิน)
  Future<void> _openSlipReview() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminSlipReviewPage()),
    );
    if (!mounted) return;
    context.read<BillProvider>().refreshAdminPendingSlips();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userProfile;
    final isAdmin = auth.isAdmin;
    final announcementProvider = context.watch<AnnouncementProvider>();
    final maintenanceProvider = context.watch<MaintenanceProvider>();
    final billProvider = context.watch<BillProvider>();
    final parcelProvider = context.watch<ParcelProvider>();

    final pendingParcels = parcelProvider.pending.length;
    final pendingSlips = billProvider.adminPendingSlipCount;
    final unreadNotifications = isAdmin
        ? pendingSlips
        : (!_notifSeenLoaded
            ? 0
            : NotificationBuilder.unreadCount(
                NotificationBuilder.build(
                  announcements: announcementProvider.announcements,
                  bills: billProvider.bills,
                  requests: maintenanceProvider.requests,
                  parcels: parcelProvider.parcels,
                ),
                _notifSeenAt,
              ));

    final openRequests =
        maintenanceProvider.requests.where((r) => r.status.name != 'done').length;
    final unpaidBills = billProvider.bills
        .where((b) => b.status == BillStatus.unpaid || b.status == BillStatus.rejected)
        .length;
    final news = announcementProvider.announcements.take(3).toList();

    final tiles = isAdmin
        ? <_MenuTile>[
            _MenuTile(
              icon: PhosphorIconsDuotone.lightning,
              label: 'ออกบิลน้ำ-ไฟ',
              color: AppColors.accent,
              onTap: () => _open(const AdminCreateBillPage()),
            ),
            _MenuTile(
              icon: PhosphorIconsDuotone.checkSquareOffset,
              label: 'ตรวจสลิป',
              color: AppColors.success,
              badge: pendingSlips > 0 ? '$pendingSlips' : null,
              onTap: _openSlipReview,
            ),
            _MenuTile(
              icon: PhosphorIconsDuotone.wrench,
              label: 'แจ้งซ่อม',
              color: AppColors.primary,
              badge: openRequests > 0 ? '$openRequests' : null,
              onTap: () => _open(const MaintenanceListPage()),
            ),
            _MenuTile(
              icon: PhosphorIconsDuotone.imagesSquare,
              label: 'สร้างประกาศ',
              color: AppColors.violet,
              onTap: () => _open(const CreateAnnouncementPage()),
            ),
            _MenuTile(
              icon: PhosphorIconsDuotone.megaphoneSimple,
              label: 'ข่าวสารหอพัก',
              color: AppColors.sky,
              onTap: () => _open(const AnnouncementListPage()),
            ),
            _MenuTile(
              icon: PhosphorIconsDuotone.package,
              label: 'พัสดุ',
              color: AppColors.violet,
              badge: pendingParcels > 0 ? '$pendingParcels' : null,
              onTap: () => _open(const ParcelsPage(isAdmin: true)),
            ),
            _MenuTile(
              icon: PhosphorIconsDuotone.calendarCheck,
              label: 'จัดการการจอง',
              color: AppColors.success,
              onTap: () => _open(const AdminBookingsPage()),
            ),
            _MenuTile(
              icon: PhosphorIconsDuotone.usersThree,
              label: 'ผู้พักทั้งหมด',
              color: AppColors.primary,
              onTap: () => _open(const AdminResidentsPage()),
            ),
          ]
        : <_MenuTile>[
            _MenuTile(
              icon: PhosphorIconsDuotone.receipt,
              label: 'บิลค่าเช่า',
              color: AppColors.accent,
              badge: unpaidBills > 0 ? '$unpaidBills' : null,
              onTap: () => _open(const BillsPage()),
            ),
            _MenuTile(
              icon: PhosphorIconsDuotone.clockCounterClockwise,
              label: 'ประวัติการชำระ',
              color: AppColors.success,
              onTap: () => _open(const PaymentHistoryPage()),
            ),
            _MenuTile(
              icon: PhosphorIconsDuotone.wrench,
              label: 'แจ้งซ่อม',
              color: AppColors.primary,
              badge: openRequests > 0 ? '$openRequests' : null,
              onTap: () => _open(const MaintenanceListPage()),
            ),
            _MenuTile(
              icon: PhosphorIconsDuotone.megaphoneSimple,
              label: 'ข่าวสารหอพัก',
              color: AppColors.sky,
              onTap: () => _open(const AnnouncementListPage()),
            ),
            _MenuTile(
              icon: PhosphorIconsDuotone.package,
              label: 'พัสดุ',
              color: AppColors.violet,
              badge: pendingParcels > 0 ? '$pendingParcels' : null,
              onTap: () => _open(const ParcelsPage()),
            ),
            _MenuTile(
              icon: PhosphorIconsDuotone.calendarCheck,
              label: 'จองส่วนกลาง',
              color: AppColors.success,
              onTap: () => _open(const FacilityListPage()),
            ),
            _MenuTile(
              icon: PhosphorIconsDuotone.buildings,
              label: 'ข้อมูลหอพัก',
              color: AppColors.primary,
              onTap: () => _open(const DormInfoPage()),
            ),
            _MenuTile(
              icon: PhosphorIconsDuotone.chartLineUp,
              label: 'วิเคราะห์น้ำ-ไฟ',
              color: AppColors.accent,
              onTap: () => _open(const UsageAnalyticsPage()),
            ),
          ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
        onRefresh: () async {
          announcementProvider.start();
          if (isAdmin) {
            await context.read<BillProvider>().refreshAdminPendingSlips();
          }
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _Header(
              name: user?.name.split(' ').first ?? '',
              unread: unreadNotifications,
              tooltip: isAdmin ? 'สลิปที่รอตรวจสอบ' : 'การแจ้งเตือน',
              onBell: isAdmin ? _openSlipReview : _openNotifications,
            ),
            const SizedBox(height: 20),
            if (user != null) _DormCard(user: user),
            const SizedBox(height: 28),
            Text('ทางลัด', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisExtent: 112,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              children: [
                for (var i = 0; i < tiles.length; i++) ListReveal(index: i, child: tiles[i]),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ข่าวสารหอพัก',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                if (news.isNotEmpty)
                  TextButton(
                    onPressed: () => _open(const AnnouncementListPage()),
                    child: const Text('ดูทั้งหมด'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (announcementProvider.isLoading && news.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (news.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text('ยังไม่มีประกาศจากหอพัก',
                        style: TextStyle(color: AppColors.textMuted)),
                  ),
                ),
              )
            else
              for (final item in news)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnnouncementCard(
                    announcement: item,
                    onTap: () => _open(AnnouncementDetailPage(announcement: item)),
                  ),
                ),
          ],
        ),
      ),
      ),
    );
  }
}

/// หัวหน้าแรก: คำทักทาย + ปุ่มกระดิ่งวงกลมนุ่ม ๆ
class _Header extends StatelessWidget {
  final String name;
  final int unread;
  final String tooltip;
  final VoidCallback onBell;
  const _Header(
      {required this.name, required this.unread, required this.tooltip, required this.onBell});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('สวัสดี,', style: t.bodyMedium?.copyWith(color: AppColors.textMuted)),
              Text(name.isEmpty ? 'DormEase' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4, height: 1.15)),
            ],
          ),
        ),
        _Pressable(
          onTap: onBell,
          child: Tooltip(
            message: tooltip,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppColors.softShadow(),
              ),
              alignment: Alignment.center,
              child: Badge(
                isLabelVisible: unread > 0,
                label: Text('$unread'),
                child: PhosphorIcon(PhosphorIconsDuotone.bell,
                    size: 26, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// การ์ดหอพัก: พื้นไล่สีอินดิโก + ฟองสีลอยช้า ๆ (จุดเด่นเดียวของหน้านี้)
class _DormCard extends StatelessWidget {
  final UserModel user;
  const _DormCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.isAdmin;
    final t = Theme.of(context).textTheme;
    return Container(
      height: 168,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C6CF7), Color(0xFF4A45D8)],
        ),
        boxShadow: AppColors.softShadow(AppColors.primaryDark),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: FloatingBubbles()),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isAdmin ? 'หอพักที่ดูแล' : 'หอพักของฉัน',
                    style: t.bodyMedium?.copyWith(color: Colors.white70)),
                const SizedBox(height: 2),
                Text(DormConfig.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleMedium
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                const Spacer(),
                if (isAdmin)
                  Text('ผู้ดูแลหอพัก',
                      style: t.headlineSmall
                          ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800))
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(user.room.isNotEmpty ? user.room : '–',
                          style: t.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 1,
                              letterSpacing: -1)),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('ห้อง', style: t.bodyMedium?.copyWith(color: Colors.white70)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ย่อเล็กน้อยเมื่อกดค้าง แล้วเด้งกลับ
class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Pressable({required this.child, required this.onTap});
  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.92 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: AppColors.softShadow(color),
                ),
                child: Center(
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: PhosphorIcon(icon, color: color, size: 26),
                  ),
                ),
              ),
              if (badge != null)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                    ),
                    child: Text(badge!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, height: 1.2)),
        ],
      ),
    );
  }
}
