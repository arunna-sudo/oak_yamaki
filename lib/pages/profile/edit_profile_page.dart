import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/validators.dart';

/// แก้ไขข้อมูลส่วนตัว (ชื่อ / เบอร์โทร) ใช้ได้ทั้งผู้พักและแอดมิน
/// อีเมลและห้องพักแสดงให้ดูอย่างเดียว (ห้องพักกำหนดโดยผู้ดูแลหอพัก)
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().userProfile;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final ok = await context.read<AuthProvider>().updateProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'บันทึกข้อมูลเรียบร้อยแล้ว' : 'บันทึกไม่สำเร็จ กรุณาลองใหม่'),
        backgroundColor: ok ? AppColors.success : AppColors.danger,
      ),
    );
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userProfile;
    final isAdmin = user?.isAdmin == true;

    return Scaffold(
      appBar: AppBar(title: const Text('แก้ไขข้อมูลส่วนตัว')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'ชื่อ-นามสกุล',
                  prefixIcon: PhosphorIcon(PhosphorIconsDuotone.user),
                ),
                validator: Validators.required(errorMessage: 'กรุณากรอกชื่อ'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'เบอร์โทรศัพท์',
                  prefixIcon: PhosphorIcon(PhosphorIconsDuotone.phone),
                ),
                validator: Validators.compose([
                  Validators.required(errorMessage: 'กรุณากรอกเบอร์โทรศัพท์'),
                  Validators.minLength(9, errorMessage: 'เบอร์โทรไม่ถูกต้อง'),
                ]),
              ),
              const SizedBox(height: 14),
              TextFormField(
                initialValue: user?.email ?? '',
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'อีเมล (แก้ไขไม่ได้)',
                  prefixIcon: PhosphorIcon(PhosphorIconsDuotone.envelopeSimple),
                ),
              ),
              if (!isAdmin) ...[
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: user?.room ?? '',
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'ห้องพัก (แก้ไขไม่ได้ หากย้ายห้องติดต่อผู้ดูแล)',
                    prefixIcon: PhosphorIcon(PhosphorIconsDuotone.door),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('บันทึก'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
