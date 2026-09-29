import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/bill_provider.dart';
import '../../widgets/bill_card.dart';
import '../../widgets/list_reveal.dart';
import '../../widgets/loading_widget.dart';
import 'bill_detail_page.dart';
import 'payment_history_page.dart';

/// หน้าบิลค่าเช่า/ค่าน้ำ/ค่าไฟ ของผู้พัก (บิลที่แอดมินออกให้ห้องของตัวเอง)
/// การออกบิลและตรวจสลิปเป็นหน้าของแอดมิน ดูที่ pages/admin/
class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final email = context.read<AuthProvider>().userProfile?.email;
      if (email != null) {
        context.read<BillProvider>().start(email);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final billProvider = context.watch<BillProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('บิลค่าเช่า'),
        actions: [
          IconButton(
            icon: const PhosphorIcon(PhosphorIconsDuotone.clockCounterClockwise),
            tooltip: 'ประวัติการชำระเงิน',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PaymentHistoryPage()),
            ),
          ),
        ],
      ),
      body: billProvider.isLoading
          ? const LoadingWidget()
          : billProvider.bills.isEmpty
              ? const EmptyStateWidget(
                  icon: PhosphorIconsRegular.receipt,
                  title: 'ยังไม่มีบิลในระบบ',
                  subtitle: 'เมื่อผู้ดูแลหอพักออกบิลค่าเช่า-ค่าน้ำ-ค่าไฟให้ห้องของคุณ รายการจะแสดงที่นี่',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  itemCount: billProvider.bills.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final bill = billProvider.bills[index];
                    return ListReveal(
                      index: index,
                      slideFromBottom: true,
                      child: BillCard(
                        bill: bill,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => BillDetailPage(bill: bill)),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
