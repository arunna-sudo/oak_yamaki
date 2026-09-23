import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/local_storage_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/validators.dart';
import 'register_page.dart';

/// LoginPage สาธิตการสร้างฟอร์มด้วย flutter_form_builder (Lecture 6)
/// ร่วมกับ SharedPreferences (Lecture 9) สำหรับฟีเจอร์ "จดจำอีเมลไว้"
///
/// เมื่อ login สำเร็จ ไม่จำเป็นต้องสั่ง Navigator.pushReplacement ด้วยตนเอง
/// เพราะ AuthGate ใน main.dart จะ "ฟัง" สถานะจาก AuthProvider (Provider package)
/// แล้วสลับไปแสดง MainShell ให้อัตโนมัติ ซึ่งให้ผลลัพธ์เดียวกับการใช้
/// pushReplacement ตามที่สอนในสไลด์ (หน้าจอ Login จะถูกถอดออกจาก Widget Tree
/// ไปเลย ผู้ใช้กดย้อนกลับไปหน้า Login ไม่ได้อีก)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _localStorage = LocalStorageService();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _initialEmail;

  @override
  void initState() {
    super.initState();
    // initState(): โหลดอีเมลที่เคยจดจำไว้จาก SharedPreferences ตอนเปิดหน้าจอครั้งแรก
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    final saved = await _localStorage.getRememberedEmail();
    if (saved != null && mounted) {
      setState(() {
        _initialEmail = saved;
        _rememberMe = true;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.saveAndValidate() != true) return;

    final values = _formKey.currentState!.value;
    final email = values['email'] as String;
    final password = values['password'] as String;

    if (_rememberMe) {
      await _localStorage.saveRememberedEmail(email);
    } else {
      await _localStorage.clearRememberedEmail();
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(email: email, password: password);

    if (!mounted) return; // ป้องกัน setState หลัง widget ถูก dispose (Lecture 9)

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'เข้าสู่ระบบไม่สำเร็จ'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.apartment, color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 20),
              const Text('ยินดีต้อนรับกลับ',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text(
                'เข้าสู่ระบบเพื่อจัดการห้องพักของคุณ',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 28),
              FormBuilder(
                key: _formKey,
                initialValue: {if (_initialEmail != null) 'email': _initialEmail},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'กรุณากรอกรหัสผ่าน'),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.primary,
                          onChanged: (v) => setState(() => _rememberMe = v ?? false),
                        ),
                        const Text('จดจำอีเมลไว้'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('เข้าสู่ระบบ'),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: 'ยังไม่มีบัญชี? ',
                      style: TextStyle(color: AppColors.textMuted),
                      children: [
                        TextSpan(
                          text: 'ลงทะเบียนที่นี่',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
