import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/auth_hero.dart';

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
  final UserService _userService = UserService();
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
      // สมัครสำเร็จ แต่ต้องรอแอดมินยืนยันก่อนถึงจะเข้าใช้งานได้
      // (AuthGate จะเช็คสถานะ isApproved แล้วพาไปหน้ารออนุมัติให้อัตโนมัติ)
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          icon: const PhosphorIcon(PhosphorIconsDuotone.hourglassHigh, color: AppColors.accent, size: 36),
          title: const Text('ลงทะเบียนสำเร็จ'),
          content: const Text(
            'บัญชีของคุณถูกสร้างเรียบร้อยแล้ว กรุณารอผู้ดูแลหอพักยืนยันบัญชี '
            'ก่อนจึงจะเข้าใช้งานได้',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ตกลง'),
            ),
          ],
        ),
      );
      if (!mounted) return;
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
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHero(title: 'สร้างบัญชีใหม่', subtitle: 'ลงทะเบียนเป็นผู้พักในไม่กี่ขั้นตอน'),
                const SizedBox(height: 28),
                FormBuilderTextField(
                  name: 'name',
                  decoration: const InputDecoration(
                    labelText: 'ชื่อ-นามสกุล',
                    prefixIcon: PhosphorIcon(PhosphorIconsDuotone.user),
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
                    prefixIcon: PhosphorIcon(PhosphorIconsDuotone.envelopeSimple),
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
                    prefixIcon: PhosphorIcon(PhosphorIconsDuotone.phone),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'กรุณากรอกเบอร์โทรศัพท์'),
                    FormBuilderValidators.minLength(9, errorText: 'เบอร์โทรไม่ถูกต้อง'),
                  ]),
                ),
                const SizedBox(height: 14),
                StreamBuilder<List<UserModel>>(
                  stream: _userService.watchAllResidents(),
                  builder: (context, snapshot) {
                    final occupiedRooms = <String>{
                      for (final r in snapshot.data ?? const <UserModel>[])
                        if (r.room.isNotEmpty) r.room,
                    };
                    return FormBuilderField<String>(
                      name: 'room',
                      validator: FormBuilderValidators.required(errorText: 'กรุณาเลือกห้องพัก'),
                      builder: (field) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final selected = await showModalBottomSheet<String>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => _RoomPickerSheet(
                                occupiedRooms: occupiedRooms,
                                selectedRoom: field.value,
                              ),
                            );
                            if (selected != null) field.didChange(selected);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'หมายเลขห้องพัก',
                              prefixIcon: const PhosphorIcon(PhosphorIconsDuotone.door),
                              suffixIcon: const PhosphorIcon(PhosphorIconsDuotone.caretDown),
                              errorText: field.errorText,
                            ),
                            child: Text(
                              field.value != null ? 'ห้อง ${field.value}' : 'แตะเพื่อเลือกห้องพัก',
                              style: TextStyle(
                                color: field.value != null ? null : AppColors.textMuted,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 14),
                FormBuilderTextField(
                  name: 'password',
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    prefixIcon: const PhosphorIcon(PhosphorIconsDuotone.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? PhosphorIconsRegular.eye
                          : PhosphorIconsRegular.eyeSlash),
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
                    prefixIcon: PhosphorIcon(PhosphorIconsDuotone.lock),
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

/// ชีทเลือกห้องพักแบบกริด แยกตามชั้น ห้องที่มีผู้พักอยู่แล้วจะถูกปิดไม่ให้กด
class _RoomPickerSheet extends StatelessWidget {
  final Set<String> occupiedRooms;
  final String? selectedRoom;

  const _RoomPickerSheet({required this.occupiedRooms, required this.selectedRoom});

  static const int _floors = 4;
  static const int _roomsPerFloor = 10;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('เลือกห้องพัก',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    IconButton(
                      icon: const PhosphorIcon(PhosphorIconsDuotone.x),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _LegendDot(color: AppColors.primaryLight, label: 'ว่าง'),
                    const SizedBox(width: 16),
                    _LegendDot(color: AppColors.textMuted.withOpacity(0.15), label: 'มีคนอยู่แล้ว'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: _floors,
                  itemBuilder: (context, floorIndex) {
                    final floor = floorIndex + 1;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ชั้น $floor',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _roomsPerFloor,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1.3,
                            ),
                            itemBuilder: (context, i) {
                              final roomNo = i + 1;
                              final room = '$floor${roomNo.toString().padLeft(2, '0')}';
                              final isOccupied = occupiedRooms.contains(room);
                              final isSelected = room == selectedRoom;

                              return _RoomCell(
                                room: room,
                                isOccupied: isOccupied,
                                isSelected: isSelected,
                                onTap: isOccupied
                                    ? null
                                    : () => Navigator.of(context).pop(room),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoomCell extends StatelessWidget {
  final String room;
  final bool isOccupied;
  final bool isSelected;
  final VoidCallback? onTap;

  const _RoomCell({
    required this.room,
    required this.isOccupied,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;
    final Border? border;

    if (isOccupied) {
      background = AppColors.textMuted.withOpacity(0.1);
      foreground = AppColors.textMuted.withOpacity(0.6);
      border = null;
    } else if (isSelected) {
      background = AppColors.primary;
      foreground = Colors.white;
      border = null;
    } else {
      background = AppColors.primaryLight;
      foreground = AppColors.primary;
      border = null;
    }

    return Opacity(
      opacity: isOccupied ? 0.7 : 1,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: border,
            ),
            alignment: Alignment.center,
            child: isOccupied
                ? PhosphorIcon(PhosphorIconsDuotone.lock, size: 16, color: foreground)
                : Text(
                    room,
                    style: TextStyle(color: foreground, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }
}
