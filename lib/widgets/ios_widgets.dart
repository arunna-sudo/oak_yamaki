import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

Color mutedOf(BuildContext context) => Theme.of(context).brightness == Brightness.dark
    ? AppColors.darkTextMuted
    : AppColors.textMuted;

Color separatorOf(BuildContext context) => Theme.of(context).brightness == Brightness.dark
    ? AppColors.darkBorder
    : AppColors.border;

/// ไอคอนสี่เหลี่ยมมุมนุ่ม (squircle) พื้นสีทึบ + สัญลักษณ์สีขาว แบบแอป Settings ของ iOS
class SquircleIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const SquircleIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: color,
        shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(size * 0.45)),
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.56),
    );
  }
}

/// หัวข้อเล็กๆ เหนือกลุ่ม (เหมือน section header ของ iOS)
class GroupHeader extends StatelessWidget {
  final String text;
  const GroupHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: mutedOf(context)),
      ),
    );
  }
}

/// กลุ่มรายการมุมโค้งสีขาว คั่นด้วยเส้นบางๆ (inset grouped list)
class InsetGroup extends StatelessWidget {
  final List<Widget> children;
  final double dividerIndent;

  const InsetGroup({super.key, required this.children, this.dividerIndent = 60});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      if (i > 0) {
        items.add(Divider(
          height: 0.5,
          thickness: 0.5,
          indent: dividerIndent,
          color: separatorOf(context),
        ));
      }
      items.add(children[i]);
    }
    return Material(
      color: Theme.of(context).colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Column(mainAxisSize: MainAxisSize.min, children: items),
    );
  }
}

/// แถวในกลุ่ม: ไอคอนซ้าย ชื่อ/คำอธิบาย ค่าขวา และลูกศร (ถ้ากดได้)
class InsetRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool chevron;
  final Color? titleColor;
  final bool centered;

  const InsetRow({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.chevron = false,
    this.titleColor,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final muted = mutedOf(context);
    final titleText = Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: titleColor),
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: centered
            ? Center(child: titleText)
            : Row(
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 14)],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleText,
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, color: muted),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[const SizedBox(width: 8), trailing!],
                  if (chevron) ...[
                    const SizedBox(width: 6),
                    Icon(CupertinoIcons.chevron_right,
                        size: 15, color: muted.withOpacity(0.7)),
                  ],
                ],
              ),
      ),
    );
  }
}
