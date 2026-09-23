import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../announcement/announcement_list_page.dart';
import '../bills/bills_page.dart';
import '../maintenance/maintenance_list_page.dart';
import '../profile/profile_page.dart';
import 'home_page.dart';

/// MainShell คือ StatefulWidget หลักหลัง Login สำเร็จ ใช้ IndexedStack
/// เพื่อสลับหน้าจอทั้ง 5 แท็บโดยไม่ทำลาย State ของแต่ละหน้า
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    AnnouncementListPage(),
    BillsPage(),
    MaintenanceListPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'หน้าแรก'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), activeIcon: Icon(Icons.campaign), label: 'ประกาศ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'ค่าห้อง'),
          BottomNavigationBarItem(icon: Icon(Icons.build_outlined), activeIcon: Icon(Icons.build), label: 'แจ้งซ่อม'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'โปรไฟล์'),
        ],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
    );
  }
}

/// Extension เล็กๆ เผื่ออยากอ้างสีพื้นหลังของ shell จากที่อื่น
extension MainShellColors on BuildContext {
  Color get dormBg => AppColors.bg;
}
