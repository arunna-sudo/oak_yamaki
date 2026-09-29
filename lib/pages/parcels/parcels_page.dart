import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/parcel_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/parcel_provider.dart';
import '../../utils/dialogs.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/parcel_card.dart';
import 'add_parcel_page.dart';

/// หน้าพัสดุ 2 แท็บ: พัสดุค้างรับ / พัสดุรับแล้ว
/// - ผู้พัก: เห็นเฉพาะพัสดุของห้องตัวเอง (ดูอย่างเดียว)
/// - แอดมิน (isAdmin): เห็นทุกห้อง + ปุ่มเพิ่มพัสดุ + กด "ผู้พักรับแล้ว" / ลบได้
class ParcelsPage extends StatefulWidget {
  final bool isAdmin;
  const ParcelsPage({super.key, this.isAdmin = false});

  @override
  State<ParcelsPage> createState() => _ParcelsPageState();
}

class _ParcelsPageState extends State<ParcelsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ParcelProvider>();
      if (widget.isAdmin) {
        provider.startForAdmin();
      } else {
        provider.startForRoom(context.read<AuthProvider>().userProfile?.room ?? '');
      }
    });
  }

  Future<void> _delete(ParcelModel parcel) async {
    final ok = await confirmDelete(
      context,
      title: 'ลบรายการพัสดุ',
      message: 'ต้องการลบพัสดุของห้อง ${parcel.room} ใช่หรือไม่?',
    );
    if (!ok || !mounted) return;
    await context.read<ParcelProvider>().deleteParcel(parcel.id);
  }

  Widget _list(List<ParcelModel> items, String emptyTitle) {
    if (items.isEmpty) {
      return EmptyStateWidget(icon: PhosphorIconsRegular.package, title: emptyTitle);
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20, 20, 20, widget.isAdmin ? 90 : 20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final parcel = items[index];
        return ParcelCard(
          parcel: parcel,
          isAdmin: widget.isAdmin,
          onMarkReceived: () => context.read<ParcelProvider>().markReceived(parcel.id),
          onDelete: () => _delete(parcel),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ParcelProvider>();
    final pending = provider.pending;
    final received = provider.received;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('พัสดุ'),
          bottom: TabBar(
            tabs: [
              Tab(text: pending.isEmpty ? 'พัสดุค้างรับ' : 'พัสดุค้างรับ (${pending.length})'),
              const Tab(text: 'พัสดุรับแล้ว'),
            ],
          ),
        ),
        floatingActionButton: widget.isAdmin
            ? FloatingActionButton.extended(
                icon: const PhosphorIcon(PhosphorIconsDuotone.plus),
                label: const Text('เพิ่มพัสดุ'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddParcelPage()),
                ),
              )
            : null,
        body: provider.isLoading
            ? const LoadingWidget()
            : TabBarView(
                children: [
                  _list(pending, 'ไม่พบรายการพัสดุค้างรับ'),
                  _list(received, 'ยังไม่มีพัสดุที่รับแล้ว'),
                ],
              ),
      ),
    );
  }
}
