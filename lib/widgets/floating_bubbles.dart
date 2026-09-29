import 'dart:math' as math;

import 'package:flutter/material.dart';

/// ฟองสีลอยขึ้นลงช้า ๆ ตามแนวภาพอ้างอิง (วนลูปไม่หยุด แต่เบามาก)
class FloatingBubbles extends StatefulWidget {
  const FloatingBubbles();
  @override
  State<FloatingBubbles> createState() => FloatingBubblesState();
}

class FloatingBubblesState extends State<FloatingBubbles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat();

  static const _b = [
    // dx (0-1 จากขวา), y (0-1), รัศมี, สีบน, สีล่าง, เฟส
    (0.08, 0.18, 34.0, Color(0xFFFF8FB8), Color(0xFFFF6F91), 0.0),
    (0.30, 0.62, 26.0, Color(0xFF6FE3FF), Color(0xFF29C9EE), 1.7),
    (0.20, 0.10, 14.0, Color(0xFFFFC98A), Color(0xFFFFA45C), 3.1),
    (0.42, 0.28, 18.0, Color(0xFFD9A0FF), Color(0xFFB56CF2), 4.4),
  ];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) _c.stop();
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => LayoutBuilder(
        builder: (context, box) => Stack(
          clipBehavior: Clip.none,
          children: [
            for (final b in _b)
              Positioned(
                right: box.maxWidth * b.$1 - b.$3 * 0.4,
                top: box.maxHeight * b.$2 +
                    math.sin(_c.value * 2 * math.pi + b.$6) * 9 -
                    b.$3,
                child: Container(
                  width: b.$3 * 2,
                  height: b.$3 * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [b.$4, b.$5],
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: b.$5.withOpacity(0.45),
                          blurRadius: 18,
                          offset: const Offset(0, 8)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
