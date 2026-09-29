import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ธีม DormEase v2: โทน "Periwinkle & Candy" ฟ้าม่วงอ่อนนุ่ม + สีพาสเทลสดใส
/// ฟอนต์ Anuphan รองรับไทย/อังกฤษในตระกูลเดียว
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF5B5BF0); // Indigo
  static const Color primaryDark = Color(0xFF3B39C9);
  static const Color primaryLight = Color(0xFFE7E8FF);

  static const Color accent = Color(0xFFFF7A8A); // Coral pink
  static const Color accentLight = Color(0xFFFFE6EA);

  static const Color success = Color(0xFF2FBF8F);
  static const Color warning = Color(0xFFFFB259);
  static const Color danger = Color(0xFFFF5D6C);

  // สีพาสเทลเสริมสำหรับไอคอน/แท็ก
  static const Color sky = Color(0xFF29C9EE);
  static const Color violet = Color(0xFFB56CF2);
  static const Color peach = Color(0xFFFFA45C);

  static const Color bg = Color(0xFFF3F4FC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1E2140);
  static const Color textMuted = Color(0xFF7A7F9E);

  static const Color darkBg = Color(0xFF111228);
  static const Color darkCard = Color(0xFF1B1D3B);
  static const Color darkTextMuted = Color(0xFFA5A9C9);

  // เส้นขอบ/เส้นแบ่งบาง ๆ ใช้กับ Divider และกรอบช่องกรอกข้อมูล
  static const Color border = Color(0xFFE2E4F5);
  static const Color darkBorder = Color(0xFF2E3160);

  // ไล่สีอินดิโกสำหรับส่วนหัว (การ์ดหอพัก, hero ของหน้า auth ฯลฯ)
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C6CF7), Color(0xFF4A45D8)],
  );

  /// เงานุ่มแบบอมม่วง แทนเงาเทาทั่วไป
  static List<BoxShadow> softShadow([Color c = primary]) => [
        BoxShadow(color: c.withOpacity(0.10), blurRadius: 24, offset: const Offset(0, 10)),
      ];
}

/// เปลี่ยนหน้า: หน้าใหม่เลื่อนเข้าจากขวาเล็กน้อย + จางเข้า, หน้าเดิมเลื่อนถอยเบา ๆ
class _SoftSlideTransitions extends PageTransitionsBuilder {
  const _SoftSlideTransitions();

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context,
      Animation<double> animation, Animation<double> secondary, Widget child) {
    final inCurve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    final outCurve = CurvedAnimation(parent: secondary, curve: Curves.easeOutCubic);
    return SlideTransition(
      position: Tween(begin: Offset.zero, end: const Offset(-0.08, 0)).animate(outCurve),
      child: FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.6).animate(outCurve),
        child: SlideTransition(
          position: Tween(begin: const Offset(0.12, 0), end: Offset.zero).animate(inCurve),
          child: FadeTransition(opacity: inCurve, child: child),
        ),
      ),
    );
  }
}

class AppTheme {
  AppTheme._();

  static const _transitions = PageTransitionsTheme(builders: {
    TargetPlatform.android: _SoftSlideTransitions(),
    TargetPlatform.iOS: _SoftSlideTransitions(),
    TargetPlatform.windows: _SoftSlideTransitions(),
    TargetPlatform.macOS: _SoftSlideTransitions(),
    TargetPlatform.linux: _SoftSlideTransitions(),
    TargetPlatform.fuchsia: _SoftSlideTransitions(),
  });

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    final base = ThemeData(brightness: b, useMaterial3: true);
    final ink = dark ? Colors.white : AppColors.textDark;
    final bg = dark ? AppColors.darkBg : AppColors.bg;
    final card = dark ? AppColors.darkCard : AppColors.card;
    final primary = dark ? const Color(0xFF8C8CFF) : AppColors.primary;
    final border = dark ? const Color(0xFF2E3160) : const Color(0xFFE2E4F5);

    final text = GoogleFonts.anuphanTextTheme(base.textTheme)
        .apply(bodyColor: ink, displayColor: ink);

    OutlineInputBorder ob(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: c, width: w),
        );

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      textTheme: text,
      primaryTextTheme: text,
      pageTransitionsTheme: _transitions,
      splashFactory: InkSparkle.splashFactory,
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: AppColors.accent,
        surface: card,
        error: AppColors.danger,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(
            color: ink, fontSize: 21, fontWeight: FontWeight.w700, letterSpacing: -0.2),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: dark ? 0 : 4,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.primary.withOpacity(0.14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: ob(border),
        enabledBorder: ob(border),
        focusedBorder: ob(primary, 1.8),
        errorBorder: ob(AppColors.danger, 1.2),
        focusedErrorBorder: ob(AppColors.danger, 1.8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: dark ? AppColors.darkBg : Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: GoogleFonts.anuphan(fontWeight: FontWeight.w700, fontSize: 16),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: border, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: GoogleFonts.anuphan(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
        extendedTextStyle: GoogleFonts.anuphan(fontWeight: FontWeight.w700, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: border),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? const Color(0xFF2B2E5E) : AppColors.textDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: border, space: 1),
    );
  }

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);
}

/// ระยะขอบ/รัศมีมุมมาตรฐาน เพื่อให้ UI ทุกหน้าไปในทิศทางเดียวกัน
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double radius = 24;
}
