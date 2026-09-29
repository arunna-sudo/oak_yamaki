import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_utils.dart';

/// หน้าสร้างโพสต์: พิมพ์ข้อความ + แนบรูปได้สูงสุด 3 รูป
class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  static const int _maxImages = 3;

  final TextEditingController _controller = TextEditingController();
  final List<Uint8List> _images = [];
  bool _posting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: error ? AppColors.danger : null),
    );
  }

  Future<void> _pickImages() async {
    final remaining = _maxImages - _images.length;
    if (remaining <= 0) return;
    final picked = await ImageUtils.pickImages(maxCount: remaining);
    if (picked.isEmpty || !mounted) return;

    final combined = [..._images, ...picked];
    if (!ImageUtils.fitsInDocument(combined)) {
      _showMessage('รูปมีขนาดใหญ่เกินไป กรุณาเลือกรูปที่เล็กลงหรือลดจำนวนรูป', error: true);
      return;
    }
    setState(() {
      _images
        ..clear()
        ..addAll(combined);
    });
  }

  Future<void> _submit() async {
    final user = context.read<AuthProvider>().userProfile;
    final text = _controller.text.trim();
    if (user == null || _posting) return;
    if (text.isEmpty && _images.isEmpty) {
      _showMessage('กรุณาพิมพ์ข้อความหรือแนบรูปภาพ', error: true);
      return;
    }

    setState(() => _posting = true);
    final ok = await context.read<PostProvider>().createPost(
          text: text,
          imagesBase64: _images.map(ImageUtils.encode).toList(),
          author: user,
        );
    if (!mounted) return;
    setState(() => _posting = false);

    if (ok) {
      Navigator.of(context).pop();
    } else {
      _showMessage('โพสต์ไม่สำเร็จ กรุณาลองใหม่', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('สร้างโพสต์'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _posting
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: _submit,
                    child: const Text('โพสต์',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    (user?.name.isNotEmpty ?? false) ? user!.name.substring(0, 1) : '?',
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 10),
                Text(user?.name ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              minLines: 5,
              maxLines: 12,
              maxLength: 2000,
              decoration: const InputDecoration(
                hintText: 'อยากคุยเรื่องอะไรกับเพื่อนร่วมหอ...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            if (_images.isNotEmpty)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (int i = 0; i < _images.length; i++)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_images[i], width: 100, height: 100, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: -8,
                          right: -8,
                          child: InkWell(
                            onTap: () => setState(() => _images.removeAt(i)),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.danger,
                              child: PhosphorIcon(PhosphorIconsDuotone.x, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _images.length >= _maxImages ? null : _pickImages,
              icon: const PhosphorIcon(PhosphorIconsDuotone.imagesSquare),
              label: Text('เพิ่มรูปภาพ (${_images.length}/$_maxImages)'),
            ),
          ],
        ),
      ),
    );
  }
}
