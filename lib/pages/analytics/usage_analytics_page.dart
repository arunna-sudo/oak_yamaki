import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/bill_model.dart';
import '../../providers/bill_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/loading_widget.dart';

/// หน้าวิเคราะห์การใช้น้ำ-ไฟ ย้อนหลังสูงสุด 6 เดือน (ดึงจากบิลของผู้พักเอง)
/// แสดงกราฟแท่ง + ค่าสูงสุด/ต่ำสุด/เฉลี่ย ของแต่ละหัวข้อ
class UsageAnalyticsPage extends StatelessWidget {
  const UsageAnalyticsPage({super.key});

  static const _months = 6;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillProvider>();
    final bills = [...provider.bills]..sort((a, b) => a.month.compareTo(b.month));
    final recent = bills.length > _months ? bills.sublist(bills.length - _months) : bills;

    return Scaffold(
      appBar: AppBar(title: const Text('วิเคราะห์การใช้น้ำ-ไฟ')),
      body: provider.isLoading && bills.isEmpty
          ? const LoadingWidget()
          : recent.isEmpty
              ? const EmptyStateWidget(
                  icon: PhosphorIconsRegular.chartLineUp,
                  title: 'ยังไม่มีข้อมูลสำหรับวิเคราะห์',
                  subtitle: 'เมื่อมีบิลค่าน้ำ-ไฟ ข้อมูลจะแสดงที่นี่',
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _ChartCard(
                      title: 'ค่าใช้จ่ายรวมทั้งหมด (บาท)',
                      labels: recent.map((b) => _label(b.month)).toList(),
                      values: recent.map((b) => b.totalAmount).toList(),
                      color: AppColors.accent,
                      isMoney: true,
                      higherIsWorse: true,
                    ),
                    const SizedBox(height: 16),
                    _ChartCard(
                      title: 'การใช้ไฟฟ้า (หน่วย)',
                      labels: recent.map((b) => _label(b.month)).toList(),
                      values: recent.map((b) => b.unitsUsed).toList(),
                      color: AppColors.peach,
                    ),
                    const SizedBox(height: 16),
                    _ChartCard(
                      title: 'รายจ่ายค่าไฟฟ้า (บาท)',
                      labels: recent.map((b) => _label(b.month)).toList(),
                      values: recent.map((b) => b.electricityAmount).toList(),
                      color: AppColors.warning,
                      isMoney: true,
                      higherIsWorse: true,
                    ),
                    const SizedBox(height: 16),
                    _ChartCard(
                      title: 'การใช้น้ำ (หน่วย)',
                      labels: recent.map((b) => _label(b.month)).toList(),
                      values: recent.map((b) => b.waterUnitsUsed).toList(),
                      color: AppColors.sky,
                    ),
                    const SizedBox(height: 16),
                    _ChartCard(
                      title: 'รายจ่ายค่าน้ำ (บาท)',
                      labels: recent.map((b) => _label(b.month)).toList(),
                      values: recent.map((b) => b.waterAmount).toList(),
                      color: AppColors.sky,
                      isMoney: true,
                      higherIsWorse: true,
                    ),
                  ],
                ),
    );
  }

  /// '2026-09' -> '09/2026'
  static String _label(String month) {
    final parts = month.split('-');
    return parts.length == 2 ? '${parts[1]}/${parts[0]}' : month;
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final List<String> labels;
  final List<double> values;
  final Color color;
  final bool isMoney;
  final bool higherIsWorse;

  const _ChartCard({
    required this.title,
    required this.labels,
    required this.values,
    required this.color,
    this.isMoney = false,
    this.higherIsWorse = false,
  });

  String _fmt(double v) =>
      isMoney ? NumberFormat('#,##0.00').format(v) : NumberFormat('#,##0.##').format(v);

  String _axis(double v) => NumberFormat.compact().format(v);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final muted = dark ? AppColors.darkTextMuted : AppColors.textMuted;
    final maxValue = values.fold<double>(0, math.max);
    final minValue = values.reduce(math.min);
    final avg = values.reduce((a, b) => a + b) / values.length;
    final maxY = maxValue <= 0 ? 1.0 : maxValue * 1.2;

    final highColor = higherIsWorse ? AppColors.danger : AppColors.success;
    final lowColor = higherIsWorse ? AppColors.success : AppColors.danger;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  minY: 0,
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: muted.withOpacity(0.2), strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        interval: maxY / 4,
                        getTitlesWidget: (v, meta) => Text(
                          _axis(v),
                          style: TextStyle(color: muted, fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (v, meta) {
                          final i = v.toInt();
                          if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(labels[i], style: TextStyle(color: muted, fontSize: 10)),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                        _fmt(rod.toY),
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < values.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: values[i],
                            color: color,
                            width: 22,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _statRow(PhosphorIconsRegular.arrowCircleUp, 'สูงสุด', _fmt(maxValue), highColor),
            _statRow(PhosphorIconsRegular.arrowCircleDown, 'ต่ำสุด', _fmt(minValue), lowColor),
            _statRow(PhosphorIconsRegular.chartBar, 'เฉลี่ย', _fmt(avg), AppColors.accent),
          ],
        ),
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15)),
        ],
      ),
    );
  }
}
