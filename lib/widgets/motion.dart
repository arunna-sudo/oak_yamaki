import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// เอฟเฟกต์ปรากฏตัว: เฟด + เลื่อนขึ้นเบาๆ (เล่นครั้งเดียวตอน widget ถูกสร้าง)
/// ใช้ [delay] ทำให้รายการปรากฏต่อเนื่องแบบ stagger ได้
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final double scaleFrom;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 520),
    this.offset = const Offset(0, 0.08),
    this.scaleFrom = 1,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(_curve),
        child: ScaleTransition(
          scale: Tween<double>(begin: widget.scaleFrom, end: 1).animate(_curve),
          child: widget.child,
        ),
      ),
    );
  }
}

/// ห่อ widget ใดๆ ให้ "ยุบเล็กน้อยตอนกด" เพื่อให้รู้สึกตอบสนอง
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.95,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// ตัวเลขที่นับขึ้นจาก 0 (และนับต่อเมื่อค่าเปลี่ยน)
class CountUp extends StatelessWidget {
  final int value;
  final TextStyle? style;

  const CountUp({super.key, required this.value, this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text('${v.round()}', style: style),
    );
  }
}

/// พื้นหลังไล่สีสำหรับส่วนหัวของหน้า พร้อมวงกลมโปร่งใสที่ลอยเคลื่อนไหวช้าๆ
/// ต้องวางในตำแหน่งที่มีขนาดจำกัด (เช่น Positioned.fill / SizedBox)
class GradientBackdrop extends StatefulWidget {
  final double radius;
  const GradientBackdrop({super.key, this.radius = 36});

  @override
  State<GradientBackdrop> createState() => _GradientBackdropState();
}

class _GradientBackdropState extends State<GradientBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 7))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _bubble(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(widget.radius)),
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final t = Curves.easeInOut.transform(_c.value);
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned(right: -50 + 24 * t, top: -40 + 16 * t, child: _bubble(190, 0.08)),
                Positioned(left: -60 + 20 * t, bottom: -70 - 10 * t, child: _bubble(200, 0.06)),
                Positioned(right: 70 - 18 * t, bottom: 26 + 14 * t, child: _bubble(64, 0.09)),
              ],
            );
          },
        ),
      ),
    );
  }
}
