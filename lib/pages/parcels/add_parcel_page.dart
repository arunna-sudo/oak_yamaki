import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/parcel_provider.dart';
import '../../services/user_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_utils.dart';
import '../../widgets/loading_widget.dart';

/// หน้าแอดมินเพิ่มพัสดุ: เลือกห้องพัก + แนบรูป (ไม่บังคับ) + หมายเหตุ (ไม่บังคับ)
class AddParcelPage extends StatefulWidget {
  const AddParcelPage({super.key});

  @override
  State<AddParcelPage> createState() => _AddParcelPageState();
}

class _AddParcelPageState extends State<AddParcelPage> {
  final _userService = UserService();
  final _noteController = TextEditingController();

  bool _loadingRooms = true;
  bool _submitting = false;
  String? _selectedRoom;
  Uint8List? _image;
  Map<String, List<String>> _roomResidents = {}; // ห้อง -> รายชื่อผู้พัก

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    try {
      final residents = await _userService.watchAllResidents().first;
      final map = <String, List<String>>{};
      for (final UserModel r in residents) {
        if (r.isAdmin || r.room.trim().isEmpty) continue;
        map.putIfAbsent(r.room, () => []).add(r.name);
      }
      if (!mounted) return;
      setState(() {
        _roomResidents = map;
        _loadingRooms = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingRooms = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('โหลดรายชื่อห้องไม่สำเร็จ: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImageUtils.pickImages(maxCount: 1);
    if (picked.isEmpty) return;
    setState(() => _image = picked.first);
  }

  Future<void> _submit() async {
    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกห้องพัก'), backgroundColor: AppColors.danger),
      );
      return;
    }
    if (_image != null && !ImageUtils.fitsInDocument([_image!])) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รูปมีขนาดใหญ่เกินไป กรุณาเลือกรูปใหม่'), backgroundColor: AppColors.danger),
      );
      return;
    }

    setState(() => _submitting = true);
    final ok = await context.read<ParcelProvider>().addParcel(
          room: _selectedRoom!,
          note: _noteController.text.trim(),
          imageBase64: _image != null ? ImageUtils.encode(_image!) : null,
        );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เพิ่มพัสดุเรียบร้อยแล้ว'), backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เพิ่มพัสดุไม่สำเร็จ กรุณาลองใหม่'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rooms = _roomResidents.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('เพิ่มพัสดุ')),
      body: _loadingRooms
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedRoom,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'เลือกห้องพัก',
                      prefixIcon: PhosphorIcon(PhosphorIconsDuotone.door),
                    ),
                    items: rooms
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                'ห้อง $r · ${_roomResidents[r]!.join(', ')}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedRoom = v),
                  ),
                  if (rooms.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('ยังไม่มีผู้พักที่ระบุห้องในระบบ',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'รายละเอียดพัสดุ (ไม่บังคับ)',
                      hintText: 'เช่น ขนส่ง, ชื่อผู้รับ, ขนาดกล่อง',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('รูปพัสดุ (ไม่บังคับ)', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  if (_image != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSpacing.radius),
                          child: Image.memory(_image!,
                              width: double.infinity, height: 220, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const PhosphorIcon(PhosphorIconsDuotone.x, color: Colors.white),
                              onPressed: () => setState(() => _image = null),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSpacing.radius),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PhosphorIcon(PhosphorIconsDuotone.imagesSquare,
                                size: 36, color: AppColors.textMuted),
                            SizedBox(height: 6),
                            Text('แตะเพื่อเลือกรูป', style: TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('บันทึกพัสดุ'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
