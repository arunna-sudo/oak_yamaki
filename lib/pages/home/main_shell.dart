import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../utils/app_theme.dart';

import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import '../admin/admin_approve_residents_page.dart';
import '../announcement/announcement_list_page.dart';
import '../community/community_page.dart';
import '../profile/profile_page.dart';
import 'home_page.dart';

/// MainShell คือ StatefulWidget หลักหลัง Login สำเร็จ ใช้ IndexedStack
/// เพื่อสลับแท็บโดยไม่ทำลาย State ของแต่ละหน้า
///
/// แถบล่างของผู้พัก 4 แท็บ: หน้าแรก / คอมมูนิตี้ / ข่าวสาร / โปรไฟล์
/// แถบล่างของแอดมินมีเพิ่มแท็บ "ยืนยันผู้ใช้ใหม่" (พร้อมตัวเลขแจ้งเตือน) เข้ามาด้วย
/// ส่วนบิลค่าเช่า แจ้งซ่อม ประกาศ และเครื่องมือแอดมินอื่น ๆ อยู่ในเมนูที่หน้าแรก
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final UserService _userService = UserService();
  late final Stream<int> _pendingCount =
      _userService.watchPendingResidents().map((l) => l.length).asBroadcastStream();

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    final pages = <Widget>[
      const HomePage(),
      const CommunityPage(),
      const AnnouncementListPage(),
      if (isAdmin) const AdminApproveResidentsPage(),
      const ProfilePage(),
    ];

    // กันแท็บที่เลือกอยู่หลุดขอบ กรณีสลับบทบาทระหว่างใช้งาน (ไม่น่าเกิดขึ้นจริง แต่กันไว้)
    if (_index >= pages.length) _index = 0;

    final items = <_NavItem>[
      const _NavItem(PhosphorIconsDuotone.house, PhosphorIconsRegular.house, 'หน้าแรก'),
      const _NavItem(
          PhosphorIconsDuotone.chatsCircle, PhosphorIconsRegular.chatsCircle, 'คอมมูนิตี้'),
      const _NavItem(
          PhosphorIconsDuotone.megaphoneSimple, PhosphorIconsRegular.megaphoneSimple, 'ข่าวสาร'),
      if (isAdmin)
        _NavItem(PhosphorIconsDuotone.userCheck, PhosphorIconsRegular.userCheck, 'ยืนยัน',
            badgeStream: _pendingCount),
      const _NavItem(
          PhosphorIconsDuotone.userCircle, PhosphorIconsRegular.userCircle, 'โปรไฟล์'),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Container(
            height: 68,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(34),
              boxShadow: AppColors.softShadow(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0; i < items.length; i++)
                  _NavButton(
                    item: items[i],
                    selected: i == _index,
                    onTap: () => setState(() => _index = i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData active;
  final IconData idle;
  final String label;
  final Stream<int>? badgeStream;
  const _NavItem(this.active, this.idle, this.label, {this.badgeStream});
}

/// ปุ่มแท็บ: ตัวที่เลือกจะขยายเป็นแคปซูลสีพร้อมป้ายชื่อ ตัวอื่นเหลือแค่ไอคอน
///
/// หมายเหตุ: เขียนใหม่ให้ควบคุม "ความกว้าง" ของแคปซูลตรง ๆ ด้วย
/// AnimatedContainer(width: ...) แทนการใช้ Expanded + FittedBox + AnimatedSize
/// เพราะชุดเดิมทำให้ Row ปล่อยความสูง/ความกว้างแบบไม่จำกัดให้ลูก (โดยเฉพาะตอนมี
/// Badge ผสมอยู่) จน Flutter คำนวณ overflow พังเป็นหลักหมื่นพิกเซล วิธีนี้ทุก
/// กล่องมีขนาดที่แน่นอนเสมอ จึงไม่มีทางเกิด unbounded constraint อีก
class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;
  const _NavButton({required this.item, required this.selected, required this.onTap});

  static const double _collapsedWidth = 48;
  static const double _expandedWidth = 108;
  static const double _height = 52;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final baseIcon = PhosphorIcon(
      selected ? item.active : item.idle,
      size: 24,
      color: selected ? Colors.white : AppColors.textMuted,
    );
    Widget icon = baseIcon;
    if (item.badgeStream != null) {
      icon = SizedBox(
        width: 24,
        height: 24,
        child: StreamBuilder<int>(
          stream: item.badgeStream,
          builder: (_, snap) {
            final count = snap.data ?? 0;
            return Badge(
              isLabelVisible: count > 0,
              label: Text(count > 99 ? '99+' : '$count'),
              child: baseIcon, // อ้างไอคอนต้นฉบับ ห้ามอ้าง `icon` ซ้ำ (จะวนลูปตัวเอง)
            );
          },
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutBack,
          width: selected ? _expandedWidth : _collapsedWidth,
          height: _height,
          decoration: BoxDecoration(
            color: selected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          clipBehavior: Clip.antiAlias,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                if (selected) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      softWrap: false,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
