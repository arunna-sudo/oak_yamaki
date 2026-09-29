import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/booking_model.dart';
import '../../models/facility_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../utils/app_theme.dart';

enum _SlotState { free, booked, mine, past }

/// เลือกวัน + ช่วงเวลาของห้องหนึ่งห้อง
/// - ช่วงที่มีคนจองแล้วจะกดไม่ได้ (สถานะ "ไม่ว่าง")
/// - แตะหลายช่องติดกันเพื่อจองต่อเนื่องได้ ไม่เกิน FacilityConfig.maxHours ชั่วโมง
class FacilityBookingPage extends StatefulWidget {
  final FacilityModel facility;
  const FacilityBookingPage({super.key, required this.facility});

  @override
  State<FacilityBookingPage> createState() => _FacilityBookingPageState();
}

class _FacilityBookingPageState extends State<FacilityBookingPage> {
  late final List<DateTime> _days;
  late DateTime _selectedDay;
  int? _selStart;
  int? _selEnd; // ไม่รวมชั่วโมงนี้
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _days = List.generate(
      FacilityConfig.advanceDays,
      (i) => DateTime(now.year, now.month, now.day + i),
    );
    _selectedDay = _days.first;
    WidgetsBinding.instance.addPostFrameCallback((_) => _watchDay());
  }

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_selectedDay);

  void _watchDay() => context.read<BookingProvider>().watchDate(_dateStr);

  void _selectDay(DateTime day) {
    setState(() {
      _selectedDay = day;
      _selStart = null;
      _selEnd = null;
    });
    _watchDay();
  }

  _SlotState _slotState(int hour, List<BookingModel> bookings, String? myUid) {
    final now = DateTime.now();
    final isToday = _selectedDay.year == now.year &&
        _selectedDay.month == now.month &&
        _selectedDay.day == now.day;
    if (isToday && hour <= now.hour) return _SlotState.past;
    for (final b in bookings) {
      if (b.facilityId == widget.facility.id &&
          b.status == BookingStatus.confirmed &&
          b.startHour <= hour &&
          hour < b.endHour) {
        return b.uid == myUid ? _SlotState.mine : _SlotState.booked;
      }
    }
    return _SlotState.free;
  }

  void _onTapSlot(int h) {
    setState(() {
      final s = _selStart;
      final e = _selEnd;
      if (s == null || e == null) {
        _selStart = h;
        _selEnd = h + 1;
        return;
      }
      if (h >= s && h < e) {
        // แตะช่องที่เลือกอยู่แล้ว: ลดช่วงจากขอบ หรือเริ่มเลือกใหม่
        if (e - s == 1) {
          _selStart = null;
          _selEnd = null;
        } else if (h == s) {
          _selStart = s + 1;
        } else if (h == e - 1) {
          _selEnd = e - 1;
        } else {
          _selStart = h;
          _selEnd = h + 1;
        }
        return;
      }
      if (h == e && e - s < FacilityConfig.maxHours) {
        _selEnd = e + 1;
      } else if (h == s - 1 && e - s < FacilityConfig.maxHours) {
        _selStart = h;
      } else {
        _selStart = h;
        _selEnd = h + 1;
      }
    });
  }

  Future<void> _submit() async {
    final s = _selStart;
    final e = _selEnd;
    final user = context.read<AuthProvider>().userProfile;
    if (s == null || e == null || user == null) return;

    setState(() => _submitting = true);
    final error = await context.read<BookingProvider>().createBooking(
          facility: widget.facility,
          date: _dateStr,
          startHour: s,
          endHour: e,
          user: user,
        );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _selStart = null;
      _selEnd = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'จอง ${widget.facility.name} สำเร็จ'),
        backgroundColor: error == null ? AppColors.success : AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final myUid = context.watch<AuthProvider>().userProfile?.uid;
    final facility = widget.facility;
    final type = facility.type;
    final hours = [for (var h = FacilityConfig.openHour; h < FacilityConfig.closeHour; h++) h];
    final hasSelection = _selStart != null && _selEnd != null;

    return Scaffold(
      appBar: AppBar(title: Text(facility.name)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasSelection)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${DateFormat('EEE d MMM', 'th').format(_selectedDay)} • '
                    '${FacilityConfig.hh(_selStart!)}–${FacilityConfig.hh(_selEnd!)} '
                    '(${_selEnd! - _selStart!} ชม.)',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (!hasSelection || _submitting) ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('ยืนยันการจอง'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('เลือกวันที่', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final day = _days[i];
                final selected = day == _selectedDay;
                return InkWell(
                  onTap: () => _selectDay(day),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 58,
                    decoration: BoxDecoration(
                      color: selected ? type.color : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: selected ? type.color : Theme.of(context).dividerColor, width: selected ? 1.6 : 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('E', 'th').format(day),
                            style: TextStyle(
                                fontSize: 12, color: selected ? Colors.white : AppColors.textMuted)),
                        const SizedBox(height: 2),
                        Text('${day.day}',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: selected ? Colors.white : null)),
                        Text(DateFormat('MMM', 'th').format(day),
                            style: TextStyle(
                                fontSize: 10, color: selected ? Colors.white : AppColors.textMuted)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text('เลือกช่วงเวลา', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
              Text('จองได้สูงสุด ${FacilityConfig.maxHours} ชม./ครั้ง',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _legend(Colors.white, 'ว่าง', border: Colors.grey.shade400),
              _legend(type.color, 'ที่เลือก'),
              _legend(AppColors.success.withOpacity(0.3), 'จองโดยคุณ'),
              _legend(AppColors.textMuted.withOpacity(0.35), 'ไม่ว่าง'),
            ],
          ),
          const SizedBox(height: 12),
          if (provider.dayError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('โหลดข้อมูลการจองไม่สำเร็จ: ${provider.dayError}',
                  style: const TextStyle(color: AppColors.danger)),
            ),
          if (provider.dayLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3.2,
              children: [
                for (final h in hours)
                  _slotTile(
                    h,
                    _slotState(h, provider.dayBookings, myUid),
                    type.color,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label, {Color? border}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: border != null ? Border.all(color: border) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _slotTile(int hour, _SlotState state, Color accent) {
    final selected = _selStart != null && hour >= _selStart! && hour < _selEnd!;
    final enabled = state == _SlotState.free;

    Color bg;
    Color fg;
    Color border;
    String? tag;
    if (selected) {
      bg = accent;
      fg = Colors.white;
      border = accent;
    } else {
      switch (state) {
        case _SlotState.free:
          bg = Theme.of(context).cardColor;
          fg = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textDark;
          border = AppColors.textMuted.withOpacity(0.35);
          break;
        case _SlotState.mine:
          bg = AppColors.success.withOpacity(0.18);
          fg = AppColors.success;
          border = AppColors.success.withOpacity(0.4);
          tag = 'จองโดยคุณ';
          break;
        case _SlotState.booked:
          bg = AppColors.textMuted.withOpacity(0.16);
          fg = AppColors.textMuted;
          border = Colors.transparent;
          tag = 'ไม่ว่าง';
          break;
        case _SlotState.past:
          bg = AppColors.textMuted.withOpacity(0.08);
          fg = AppColors.textMuted.withOpacity(0.6);
          border = Colors.transparent;
          tag = 'ผ่านไปแล้ว';
          break;
      }
    }

    return InkWell(
      onTap: enabled ? () => _onTapSlot(hour) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${FacilityConfig.hh(hour)}–${FacilityConfig.hh(hour + 1)}',
              style: TextStyle(fontWeight: FontWeight.w700, color: fg, fontSize: 14),
            ),
            if (tag != null && !selected)
              Text(tag, style: TextStyle(color: fg, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
