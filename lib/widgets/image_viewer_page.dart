import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../utils/app_theme.dart';
import '../utils/image_saver.dart';
import 'base64_image.dart';

/// หน้าดูรูปแบบเต็มจอ (บีบนิ้วซูมได้ / ปัดซ้ายขวาเมื่อมีหลายรูป)
/// รับรูปเป็น base64 ตามที่แอปเก็บใน Firestore
class ImageViewerPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String title;

  /// true = แสดงปุ่มบันทึกรูปลงเครื่องที่มุมขวาบน (ใช้กับสลิปโอนเงิน)
  final bool allowSave;

  /// ชื่อไฟล์ที่บันทึก (ไม่ต้องใส่นามสกุล)
  final String fileName;

  const ImageViewerPage({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.title = 'รูปภาพ',
    this.allowSave = false,
    this.fileName = 'image',
  });

  static Future<void> open(
    BuildContext context,
    List<String> images, {
    int initialIndex = 0,
    String title = 'รูปภาพ',
    bool allowSave = false,
    String fileName = 'image',
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImageViewerPage(
          images: images,
          initialIndex: initialIndex,
          title: title,
          allowSave: allowSave,
          fileName: fileName,
        ),
      ),
    );
  }

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.images.length - 1);
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = widget.images.length > 1 ? '${widget.fileName}_${_index + 1}' : widget.fileName;
    final ok = await ImageSaver.saveBase64(widget.images[_index], fileName: name);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'บันทึกรูปเรียบร้อยแล้ว' : 'บันทึกรูปไม่สำเร็จ'),
        backgroundColor: ok ? AppColors.success : AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final multiple = widget.images.length > 1;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          multiple ? '${widget.title} (${_index + 1}/${widget.images.length})' : widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          if (widget.allowSave)
            IconButton(
              icon: const PhosphorIcon(PhosphorIconsDuotone.downloadSimple),
              tooltip: 'บันทึกรูป',
              onPressed: _save,
            ),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Center(
              child: Base64Image(data: widget.images[i], fit: BoxFit.contain),
            ),
          );
        },
      ),
    );
  }
}
