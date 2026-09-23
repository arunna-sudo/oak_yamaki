import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

/// CreateAnnouncementPage: มีเฉพาะผู้ใช้ role เป็น admin เท่านั้นที่เข้าถึงเมนูนี้ได้
/// (ตรวจสอบสิทธิ์ตั้งแต่ระดับ UI ใน AnnouncementListPage และควรตั้งค่า
/// Firestore Security Rules เพิ่มเติมเพื่อป้องกันในระดับ Server ด้วย)
class CreateAnnouncementPage extends StatefulWidget {
  const CreateAnnouncementPage({super.key});

  @override
  State<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _pinned = false;
  bool _submitting = false;

  Future<void> _submit() async {
    if (_formKey.currentState?.saveAndValidate() != true) return;

    setState(() => _submitting = true);
    final values = _formKey.currentState!.value;
    final auth = context.read<AuthProvider>();
    final provider = context.read<AnnouncementProvider>();

    final success = await provider.createAnnouncement(
      title: values['title'] as String,
      body: values['body'] as String,
      createdByName: auth.userProfile?.name ?? 'ผู้ดูแลหอพัก',
      createdByUid: auth.userProfile?.uid ?? '',
      pinned: _pinned,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('สร้างประกาศไม่สำเร็จ กรุณาลองใหม่'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สร้างประกาศใหม่')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormBuilderTextField(
                name: 'title',
                decoration: const InputDecoration(labelText: 'หัวข้อประกาศ'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'กรุณากรอกหัวข้อ'),
                  FormBuilderValidators.maxLength(80, errorText: 'หัวข้อยาวเกินไป'),
                ]),
              ),
              const SizedBox(height: 14),
              FormBuilderTextField(
                name: 'body',
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'รายละเอียด',
                  alignLabelWithHint: true,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: FormBuilderValidators.required(errorText: 'กรุณากรอกรายละเอียด'),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _pinned,
                activeColor: AppColors.primary,
                title: const Text('ปักหมุดประกาศนี้ไว้บนสุด'),
                onChanged: (v) => setState(() => _pinned = v),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('เผยแพร่ประกาศ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
