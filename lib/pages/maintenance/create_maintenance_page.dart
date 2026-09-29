import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../../models/maintenance_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/maintenance_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/image_utils.dart';

/// CreateMaintenancePage สาธิตองค์ประกอบฟอร์มที่หลากหลายตาม Lecture 6:
/// - FormBuilderDropdown (หมวดหมู่ปัญหา)
/// - FormBuilderRadioGroup (ระดับความเร่งด่วน) พร้อม orientation แนวนอน
/// - FormBuilderDateTimePicker (วันที่สะดวกให้เข้าซ่อม)
/// - FormBuilderTextField พร้อม maxLines สำหรับรายละเอียด
class CreateMaintenancePage extends StatefulWidget {
  const CreateMaintenancePage({super.key});

  @override
  State<CreateMaintenancePage> createState() => _CreateMaintenancePageState();
}

class _CreateMaintenancePageState extends State<CreateMaintenancePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _submitting = false;
  final List<Uint8List> _images = [];
  static const int _maxImages = 3;

  static const _categories = ['ไฟฟ้า', 'ประปา', 'เครื่องใช้ไฟฟ้า', 'อื่นๆ'];
  static const _urgencyLevels = ['ต่ำ', 'ปานกลาง', 'สูง'];

  Future<void> _addImages() async {
    final remaining = _maxImages - _images.length;
    if (remaining <= 0) return;
    final picked = await ImageUtils.pickImages(maxCount: remaining);
    if (picked.isEmpty) return;
    setState(() => _images.addAll(picked));
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.saveAndValidate() != true) return;

    if (!ImageUtils.fitsInDocument(_images)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('รูปมีขนาดรวมใหญ่เกินไป กรุณาลดจำนวนรูปหรือเลือกรูปใหม่'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final values = _formKey.currentState!.value;
    final auth = context.read<AuthProvider>();
    final user = auth.userProfile;
    if (user == null) return;

    setState(() => _submitting = true);

    final success = await context.read<MaintenanceProvider>().createRequest(
          MaintenanceModel(
            id: '',
            uid: user.uid,
            room: user.room,
            category: values['category'] as String,
            title: values['title'] as String,
            description: values['description'] as String,
            urgency: values['urgency'] as String,
            status: MaintenanceStatus.pending,
            preferredDate: values['preferredDate'] as DateTime?,
            imagesBase64: _images.map(ImageUtils.encode).toList(),
            createdAt: DateTime.now(),
          ),
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ส่งคำขอแจ้งซ่อมเรียบร้อยแล้ว'), backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ส่งคำขอไม่สำเร็จ กรุณาลองใหม่'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แจ้งซ่อม')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FormBuilder(
          key: _formKey,
          initialValue: const {'urgency': 'ปานกลาง'},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormBuilderDropdown<String>(
                name: 'category',
                decoration: const InputDecoration(labelText: 'หมวดหมู่ปัญหา'),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                validator: FormBuilderValidators.required(errorText: 'กรุณาเลือกหมวดหมู่'),
              ),
              const SizedBox(height: 14),
              FormBuilderTextField(
                name: 'title',
                decoration: const InputDecoration(labelText: 'หัวข้อปัญหาโดยย่อ'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: FormBuilderValidators.required(errorText: 'กรุณากรอกหัวข้อ'),
              ),
              const SizedBox(height: 14),
              FormBuilderTextField(
                name: 'description',
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'รายละเอียดปัญหา',
                  alignLabelWithHint: true,
                ),
                autovalidateMode: AutovalidateMode.disabled,
                validator: FormBuilderValidators.required(errorText: 'กรุณาอธิบายปัญหา'),
              ),
              const SizedBox(height: 14),
              const Text('ระดับความเร่งด่วน', style: TextStyle(fontWeight: FontWeight.w600)),
              FormBuilderRadioGroup<String>(
                name: 'urgency',
                orientation: OptionsOrientation.horizontal,
                decoration: const InputDecoration(border: InputBorder.none),
                options: _urgencyLevels
                    .map((u) => FormBuilderFieldOption(value: u, child: Text(u)))
                    .toList(),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 14),
              FormBuilderDateTimePicker(
                name: 'preferredDate',
                inputType: InputType.date,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                decoration: const InputDecoration(
                  labelText: 'วันที่สะดวกให้เข้าซ่อม (ถ้ามี)',
                  prefixIcon: PhosphorIcon(PhosphorIconsDuotone.calendar),
                ),
              ),
              const SizedBox(height: 18),
              Text('รูปประกอบ (ไม่บังคับ, สูงสุด $_maxImages รูป)',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < _images.length; i++)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_images[i], width: 88, height: 88, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: GestureDetector(
                            onTap: () => setState(() => _images.removeAt(i)),
                            child: const CircleAvatar(
                              radius: 11,
                              backgroundColor: AppColors.danger,
                              child: PhosphorIcon(PhosphorIconsDuotone.x, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (_images.length < _maxImages)
                    InkWell(
                      onTap: _addImages,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: const PhosphorIcon(PhosphorIconsDuotone.imagesSquare,
                            color: AppColors.textMuted, size: 30),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('ส่งคำขอแจ้งซ่อม'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
