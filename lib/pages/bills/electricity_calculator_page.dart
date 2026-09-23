import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/bill_provider.dart';
import '../../services/electricity_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/validators.dart';

/// ElectricityCalculatorPage คือฟีเจอร์ "คำนวณค่าไฟ" ที่ออกแบบตามสถาปัตยกรรม
/// เดียวกับตัวอย่าง BMR ใน Lecture 7:
///   UI (ฟอร์มนี้) -> BillProvider (Controller) -> ElectricityService (คำนวณ)
/// ฟอร์มกรอกข้อมูลใช้ flutter_form_builder ตาม Lecture 6 พร้อม Validator
/// ที่ตรวจว่าต้องเป็นตัวเลขและห้ามติดลบ
class ElectricityCalculatorPage extends StatefulWidget {
  const ElectricityCalculatorPage({super.key});

  @override
  State<ElectricityCalculatorPage> createState() => _ElectricityCalculatorPageState();
}

class _ElectricityCalculatorPageState extends State<ElectricityCalculatorPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final billProvider = context.watch<BillProvider>();
    final result = billProvider.lastCalculation;
    final currency = NumberFormat.currency(locale: 'th', symbol: '฿', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(title: const Text('คำนวณค่าไฟฟ้า')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormBuilder(
              key: _formKey,
              initialValue: {'month': DateFormat('yyyy-MM').format(DateTime.now())},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormBuilderTextField(
                    name: 'month',
                    decoration: const InputDecoration(
                      labelText: 'เดือนของบิล (yyyy-MM)',
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: FormBuilderValidators.required(errorText: 'กรุณาระบุเดือน'),
                  ),
                  const SizedBox(height: 14),
                  FormBuilderTextField(
                    name: 'previousUnit',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'เลขมิเตอร์ครั้งก่อน (หน่วย)',
                      prefixIcon: Icon(Icons.speed_outlined),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: Validators.compose([
                      Validators.required(errorMessage: 'กรุณากรอกเลขมิเตอร์ครั้งก่อน'),
                      Validators.positiveNumber(),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  FormBuilderTextField(
                    name: 'currentUnit',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'เลขมิเตอร์ครั้งนี้ (หน่วย)',
                      prefixIcon: Icon(Icons.speed),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: Validators.compose([
                      Validators.required(errorMessage: 'กรุณากรอกเลขมิเตอร์ครั้งนี้'),
                      Validators.positiveNumber(),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  FormBuilderTextField(
                    name: 'roomRent',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'ค่าเช่าห้องต่อเดือน (บาท)',
                      prefixIcon: Icon(Icons.house_outlined),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: Validators.compose([
                      Validators.required(errorMessage: 'กรุณากรอกค่าเช่าห้อง'),
                      Validators.positiveNumber(),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('คำนวณ'),
                onPressed: _calculate,
              ),
            ),
            const SizedBox(height: 20),
            if (result != null) _ResultCard(result: result, currency: currency),
            if (result != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : () => _saveBill(result),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('บันทึกเป็นบิลใหม่'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _calculate() {
    if (_formKey.currentState?.saveAndValidate() != true) return;
    final values = _formKey.currentState!.value;

    final previousUnit = double.parse(values['previousUnit'].toString());
    final currentUnit = double.parse(values['currentUnit'].toString());
    final roomRent = double.parse(values['roomRent'].toString());

    if (currentUnit < previousUnit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เลขมิเตอร์ครั้งนี้ต้องมากกว่าหรือเท่ากับครั้งก่อน'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    context.read<BillProvider>().calculate(
          previousUnit: previousUnit,
          currentUnit: currentUnit,
          roomRent: roomRent,
        );
  }

  Future<void> _saveBill(ElectricityCalculationResult result) async {
    final values = _formKey.currentState!.value;
    final auth = context.read<AuthProvider>();
    final email = auth.userProfile?.email;
    if (email == null) return;

    setState(() => _saving = true);

    final success = await context.read<BillProvider>().saveBillFromCalculation(
          email: email,
          month: values['month'] as String,
          previousUnit: double.parse(values['previousUnit'].toString()),
          currentUnit: double.parse(values['currentUnit'].toString()),
          calc: result,
        );

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกบิลเรียบร้อยแล้ว'), backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกบิลไม่สำเร็จ'), backgroundColor: AppColors.danger),
      );
    }
  }
}

class _ResultCard extends StatelessWidget {
  final ElectricityCalculationResult result;
  final NumberFormat currency;

  const _ResultCard({required this.result, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('สรุปยอดค่าใช้จ่าย',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(currency.format(result.totalAmount),
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          _row('หน่วยที่ใช้', '${result.unitsUsed.toStringAsFixed(1)} หน่วย'),
          _row('ค่าไฟฟ้า (เฉลี่ย ${result.ratePerUnit.toStringAsFixed(2)} บาท/หน่วย)',
              currency.format(result.electricityAmount)),
          _row('ค่าเช่าห้อง', currency.format(result.roomRent)),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
