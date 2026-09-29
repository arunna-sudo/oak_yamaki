import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/dorm_config.dart';

/// หน้าข้อมูลหอพักสำหรับผู้พัก: รายละเอียดหอ / ช่องทางติดต่อ / บัญชีธนาคาร
/// (ค่าทั้งหมดแก้ได้ที่ utils/dorm_config.dart) แตะที่เบอร์/อีเมล/เลขบัญชีเพื่อคัดลอก
class DormInfoPage extends StatelessWidget {
  const DormInfoPage({super.key});

  Future<void> _copy(BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('คัดลอก$labelแล้ว'), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userProfile;
    final muted = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkTextMuted
        : AppColors.textMuted;

    Widget row(String label, String value, {VoidCallback? onTap, IconData? trailing}) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 110, child: Text(label, style: TextStyle(color: muted))),
              Expanded(
                child: Text(value,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4)),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                Icon(trailing, size: 16, color: muted),
              ],
            ],
          ),
        ),
      );
    }

    Widget section(String title, List<Widget> children) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                ...children,
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ข้อมูลหอพัก')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          section('รายละเอียดหอพัก', [
            row('ชื่อหอพัก', DormConfig.fullName),
            row('ห้อง', (user?.room.isNotEmpty ?? false) ? user!.room : '-'),
            if (DormConfig.address.isNotEmpty) row('ที่อยู่', DormConfig.address),
          ]),
          section('ติดต่อหอพัก', [
            for (final phone in DormConfig.phones)
              row('เบอร์โทรติดต่อ', phone,
                  trailing: PhosphorIconsRegular.copy, onTap: () => _copy(context, phone, 'เบอร์โทร')),
            if (DormConfig.email.isNotEmpty)
              row('อีเมล', DormConfig.email,
                  trailing: PhosphorIconsRegular.copy,
                  onTap: () => _copy(context, DormConfig.email, 'อีเมล')),
          ]),
          section('บัญชีธนาคารหอพัก', [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const PhosphorIcon(PhosphorIconsDuotone.bank, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DormConfig.bankName,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text('ชื่อบัญชี ${DormConfig.bankAccountName}',
                            style: TextStyle(color: muted, fontSize: 13)),
                        Text('เลขที่บัญชี ${DormConfig.bankAccountNumber}',
                            style: TextStyle(color: muted, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'คัดลอกเลขบัญชี',
                    icon: const PhosphorIcon(PhosphorIconsDuotone.copy),
                    onPressed: () =>
                        _copy(context, DormConfig.bankAccountNumber, 'เลขบัญชี'),
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
