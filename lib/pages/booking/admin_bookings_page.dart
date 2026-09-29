import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/booking_model.dart';
import '../../models/facility_model.dart';
import '../../providers/booking_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/dialogs.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/loading_widget.dart';

/// แอดมิน: ดูการจองห้องส่วนกลางทั้งหมด แยกแท็บ "กำลังจะถึง" / "ประวัติ"
/// กรองตามประเภทห้องได้ และยกเลิกการจองของผู้พักได้
class AdminBookingsPage extends StatefulWidget {
  const AdminBookingsPage({super.key});

  @override
  State<AdminBookingsPage> createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<AdminBookingsPage> {
  FacilityType? _filter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().startAll();
    });
  }

  Future<void> _cancel(BookingModel booking) async {
    final ok = await confirmAction(
      context,
      title: 'ยกเลิกการจอง',
      message:
          'ยกเลิกการจอง ${booking.facilityName} ของห้อง ${booking.room} (${booking.userName})\n'
          'เวลา ${booking.timeRange} ใช่หรือไม่?',
      confirmLabel: 'ยกเลิกการจอง',
    );
    if (!ok || !mounted) return;
    final error = await context.read<BookingProvider>().cancelBooking(booking, byAdmin: true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'ยกเลิกการจองแล้ว'),
        backgroundColor: error == null ? AppColors.success : AppColors.danger,
      ),
    );
  }

  Widget _list(List<BookingModel> items, String emptyTitle, {required bool canCancel}) {
    if (items.isEmpty) {
      return EmptyStateWidget(icon: PhosphorIconsRegular.calendarCheck, title: emptyTitle);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => BookingCard(
        booking: items[i],
        showResident: true,
        onCancel: canCancel ? () => _cancel(items[i]) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final filtered = provider.bookings.where((b) {
      if (_filter == null) return true;
      return FacilityConfig.byId(b.facilityId)?.type == _filter;
    }).toList();
    final upcoming = filtered.where((b) => b.isActive).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final history = filtered.where((b) => !b.isActive).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('จัดการการจอง'),
          bottom: TabBar(
            tabs: [
              Tab(text: upcoming.isEmpty ? 'กำลังจะถึง' : 'กำลังจะถึง (${upcoming.length})'),
              const Tab(text: 'ประวัติ / ยกเลิก'),
            ],
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('ทั้งหมด'),
                      selected: _filter == null,
                      onSelected: (_) => setState(() => _filter = null),
                    ),
                  ),
                  for (final type in FacilityType.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(type.label),
                        selected: _filter == type,
                        onSelected: (_) => setState(() => _filter = type),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: provider.isLoading
                  ? const LoadingWidget()
                  : TabBarView(
                      children: [
                        _list(upcoming, 'ไม่มีการจองที่กำลังจะถึง', canCancel: true),
                        _list(history, 'ยังไม่มีประวัติการจอง', canCancel: false),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
