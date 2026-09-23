import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/validators.dart';

/// RegisterPage สาธิตองค์ประกอบฟอร์มหลายชนิดตาม Lecture 6:
/// FormBuilderTextField, FormBuilderDropdown พร้อม Validation หลายรูปแบบ
/// (required, email, minLength, และ custom confirmPassword validator)
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  String _password = '';
  bool _obscurePassword = true;

  Future<void> _submit() async {
    if (_formKey.currentState?.saveAndValidate() != true) return;

    final values = _formKey.currentState!.value;
    final auth = context.read<AuthProvider>();

    final success = await auth.register(
      email: values['email'] as String,
      password: values['password'] as String,
      name: values['name'] as String,
      phone: values['phone'] as String,
      room: values['room'] as String,
    );

    if (!mounted) return;

    if (success) {
      // สมัครสำเร็จ = login เข้าระบบให้ทันที; AuthGate จะสลับหน้าให้อัตโนมัติ
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'ลงทะเบียนไม่สำเร็จ'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('ลงทะเบียนผู้พักใหม่')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormBuilderTextField(
                  name: 'name',
                  decoration: const InputDecoration(
                    labelText: 'ชื่อ-นามสกุล',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: FormBuilderValidators.required(errorText: 'กรุณากรอกชื่อ-นามสกุล'),
                ),
                const SizedBox(height: 14),
                FormBuilderTextField(
                  name: 'email',
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'อีเมล',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'กรุณากรอกอีเมล'),
                    Validators.email(),
                  ]),
                ),
                const SizedBox(height: 14),
                FormBuilderTextField(
                  name: 'phone',
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'เบอร์โทรศัพท์',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'กรุณากรอกเบอร์โทรศัพท์'),
                    FormBuilderValidators.minLength(9, errorText: 'เบอร์โทรไม่ถูกต้อง'),
                  ]),
                ),
                const SizedBox(height: 14),
                FormBuilderDropdown<String>(
                  name: 'room',
                  decoration: const InputDecoration(
                    labelText: 'หมายเลขห้องพัก',
                    prefixIcon: Icon(Icons.meeting_room_outlined),
                  ),
                  items: List.generate(40, (i) {
                    final floor = (i ~/ 10) + 1;
                    final roomNo = (i % 10) + 1;
                    final room = '$floor${roomNo.toString().padLeft(2, '0')}';
                    return DropdownMenuItem(value: room, child: Text('ห้อง $room'));
                  }),
                  validator: FormBuilderValidators.required(errorText: 'กรุณาเลือกห้องพัก'),
                ),
                const SizedBox(height: 14),
                FormBuilderTextField(
                  name: 'password',
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  onChanged: (v) => _password = v ?? '',
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'กรุณากรอกรหัสผ่าน'),
                    FormBuilderValidators.minLength(6, errorText: 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร'),
                  ]),
                ),
                const SizedBox(height: 14),
                FormBuilderTextField(
                  name: 'confirmPassword',
                  obscureText: _obscurePassword,
                  decoration: const InputDecoration(
                    labelText: 'ยืนยันรหัสผ่าน',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: Validators.confirmPassword(() => _password),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _submit,
                    child: auth.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('ลงทะเบียน'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
