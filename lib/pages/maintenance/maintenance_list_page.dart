import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/maintenance_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/maintenance_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/list_reveal.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/maintenance_card.dart';
import 'create_maintenance_page.dart';
import 'maintenance_detail_page.dart';

class MaintenanceListPage extends StatefulWidget {
  const MaintenanceListPage({super.key});

  @override
  State<MaintenanceListPage> createState() => _MaintenanceListPageState();
}

class _MaintenanceListPageState extends State<MaintenanceListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final provider = context.read<MaintenanceProvider>();
      if (auth.isAdmin) {
        provider.startForAdmin();
      } else if (auth.userProfile != null) {
        provider.startForUser(auth.userProfile!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<MaintenanceProvider>();
    final isAdmin = auth.isAdmin;

    return Scaffold(
      appBar: AppBar(title: Text(isAdmin ? 'คำขอแจ้งซ่อมทั้งหมด' : 'แจ้งซ่อมของฉัน')),
      floatingActionButton: isAdmin
          ? null
          : FloatingActionButton.extended(
              icon: const PhosphorIcon(PhosphorIconsDuotone.plus),
              label: const Text('แจ้งซ่อม'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateMaintenancePage()),
              ),
            ),
      body: provider.isLoading
          ? const LoadingWidget()
          : provider.requests.isEmpty
              ? EmptyStateWidget(
                  icon: PhosphorIconsRegular.wrench,
                  title: isAdmin ? 'ยังไม่มีคำขอแจ้งซ่อม' : 'ยังไม่มีรายการแจ้งซ่อม',
                  subtitle: isAdmin ? null : 'พบปัญหาในห้องพัก? กดปุ่ม "แจ้งซ่อม" ด้านล่างได้เลย',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
                  itemCount: provider.requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final request = provider.requests[index];
                    return ListReveal(
                      index: index,
                      slideFromBottom: true,
                      child: MaintenanceCard(
                        request: request,
                        showRoom: isAdmin,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MaintenanceDetailPage(request: request, isAdmin: isAdmin),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
