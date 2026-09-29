import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/loading_widget.dart';

/// AdminResidentsPage: ใช้ StreamBuilder ฟังข้อมูลจาก UserService.watchAllResidents()
/// แบบเรียลไทม์ เพื่อแสดงรายชื่อผู้พักอาศัยทั้งหมดในหอพัก (เฉพาะ Admin เท่านั้น)
class AdminResidentsPage extends StatelessWidget {
  const AdminResidentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

    return Scaffold(
      appBar: AppBar(title: const Text('รายชื่อผู้พักทั้งหมด')),
      body: StreamBuilder<List<UserModel>>(
        stream: userService.watchAllResidents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }
          final residents = snapshot.data ?? [];
          if (residents.isEmpty) {
            return const EmptyStateWidget(
              icon: PhosphorIconsRegular.usersThree,
              title: 'ยังไม่มีผู้พักในระบบ',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: residents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final r = residents[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Text(r.name.isNotEmpty ? r.name.substring(0, 1) : '?',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                  ),
                  title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${r.email}\nเบอร์โทร: ${r.phone}'),
                  isThreeLine: true,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: r.isAdmin ? AppColors.accentLight : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      r.isAdmin ? 'ผู้ดูแล' : 'ห้อง ${r.room}',
                      style: TextStyle(
                        color: r.isAdmin ? AppColors.accent : AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
