import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../utils/app_theme.dart';

/// สแปลช: โลโก้เด้งเข้า แล้วค่อยเลื่อนชื่อแอปขึ้นมา
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C6CF7), Color(0xFF3B39C9)],
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutBack,
            builder: (context, v, _) => Opacity(
              opacity: v.clamp(0.0, 1.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: 0.6 + 0.4 * v,
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: AppColors.softShadow(Colors.black),
                      ),
                      child: const Center(
                        child: PhosphorIcon(PhosphorIconsDuotone.buildings,
                            size: 56, color: AppColors.primary),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, 16 * (1 - v)),
                    child: Column(children: [
                      const SizedBox(height: 22),
                      Text('DormEase',
                          style: t.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      Text('ผู้ช่วยจัดการหอพักของคุณ',
                          style: t.bodyMedium?.copyWith(color: Colors.white70)),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
