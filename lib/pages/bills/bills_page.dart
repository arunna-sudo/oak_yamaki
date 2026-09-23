import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/bill_provider.dart';
import '../../widgets/bill_card.dart';
import '../../widgets/loading_widget.dart';
import '../admin/admin_slip_review_page.dart';
import 'bill_detail_page.dart';
import 'electricity_calculator_page.dart';

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
      final auth = context.read<AuthProvider>();
      final email = auth.userProfile?.email;
      if (email != null) {
        context.read<BillProvider>().start(email);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final billProvider = context.watch<BillProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ค่าห้องและค่าไฟ'),
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.fact_check_outlined),
              tooltip: 'ตรวจสอบสลิปโอนเงิน',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminSlipReviewPage()),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.calculate_outlined),
        label: const Text('คำนวณค่าไฟ'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ElectricityCalculatorPage()),
        ),
      ),
      body: billProvider.isLoading
          ? const LoadingWidget()
          : billProvider.bills.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.receipt_long_outlined,
                  title: 'ยังไม่มีบิลในระบบ',
                  subtitle: 'กดปุ่ม "คำนวณค่าไฟ" ด้านล่างเพื่อสร้างบิลเดือนแรกของคุณ',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
                  itemCount: billProvider.bills.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final bill = billProvider.bills[index];
                    return BillCard(
                      bill: bill,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => BillDetailPage(bill: bill)),
                      ),
                    );
                  },
                ),
    );
  }
}
