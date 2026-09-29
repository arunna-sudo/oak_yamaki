import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/loading_widget.dart';

/// AdminApproveResidentsPage: แท็บสำหรับแอดมินโดยเฉพาะ ใช้ยืนยัน (หรือปฏิเสธ)
/// ผู้พักที่เพิ่งลงทะเบียนใหม่ ก่อนที่พวกเขาจะเข้าใช้งานแอปได้
class AdminApproveResidentsPage extends StatelessWidget {
  const AdminApproveResidentsPage({super.key});

  Future<void> _approve(BuildContext context, UserModel user) async {
    await UserService().approveResident(user.uid);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ยืนยันบัญชี ${user.name} เรียบร้อยแล้ว'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _reject(BuildContext context, UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ปฏิเสธการสมัคร'),
        content: Text('ต้องการปฏิเสธและลบบัญชีของ "${user.name}" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('ปฏิเสธ'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await UserService().rejectResident(user.uid);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ปฏิเสธการสมัครของ ${user.name} แล้ว')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

    return Scaffold(
      appBar: AppBar(title: const Text('ยืนยันผู้พักใหม่')),
      body: StreamBuilder<List<UserModel>>(
        stream: userService.watchPendingResidents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }
          final pending = snapshot.data ?? [];
          if (pending.isEmpty) {
            return const EmptyStateWidget(
              icon: PhosphorIconsRegular.userCheck,
              title: 'ไม่มีผู้พักที่รอยืนยัน',
              subtitle: 'เมื่อมีคนสมัครใหม่ จะปรากฏที่นี่',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: pending.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final u = pending[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            child: Text(
                              u.name.isNotEmpty ? u.name.substring(0, 1) : '?',
                              style: const TextStyle(
                                  color: AppColors.primary, fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text('${u.email} • เบอร์โทร: ${u.phone}',
                                    style: const TextStyle(
                                        color: AppColors.textMuted, fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'ห้อง ${u.room}',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _reject(context, u),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.danger,
                                  side: const BorderSide(color: AppColors.danger)),
                              child: const Text('ปฏิเสธ'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _approve(context, u),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                              child: const Text('ยืนยัน'),
                            ),
                          ),
                        ],
                      ),
                    ],
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
