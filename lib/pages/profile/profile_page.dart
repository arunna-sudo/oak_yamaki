import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import '../admin/admin_residents_page.dart';

/// ProfilePage รวมฟีเจอร์:
/// - แสดงข้อมูลผู้ใช้จาก AuthProvider (Firebase Auth + Firestore "users")
/// - สลับธีม Light/Dark ผ่าน ThemeProvider ซึ่งบันทึกค่าไว้ด้วย SharedPreferences
/// - เมนูเฉพาะผู้ดูแล (admin) สำหรับดูรายชื่อผู้พักทั้งหมด
/// - ออกจากระบบ (logout) ผ่าน AuthProvider.logout()
///
/// เมื่อออกจากระบบ ไม่ต้องเรียก Navigator.pushAndRemoveUntil ด้วยตนเอง เพราะ
/// AuthGate ใน main.dart จะตรวจพบว่า isLoggedIn == false แล้วสลับไปหน้า Login
/// ให้อัตโนมัติ ซึ่งให้ผลลัพธ์เดียวกับที่สอนในสไลด์ (ล้าง Stack ทั้งหมด
/// ผู้ใช้กดย้อนกลับไปหน้า Home เดิมไม่ได้อีก)
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.userProfile;

    return Scaffold(
      appBar: AppBar(title: const Text('โปรไฟล์')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    (user?.name.isNotEmpty ?? false) ? user!.name.substring(0, 1) : '?',
                    style: const TextStyle(
                        color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? '-',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(user?.email ?? '-', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user?.isAdmin == true ? 'ผู้ดูแลหอพัก' : 'ห้อง ${user?.room ?? '-'}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('ข้อมูลติดต่อ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 10),
          _InfoTile(icon: Icons.phone_outlined, label: 'เบอร์โทรศัพท์', value: user?.phone ?? '-'),
          _InfoTile(icon: Icons.meeting_room_outlined, label: 'ห้องพัก', value: user?.room ?? '-'),
          const SizedBox(height: 24),
          const Text('การตั้งค่า', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 10),
          Card(
            child: SwitchListTile(
              value: themeProvider.isDarkMode,
              activeColor: AppColors.primary,
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('โหมดมืด (Dark Mode)'),
              subtitle: const Text('บันทึกค่าไว้ด้วย SharedPreferences'),
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ),
          if (user?.isAdmin == true) ...[
            const SizedBox(height: 24),
            const Text('เครื่องมือผู้ดูแล', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.groups_outlined, color: AppColors.primary),
                title: const Text('รายชื่อผู้พักทั้งหมด'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminResidentsPage()),
                ),
              ),
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: AppColors.danger),
              label: const Text('ออกจากระบบ', style: TextStyle(color: AppColors.danger)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger)),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('ออกจากระบบ'),
                    content: const Text('ยืนยันการออกจากระบบใช่หรือไม่?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ยกเลิก')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('ออกจากระบบ', style: TextStyle(color: AppColors.danger)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await context.read<AuthProvider>().logout();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }
}
