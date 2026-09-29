import 'package:flutter/material.dart';

/// ทำให้รายการ/กริดค่อย ๆ โผล่ทีละอันตอนหน้าเปิดขึ้นครั้งแรก (ไล่ตาม [index])
/// ใช้ซ้ำได้ทั้งหน้าแรก บิล แจ้งซ่อม และฟีดคอมมูนิตี้
class ListReveal extends StatelessWidget {
  final int index;
  final Widget child;
  final bool slideFromBottom;

  const ListReveal({
    super.key,
    required this.index,
    required this.child,
    this.slideFromBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    final delay = (index * 55).clamp(0, 500);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) {
        final eased = Curves.easeOutBack.transform(v.clamp(0.0, 1.0));
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: slideFromBottom
                ? Offset(0, 18 * (1 - eased))
                : Offset(0, 0),
            child: slideFromBottom ? c : Transform.scale(scale: 0.88 + 0.12 * eased, child: c),
          ),
        );
      },
      child: child,
    );
  }
}
