import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/dialogs.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/loading_widget.dart';

/// การจองของฉัน (ผู้พัก) ยกเลิกการจองที่ยังไม่ถึงเวลาได้
class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().userProfile?.uid;
      if (uid != null) context.read<BookingProvider>().startMine(uid);
    });
  }

  Future<void> _cancel(BookingModel booking) async {
    final ok = await confirmAction(
      context,
      title: 'ยกเลิกการจอง',
      message: 'ต้องการยกเลิกการจอง ${booking.facilityName}\n${booking.timeRange} ใช่หรือไม่?',
      confirmLabel: 'ยกเลิกการจอง',
    );
    if (!ok || !mounted) return;
    final error = await context.read<BookingProvider>().cancelBooking(booking, byAdmin: false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'ยกเลิกการจองแล้ว'),
        backgroundColor: error == null ? AppColors.success : AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    // กำลังจะถึงขึ้นก่อน (ใกล้สุดก่อน) แล้วตามด้วยประวัติ (ล่าสุดก่อน)
    final upcoming = provider.bookings.where((b) => b.isActive).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final past = provider.bookings.where((b) => !b.isActive).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    final items = [...upcoming, ...past];

    return Scaffold(
      appBar: AppBar(title: const Text('การจองของฉัน')),
      body: provider.isLoading
          ? const LoadingWidget()
          : items.isEmpty
              ? const EmptyStateWidget(
                  icon: PhosphorIconsRegular.calendarCheck,
                  title: 'ยังไม่มีการจอง',
                  subtitle: 'เลือกห้องที่หน้า "จองส่วนกลาง" เพื่อเริ่มจอง',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => BookingCard(
                    booking: items[i],
                    onCancel: () => _cancel(items[i]),
                  ),
                ),
    );
  }
}
