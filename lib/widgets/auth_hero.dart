import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'floating_bubbles.dart';

/// ส่วนหัวของหน้า Login/Register: การ์ดไล่สีอินดิโก + ฟองลอย + โลโก้ที่เด้งเข้า
class AuthHero extends StatelessWidget {
  final String title;
  final String subtitle;
  const AuthHero({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      height: 200,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C6CF7), Color(0xFF3B39C9)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: FloatingBubbles()),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutBack,
                  builder: (_, v, c) => Transform.scale(scale: 0.5 + 0.5 * v, child: c),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: const Center(
                      child: PhosphorIcon(PhosphorIconsDuotone.buildings,
                          size: 30, color: Color(0xFF5B5BF0)),
                    ),
                  ),
                ),
                const Spacer(),
                Text(title,
                    style: t.headlineSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                const SizedBox(height: 2),
                Text(subtitle, style: t.bodyMedium?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
