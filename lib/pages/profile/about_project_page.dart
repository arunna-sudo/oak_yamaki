import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../utils/app_theme.dart';
import '../../utils/dorm_config.dart';

/// ข้อมูลผู้ร่วมพัฒนาโปรเจกต์ 1 คน
class _TeamMember {
  final String name;
  final String studentId;
  final String photoAsset;

  const _TeamMember({required this.name, required this.studentId, required this.photoAsset});
}

const _teamMembers = <_TeamMember>[
  _TeamMember(
    name: 'กันต์นัย แก้ววันนา',
    studentId: '6721651971',
    photoAsset: 'assets/images/team/member1_kannanai.png',
  ),
  _TeamMember(
    name: 'ปุญญาพัฒน์ สุขเจริญ',
    studentId: '6721652382',
    photoAsset: 'assets/images/team/member2_punyapat.png',
  ),
  _TeamMember(
    name: 'อรุณ นาท',
    studentId: '6721656183',
    photoAsset: 'assets/images/team/member3_arun.png',
  ),
];

/// AboutProjectPage: หน้าแสดงข้อมูลผู้จัดทำโปรเจกต์ DormEase
/// เข้าถึงได้จากหน้าโปรไฟล์ ทั้งฝั่งผู้พักและแอดมิน
class AboutProjectPage extends StatelessWidget {
  const AboutProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เกี่ยวกับโปรเจกต์')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // การ์ดหัวเรื่อง: โลโก้แอป + ชื่อโปรเจกต์ + คำอธิบายสั้น ๆ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const PhosphorIcon(PhosphorIconsDuotone.buildings, color: AppColors.primary, size: 38),
                ),
                const SizedBox(height: 16),
                const Text(
                  'DormEase',
                  style: TextStyle(
                      color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  DormConfig.fullName.isNotEmpty ? DormConfig.fullName : 'หอพักของเรา',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'โปรเจกต์จบวิชา Application Development',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Row(
            children: [
              PhosphorIcon(PhosphorIconsDuotone.usersThree, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('ผู้จัดทำโปรเจกต์',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'สมาชิกทั้งหมด 3 คน',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < _teamMembers.length; i++) ...[
            _TeamMemberCard(index: i + 1, member: _teamMembers[i]),
            if (i != _teamMembers.length - 1) const SizedBox(height: 14),
          ],
          const SizedBox(height: 28),
          Center(
            child: Text(
              'DormEase © ${DateTime.now().year}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final int index;
  final _TeamMember member;

  const _TeamMemberCard({required this.index, required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // รูปภาพสมาชิก
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.25), width: 1.5),
                    image: DecorationImage(
                      image: AssetImage(member.photoAsset),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$index',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const PhosphorIcon(PhosphorIconsDuotone.identificationCard, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        'รหัสนิสิต ${member.studentId}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
