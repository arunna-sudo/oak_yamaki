import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

/// หน้าที่แสดงให้ผู้พักที่เพิ่งสมัครใหม่เห็น ระหว่างรอแอดมินกดยืนยันบัญชี
/// (AuthGate ใน main.dart จะแสดงหน้านี้แทน MainShell จนกว่า isApproved จะเป็น true)
class PendingApprovalPage extends StatefulWidget {
  const PendingApprovalPage({super.key});

  @override
  State<PendingApprovalPage> createState() => _PendingApprovalPageState();
}

class _PendingApprovalPageState extends State<PendingApprovalPage> {
  bool _checking = false;

  Future<void> _checkStatus() async {
    setState(() => _checking = true);
    await context.read<AuthProvider>().refreshProfile();
    if (!mounted) return;
    setState(() => _checking = false);

    final approved = context.read<AuthProvider>().userProfile?.isApproved ?? false;
    if (!approved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บัญชียังไม่ได้รับการยืนยันจากแอดมิน กรุณารอสักครู่')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const PhosphorIcon(PhosphorIconsDuotone.hourglassHigh, color: AppColors.accent, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                'รอการยืนยันจากแอดมิน',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const Text(
                'บัญชีของคุณสมัครเรียบร้อยแล้ว แต่ต้องรอผู้ดูแลหอพัก\n'
                'ตรวจสอบและกดยืนยันก่อน จึงจะเข้าใช้งานแอปได้',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _checking ? null : _checkStatus,
                  icon: _checking
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const PhosphorIcon(PhosphorIconsDuotone.arrowsClockwise),
                  label: const Text('ตรวจสอบสถานะอีกครั้ง'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.read<AuthProvider>().logout(),
                child: const Text('ออกจากระบบ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
