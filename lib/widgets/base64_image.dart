import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../utils/app_theme.dart';

/// แสดงรูปที่เก็บเป็น base64 (ถอดรหัสครั้งเดียวแล้วเก็บไว้ ไม่ถอดซ้ำทุกครั้งที่ build)
class Base64Image extends StatefulWidget {
  final String data;
  final double? width;
  final double? height;
  final BoxFit fit;

  const Base64Image({
    super.key,
    required this.data,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<Base64Image> createState() => _Base64ImageState();
}

class _Base64ImageState extends State<Base64Image> {
  late Uint8List _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = _decode(widget.data);
  }

  @override
  void didUpdateWidget(covariant Base64Image oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _bytes = _decode(widget.data);
    }
  }

  static Uint8List _decode(String data) {
    try {
      return base64Decode(data);
    } catch (_) {
      return Uint8List(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = SizedBox(
      width: widget.width,
      height: widget.height ?? 120,
      child: const Center(child: PhosphorIcon(PhosphorIconsDuotone.imageBroken, color: AppColors.textMuted)),
    );
    if (_bytes.isEmpty) return placeholder;
    return Image.memory(
      _bytes,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}
